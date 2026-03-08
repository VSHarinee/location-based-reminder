// // import 'package:flutter_local_notifications/flutter_local_notifications.dart';
// // import 'package:wakelock_plus/wakelock_plus.dart';
// //
// // class NotificationService {
// //   static final FlutterLocalNotificationsPlugin _plugin =
// //   FlutterLocalNotificationsPlugin();
// //
// //   static Future<void> init() async {
// //     const android = AndroidInitializationSettings('@mipmap/ic_launcher');
// //
// //     await _plugin.initialize(
// //       const InitializationSettings(android: android),
// //     );
// //   }
// //
// //   static Future<void> showAlarm() async {
// //     // Wake screen
// //     await WakelockPlus.enable();
// //
// //     const androidDetails = AndroidNotificationDetails(
// //       'alarm_channel',
// //       'Location Alarm',
// //       importance: Importance.max,
// //       priority: Priority.high,
// //       category: AndroidNotificationCategory.alarm,
// //       fullScreenIntent: true,
// //       playSound: true,
// //       sound: RawResourceAndroidNotificationSound('alarm'),
// //     );
// //
// //     await _plugin.show(
// //       0,
// //       'Location Reminder',
// //       'You have reached your destination',
// //       const NotificationDetails(android: androidDetails),
// //     );
// //   }
// // }
// import 'package:flutter_local_notifications/flutter_local_notifications.dart';
//
// class NotificationService {
//   static final FlutterLocalNotificationsPlugin _plugin =
//   FlutterLocalNotificationsPlugin();
//
//   static Future<void> init() async {
//     const androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');
//
//     const initSettings = InitializationSettings(
//       android: androidInit,
//     );
//
//     await _plugin.initialize(initSettings);
//   }
//
//   // ✅ BACKGROUND-SAFE ALARM
//   static Future<void> showAlarmFromBackground() async {
//     const androidDetails = AndroidNotificationDetails(
//       'alarm_channel',
//       'Location Alarm',
//       channelDescription: 'Triggers when near target location',
//       importance: Importance.max,
//       priority: Priority.high,
//       fullScreenIntent: true,
//       playSound: true,
//       enableVibration: true,
//     );
//
//     const notificationDetails =
//     NotificationDetails(android: androidDetails);
//
//     await _plugin.show(
//       999,
//       '📍 Location Reached',
//       'You are near your target location',
//       notificationDetails,
//     );
//   }
// }
//
// import 'package:flutter_local_notifications/flutter_local_notifications.dart';
//
// class NotificationService {
//   static final FlutterLocalNotificationsPlugin _plugin =
//   FlutterLocalNotificationsPlugin();
//
//   static Future<void> init() async {
//     const androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');
//
//     const initSettings = InitializationSettings(
//       android: androidInit,
//     );
//
//     await _plugin.initialize(initSettings);
//   }
//
//   // ✅ BACKGROUND-SAFE ALARM
//   static Future<void> showAlarmFromBackground({
//     required String reminderId,
//     required String description,
//   }) async {
//     const androidDetails = AndroidNotificationDetails(
//       'alarm_channel',
//       'Location Alarm',
//       channelDescription: 'Triggers when near target location',
//       importance: Importance.max,
//       priority: Priority.high,
//       fullScreenIntent: true,
//       playSound: true,
//       enableVibration: true,
//     );
//
//     const notificationDetails =
//     NotificationDetails(android: androidDetails);
//
//     await _plugin.show(
//       999,
//       '📍 Location Reached',
//       'You are near your target location',
//       notificationDetails,
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import '../main.dart';
import '../screens/full_screen_alarm_loader.dart';

class NotificationService {
  static final FlutterLocalNotificationsPlugin _plugin =
  FlutterLocalNotificationsPlugin();

  static Future<void> init() async {
    const androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');

    const initSettings = InitializationSettings(
      android: androidInit,
    );

    await _plugin.initialize(
      initSettings,
      onDidReceiveNotificationResponse: _onNotificationResponse,
      onDidReceiveBackgroundNotificationResponse: notificationTapBackground,
    );

    // Optional: create channel explicitly
    const channel = AndroidNotificationChannel(
      'alarm_channel',
      'Location Alarm',
      description: 'Triggers when near target location',
      importance: Importance.max,
      playSound: true,
      sound: RawResourceAndroidNotificationSound('alarm'),
    );

    await _plugin
        .resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);

    // Handle app launched from notification tap / full-screen intent
    final launchDetails = await _plugin.getNotificationAppLaunchDetails();
    final payload = launchDetails?.notificationResponse?.payload;
    if (payload != null && payload.isNotEmpty) {
      _openAlarmScreen(payload);
    }
  }

  static void _onNotificationResponse(NotificationResponse response) {
    final payload = response.payload;
    if (payload != null && payload.isNotEmpty) {
      _openAlarmScreen(payload);
    }
  }

  @pragma('vm:entry-point')
  static void notificationTapBackground(NotificationResponse response) {
    // App may be in background isolate; UI nav should happen when main isolate resumes.
    // Keeping this entry-point prevents plugin callback issues.
  }

  static void _openAlarmScreen(String reminderId) {
    final nav = navigatorKey.currentState;
    if (nav == null) return;

    nav.push(
      MaterialPageRoute(
        builder: (_) => FullScreenAlarmLoader(reminderId: reminderId),
        fullscreenDialog: true,
      ),
    );
  }

  static Future<void> showAlarmFromBackground({
    required String reminderId,
    required String description,
  }) async {
    const androidDetails = AndroidNotificationDetails(
      'alarm_channel',
      'Location Alarm',
      channelDescription: 'Triggers when near target location',
      importance: Importance.max,
      priority: Priority.high,
      category: AndroidNotificationCategory.alarm,
      fullScreenIntent: true,
      playSound: true,
      sound: RawResourceAndroidNotificationSound('alarm'),
      enableVibration: true,
      ticker: 'Location Alarm',
      ongoing: true,
      autoCancel: false,
      visibility: NotificationVisibility.public,
    );

    const notificationDetails = NotificationDetails(android: androidDetails);

    await _plugin.show(
      999, // can also use reminderId.hashCode
      '📍 Location Reached',
      description,
      notificationDetails,
      payload: reminderId, // critical for opening full-screen page
    );
  }

  static Future<void> stopAlarmNotification() async {
    await _plugin.cancel(999);
  }
}