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
//   if (service is AndroidServiceInstance) {
//     service.setAsForegroundService();
//   }
//
//   final speedFilter = SpeedFilter();
//   final reminderEngine = ReminderEngine();
//
//   // TEMP: hardcoded target (we’ll connect UI next)
//   const double targetLat = 12.9716;
//   const double targetLng = 77.5946;
//
//   Geolocator.getPositionStream(
//     locationSettings: const LocationSettings(
//       accuracy: LocationAccuracy.high,
//       distanceFilter: 5,
//     ),
//   ).listen((position) async {
//     final instantSpeed = position.speed * 3.6;
//     final avgSpeed = speedFilter.addSpeed(instantSpeed);
//
//     final distance = DistanceUtils.calculateDistance(
//       position.latitude,
//       position.longitude,
//       targetLat,
//       targetLng,
//     );
//
//     if (reminderEngine.shouldTrigger(
//       distanceMeters: distance,
//       avgSpeedKmh: avgSpeed,
//     )) {
//       await NotificationService.showAlarm();
//     }
//   });
// }
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:flutter_background_service_android/flutter_background_service_android.dart';
import 'package:geolocator/geolocator.dart';

import 'distance_utils.dart';
import 'speed_filter.dart';
import 'reminder_engine.dart';
import 'notification_service.dart';

// void onStart(ServiceInstance service) async {
//   // Required to make it a foreground service on Android
//   service.on('stop').listen((event) {
//     service.stopSelf();
//   });
//
//   if (service is AndroidServiceInstance) {
//     service.setAsForegroundService();
//   }
//
//   final speedFilter = SpeedFilter();
//   final reminderEngine = ReminderEngine();
//
//   // TEMP target (we’ll connect UI later)
//   const double targetLat = 12.9716;
//   const double targetLng = 77.5946;
//
//   Geolocator.getPositionStream(
//     locationSettings: const LocationSettings(
//       accuracy: LocationAccuracy.high,
//       distanceFilter: 5,
//     ),
//   ).listen((position) async {
//     final instantSpeed = position.speed * 3.6;
//     final avgSpeed = speedFilter.addSpeed(instantSpeed);
//
//     final distance = DistanceUtils.calculateDistance(
//       position.latitude,
//       position.longitude,
//       targetLat,
//       targetLng,
//     );
//
//     if (reminderEngine.shouldTrigger(
//       distanceMeters: distance,
//       avgSpeedKmh: avgSpeed,
//     )) {
//       await NotificationService.showAlarmFromBackground();
//     }
//   });
// }
void onStart(ServiceInstance service) async {
  // Stop handler
  service.on('stop').listen((event) {
    service.stopSelf();
  });

  if (service is AndroidServiceInstance) {
    service.setAsForegroundService();
  }

  // 🔐 ENSURE PERMISSION AGAIN (CRITICAL)
  LocationPermission permission = await Geolocator.checkPermission();

  if (permission == LocationPermission.denied ||
      permission == LocationPermission.deniedForever) {
    // 🚨 DO NOT START GPS → avoid crash
    return;
  }

  final speedFilter = SpeedFilter();
  final reminderEngine = ReminderEngine();

  const double targetLat = 12.9716;
  const double targetLng = 77.5946;

  // 🛡️ WRAP STREAM IN TRY–CATCH
  try {
    Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 5,
      ),
    ).listen((position) async {
      final instantSpeed = position.speed * 3.6;
      final avgSpeed = speedFilter.addSpeed(instantSpeed);

      final distance = DistanceUtils.calculateDistance(
        position.latitude,
        position.longitude,
        targetLat,
        targetLng,
      );

      if (reminderEngine.shouldTrigger(
        distanceMeters: distance,
        avgSpeedKmh: avgSpeed,
      )) {
        await NotificationService.showAlarmFromBackground();
      }
    });
  } catch (e) {
    // Emulator safety
    return;
  }
}

