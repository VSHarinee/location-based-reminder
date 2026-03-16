// // import 'package:flutter/material.dart';
// // import 'package:cloud_firestore/cloud_firestore.dart';
// // import 'package:firebase_auth/firebase_auth.dart';
// // //add
// // import '../main.dart';
// // class ReminderListScreen extends StatelessWidget {
// //   const ReminderListScreen({Key? key}) : super(key: key);
// //
// //   @override
// //   Widget build(BuildContext context) {
// //     final user = FirebaseAuth.instance.currentUser;
// //
// //     return Scaffold(
// //       appBar: AppBar(
// //         title: const Text("My Reminders"),
// //       ),
// //       body: StreamBuilder<QuerySnapshot>(
// //         stream: FirebaseFirestore.instance
// //             .collection("reminders")
// //             .where("userId", isEqualTo: user!.uid)
// //             .orderBy("createdAt", descending: true)
// //             .snapshots(),
// //         builder: (context, snapshot) {
// //           if (snapshot.hasError) {
// //             return const Center(child: Text("Error loading reminders"));
// //           }
// //
// //           if (snapshot.connectionState == ConnectionState.waiting) {
// //             return const Center(child: CircularProgressIndicator());
// //           }
// //
// //           final reminders = snapshot.data!.docs;
// //
// //           if (reminders.isEmpty) {
// //             return const Center(child: Text("No reminders found"));
// //           }
// //
// //           return ListView.builder(
// //             itemCount: reminders.length,
// //             itemBuilder: (context, index) {
// //               final doc = reminders[index];
// //               final data = doc.data() as Map<String, dynamic>;
// //
// //               return Card(
// //                 margin: const EdgeInsets.all(10),
// //                 child: ListTile(
// //                   title: Text(data["description"] ?? ""),
// //                   subtitle: Column(
// //                     crossAxisAlignment: CrossAxisAlignment.start,
// //                     children: [
// //                       Text("Location: ${data["locationName"]}"),
// //                       Text("Status: ${data["status"]}"),
// //                     ],
// //                   ),
// //                   trailing: PopupMenuButton<String>(
// //                     onSelected: (value) {
// //                       if (value == "edit") {
// //                         _editReminder(context, doc.id, data);
// //                       } else if (value == "delete") {
// //                         _deleteReminder(context, doc.id);
// //                       }
// //                     },
// //                     itemBuilder: (context) => const [
// //                       PopupMenuItem(
// //                         value: "edit",
// //                         child: Text("Edit"),
// //                       ),
// //                       PopupMenuItem(
// //                         value: "delete",
// //                         child: Text("Delete"),
// //                       ),
// //                     ],
// //                   ),
// //                 ),
// //               );
// //             },
// //           );
// //         },
// //       ),
// //     );
// //   }
// //
// //   // 🗑 Delete Reminder
// //   Future<void> _deleteReminder(BuildContext context, String reminderId) async {
// //     final user = FirebaseAuth.instance.currentUser;
// //
// //     await FirebaseFirestore.instance
// //         .collection("reminders")
// //         .doc(reminderId)
// //         .delete();
// //
// //     // Decrement counter
// //     await FirebaseFirestore.instance
// //         .collection("users")
// //         .doc(user!.uid)
// //         .update({
// //       "pendingReminders": FieldValue.increment(-1),
// //     });
// //     await debugDriver.syncAndRefreshCache();
// //
// //     ScaffoldMessenger.of(context)
// //         .showSnackBar(const SnackBar(content: Text("Reminder deleted")));
// //   }
// //
// //   // ✏ Edit Reminder
// //   void _editReminder(
// //       BuildContext context, String reminderId, Map<String, dynamic> data) {
// //
// //     final descriptionController =
// //     TextEditingController(text: data["description"]);
// //     final locationController =
// //     TextEditingController(text: data["locationName"]);
// //     final personController =
// //     TextEditingController(text: data["person"]);
// //
// //     showDialog(
// //       context: context,
// //       builder: (context) => AlertDialog(
// //         title: const Text("Edit Reminder"),
// //         content: SingleChildScrollView(
// //           child: Column(
// //             children: [
// //               TextField(
// //                 controller: descriptionController,
// //                 decoration:
// //                 const InputDecoration(labelText: "Description"),
// //               ),
// //               TextField(
// //                 controller: locationController,
// //                 decoration:
// //                 const InputDecoration(labelText: "Location"),
// //               ),
// //               TextField(
// //                 controller: personController,
// //                 decoration:
// //                 const InputDecoration(labelText: "Person"),
// //               ),
// //             ],
// //           ),
// //         ),
// //         actions: [
// //           TextButton(
// //             onPressed: () async {
// //               await FirebaseFirestore.instance
// //                   .collection("reminders")
// //                   .doc(reminderId)
// //                   .update({
// //                 "description": descriptionController.text.trim(),
// //                 "locationName": locationController.text.trim(),
// //                 "person": personController.text.trim(),
// //               });
// //
// //               await debugDriver.syncAndRefreshCache();
// //               Navigator.pop(context);
// //
// //             },
// //
// //
// //             child: const Text("Update"),
// //           ),
// //         ],
// //       ),
// //     );
// //   }
// // }
//
// import 'package:flutter/material.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import '../main.dart';
//
// class ReminderListScreen extends StatelessWidget {
//   const ReminderListScreen({Key? key}) : super(key: key);
//
//   @override
//   Widget build(BuildContext context) {
//
//     return DefaultTabController(
//       length: 2,
//       child: Scaffold(
//         appBar: AppBar(
//           title: const Text("My Reminders"),
//           bottom: const TabBar(
//             tabs: [
//               Tab(text: "Pending"),
//               Tab(text: "Completed"),
//             ],
//           ),
//         ),
//         body: const TabBarView(
//           children: [
//             ReminderList(status: "pending"),
//             ReminderList(status: "completed"),
//           ],
//         ),
//       ),
//     );
//   }
// }
//
// class ReminderList extends StatelessWidget {
//   final String status;
//
//   const ReminderList({required this.status, Key? key}) : super(key: key);
//
//   @override
//   Widget build(BuildContext context) {
//
//     final user = FirebaseAuth.instance.currentUser;
//
//     return StreamBuilder<QuerySnapshot>(
//       stream: FirebaseFirestore.instance
//           .collection("reminders")
//           .where("userId", isEqualTo: user!.uid)
//           .where("status", isEqualTo: status)
//           .orderBy("createdAt", descending: true)
//           .snapshots(),
//       builder: (context, snapshot) {
//
//         if (snapshot.hasError) {
//           return const Center(child: Text("Error loading reminders"));
//         }
//
//         if (snapshot.connectionState == ConnectionState.waiting) {
//           return const Center(child: CircularProgressIndicator());
//         }
//
//         final reminders = snapshot.data!.docs;
//
//         if (reminders.isEmpty) {
//           return const Center(child: Text("No reminders found"));
//         }
//
//         return ListView.builder(
//           itemCount: reminders.length,
//           itemBuilder: (context, index) {
//
//             final doc = reminders[index];
//             final data = doc.data() as Map<String, dynamic>;
//
//             return Card(
//               margin: const EdgeInsets.all(10),
//               child: ListTile(
//
//                 title: Text(data["description"] ?? ""),
//
//                 subtitle: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Text("Location: ${data["locationName"]}"),
//                     Text("Status: ${data["status"]}"),
//                   ],
//                 ),
//
//                 trailing: PopupMenuButton<String>(
//                   onSelected: (value) {
//                     if (value == "edit") {
//                       _editReminder(context, doc.id, data);
//                     }
//                     else if (value == "delete") {
//                       _deleteReminder(context, doc.id);
//                     }
//                     else if (value == "toggle") {
//                       _toggleStatus(doc.id, data["status"]);
//                     }
//                   },
//
//                   itemBuilder: (context) => [
//
//                     const PopupMenuItem(
//                       value: "edit",
//                       child: Text("Edit"),
//                     ),
//
//                     const PopupMenuItem(
//                       value: "delete",
//                       child: Text("Delete"),
//                     ),
//
//                     PopupMenuItem(
//                       value: "toggle",
//                       child: Text(
//                         data["status"] == "pending"
//                             ? "Mark Completed"
//                             : "Mark Pending",
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//             );
//           },
//         );
//       },
//     );
//   }
//
//   /// 🗑 Delete Reminder
//   Future<void> _deleteReminder(BuildContext context, String reminderId) async {
//
//     final user = FirebaseAuth.instance.currentUser;
//
//     await FirebaseFirestore.instance
//         .collection("reminders")
//         .doc(reminderId)
//         .delete();
//
//     await FirebaseFirestore.instance
//         .collection("users")
//         .doc(user!.uid)
//         .update({
//       "pendingReminders": FieldValue.increment(-1),
//     });
//
//     await debugDriver.syncAndRefreshCache();
//
//     ScaffoldMessenger.of(context)
//         .showSnackBar(const SnackBar(content: Text("Reminder deleted")));
//   }
//
//   /// 🔄 Toggle Pending ⇄ Completed
//   Future<void> _toggleStatus(String reminderId, String currentStatus) async {
//
//     final newStatus =
//     currentStatus == "pending" ? "completed" : "pending";
//
//     await FirebaseFirestore.instance
//         .collection("reminders")
//         .doc(reminderId)
//         .update({
//       "status": newStatus,
//     });
//
//     await debugDriver.syncAndRefreshCache();
//   }
//
//   /// ✏ Edit Reminder
//   void _editReminder(
//       BuildContext context, String reminderId, Map<String, dynamic> data) {
//
//     final descriptionController =
//     TextEditingController(text: data["description"]);
//
//     final locationController =
//     TextEditingController(text: data["locationName"]);
//
//     final personController =
//     TextEditingController(text: data["person"]);
//
//     showDialog(
//       context: context,
//       builder: (context) => AlertDialog(
//         title: const Text("Edit Reminder"),
//
//         content: SingleChildScrollView(
//           child: Column(
//             children: [
//
//               TextField(
//                 controller: descriptionController,
//                 decoration: const InputDecoration(labelText: "Description"),
//               ),
//
//               TextField(
//                 controller: locationController,
//                 decoration: const InputDecoration(labelText: "Location"),
//               ),
//
//               TextField(
//                 controller: personController,
//                 decoration: const InputDecoration(labelText: "Person"),
//               ),
//             ],
//           ),
//         ),
//
//         actions: [
//           TextButton(
//             onPressed: () async {
//
//               await FirebaseFirestore.instance
//                   .collection("reminders")
//                   .doc(reminderId)
//                   .update({
//                 "description": descriptionController.text.trim(),
//                 "locationName": locationController.text.trim(),
//                 "person": personController.text.trim(),
//               });
//
//               await debugDriver.syncAndRefreshCache();
//
//               Navigator.pop(context);
//             },
//
//             child: const Text("Update"),
//           ),
//         ],
//       ),
//     );
//   }
// }


