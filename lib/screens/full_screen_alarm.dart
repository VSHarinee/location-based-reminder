// import 'package:flutter/material.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:wakelock_plus/wakelock_plus.dart';
// import '../services/notification_service.dart';
// class FullScreenAlarmPage extends StatefulWidget {
//   final Map<String, dynamic> reminder;
//
//   const FullScreenAlarmPage({super.key, required this.reminder});
//
//   @override
//   State<FullScreenAlarmPage> createState() => _FullScreenAlarmPageState();
// }
//
// class _FullScreenAlarmPageState extends State<FullScreenAlarmPage> {
//
//   @override
//   void initState() {
//     super.initState();
//     WakelockPlus.enable();
//   }
//
//
//   //changed by codex
//   Future<void> _completeReminder() async {
//     await FirebaseFirestore.instance
//         .collection("reminders")
//         .doc(widget.reminder["id"])
//         .update({
//       "status": "completed",
//       "triggeredAt": FieldValue.serverTimestamp(),
//
//     });
//
//     // stop ringing notification
//     // import NotificationService
//     await NotificationService.stopAlarmNotification(widget.reminder["id"]);
//
//     if (!mounted) return;
//     Navigator.pop(context);
//   }
//
//
//
//   // Future<void> _snooze() async {
//   //   // Example snooze: keep reminder pending but postpone trigger metadata.
//   //   await FirebaseFirestore.instance
//   //       .collection("reminders")
//   //       .doc(widget.reminder["id"])
//   //       .update({
//   //     "status": "pending",
//   //     "snoozedAt": FieldValue.serverTimestamp(),
//   //   });
//   //
//   //   await NotificationService.stopAlarmNotification();
//   //
//   //   if (!mounted) return;
//   //   Navigator.pop(context);
//   // }
//   Future<void> _snooze(int hours) async {
//
//     final snoozeUntil = DateTime.now().add(Duration(hours: hours));
//
//     await FirebaseFirestore.instance
//         .collection("reminders")
//         .doc(widget.reminder["id"])
//         .update({
//       "status": "pending",
//       "snoozeUntil": snoozeUntil,
//     });
//
//     await NotificationService.stopAlarmNotification(widget.reminder["id"]);
//
//     if (!mounted) return;
//     Navigator.pop(context);
//   }
//   @override
//   void dispose() {
//     WakelockPlus.disable();
//     super.dispose();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//
//     return Scaffold(
//       backgroundColor: Colors.red.shade900,
//       body: SafeArea(
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//
//             const Icon(Icons.alarm, size: 120, color: Colors.white),
//
//             const SizedBox(height: 20),
//
//             Text(
//               widget.reminder["description"],
//               style: const TextStyle(
//                 color: Colors.white,
//                 fontSize: 22,
//               ),
//               textAlign: TextAlign.center,
//             ),
//
//             const SizedBox(height: 50),
//
//             Row(
//               mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//               children: [
//
//                 ElevatedButton(
//                   style: ElevatedButton.styleFrom(
//                     backgroundColor: Colors.green,
//                     padding: const EdgeInsets.all(20),
//                   ),
//                   onPressed: _completeReminder,
//                   child: const Text("ACCEPT"),
//                 ),
//
//                 PopupMenuButton<int>(
//                   itemBuilder: (context) => [
//                     const PopupMenuItem(value: 1, child: Text("Snooze 1 hour")),
//                     const PopupMenuItem(value: 2, child: Text("Snooze 2 hours")),
//                     const PopupMenuItem(value: 3, child: Text("Snooze 3 hours")),
//                   ],
//                   onSelected: (hours) {
//                     _snooze(hours);
//                   },
//                 )
//               ],
//             )
//           ],
//         ),
//       ),
//     );
//   }
// }
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:wakelock_plus/wakelock_plus.dart';
import '../services/notification_service.dart';

class FullScreenAlarmPage extends StatefulWidget {
  final Map<String, dynamic> reminder;

  const FullScreenAlarmPage({super.key, required this.reminder});

  @override
  State<FullScreenAlarmPage> createState() => _FullScreenAlarmPageState();
}

