// import 'package:flutter/material.dart';
// import 'screens/location_status_screen.dart';
//
// void main() {
//   runApp(const MyApp());
// }
//
// class MyApp extends StatelessWidget {
//   const MyApp({super.key});
//
//   @override
//   Widget build(BuildContext context) {
//     return const MaterialApp(
//       debugShowCheckedModeBanner: false,
//       home: LocationStatusScreen(),
//     );
//   }
// }
// import 'package:flutter/material.dart';
// import 'package:flutter_background_service/flutter_background_service.dart';
// import 'package:flutter_background_service_android/flutter_background_service_android.dart';
//
// import 'screens/location_status_screen.dart';
// import 'services/background_service.dart';
// import 'services/notification_service.dart';
//
// Future<void> main() async {
//   WidgetsFlutterBinding.ensureInitialized();
//
//   await NotificationService.init();
//
//   await FlutterBackgroundService().configure(
//     androidConfiguration: AndroidConfiguration(
//       onStart: onStart,
//       isForegroundMode: true,
//       autoStart: false,
//       foregroundServiceNotificationId: 888,
//     ),
//     iosConfiguration: IosConfiguration(
//       autoStart: false,
//       onForeground: onStart,
//       onBackground: iosBackgroundHandler,
//     ),
//   );
//
//   runApp(const MyApp());
// }
//
// bool iosBackgroundHandler(ServiceInstance service) {
//   WidgetsFlutterBinding.ensureInitialized();
//   return true;
// }
//
// class MyApp extends StatelessWidget {
//   const MyApp({super.key});
//
//   @override
//   Widget build(BuildContext context) {
//     return const MaterialApp(
//       debugShowCheckedModeBanner: false,
//       home: LocationStatusScreen(),
//     );
//   }
// }
// import 'package:flutter/material.dart';
// import 'package:flutter_background_service/flutter_background_service.dart';
// import 'package:flutter_background_service_android/flutter_background_service_android.dart';
//
// import 'package:firebase_core/firebase_core.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
//
// import 'screens/location_status_screen.dart';
// import 'services/background_service.dart';
// import 'services/notification_service.dart';
//
// Future<void> main() async {
//   WidgetsFlutterBinding.ensureInitialized();
//
//   // 🔥 Firebase initialization using firebase_core
//   await Firebase.initializeApp();
//
//   // 🔍 Firestore connection check
//   await checkFirestoreConnection();
//
//   await NotificationService.init();
//
//   await FlutterBackgroundService().configure(
//     androidConfiguration: AndroidConfiguration(
//       onStart: onStart,
//       isForegroundMode: true,
//       autoStart: false,
//       foregroundServiceNotificationId: 888,
//     ),
//     iosConfiguration: IosConfiguration(
//       autoStart: false,
//       onForeground: onStart,
//       onBackground: iosBackgroundHandler,
//     ),
//   );
//
//   runApp(const MyApp());
// }
//
// bool iosBackgroundHandler(ServiceInstance service) {
//   WidgetsFlutterBinding.ensureInitialized();
//   return true;
// }
//
// // ✅ Firestore test function (ADDED ONLY)
// Future<void> checkFirestoreConnection() async {
//   try {
//     await FirebaseFirestore.instance
//         .collection('connection_test')
//         .doc('status')
//         .set({
//       'connected': true,
//       'timestamp': FieldValue.serverTimestamp(),
//     });
//
//     debugPrint('🔥 Firebase Firestore connected successfully');
//   } catch (e) {
//     debugPrint('❌ Firebase Firestore connection failed: $e');
//   }
// }
//
// class MyApp extends StatelessWidget {
//   const MyApp({super.key});
//
//   @override
//   Widget build(BuildContext context) {
//     return const MaterialApp(
//       debugShowCheckedModeBanner: false,
//       home: LocationStatusScreen(),
//     );
//   }
// }
import 'package:flutter/material.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:flutter_background_service_android/flutter_background_service_android.dart';

import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'screens/location_status_screen.dart';
import 'screens/login.dart';
import 'services/background_service.dart';
import 'services/notification_service.dart';
import 'screens/home.dart';
import 'services/dynamic_driver.dart';

final DynamicDriver debugDriver = DynamicDriver();
final GlobalKey<NavigatorState> navigatorKey =
GlobalKey<NavigatorState>();
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 🔥 Firebase initialization
  await Firebase.initializeApp();
  await debugDriver.initialize();
  debugDriver.start();
  // 🔍 Firestore connection check
  await checkFirestoreConnection();

  await NotificationService.init();

  await FlutterBackgroundService().configure(
    androidConfiguration: AndroidConfiguration(
      onStart: onStart,
      isForegroundMode: true,
      autoStart: false,
      foregroundServiceNotificationId: 888,
    ),
    iosConfiguration: IosConfiguration(
      autoStart: false,
      onForeground: onStart,
      onBackground: iosBackgroundHandler,
    ),
  );

  runApp(const MyApp());
}

bool iosBackgroundHandler(ServiceInstance service) {
  WidgetsFlutterBinding.ensureInitialized();
  return true;
}

// 🔍 Firestore test
Future<void> checkFirestoreConnection() async {
  try {
    await FirebaseFirestore.instance
        .collection('connection_test')
        .doc('status')
        .set({
      'connected': true,
      'timestamp': FieldValue.serverTimestamp(),
    });

    debugPrint('🔥 Firebase Firestore connected successfully');
  } catch (e) {
    debugPrint('❌ Firebase Firestore connection failed: $e');
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // return const MaterialApp(
    //   debugShowCheckedModeBanner: false,
    //   home: AuthGate(), // ✅ AUTH DECISION HERE
    // );
    return MaterialApp(
      navigatorKey: navigatorKey,
      debugShowCheckedModeBanner: false,

      home: const AuthGate(),

      routes: {
        "/login": (context) => const LoginScreen(),
        "/home": (context) => const HomeScreen(),
       // "/location": (context) => const LocationStatusScreen(),
      },
    );
  }
}

/// 🔐 AuthGate decides Login vs Home
class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      // ❌ Not logged in
      return const LoginScreen();
    } else {
      // ✅ Logged in
      return const HomeScreen();
    }
  }
}
