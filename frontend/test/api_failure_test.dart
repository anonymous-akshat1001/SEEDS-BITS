import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/services/api_service.dart';

void main() {
  test('maps supported HTTP and network failures to safe messages', () {
    expect(
      ApiService.mapFailure(statusCode: 400, responseBody: 'bad input').message,
      'Please check the information and try again.',
    );
    expect(
      ApiService.mapFailure(statusCode: 401, context: 'login').message,
      'Invalid phone number or password.',
    );
    expect(
      ApiService.mapFailure(statusCode: 404, context: 'session join').message,
      'Session not found. Check the session ID and try again.',
    );
    expect(
      ApiService.mapFailure(
        statusCode: 422,
        context: 'registration password',
      ).message,
      'Password must be at least 6 characters.',
    );
    expect(
      ApiService.mapFailure(statusCode: 500).message,
      'The service is temporarily unavailable. Please try again.',
    );
    expect(
      ApiService.mapFailure(error: Exception('socket')).message,
      'We could not complete that request. Check your connection and try again.',
    );
  });
}