import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:math' as math;
import '../main.dart';

class ReminderListScreen extends StatefulWidget {
  const ReminderListScreen({Key? key}) : super(key: key);

  @override
  State<ReminderListScreen> createState() => _ReminderListScreenState();
}

class _ReminderListScreenState extends State<ReminderListScreen>
    with TickerProviderStateMixin {
  late AnimationController _masterController;
  late AnimationController _orbController;
  late Animation<double> _fadeIn;
  late Animation<Offset> _slideUp;
  late Animation<double> _orbRotate;

  // ── Light theme palette ──────────────────────────────────────────────────
  static const _accent = Color(0xFF2563EB);
  static const _accentLight = Color(0xFF60A5FA);
  static const _bg = Color(0xFFF0F6FF);
  static const _surface = Colors.white;
  static const _textPrimary = Color(0xFF0F172A);
  static const _textSecondary = Color(0xFF64748B);
  static const _border = Color(0xFFE2E8F0);
  static const _successColor = Color(0xFF16A34A);
  static const _warningColor = Color(0xFFF59E0B);

  @override
  void initState() {
    super.initState();
    _masterController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1100),
    );
    _orbController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 14),
    )..repeat();

    _fadeIn = CurvedAnimation(
      parent: _masterController,
      curve: const Interval(0.0, 0.55, curve: Curves.easeOut),
    );
    _slideUp = Tween<Offset>(
      begin: const Offset(0, 0.08),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _masterController,
      curve: const Interval(0.15, 0.8, curve: Curves.easeOutCubic),
    ));
    _orbRotate = Tween<double>(begin: 0, end: 2 * math.pi).animate(
        CurvedAnimation(parent: _orbController, curve: Curves.linear));

    _masterController.forward();
  }

  @override
  void dispose() {
    _masterController.dispose();
    _orbController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark,
      child: DefaultTabController(
        length: 2,
        child: Scaffold(
          backgroundColor: _bg,
          body: Stack(
            children: [
              // Animated background
              AnimatedBuilder(
                animation: _orbRotate,
                builder: (_, __) => CustomPaint(
                  size: size,
                  painter: _LightBackgroundPainter(rotation: _orbRotate.value),
                ),
              ),
              SafeArea(
                child: FadeTransition(
                  opacity: _fadeIn,
                  child: SlideTransition(
                    position: _slideUp,
                    child: Column(
                      children: [
                        _buildHeader(),
                        _buildTabBar(),
                        const Expanded(
                          child: TabBarView(
                            children: [
                              ReminderList(status: "pending"),
                              ReminderList(status: "completed"),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(22, 14, 22, 16),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: _surface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: _border),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: const Icon(Icons.arrow_back_ios_new_rounded,
                  size: 15, color: _textPrimary),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text(
                  "My Reminders",
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    color: _textPrimary,
                    letterSpacing: -0.6,
                  ),
                ),
                Text(
                  "Manage your location reminders",
                  style: TextStyle(fontSize: 12, color: _textSecondary),
                ),
              ],
            ),
          ),
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [_accent, _accentLight],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: _accent.withOpacity(0.30),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: const Icon(Icons.notifications_active_rounded,
                color: Colors.white, size: 19),
          ),
        ],
      ),
    );
  }

  Widget _buildTabBar() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 22, vertical: 8),
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: _surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _border),
        boxShadow: [
          BoxShadow(
            color: _accent.withOpacity(0.06),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: TabBar(
        indicator: BoxDecoration(
          gradient: const LinearGradient(
            colors: [_accent, _accentLight],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: _accent.withOpacity(0.25),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        labelColor: Colors.white,
        unselectedLabelColor: _textSecondary,
        labelStyle: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.3,
        ),
        unselectedLabelStyle: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
        ),
        tabs: const [
          Tab(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.schedule_rounded, size: 16),
                SizedBox(width: 6),
                Text("Pending"),
              ],
            ),
          ),
          Tab(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.check_circle_rounded, size: 16),
                SizedBox(width: 6),
                Text("Completed"),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class ReminderList extends StatefulWidget {
  final String status;

  const ReminderList({required this.status, Key? key}) : super(key: key);

  @override
  State<ReminderList> createState() => _ReminderListState();
}

class _ReminderListState extends State<ReminderList>
    with AutomaticKeepAliveClientMixin {
  // ── Light theme palette ──────────────────────────────────────────────────
  static const _accent = Color(0xFF2563EB);
  static const _accentLight = Color(0xFF60A5FA);
  static const _bg = Color(0xFFF0F6FF);
  static const _surface = Colors.white;
  static const _textPrimary = Color(0xFF0F172A);
  static const _textSecondary = Color(0xFF64748B);
  static const _border = Color(0xFFE2E8F0);
  static const _errorColor = Color(0xFFDC2626);
  static const _successColor = Color(0xFF16A34A);
  static const _warningColor = Color(0xFFF59E0B);

  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final user = FirebaseAuth.instance.currentUser;

    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection("reminders")
          .where("userId", isEqualTo: user!.uid)
          .where("status", isEqualTo: widget.status)
          .where("approvalStatus",isEqualTo:"accepted" )
          .orderBy("createdAt", descending: true)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return _buildErrorState();
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return _buildLoadingState();
        }

        final reminders = snapshot.data!.docs;

        if (reminders.isEmpty) {
          return _buildEmptyState();
        }

        return ListView.builder(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(22, 16, 22, 32),
          itemCount: reminders.length,
          itemBuilder: (context, index) {
            final doc = reminders[index];
            final data = doc.data() as Map<String, dynamic>;

            return _ReminderCard(
              data: data,
              docId: doc.id,
              index: index,
              onDelete: () => _deleteReminder(context, doc.id),
              onToggle: () => _toggleStatus(doc.id, data["status"]),
              onEdit: () => _editReminder(context, doc.id, data),
            );
          },
        );
      },
    );
  }

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 64,
            height: 64,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: _accent.withOpacity(0.08),
              shape: BoxShape.circle,
            ),
            child: const CircularProgressIndicator(
              strokeWidth: 3,
              valueColor: AlwaysStoppedAnimation<Color>(_accent),
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            "Loading reminders...",
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: _textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    final isPending = widget.status == "pending";
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    (isPending ? _warningColor : _successColor)
                        .withOpacity(0.12),
                    (isPending ? _warningColor : _successColor)
                        .withOpacity(0.06),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                shape: BoxShape.circle,
              ),
              child: Icon(
                isPending
                    ? Icons.event_available_rounded
                    : Icons.check_circle_outline_rounded,
                size: 48,
                color: isPending ? _warningColor : _successColor,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              isPending ? "No Pending Reminders" : "No Completed Reminders",
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: _textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              isPending
                  ? "Create your first reminder to get started"
                  : "Complete some reminders to see them here",
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 14,
                color: _textSecondary,
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: _errorColor.withOpacity(0.10),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.error_outline_rounded,
                  size: 40, color: _errorColor),
            ),
            const SizedBox(height: 16),
            const Text(
              "Error Loading Reminders",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: _textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              "Please check your connection and try again",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 13, color: _textSecondary),
            ),
          ],
        ),
      ),
    );
  }

  /// 🗑 Delete Reminder
  Future<void> _deleteReminder(BuildContext context, String reminderId) async {
    final user = FirebaseAuth.instance.currentUser;

    await FirebaseFirestore.instance
        .collection("reminders")
        .doc(reminderId)
        .delete();

    await FirebaseFirestore.instance.collection("users").doc(user!.uid).update({
      "pendingReminders": FieldValue.increment(-1),
    });

    await debugDriver.syncAndRefreshCache();

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: const [
            Icon(Icons.check_circle_rounded, color: Colors.white, size: 20),
            SizedBox(width: 10),
            Text("Reminder deleted successfully"),
          ],
        ),
        backgroundColor: _successColor,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  /// 🔄 Toggle Pending ⇄ Completed
  Future<void> _toggleStatus(String reminderId, String currentStatus) async {
    final newStatus = currentStatus == "pending" ? "completed" : "pending";

    await FirebaseFirestore.instance
        .collection("reminders")
        .doc(reminderId)
        .update({
      "status": newStatus,
    });

    await debugDriver.syncAndRefreshCache();
  }

  /// ✏ Edit Reminder
  void _editReminder(
      BuildContext context, String reminderId, Map<String, dynamic> data) {
    final descriptionController =
    TextEditingController(text: data["description"]);

    final locationController =
    TextEditingController(text: data["locationName"]);

    final personController = TextEditingController(text: data["person"]);

    showDialog(
      context: context,
      barrierColor: _textPrimary.withOpacity(0.5),
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          constraints: const BoxConstraints(maxWidth: 400),
          decoration: BoxDecoration(
            color: _surface,
            borderRadius: BorderRadius.circular(28),
            border: Border.all(color: _border, width: 1.5),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                blurRadius: 40,
                offset: const Offset(0, 20),
              ),
            ],
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Header
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        _accent.withOpacity(0.08),
                        _accentLight.withOpacity(0.05),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(28),
                      topRight: Radius.circular(28),
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [_accent, _accentLight],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(14),
                          boxShadow: [
                            BoxShadow(
                              color: _accent.withOpacity(0.30),
                              blurRadius: 12,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: const Icon(Icons.edit_rounded,
                            color: Colors.white, size: 22),
                      ),
                      const SizedBox(width: 14),
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Edit Reminder",
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w800,
                                color: _textPrimary,
                                letterSpacing: -0.3,
                              ),
                            ),
                            Text(
                              "Update your reminder details",
                              style: TextStyle(
                                fontSize: 12,
                                color: _textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                // Form fields
                Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _buildDialogField(
                        controller: descriptionController,
                        label: "Description",
                        hint: "What do you need to do?",
                        icon: Icons.description_outlined,
                        maxLines: 2,
                      ),
                      const SizedBox(height: 16),
                      _buildDialogField(
                        controller: locationController,
                        label: "Location",
                        hint: "Where?",
                        icon: Icons.location_on_outlined,
                      ),
                      const SizedBox(height: 16),
                      _buildDialogField(
                        controller: personController,
                        label: "Person",
                        hint: "For whom?",
                        icon: Icons.person_outline_rounded,
                      ),
                    ],
                  ),
                ),

                // Actions
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
                  child: Row(
                    children: [
                      Expanded(
                        child: GestureDetector(
                          onTap: () => Navigator.pop(context),
                          child: Container(
                            height: 48,
                            decoration: BoxDecoration(
                              color: _bg,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: _border),
                            ),
                            child: const Center(
                              child: Text(
                                "Cancel",
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600,
                                  color: _textSecondary,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        flex: 2,
                        child: GestureDetector(
                          onTap: () async {
                            await FirebaseFirestore.instance
                                .collection("reminders")
                                .doc(reminderId)
                                .update({
                              "description": descriptionController.text.trim(),
                              "locationName": locationController.text.trim(),
                              "person": personController.text.trim(),
                            });

                            await debugDriver.syncAndRefreshCache();

                            if (!context.mounted) return;
                            Navigator.pop(context);

                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Row(
                                  children: const [
                                    Icon(Icons.check_circle_rounded,
                                        color: Colors.white, size: 20),
                                    SizedBox(width: 10),
                                    Text("Reminder updated successfully"),
                                  ],
                                ),
                                backgroundColor: _successColor,
                                behavior: SnackBarBehavior.floating,
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12)),
                                margin: const EdgeInsets.all(16),
                              ),
                            );
                          },
                          child: Container(
                            height: 48,
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [_accent, _accentLight],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: [
                                BoxShadow(
                                  color: _accent.withOpacity(0.30),
                                  blurRadius: 12,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: const Center(
                              child: Text(
                                "Update",
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white,
                                  letterSpacing: 0.3,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDialogField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    int maxLines = 1,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label.toUpperCase(),
          style: const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.7,
            color: _textSecondary,
          ),
        ),
        const SizedBox(height: 7),
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            color: const Color(0xFFF8FAFC),
            border: Border.all(color: _border),
          ),
          child: TextField(
            controller: controller,
            maxLines: maxLines,
            style: const TextStyle(
              color: _textPrimary,
              fontSize: 15,
              fontWeight: FontWeight.w500,
            ),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: const TextStyle(
                color: Color(0xFFCBD5E1),
                fontSize: 15,
              ),
              prefixIcon: Icon(icon, size: 18, color: const Color(0xFFCBD5E1)),
              border: InputBorder.none,
              contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            ),
          ),
        ),
      ],
    );
  }
}

