import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:frontend/screens/login_screen.dart';
import 'package:frontend/services/notification_services.dart';
import 'package:frontend/services/tts_service.dart';
import 'package:frontend/widgets/sim_suggestion_dialog.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  void androidTestWidgets(
    String description,
    Future<void> Function(WidgetTester) body,
  ) {
    testWidgets(
      description,
      body,
      variant: TargetPlatformVariant.only(TargetPlatform.android),
    );
  }

  late List<MethodCall> phoneCalls;
  late List<MethodCall> simCalls;
  var permissionGranted = true;
  List<Map<String, dynamic>> cards = [];

  Future<void> activate(WidgetTester tester, String label) async {
    for (
      var i = 0;
      i < 90 && FocusManager.instance.primaryFocus?.debugLabel != label;
      i++
    ) {
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
      await tester.pump(const Duration(milliseconds: 30));
    }
    expect(FocusManager.instance.primaryFocus?.debugLabel, label);
    await tester.sendKeyEvent(LogicalKeyboardKey.enter);
    await tester.pumpAndSettle();
  }

  setUp(() async {
    AndroidFlutterLocalNotificationsPlugin.registerWith();
    SharedPreferences.setMockInitialValues({});
    phoneCalls = [];
    simCalls = [];
    cards = [
      {
        'carrierName': 'Test carrier',
        'number': '+91 9000000001',
        'slotIndex': 0,
      },
    ];
    permissionGranted = true;
    final messenger =
        TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;
    messenger.setMockMethodCallHandler(
      const MethodChannel('flutter_tts'),
      (_) async => 1,
    );
    messenger.setMockMethodCallHandler(
      const MethodChannel('flutter.baseflow.com/permissions/methods'),
      (call) async {
        phoneCalls.add(call);
        if (call.method == 'requestPermissions') {
          return {Permission.phone.value: permissionGranted ? 1 : 0};
        }
        return permissionGranted ? 1 : 0;
      },
    );
    messenger.setMockMethodCallHandler(const MethodChannel('mobile_number'), (
      call,
    ) async {
      simCalls.add(call);
      if (call.method == 'hasPhonePermission') return true;
      if (call.method == 'getMobileNumber') return jsonEncode(cards);
      return null;
    });
    await TtsService.configure(enabled: true);
  });

  tearDown(() {
    final messenger =
        TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;
    for (final channel in [
      'mobile_number',
      'flutter.baseflow.com/permissions/methods',
      'dexterous.com/flutter/local_notifications',
    ]) {
      messenger.setMockMethodCallHandler(MethodChannel(channel), null);
    }
  });

  androidTestWidgets(
    'login never reads SIM information automatically even when permission already exists; declining keeps manual entry',
    (tester) async {
      await tester.pumpWidget(const MaterialApp(home: LoginScreen()));
      await tester.pumpAndSettle();
      expect(phoneCalls, isEmpty);
      expect(simCalls, isEmpty);
      await tester.enterText(find.byType(TextField).first, '9000000002');
      await activate(tester, 'login-sim-suggestion');
      await activate(tester, 'dialog-cancel');
      expect(phoneCalls, isEmpty);
      expect(simCalls, isEmpty);
      expect(
        tester.widget<TextField>(find.byType(TextField).first).controller!.text,
        '9000000002',
      );
    },
  );

  androidTestWidgets(
    'SIM suggestions require consent then a keypad selection; one SIM never silently replaces manual entry',
    (tester) async {
      await tester.pumpWidget(const MaterialApp(home: LoginScreen()));
      await tester.pump();
      await tester.enterText(find.byType(TextField).first, '9000000002');
      await activate(tester, 'login-sim-suggestion');
      await activate(tester, 'dialog-confirm');
      expect(find.text('Choose SIM suggestion'), findsOneWidget);
      expect(
        tester.widget<TextField>(find.byType(TextField).first).controller!.text,
        '9000000002',
      );
      await activate(tester, 'sim-suggestion-0');
      expect(
        tester.widget<TextField>(find.byType(TextField).first).controller!.text,
        '9000000001',
      );
      expect(
        simCalls.where((call) => call.method == 'getMobileNumber'),
        hasLength(1),
      );
      expect(
        tester.widget<TextField>(find.byType(TextField).at(1)).controller!.text,
        isEmpty,
      );
    },
  );

  androidTestWidgets(
    'denied phone permission leaves login and Wi-Fi/manual number entry available',
    (tester) async {
      permissionGranted = false;
      await tester.pumpWidget(const MaterialApp(home: LoginScreen()));
      await tester.pump();
      await tester.enterText(find.byType(TextField).first, '9000000002');
      await activate(tester, 'login-sim-suggestion');
      await activate(tester, 'dialog-confirm');
      expect(simCalls, isEmpty);
      expect(
        find.text('SIM autofill unavailable. Enter the phone number manually.'),
        findsOneWidget,
      );
      expect(
        tester.widget<TextField>(find.byType(TextField).first).controller!.text,
        '9000000002',
      );
      expect(find.text('4: Login as Student'), findsOneWidget);
    },
  );

  androidTestWidgets(
    'unavailable SIM number never fills an invalid placeholder and Cancel preserves manual input',
    (tester) async {
      cards = [
        {'carrierName': 'Test carrier', 'number': null},
      ];
      await tester.pumpWidget(const MaterialApp(home: LoginScreen()));
      await tester.pump();
      await tester.enterText(find.byType(TextField).first, '9000000002');
      await activate(tester, 'login-sim-suggestion');
      await activate(tester, 'dialog-confirm');
      await activate(tester, 'sim-suggestion-0');
      expect(find.text('Choose SIM suggestion'), findsOneWidget);
      await activate(tester, 'sim-suggestion-cancel');
      expect(
        tester.widget<TextField>(find.byType(TextField).first).controller!.text,
        '9000000002',
      );
    },
  );

  androidTestWidgets(
    'late SIM response cannot reopen a dialog after leaving login',
    (tester) async {
      final response = Completer<String>();
      tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
        const MethodChannel('mobile_number'),
        (call) async {
          simCalls.add(call);
          if (call.method == 'hasPhonePermission') return true;
          return response.future;
        },
      );
      await tester.pumpWidget(const MaterialApp(home: LoginScreen()));
      await tester.pump();
      await activate(tester, 'login-sim-suggestion');
      final confirm = find.textContaining('Read SIM suggestions');
      await tester.tap(confirm);
      await tester.pump();
      expect(
        simCalls.where((call) => call.method == 'getMobileNumber'),
        hasLength(1),
      );
      await tester.pumpWidget(
        MaterialApp(
          key: UniqueKey(),
          home: const Scaffold(body: Text('Other screen')),
        ),
      );
      response.complete(jsonEncode(cards));
      await tester.pumpAndSettle();
      expect(find.text('Other screen'), findsOneWidget);
      expect(find.text('Choose SIM suggestion'), findsNothing);
      expect(tester.takeException(), isNull);
    },
  );

  androidTestWidgets(
    'leaving during the native permission check never requests another permission or scans SIMs',
    (tester) async {
      final response = Completer<bool>();
      tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
        const MethodChannel('mobile_number'),
        (call) async {
          simCalls.add(call);
          if (call.method == 'hasPhonePermission') return response.future;
          return null;
        },
      );
      await tester.pumpWidget(const MaterialApp(home: LoginScreen()));
      await tester.pump();
      await activate(tester, 'login-sim-suggestion');
      await tester.tap(find.textContaining('Read SIM suggestions'));
      await tester.pump();
      expect(simCalls.map((call) => call.method), ['hasPhonePermission']);
      await tester.pumpWidget(const SizedBox.shrink());
      response.complete(false);
      await tester.pumpAndSettle();
      expect(simCalls.map((call) => call.method), ['hasPhonePermission']);
      expect(tester.takeException(), isNull);
    },
  );

  androidTestWidgets(
    'no SIM leaves the manually entered phone number and login available',
    (tester) async {
      cards = [];
      await tester.pumpWidget(const MaterialApp(home: LoginScreen()));
      await tester.pump();
      await tester.enterText(find.byType(TextField).first, '9000000002');
      await activate(tester, 'login-sim-suggestion');
      await activate(tester, 'dialog-confirm');
      expect(
        find.text('No SIM card found. Enter the phone number manually.'),
        findsOneWidget,
      );
      expect(
        find.ancestor(
          of: find.text('No SIM card found. Enter the phone number manually.'),
          matching: find.byWidgetPredicate(
            (widget) =>
                widget is Semantics && widget.properties.liveRegion == true,
          ),
        ),
        findsOneWidget,
      );
      expect(
        tester.widget<TextField>(find.byType(TextField).first).controller!.text,
        '9000000002',
      );
      expect(find.text('4: Login as Student'), findsOneWidget);
      expect(find.text('Choose SIM suggestion'), findsNothing);
    },
  );

  androidTestWidgets(
    'multiple SIMs fill only the explicitly selected second suggestion',
    (tester) async {
      cards.add({
        'carrierName': 'Second carrier',
        'number': '+91 9000000003',
        'slotIndex': 1,
      });
      await tester.pumpWidget(const MaterialApp(home: LoginScreen()));
      await tester.pump();
      await tester.enterText(find.byType(TextField).first, '9000000002');
      await activate(tester, 'login-sim-suggestion');
      await activate(tester, 'dialog-confirm');
      expect(
        tester.widget<TextField>(find.byType(TextField).first).controller!.text,
        '9000000002',
      );
      await activate(tester, 'sim-suggestion-1');
      expect(
        tester.widget<TextField>(find.byType(TextField).first).controller!.text,
        '9000000003',
      );
    },
  );

  for (final failure in ['platform', 'missing plugin', 'malformed response']) {
    androidTestWidgets(
      '$failure is explained without blocking manual login or exposing SIM data',
      (tester) async {
        tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
          const MethodChannel('mobile_number'),
          (call) async {
            if (call.method == 'hasPhonePermission') return true;
            if (failure == 'platform') {
              throw PlatformException(code: 'unavailable');
            }
            if (failure == 'missing plugin') {
              throw MissingPluginException();
            }
            return 'invalid JSON';
          },
        );
        await tester.pumpWidget(const MaterialApp(home: LoginScreen()));
        await tester.pump();
        await tester.enterText(find.byType(TextField).first, '9000000002');
        await activate(tester, 'login-sim-suggestion');
        await activate(tester, 'dialog-confirm');
        expect(
          find.text(
            'SIM suggestion unavailable. Enter the phone number manually.',
          ),
          findsOneWidget,
        );
        expect(
          tester
              .widget<TextField>(find.byType(TextField).first)
              .controller!
              .text,
          '9000000002',
        );
        expect(find.text('4: Login as Student'), findsOneWidget);
        expect(tester.takeException(), isNull);
      },
    );
  }

  androidTestWidgets(
    'SIM picker reflows and reaches the last item at 240x320 and 1.5x without silent selection',
    (tester) async {
      tester.view.physicalSize = const Size(240, 320);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      await tester.pumpWidget(
        MaterialApp(
          builder: (context, child) => MediaQuery(
            data: MediaQuery.of(
              context,
            ).copyWith(textScaler: const TextScaler.linear(1.5)),
            child: child!,
          ),
          home: SimSuggestionDialog(
            options: [
              for (var i = 0; i < 25; i++)
                (label: 'SIM ${i + 1}', number: '9000000001'),
            ],
          ),
        ),
      );
      await tester.pump();
      for (var i = 0; i < 25; i++) {
        await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
        await tester.pump(const Duration(milliseconds: 30));
      }
      expect(
        FocusManager.instance.primaryFocus?.debugLabel,
        'sim-suggestion-24',
      );
      expect(tester.takeException(), isNull);
    },
  );

  androidTestWidgets(
    'actual native notification uses generic previews, private visibility and strips personal data from routing payload',
    (tester) async {
      MethodCall? shown;
      tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
        const MethodChannel('dexterous.com/flutter/local_notifications'),
        (call) async {
          if (call.method == 'show') shown = call;
          return null;
        },
      );
      expect(
        await NotificationService().showPrivateUpdate({
          'type': 'session_invitation',
          'session_id': '7',
          'teacher_name': 'Personal teacher',
          'session_title': 'Private lesson',
          'grade': '100',
          'phone_number': '9000000001',
        }),
        isTrue,
      );
      final args = shown!.arguments as Map;
      expect(args['title'], NotificationService.privateTitle);
      expect(args['body'], NotificationService.privateBody);
      expect(args['payload'], 'type=session_invitation&session_id=7');
      expect(args['platformSpecifics']['visibility'], 0);
      expect(jsonEncode(args), isNot(contains('Personal teacher')));
      expect(jsonEncode(args), isNot(contains('9000000001')));
    },
  );
}
