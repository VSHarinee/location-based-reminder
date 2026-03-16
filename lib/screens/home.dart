// import 'package:flutter/material.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:locationbasedreminder/screens/place.dart';
// import 'package:locationbasedreminder/screens/reminder_creation.dart';
// import 'package:locationbasedreminder/screens/viewreminder.dart';
// import '../main.dart';
// import 'debug_dashboard_screen.dart';
// import 'location_status_screen.dart';
// import 'voice_input_page.dart';
//
// class HomeScreen extends StatelessWidget {
//   const HomeScreen({Key? key}) : super(key: key);
//
//   void _logout(BuildContext context) async {
//     await FirebaseAuth.instance.signOut();
//
//     Navigator.pushReplacementNamed(context, "/login");
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     final user = FirebaseAuth.instance.currentUser;
//
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text("Home"),
//       ),
//
//       drawer: Drawer(
//         child: Column(
//           children: [
//
//             // 🔹 Drawer Header
//             UserAccountsDrawerHeader(
//               accountName: const Text("Welcome"),
//               accountEmail: Text(user?.email ?? ""),
//               currentAccountPicture: const CircleAvatar(
//                 child: Icon(Icons.person, size: 40),
//               ),
//             ),
//
//             // 🔹 Location Status Page
//             // ListTile(
//             //   leading: const Icon(Icons.location_on),
//             //   title: const Text("Location Status"),
//             //   onTap: () {
//             //     Navigator.push(
//             //       context,
//             //       MaterialPageRoute(
//             //         builder: (_) => const LocationStatusScreen(),
//             //       ),
//             //     );
//             //   },
//             // ),
//             ListTile(
//               leading: const Icon(Icons.bug_report, color: Colors.deepPurple),
//               title: const Text("Engine Debug Dashboard"),
//               onTap: () {
//                 Navigator.push(
//                   context,
//                   MaterialPageRoute(
//                     builder: (_) => DebugDashboardScreen(
//                       driver: debugDriver,
//                     ),
//                   ),
//                 );
//               },
//             ),
//
//             // 🔹 Voice Input Page
//             ListTile(
//               leading: const Icon(Icons.mic),
//               title: const Text("Voice Reminder"),
//               onTap: () {
//                 Navigator.push(
//                   context,
//                   MaterialPageRoute(
//                     builder: (_) => const VoiceInputPage(),
//                   ),
//                 );
//               },
//             ),
//             ListTile(
//               leading: const Icon(Icons.add_circle_outline),
//               title: const Text("Create Reminder"),
//               onTap: () {
//                 Navigator.push(
//                   context,
//                   MaterialPageRoute(
//                     builder: (_) => const CreateReminderScreen(),
//                   ),
//                 );
//               },
//             ),
//             ListTile(
//               leading: const Icon(Icons.list),
//               title: const Text("My Reminders"),
//               onTap: () {
//                 Navigator.push(
//                   context,
//                   MaterialPageRoute(
//                     builder: (_) => const ReminderListScreen(),
//                   ),
//                 );
//               },
//             ),
//
//             ListTile(
//               leading: const Icon(Icons.place),
//               title: const Text("Add Place"),
//               onTap: () {
//                 Navigator.push(
//                   context,
//                   MaterialPageRoute(
//                     builder: (_) => const CreatePlaceScreen(),
//                   ),
//                 );
//               },
//             ),
//             const Spacer(),
//
//             const Divider(),
//
//             // 🔹 Logout
//             ListTile(
//               leading: const Icon(Icons.logout, color: Colors.red),
//               title: const Text("Logout",
//                   style: TextStyle(color: Colors.red)),
//               onTap: () => _logout(context),
//             ),
//           ],
//         ),
//       ),
//
//
//
//       body: const Center(
//         child: Text(
//           "Welcome to Adaptive Location Reminder App 🚀",
//           style: TextStyle(fontSize: 18),
//         ),
//       ),
//     );
//   }
// }


