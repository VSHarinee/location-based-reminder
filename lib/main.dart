import 'package:flutter/material.dart';

/// Firebase
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

/// Background Service
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:flutter_background_service_android/flutter_background_service_android.dart';

/// Screens
import 'screens/login.dart';
import 'screens/home.dart';
import 'screens/location_status_screen.dart';

/// Services
import 'services/background_service.dart';
import 'services/notification_service.dart';
import 'services/dynamic_driver.dart';
import 'services/reminder_cache.dart';

/// Global Driver Instance
final DynamicDriver debugDriver = DynamicDriver();

/// Global Navigator Key
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  /// Initialize Firebase
  await Firebase.initializeApp();

  /// Listen for authentication state changes
  FirebaseAuth.instance.authStateChanges().listen((user) async {
    if (user != null) {
      debugPrint("✅ User logged in → Starting DynamicDriver");

      await debugDriver.initialize();
      //for alarm
      debugDriver.onAlarm = (reminder) async {
        await NotificationService.showAlarmFromBackground(
          reminderId: reminder["id"],
          description: reminder["description"],
        );
      };
      // for alarm

      debugDriver.start();

      /// Debug alarm hook
      /*
      debugDriver.onAlarm = (reminder) async {
        await NotificationService.showAlarmFromBackground(
          reminderId: reminder["id"],
          description: reminder["description"],
        );
      };
      */
    } else {
      debugPrint("❌ User logged out → Stopping DynamicDriver");

      debugDriver.stop();
      await ReminderCache.clear();
    }
  });

  /// Test Firestore connection
  await checkFirestoreConnection();

  /// Initialize notification service
  await NotificationService.init();

  /// Configure background service
  await FlutterBackgroundService().configure(
    androidConfiguration: AndroidConfiguration(
      onStart: onStart,
      isForegroundMode: true,
      autoStart: true,
      foregroundServiceNotificationId: 888,
    ),
    iosConfiguration: IosConfiguration(
      autoStart: true,
      onForeground: onStart,
      onBackground: iosBackgroundHandler,
    ),
  );

  runApp(const MyApp());
}

/// iOS background handler
bool iosBackgroundHandler(ServiceInstance service) {
  WidgetsFlutterBinding.ensureInitialized();
  return true;
}

/// Firestore connectivity test
Future<void> checkFirestoreConnection() async {
  try {
    await FirebaseFirestore.instance
        .collection('connection_test')
        .doc('status')
        .set({
      'connected': true,
      'timestamp': FieldValue.serverTimestamp(),
    });

    debugPrint("🔥 Firebase Firestore connected successfully");
  } catch (e) {
    debugPrint("❌ Firebase Firestore connection failed: $e");
  }
}

/// Root App Widget
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
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

/// Authentication Gate
/// Decides whether to show Login or Home
class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return const LoginScreen();
    }

    return const HomeScreen();
  }
}