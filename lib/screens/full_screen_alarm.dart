import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:wakelock_plus/wakelock_plus.dart';

class FullScreenAlarmPage extends StatefulWidget {
  final Map<String, dynamic> reminder;

  const FullScreenAlarmPage({super.key, required this.reminder});

  @override
  State<FullScreenAlarmPage> createState() => _FullScreenAlarmPageState();
}

class _FullScreenAlarmPageState extends State<FullScreenAlarmPage> {

  @override
  void initState() {
    super.initState();
    WakelockPlus.enable();
  }

  Future<void> _completeReminder() async {
    await FirebaseFirestore.instance
        .collection("reminders")
        .doc(widget.reminder["id"])
        .update({
      "status": "completed",
      "triggeredAt": FieldValue.serverTimestamp(),
    });

    Navigator.pop(context);
  }

  void _snooze() {
    Navigator.pop(context);
  }

  @override
  void dispose() {
    WakelockPlus.disable();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      backgroundColor: Colors.red.shade900,
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [

            const Icon(Icons.alarm, size: 120, color: Colors.white),

            const SizedBox(height: 20),

            Text(
              widget.reminder["description"],
              style: const TextStyle(
                color: Colors.white,
                fontSize: 22,
              ),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 50),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [

                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    padding: const EdgeInsets.all(20),
                  ),
                  onPressed: _completeReminder,
                  child: const Text("ACCEPT"),
                ),

                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange,
                    padding: const EdgeInsets.all(20),
                  ),
                  onPressed: _snooze,
                  child: const Text("SNOOZE"),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}