import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:locationbasedreminder/screens/reminder_creation.dart';
import 'package:locationbasedreminder/screens/viewreminder.dart';
import '../main.dart';
import 'debug_dashboard_screen.dart';
import 'friend_requests_screen.dart';
import 'friends_screen.dart';
import 'notifications_screen.dart';
import 'voice_input_page.dart';
import 'dart:math' as math;

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with TickerProviderStateMixin {
  late AnimationController _masterController;
  late AnimationController _orbController;
  late AnimationController _fabController;

  late Animation<double> _fadeIn;
  late Animation<Offset> _slideUp;
  late Animation<double> _cardScale;
  late Animation<double> _orbRotate;
  late Animation<double> _fabScale;

  bool _drawerOpen = false;

  // ── Light theme palette ──────────────────────────────────────────────────
  static const _accent = Color(0xFF2563EB);
  static const _accentLight = Color(0xFF60A5FA);
  static const _accentGlow = Color(0xFFBAE6FD);
  static const _bg = Color(0xFFF0F6FF);
  static const _surface = Colors.white;
  static const _textPrimary = Color(0xFF0F172A);
  static const _textSecondary = Color(0xFF64748B);
  static const _border = Color(0xFFE2E8F0);
  static const _errorColor = Color(0xFFDC2626);
  static const _successColor = Color(0xFF16A34A);
  static const _warningColor = Color(0xFFF59E0B);

  @override
  void initState() {
    super.initState();

    _masterController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    _orbController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 14),
    )..repeat();
    _fabController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );

    _fadeIn = CurvedAnimation(
      parent: _masterController,
      curve: const Interval(0.0, 0.6, curve: Curves.easeOut),
    );
    _slideUp = Tween<Offset>(
      begin: const Offset(0, 0.12),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _masterController,
      curve: const Interval(0.2, 0.85, curve: Curves.easeOutCubic),
    ));
    _cardScale = Tween<double>(begin: 0.92, end: 1.0).animate(
      CurvedAnimation(
        parent: _masterController,
        curve: const Interval(0.2, 0.85, curve: Curves.easeOutCubic),
      ),
    );
    _orbRotate = Tween<double>(begin: 0, end: 2 * math.pi).animate(
        CurvedAnimation(parent: _orbController, curve: Curves.linear));
    _fabScale = Tween<double>(begin: 0, end: 1.0).animate(
      CurvedAnimation(parent: _fabController, curve: Curves.elasticOut),
    );

    _masterController.forward();
    Future.delayed(const Duration(milliseconds: 800), () {
      if (mounted) _fabController.forward();
    });
  }

  @override
  void dispose() {
    _masterController.dispose();
    _orbController.dispose();
    _fabController.dispose();
    super.dispose();
  }

  void _logout(BuildContext context) async {
    await FirebaseAuth.instance.signOut();
    if (!mounted) return;
    Navigator.pushReplacementNamed(context, "/login");
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final user = FirebaseAuth.instance.currentUser;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark,
      child: Scaffold(
        backgroundColor: _bg,
        drawer: _buildDrawer(user),
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
                child: Column(
                  children: [
                    _buildTopBar(user),
                    Expanded(
                      child: SlideTransition(
                        position: _slideUp,
                        child: ScaleTransition(
                          scale: _cardScale,
                          child: SingleChildScrollView(
                            physics: const BouncingScrollPhysics(),
                            padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                _buildWelcomeCard(user),
                                const SizedBox(height: 20),
                                _buildStatsCards(),
                                const SizedBox(height: 20),
                                _buildQuickActions(),
                                const SizedBox(height: 20),
                                _buildRecentReminders(),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
        floatingActionButton: ScaleTransition(
          scale: _fabScale,
          child: FloatingActionButton.extended(
            onPressed: () {
              HapticFeedback.mediumImpact();
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const CreateReminderScreen(),
                ),
              );
            },
            backgroundColor: _accent,
            elevation: 8,
            icon: const Icon(Icons.add_rounded, size: 24,color: Colors.white),
            label: const Text(
              "New Reminder",
              style: TextStyle(
                fontSize: 15,
                color: Colors.white,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.3,
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ── Top Bar ───────────────────────────────────────────────────────────────
  Widget _buildTopBar(User? user) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 14, 20, 8),
      child: Row(
        children: [
          Builder(
            builder: (context) => GestureDetector(
              onTap: () {
                HapticFeedback.selectionClick();
                Scaffold.of(context).openDrawer();
              },
              child: Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: _surface,
                  borderRadius: BorderRadius.circular(13),
                  border: Border.all(color: _border),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: const Icon(Icons.menu_rounded,
                    size: 22, color: _textPrimary),
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Welcome Back 👋",
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: _textSecondary,
                  ),
                ),
                Text(
                  user?.email?.split('@')[0].toUpperCase() ?? "USER",
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: _textPrimary,
                    letterSpacing: -0.3,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          // Container(
          //   width: 44,
          //   height: 44,
          //   decoration: BoxDecoration(
          //     gradient: const LinearGradient(
          //       colors: [_accent, _accentLight],
          //       begin: Alignment.topLeft,
          //       end: Alignment.bottomRight,
          //     ),
          //     borderRadius: BorderRadius.circular(13),
          //     boxShadow: [
          //       BoxShadow(
          //         color: _accent.withOpacity(0.30),
          //         blurRadius: 12,
          //         offset: const Offset(0, 4),
          //       ),
          //     ],
          //   ),
          //   child: const Icon(Icons.notifications_active_rounded,
          //       color: Colors.white, size: 20),
          // ),

          StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection("friend_requests")
                .where("toUid", isEqualTo: user?.uid)
                .snapshots(),
            builder: (context, snapshot) {

              int requestCount = snapshot.data?.docs.length ?? 0;

              return Stack(
                children: [

                  GestureDetector(
                    onTap: () {

                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const NotificationsScreen(),
                        ),
                      );
                    },

                    child: Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [_accent, _accentLight],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(13),
                        boxShadow: [
                          BoxShadow(
                            color: _accent.withOpacity(0.30),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.notifications_active_rounded,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                  ),

                  if (requestCount > 0)
                    Positioned(
                      right: 0,
                      top: 0,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: const BoxDecoration(
                          color: Colors.red,
                          shape: BoxShape.circle,
                        ),
                        constraints: const BoxConstraints(
                          minWidth: 18,
                          minHeight: 18,
                        ),
                        child: Text(
                          "$requestCount",
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                ],
              );
            },
          )
        ],
      ),
    );
  }

  // ── Welcome Card ──────────────────────────────────────────────────────────
  Widget _buildWelcomeCard(User? user) {
    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [_accent, _accentLight],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: _accent.withOpacity(0.35),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.25),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: Colors.white.withOpacity(0.3),
                    width: 2,
                  ),
                ),
                child: const Icon(Icons.my_location_rounded,
                    color: Colors.white, size: 28),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Adaptive Location",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: Colors.white.withOpacity(0.95),
                        letterSpacing: 0.2,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      "Reminder System",
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: Colors.white.withOpacity(0.85),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          Container(
            height: 1,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.white.withOpacity(0.0),
                  Colors.white.withOpacity(0.3),
                  Colors.white.withOpacity(0.0),
                ],
              ),
            ),
          ),
          const SizedBox(height: 18),
          Row(
            children: [
              Icon(Icons.email_outlined,
                  size: 16, color: Colors.white.withOpacity(0.8)),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  user?.email ?? "user@example.com",
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: Colors.white.withOpacity(0.9),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Icon(Icons.verified_user_rounded,
                  size: 16, color: Colors.white.withOpacity(0.8)),
              const SizedBox(width: 8),
              Text(
                "Active Account",
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: Colors.white.withOpacity(0.9),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ── Stats Cards ───────────────────────────────────────────────────────────
  Widget _buildStatsCards() {
    final user = FirebaseAuth.instance.currentUser;

    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance
          .collection("users")
          .doc(user?.uid)
          .snapshots(),
      builder: (context, snapshot) {
        int pendingCount = 0;
        int friendsCount = 0;

        if (snapshot.hasData && snapshot.data != null) {
          final data = snapshot.data!.data() as Map<String, dynamic>?;
          pendingCount = data?["pendingReminders"] ?? 0;
          friendsCount = data?["noOfFriends"] ?? 0;
        }

        return Row(
          children: [
            Expanded(
              child: _buildStatCard(
                icon: Icons.schedule_rounded,
                label: "Pending",
                value: "$pendingCount",
                color: _warningColor,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildStatCard(
                icon: Icons.people_outline_rounded,
                label: "Friends",
                value: "$friendsCount",
                color: _successColor,
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: _surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _border),
        boxShadow: [
          BoxShadow(
            color: _accent.withOpacity(0.05),
            blurRadius: 20,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  color.withOpacity(0.15),
                  color.withOpacity(0.08),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(13),
              border: Border.all(color: color.withOpacity(0.25)),
            ),
            child: Icon(icon, color: color, size: 22),
          ),
          const SizedBox(height: 14),
          Text(
            value,
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w800,
              color: _textPrimary,
              letterSpacing: -0.5,
              height: 1.0,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: _textSecondary,
              letterSpacing: 0.3,
            ),
          ),
        ],
      ),
    );
  }

  // ── Quick Actions ─────────────────────────────────────────────────────────
  Widget _buildQuickActions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 4),
          child: Text(
            "QUICK ACTIONS",
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w800,
              letterSpacing: 1.0,
              color: _textSecondary,
            ),
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildActionCard(
                icon: Icons.mic_rounded,
                label: "Voice Reminder",
                gradient: const [Color(0xFF8B5CF6), Color(0xFFA78BFA)],
                onTap: () {
                  HapticFeedback.mediumImpact();
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const VoiceInputPage(),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildActionCard(
                icon: Icons.people,
                label: "My Friends ",
                gradient: const [Color(0xFF5CF6CD), Color(0xFFA78BFA)],
                onTap: () {
                  HapticFeedback.mediumImpact();
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const FriendsScreen(),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(width: 12),

            Expanded(
              child: _buildActionCard(
                icon: Icons.list_rounded,
                label: "My Reminder",
                gradient: const [_accent, _accentLight],
                onTap: () {
                  HapticFeedback.mediumImpact();
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const ReminderListScreen(),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildActionCard({
    required IconData icon,
    required String label,
    required List<Color> gradient,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: gradient,
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: gradient[0].withOpacity(0.30),
                blurRadius: 16,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.25),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: Colors.white.withOpacity(0.3),
                    width: 1.5,
                  ),
                ),
                child: Icon(icon, color: Colors.white, size: 24),
              ),
              const SizedBox(height: 16),
              Text(
                label,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                  height: 1.3,
                  letterSpacing: 0.2,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── Recent Reminders ──────────────────────────────────────────────────────
  Widget _buildRecentReminders() {
    final user = FirebaseAuth.instance.currentUser;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "RECENT REMINDERS",
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.0,
                  color: _textSecondary,
                ),
              ),
              GestureDetector(
                onTap: () {
                  HapticFeedback.selectionClick();
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const ReminderListScreen(),
                    ),
                  );
                },
                child: Container(
                  padding:
                  const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: _accent.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: _accent.withOpacity(0.20)),
                  ),
                  child: const Text(
                    "View All",
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: _accent,
                      letterSpacing: 0.3,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection("reminders")
              .where("userId", isEqualTo: user?.uid)
              .where("status", isEqualTo: "pending")
              .where("approvalStatus",isEqualTo:"accepted" )
              .orderBy("createdAt", descending: true)
              .limit(3)
              .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return _buildLoadingCard();
            }

            if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
              return _buildEmptyRemindersCard();
            }

            final reminders = snapshot.data!.docs;

            return Column(
              children: reminders.map((doc) {
                final data = doc.data() as Map<String, dynamic>;
                return Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: _buildReminderPreviewCard(data),
                );
              }).toList(),
            );
          },
        ),
      ],
    );
  }

  Widget _buildReminderPreviewCard(Map<String, dynamic> data) {
    return Container(
      decoration: BoxDecoration(
        color: _surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: _border),
        boxShadow: [
          BoxShadow(
            color: _accent.withOpacity(0.04),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  _warningColor.withOpacity(0.15),
                  _warningColor.withOpacity(0.08),
                ],
              ),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: _warningColor.withOpacity(0.25)),
            ),
            child: const Icon(Icons.schedule_rounded,
                color: _warningColor, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  data["description"] ?? "No description",
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: _textPrimary,
                    height: 1.3,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 3),
                Row(
                  children: [
                    Icon(Icons.location_on_outlined,
                        size: 12, color: _textSecondary.withOpacity(0.7)),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        data["locationName"] ?? "Unknown location",
                        style: const TextStyle(
                          fontSize: 12,
                          color: _textSecondary,
                          fontWeight: FontWeight.w500,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: _warningColor.withOpacity(0.12),
              borderRadius: BorderRadius.circular(6),
            ),
            child: const Text(
              "PENDING",
              style: TextStyle(
                fontSize: 9,
                fontWeight: FontWeight.w800,
                letterSpacing: 0.4,
                color: _warningColor,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingCard() {
    return Container(
      height: 100,
      decoration: BoxDecoration(
        color: _surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: _border),
      ),
      child: Center(
        child: SizedBox(
          width: 28,
          height: 28,
          child: CircularProgressIndicator(
            strokeWidth: 2.5,
            valueColor: AlwaysStoppedAnimation<Color>(_accent),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyRemindersCard() {
    return Container(
      decoration: BoxDecoration(
        color: _surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: _border),
      ),
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: _accent.withOpacity(0.08),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.event_available_rounded,
                size: 32, color: _accent.withOpacity(0.6)),
          ),
          const SizedBox(height: 14),
          const Text(
            "No Pending Reminders",
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: _textPrimary,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            "Create your first reminder to get started",
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 12,
              color: _textSecondary,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  // ── Drawer ────────────────────────────────────────────────────────────────
  Widget _buildDrawer(User? user) {
    return Drawer(
      backgroundColor: _surface,
      child: Column(
        children: [
          // Drawer Header
          Container(
            padding: const EdgeInsets.fromLTRB(24, 60, 24, 24),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [_accent, _accentLight],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              boxShadow: [
                BoxShadow(
                  color: _accent.withOpacity(0.25),
                  blurRadius: 16,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 68,
                  height: 68,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.25),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: Colors.white.withOpacity(0.4),
                      width: 3,
                    ),
                  ),
                  child: const Icon(Icons.person_rounded,
                      size: 36, color: Colors.white),
                ),
                const SizedBox(height: 16),
                Text(
                  "Welcome",
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.white.withOpacity(0.85),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  user?.email ?? "user@example.com",
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),

          // Menu Items
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(vertical: 12),
              children: [
                _buildDrawerItem(
                  icon: Icons.mic_rounded,
                  title: "Voice Reminder",
                  color: const Color(0xFF8B5CF6),
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const VoiceInputPage(),
                      ),
                    );
                  },
                ),
                _buildDrawerItem(
                  icon: Icons.add_circle_outline_rounded,
                  title: "Create Reminder",
                  color: _accent,
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const CreateReminderScreen(),
                      ),
                    );
                  },
                ),
                _buildDrawerItem(
                  icon: Icons.list_rounded,
                  title: "My Reminders",
                  color: _accentLight,
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const ReminderListScreen(),
                      ),
                    );
                  },
                ),
                _buildDrawerItem(
                  icon: Icons.bug_report_rounded,
                  title: "Engine Debug Dashboard",
                  color: const Color(0xFF7C3AED),
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => DebugDashboardScreen(
                          driver: debugDriver,
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),

          const Divider(color: _border, height: 1),

          // Logout
          _buildDrawerItem(
            icon: Icons.logout_rounded,
            title: "Logout",
            color: _errorColor,
            onTap: () => _logout(context),
          ),
          const SizedBox(height: 12),
        ],
      ),
    );
  }

  Widget _buildDrawerItem({
    required IconData icon,
    required String title,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            HapticFeedback.selectionClick();
            onTap();
          },
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(11),
                    border: Border.all(color: color.withOpacity(0.25)),
                  ),
                  child: Icon(icon, color: color, size: 20),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: _textPrimary,
                    ),
                  ),
                ),
                Icon(Icons.arrow_forward_ios_rounded,
                    size: 14, color: _textSecondary.withOpacity(0.4)),
              ],
            ),
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