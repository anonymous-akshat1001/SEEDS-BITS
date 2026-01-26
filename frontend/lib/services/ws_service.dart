// Imports JSON utilites, needed since webSocket messages arrive as strings, but your app needs Dart objects
import 'dart:convert';
import 'package:flutter/material.dart';
// A Flutter/Dart package for WebSocket communication
import 'package:web_socket_channel/web_socket_channel.dart';
// Allows reading environment variables
import 'package:flutter_dotenv/flutter_dotenv.dart';

// Backend and websocket URL
final baseUrl = dotenv.env['API_BASE_URL'];
final wsBaseUrl = dotenv.env['WS_BASE_URL'];

// This creates a custom function type - any function that takes a Map and returns nothing
typedef MsgHandler = void Function(Map);

// A websocket service class
class WsService {
  // the actual websocket connection - may be NULL as it may be closed/may not exist
  WebSocketChannel? _channel;
  // stores the session ID
  String? sessionId;
  // stores the user ID
  String? userId;
  // main message handler (e.g., session screen) - called for each incoming message
  MsgHandler? onMessage; 
  // Small registry for chat handlers - allows chat UI, logging, notifs
  final List<MsgHandler> _chatHandlers = [];

  // Establish a websocket connection
  void connect(String sessionId_, int userId_, MsgHandler onMsg) {
    sessionId = sessionId_;
    userId = userId_.toString();

    // If a connection already exists then close it
    _channel?.sink.close();
    _channel = null;

    // Set the websocket URL
    final wsUrl = '$wsBaseUrl/ws/sessions/$sessionId?user_id=$userId';

    // Establish a new websocket connection
    _channel = WebSocketChannel.connect(
      Uri.parse(wsUrl),
    );


    // saves the callback function, used later when message arrives
    onMessage = onMsg;

    // Listens continuously to incoming WebSocket messages, event is a JSON string
    _channel!.stream.listen((event) {
      try {
        // convert JSON string to Dart map
        final data = jsonDecode(event);
        // check the message type
        if (data['type'] == 'chat') {
          // send chat message to all registered listeners
          for (final h in _chatHandlers){
            h(data);
          }
        }
        // Calls the main handler(the ? prevents crash if NULL)
        onMessage?.call(data);
      } 
      catch (e) {
        debugPrint("[WS PARSE ERROR] $e");
      }
    }, 
    // Auto reconnect logic, triggered when connection closes
    onDone: () {
      // waits 2 seconds before reconnecting
      Future.delayed(const Duration(seconds: 2), () {
        if (sessionId != null && userId != null) {
          // reuses the stored values
          connect(sessionId!, int.parse(userId!), onMsg);
        }
      });
    }, 
    // logs connection errors
    onError: (e) {
      debugPrint("[WS ERROR] $e");
    });
  }

  // Send a message to backend
  void send(Map msg) {
    try {
      _channel?.sink.add(jsonEncode(msg));
    } catch (e) {}
  }

  // Close connection
  void close() {
    try {
      _channel?.sink.close();
    } catch (e) {}
  }

  // Adds a chat listener
  void registerChatHandler(MsgHandler h) {
    _chatHandlers.add(h);
  }

  // Removes a chat listener
  void unregisterChatHandler(MsgHandler h) {
    _chatHandlers.remove(h);
  }
}