class _FullScreenAlarmPageState extends State<FullScreenAlarmPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    WakelockPlus.enable();

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.08).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  Future<void> _completeReminder() async {
    await FirebaseFirestore.instance
        .collection("reminders")
        .doc(widget.reminder["id"])
        .update({
      "status": "completed",
      "triggeredAt": FieldValue.serverTimestamp(),
    });

    await NotificationService.stopAlarmNotification(widget.reminder["id"]);

    if (!mounted) return;
    Navigator.pop(context);
  }

  Future<void> _snooze(int hours) async {
    final snoozeUntil = DateTime.now().add(Duration(hours: hours));

    await FirebaseFirestore.instance
        .collection("reminders")
        .doc(widget.reminder["id"])
        .update({
      "status": "pending",
      "snoozeUntil": snoozeUntil,
    });

    await NotificationService.stopAlarmNotification(widget.reminder["id"]);

    if (!mounted) return;
    Navigator.pop(context);
  }

  @override
  void dispose() {
    _pulseController.dispose();
    WakelockPlus.disable();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFFEDE9FE), // violet-100
              Color(0xFFF3E8FF), // purple-100
              Color(0xFFEEF2FF), // indigo-50
            ],
          ),
        ),
        child: SafeArea(
          child: Stack(
            children: [
              // Decorative circles
              Positioned(
                top: -60,
                right: -60,
                child: Container(
                  width: 200,
                  height: 200,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: const Color(0xFFA78BFA).withOpacity(0.2),
                  ),
                ),
              ),
              Positioned(
                bottom: -40,
                left: -40,
                child: Container(
                  width: 160,
                  height: 160,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: const Color(0xFFC4B5FD).withOpacity(0.2),
                  ),
                ),
              ),

              // Main content
              Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 32),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Pulsing icon ring
                      ScaleTransition(
                        scale: _pulseAnimation,
                        child: Container(
                          width: 110,
                          height: 110,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: const Color(0xFF8B5CF6).withOpacity(0.12),
                            border: Border.all(
                              color: const Color(0xFF8B5CF6).withOpacity(0.3),
                              width: 2,
                            ),
                          ),
                          child: const Icon(
                            Icons.notifications_rounded,
                            size: 52,
                            color: Color(0xFF7C3AED),
                          ),
                        ),
                      ),

                      const SizedBox(height: 28),

                      // "Reminder" badge
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 5),
                        decoration: BoxDecoration(
                          color: const Color(0xFF8B5CF6).withOpacity(0.12),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Text(
                          "REMINDER",
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF6D28D9),
                            letterSpacing: 1.2,
                          ),
                        ),
                      ),

                      const SizedBox(height: 14),

                      // Description
                      Text(
                        widget.reminder["description"],
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF3B1F7A),
                          height: 1.35,
                        ),
                        textAlign: TextAlign.center,
                      ),

                      const SizedBox(height: 8),

                      const Text(
                        "Tap accept when done",
                        style: TextStyle(
                          fontSize: 14,
                          color: Color(0xFF7C6FAD),
                        ),
                      ),

                      const SizedBox(height: 44),

                      // Accept button
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF7C3AED),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(18),
                            ),
                            elevation: 0,
                          ),
                          onPressed: _completeReminder,
                          icon: const Icon(Icons.check_rounded, size: 20),
                          label: const Text(
                            "Accept",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 0.4,
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 16),

                      // Snooze label
                      const Text(
                        "Snooze for",
                        style: TextStyle(
                          fontSize: 12,
                          color: Color(0xFF9B8CCC),
                        ),
                      ),

                      const SizedBox(height: 10),

                      // Snooze buttons row
                      Row(
                        children: [1, 2, 3].map((hours) {
                          return Expanded(
                            child: Padding(
                              padding: EdgeInsets.only(
                                left: hours == 1 ? 0 : 6,
                                right: hours == 3 ? 0 : 6,
                              ),
                              child: OutlinedButton(
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: const Color(0xFF6D28D9),
                                  side: const BorderSide(
                                    color: Color(0xFFA78BFA),
                                    width: 1.5,
                                  ),
                                  backgroundColor:
                                  Colors.white.withOpacity(0.65),
                                  padding:
                                  const EdgeInsets.symmetric(vertical: 12),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(14),
                                  ),
                                  elevation: 0,
                                ),
                                onPressed: () => _snooze(hours),
                                child: Text(
                                  "$hours hr${hours > 1 ? 's' : ''}",
                                  style: const TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}