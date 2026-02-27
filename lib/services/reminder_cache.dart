import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ReminderCache {

  static const _key = "cached_reminders";

  /// 🔥 STEP 1: Sync Firestore → Local Cache
  static Future<void> syncFromFirestore() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final snapshot = await FirebaseFirestore.instance
        .collection("reminders")
        .where("userId", isEqualTo: user.uid)
        .where("status", isEqualTo: "pending")
        .get();

    final reminders = snapshot.docs.map((doc) {
      final data = doc.data();

      return {
        "id": doc.id,
        "description": data["description"],
        "latitude": data["latitude"],
        "longitude": data["longitude"],
        "person": data["person"],
        "status": data["status"],

        // 🔥 CONVERT Timestamp → int
        "createdAt": data["createdAt"] != null
            ? (data["createdAt"] as Timestamp)
            .millisecondsSinceEpoch
            : null,

        "triggeredAt": data["triggeredAt"] != null
            ? (data["triggeredAt"] as Timestamp)
            .millisecondsSinceEpoch
            : null,
      };
    }).toList();

    await saveReminders(reminders);

    print("🔥 Cache synced. Count: ${reminders.length}");
  }

  /// 💾 Save locally
  static Future<void> saveReminders(List<Map<String, dynamic>> reminders) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = jsonEncode(reminders);
    await prefs.setString(_key, jsonString);
  }

  /// 📦 Load from local storage
  static Future<List<Map<String, dynamic>>> loadReminders() async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getString(_key);

    if (data == null) return [];

    final List decoded = jsonDecode(data);
    return decoded.map((e) => Map<String, dynamic>.from(e)).toList();
  }

  /// 🗑 Clear cache
  static Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_key);
  }
}