// ── Reminder Card Widget ──────────────────────────────────────────────────
class _ReminderCard extends StatefulWidget {
  final Map<String, dynamic> data;
  final String docId;
  final int index;
  final VoidCallback onDelete;
  final VoidCallback onToggle;
  final VoidCallback onEdit;

  const _ReminderCard({
    required this.data,
    required this.docId,
    required this.index,
    required this.onDelete,
    required this.onToggle,
    required this.onEdit,
  });

  @override
  State<_ReminderCard> createState() => _ReminderCardState();
}

class _ReminderCardState extends State<_ReminderCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnim;
  late Animation<Offset> _slideAnim;

  static const _accent = Color(0xFF2563EB);
  static const _accentLight = Color(0xFF60A5FA);
  static const _surface = Colors.white;
  static const _textPrimary = Color(0xFF0F172A);
  static const _textSecondary = Color(0xFF64748B);
  static const _border = Color(0xFFE2E8F0);
  static const _successColor = Color(0xFF16A34A);
  static const _warningColor = Color(0xFFF59E0B);

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 400 + (widget.index * 80)),
    );

    _scaleAnim = Tween<double>(begin: 0.9, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic),
    );

    _slideAnim = Tween<Offset>(
      begin: const Offset(0, 0.15),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic));

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isPending = widget.data["status"] == "pending";

    return SlideTransition(
      position: _slideAnim,
      child: ScaleTransition(
        scale: _scaleAnim,
        child: Container(
          margin: const EdgeInsets.only(bottom: 14),
          decoration: BoxDecoration(
            color: _surface,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: _border, width: 1.0),
            boxShadow: [
              BoxShadow(
                color: _accent.withOpacity(0.05),
                blurRadius: 20,
                offset: const Offset(0, 6),
              ),
              BoxShadow(
                color: Colors.black.withOpacity(0.03),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(20),
              onTap: widget.onEdit,
              child: Padding(
                padding: const EdgeInsets.all(18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: isPending
                                  ? [
                                _warningColor.withOpacity(0.15),
                                _warningColor.withOpacity(0.08),
                              ]
                                  : [
                                _successColor.withOpacity(0.15),
                                _successColor.withOpacity(0.08),
                              ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(13),
                            border: Border.all(
                              color: isPending
                                  ? _warningColor.withOpacity(0.25)
                                  : _successColor.withOpacity(0.25),
                            ),
                          ),
                          child: Icon(
                            isPending
                                ? Icons.schedule_rounded
                                : Icons.check_circle_rounded,
                            color: isPending ? _warningColor : _successColor,
                            size: 22,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                widget.data["description"] ?? "No description",
                                style: const TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w700,
                                  color: _textPrimary,
                                  height: 1.3,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 2),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 3),
                                decoration: BoxDecoration(
                                  color: isPending
                                      ? _warningColor.withOpacity(0.12)
                                      : _successColor.withOpacity(0.12),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  isPending ? "PENDING" : "COMPLETED",
                                  style: TextStyle(
                                    fontSize: 9,
                                    fontWeight: FontWeight.w800,
                                    letterSpacing: 0.5,
                                    color:
                                    isPending ? _warningColor : _successColor,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        PopupMenuButton<String>(
                          onSelected: (value) {
                            HapticFeedback.selectionClick();
                            if (value == "edit") {
                              widget.onEdit();
                            } else if (value == "delete") {
                              _showDeleteConfirmation(context);
                            } else if (value == "toggle") {
                              widget.onToggle();
                            }
                          },
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                            side: BorderSide(color: _border),
                          ),
                          offset: const Offset(-10, 10),
                          icon: Container(
                            width: 32,
                            height: 32,
                            decoration: BoxDecoration(
                              color: _accent.withOpacity(0.08),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Icon(Icons.more_vert_rounded,
                                size: 18, color: _accent),
                          ),
                          itemBuilder: (context) => [
                            PopupMenuItem(
                              value: "edit",
                              child: Row(
                                children: const [
                                  Icon(Icons.edit_outlined,
                                      size: 18, color: _accent),
                                  SizedBox(width: 12),
                                  Text(
                                    "Edit",
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                      color: _textPrimary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            PopupMenuItem(
                              value: "toggle",
                              child: Row(
                                children: [
                                  Icon(
                                    isPending
                                        ? Icons.check_circle_outline_rounded
                                        : Icons.schedule_rounded,
                                    size: 18,
                                    color:
                                    isPending ? _successColor : _warningColor,
                                  ),
                                  const SizedBox(width: 12),
                                  Text(
                                    isPending
                                        ? "Mark Completed"
                                        : "Mark Pending",
                                    style: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                      color: _textPrimary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const PopupMenuDivider(),
                            const PopupMenuItem(
                              value: "delete",
                              child: Row(
                                children: [
                                  Icon(Icons.delete_outline_rounded,
                                      size: 18, color: Color(0xFFDC2626)),
                                  SizedBox(width: 12),
                                  Text(
                                    "Delete",
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                      color: Color(0xFFDC2626),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    const Divider(color: _border, height: 1),
                    const SizedBox(height: 14),
                    _buildInfoRow(
                      Icons.location_on_outlined,
                      "Location",
                      widget.data["locationName"] ?? "Unknown",
                    ),
                    const SizedBox(height: 10),
                    _buildInfoRow(
                      Icons.person_outline_rounded,
                      "Person",
                      widget.data["person"] ?? "Unknown",
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: _accent.withOpacity(0.08),
            borderRadius: BorderRadius.circular(9),
          ),
          child: Icon(icon, size: 16, color: _accent),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.5,
                  color: _textSecondary,
                ),
              ),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: _textPrimary,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _showDeleteConfirmation(BuildContext context) {
    showDialog(
      context: context,
      barrierColor: _textPrimary.withOpacity(0.5),
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          constraints: const BoxConstraints(maxWidth: 360),
          decoration: BoxDecoration(
            color: _surface,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: _border, width: 1.5),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                blurRadius: 40,
                offset: const Offset(0, 20),
              ),
            ],
          ),
          padding: const EdgeInsets.all(28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: const Color(0xFFDC2626).withOpacity(0.12),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.delete_outline_rounded,
                    size: 32, color: Color(0xFFDC2626)),
              ),
              const SizedBox(height: 20),
              const Text(
                "Delete Reminder?",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: _textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                "This action cannot be undone. The reminder will be permanently deleted.",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 13,
                  color: _textSecondary,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Container(
                        height: 46,
                        decoration: BoxDecoration(
                          color: const Color(0xFFF8FAFC),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: _border),
                        ),
                        child: const Center(
                          child: Text(
                            "Cancel",
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              color: _textSecondary,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        Navigator.pop(context);
                        widget.onDelete();
                      },
                      child: Container(
                        height: 46,
                        decoration: BoxDecoration(
                          color: const Color(0xFFDC2626),
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color:
                              const Color(0xFFDC2626).withOpacity(0.30),
                              blurRadius: 12,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: const Center(
                          child: Text(
                            "Delete",
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                              letterSpacing: 0.3,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Light background painter ───────────────────────────────────────────────
class _LightBackgroundPainter extends CustomPainter {
  final double rotation;
  _LightBackgroundPainter({required this.rotation});

  @override
  void paint(Canvas canvas, Size size) {
    // Soft white-blue base
    final bgPaint = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          Color(0xFFEFF6FF),
          Color(0xFFF0F6FF),
          Color(0xFFE8F0FE),
        ],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), bgPaint);

    // Orb 1 — large blue top-right
    _drawOrb(
      canvas,
      center: Offset(
        size.width * 0.88 + math.cos(rotation) * 22,
        size.height * 0.12 + math.sin(rotation) * 16,
      ),
      radius: size.width * 0.52,
      innerColor: const Color(0xFF2563EB).withOpacity(0.07),
    );

    // Orb 2 — sky bottom-left
    _drawOrb(
      canvas,
      center: Offset(
        size.width * 0.08 + math.cos(rotation + math.pi) * 18,
        size.height * 0.82 + math.sin(rotation + math.pi) * 14,
      ),
      radius: size.width * 0.46,
      innerColor: const Color(0xFF60A5FA).withOpacity(0.09),
    );

    // Orb 3 — tiny accent center
    _drawOrb(
      canvas,
      center: Offset(
        size.width * 0.5 + math.cos(rotation * 0.6) * 30,
        size.height * 0.42 + math.sin(rotation * 0.6) * 20,
      ),
      radius: size.width * 0.28,
      innerColor: const Color(0xFFBAE6FD).withOpacity(0.12),
    );

    // Subtle dot grid
    _drawDotGrid(canvas, size);
  }

  void _drawOrb(Canvas canvas,
      {required Offset center,
        required double radius,
        required Color innerColor}) {
    final paint = Paint()
      ..shader = RadialGradient(
        colors: [innerColor, Colors.transparent],
      ).createShader(Rect.fromCircle(center: center, radius: radius));
    canvas.drawCircle(center, radius, paint);
  }

  void _drawDotGrid(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF2563EB).withOpacity(0.055)
      ..style = PaintingStyle.fill;
    const spacing = 28.0;
    const dotR = 1.2;
    for (double x = spacing; x < size.width; x += spacing) {
      for (double y = spacing; y < size.height; y += spacing) {
        canvas.drawCircle(Offset(x, y), dotR, paint);
      }
    }
  }

  @override
  bool shouldRepaint(_LightBackgroundPainter old) => old.rotation != rotation;
}