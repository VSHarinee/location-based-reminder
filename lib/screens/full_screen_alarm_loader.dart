import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'full_screen_alarm.dart';

class FullScreenAlarmLoader extends StatelessWidget {

  final String reminderId;

  const FullScreenAlarmLoader({super.key, required this.reminderId});

  @override
  Widget build(BuildContext context) {

    return FutureBuilder(
      future: FirebaseFirestore.instance
          .collection("reminders")
          .doc(reminderId)
          .get(),
      builder: (context, snapshot) {

        if (!snapshot.hasData) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        final data = snapshot.data!.data()!;
        data["id"] = reminderId;

        return FullScreenAlarmPage(reminder: data);
      },
    );
  }
}