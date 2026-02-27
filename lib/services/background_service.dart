//
// import 'package:flutter_background_service/flutter_background_service.dart';
// import 'package:flutter_background_service_android/flutter_background_service_android.dart';
// import 'package:geolocator/geolocator.dart';
//
// import 'distance_utils.dart';
// import 'speed_filter.dart';
// import 'reminder_engine.dart';
// import 'notification_service.dart';
//
// void onStart(ServiceInstance service) async {
//   // Stop handler
//   service.on('stop').listen((event) {
//     service.stopSelf();
//   });
//
//   if (service is AndroidServiceInstance) {
//     service.setAsForegroundService();
//   }
//
//   // 🔐 ENSURE PERMISSION AGAIN (CRITICAL)
//   LocationPermission permission = await Geolocator.checkPermission();
//
//   if (permission == LocationPermission.denied ||
//       permission == LocationPermission.deniedForever) {
//     // 🚨 DO NOT START GPS → avoid crash
//     return;
//   }
//
//   final speedFilter = SpeedFilter();
//   final reminderEngine = ReminderEngine();
//
//   const double targetLat = 12.9716;
//   const double targetLng = 77.5946;
//
//   // 🛡️ WRAP STREAM IN TRY–CATCH
//   try {
//     Geolocator.getPositionStream(
//       locationSettings: const LocationSettings(
//         accuracy: LocationAccuracy.high,
//         distanceFilter: 5,
//       ),
//     ).listen((position) async {
//       final instantSpeed = position.speed * 3.6;
//       final avgSpeed = speedFilter.addSpeed(instantSpeed);
//
//       final distance = DistanceUtils.calculateDistance(
//         position.latitude,
//         position.longitude,
//         targetLat,
//         targetLng,
//       );
//
//       if (reminderEngine.shouldTrigger(
//         distanceMeters: distance,
//         avgSpeedKmh: avgSpeed,
//       )) {
//         await NotificationService.showAlarmFromBackground();
//       }
//     });
//   } catch (e) {
//     // Emulator safety
//     return;
//   }
// }
//
import 'dart:ui';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:flutter_background_service_android/flutter_background_service_android.dart';
import 'package:geolocator/geolocator.dart';

import 'dynamic_driver.dart';
import 'notification_service.dart';
import 'reminder_cache.dart';

DynamicDriver? _driver;

void onStart(ServiceInstance service) async {

  DartPluginRegistrant.ensureInitialized();

  if (service is AndroidServiceInstance) {
    service.setAsForegroundService();
  }

  // 🔐 Ensure permission
  final permission = await Geolocator.checkPermission();
  if (permission == LocationPermission.denied ||
      permission == LocationPermission.deniedForever) {
    return;
  }

  // 🔥 Initialize Engine
  _driver = DynamicDriver();

  await _driver!.initialize();

  // 🚨 Alarm callback from engine
  _driver!.onAlarm = (reminder) async {

    await NotificationService.showAlarmFromBackground(
      reminderId: reminder["id"],
      description: reminder["description"],
    );
  };

  // ▶ Start Engine
  _driver!.start();

  // 🛑 Stop handler
  service.on('stop').listen((event) {
    _driver?.stop();
    service.stopSelf();
  });
}