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

import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationService {
  static final FlutterLocalNotificationsPlugin _plugin =
  FlutterLocalNotificationsPlugin();

  static Future<void> init() async {
    const androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');

    const initSettings = InitializationSettings(
      android: androidInit,
    );

    await _plugin.initialize(initSettings);
  }

  // ✅ BACKGROUND-SAFE ALARM
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
      fullScreenIntent: true,
      playSound: true,
      enableVibration: true,
    );

    const notificationDetails =
    NotificationDetails(android: androidDetails);

    await _plugin.show(
      999,
      '📍 Location Reached',
      'You are near your target location',
      notificationDetails,
    );
  }
}
