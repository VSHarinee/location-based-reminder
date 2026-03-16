// import 'package:flutter/material.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// //added by codex
// import '../main.dart';
// class CreateReminderScreen extends StatefulWidget {
//   const CreateReminderScreen({Key? key}) : super(key: key);
//
//   @override
//   State<CreateReminderScreen> createState() =>
//       _CreateReminderScreenState();
// }
//
// class _CreateReminderScreenState
//     extends State<CreateReminderScreen> {
//
//   final _descriptionController = TextEditingController();
//   final _personController = TextEditingController();
//   final _manualLatController = TextEditingController();
//   final _manualLonController = TextEditingController();
//   final _searchController = TextEditingController();
//
//   bool _loading = false;
//   bool _manualMode = false;
//   String _message = "";
//
//   Map<String, dynamic>? selectedPlace;
//
//   Stream<QuerySnapshot> _searchPlaces(String query) {
//     return FirebaseFirestore.instance
//         .collection("places")
//         .where("name_lower",
//         isGreaterThanOrEqualTo: query.toLowerCase())
//         .where("name_lower",
//         isLessThanOrEqualTo: query.toLowerCase() + '\uf8ff')
//         .snapshots();
//   }
//
//   Future<void> _createReminder() async {
//     setState(() {
//       _loading = true;
//       _message = "";
//     });
//
//     try {
//       final user = FirebaseAuth.instance.currentUser;
//       if (user == null) {
//         setState(() => _message = "User not logged in");
//         return;
//       }
//
//       double latitude;
//       double longitude;
//       String locationName;
//
//       if (_manualMode) {
//         latitude = double.parse(_manualLatController.text.trim());
//         longitude = double.parse(_manualLonController.text.trim());
//         locationName = "Custom Location";
//       } else {
//         if (selectedPlace == null) {
//           setState(() {
//             _message = "Please select a place";
//             _loading = false;
//           });
//           return;
//         }
//
//         latitude = selectedPlace!["latitude"];
//         longitude = selectedPlace!["longitude"];
//         locationName = selectedPlace!["name"];
//       }
//
//       await FirebaseFirestore.instance.collection("reminders").add({
//         "userId": user.uid,
//         "description": _descriptionController.text.trim(),
//         "locationName": locationName,
//         "latitude": latitude,
//         "longitude": longitude,
//         "person": _personController.text.trim(),
//         "status": "pending",
//         "createdAt": FieldValue.serverTimestamp(),
//         "triggeredAt": null,
//       });
//
//       await FirebaseFirestore.instance
//           .collection("users")
//           .doc(user.uid)
//           .update({
//         "pendingReminders": FieldValue.increment(1),
//       });
//       await debugDriver.syncAndRefreshCache();//added codex
//
//       setState(() {
//         _message = "✅ Reminder Created Successfully";
//         selectedPlace = null;
//         _searchController.clear();
//       });
//
//     } catch (e) {
//       setState(() {
//         _message = "❌ Failed to create reminder";
//       });
//     } finally {
//       setState(() {
//         _loading = false;
//       });
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//
//     return Scaffold(
//       appBar: AppBar(title: const Text("Create Reminder")),
//       body: SingleChildScrollView(
//         padding: const EdgeInsets.all(20),
//         child: Column(
//           children: [
//
//             TextField(
//               controller: _descriptionController,
//               decoration: const InputDecoration(
//                 labelText: "Description",
//                 border: OutlineInputBorder(),
//               ),
//             ),
//             const SizedBox(height: 16),
//
//             if (!_manualMode) ...[
//               TextField(
//                 controller: _searchController,
//                 decoration: const InputDecoration(
//                   labelText: "Search Place",
//                   border: OutlineInputBorder(),
//                 ),
//                 onChanged: (_) => setState(() {}),
//               ),
//               const SizedBox(height: 5),
//
//               if (_searchController.text.isNotEmpty)
//                 Container(
//                   constraints: const BoxConstraints(maxHeight: 200),
//                   decoration: BoxDecoration(
//                     border: Border.all(color: Colors.grey),
//                     borderRadius: BorderRadius.circular(8),
//                   ),
//                   child: StreamBuilder<QuerySnapshot>(
//                     stream: _searchPlaces(_searchController.text),
//                     builder: (context, snapshot) {
//                       if (!snapshot.hasData) {
//                         return const SizedBox();
//                       }
//
//                       final docs = snapshot.data!.docs;
//
//                       if (docs.isEmpty) {
//                         return const Padding(
//                           padding: EdgeInsets.all(10),
//                           child: Text("No places found"),
//                         );
//                       }
//
//                       return ListView.builder(
//                         shrinkWrap: true,
//                         itemCount: docs.length,
//                         itemBuilder: (context, index) {
//                           final data = docs[index].data()
//                           as Map<String, dynamic>;
//
//                           return ListTile(
//                             title: Text(data["name"]),
//                             onTap: () {
//                               setState(() {
//                                 selectedPlace = data;
//                                 _searchController.text =
//                                 data["name"];
//                               });
//                             },
//                           );
//                         },
//                       );
//                     },
//                   ),
//                 ),
//             ],
//
//             const SizedBox(height: 10),
//
//             Row(
//               children: [
//                 Checkbox(
//                   value: _manualMode,
//                   onChanged: (value) {
//                     setState(() {
//                       _manualMode = value!;
//                       selectedPlace = null;
//                       _searchController.clear();
//                     });
//                   },
//                 ),
//                 const Text("Enter Latitude/Longitude Manually"),
//               ],
//             ),
//
//             if (_manualMode) ...[
//               const SizedBox(height: 10),
//               TextField(
//                 controller: _manualLatController,
//                 keyboardType:
//                 const TextInputType.numberWithOptions(decimal: true),
//                 decoration: const InputDecoration(
//                   labelText: "Latitude",
//                   border: OutlineInputBorder(),
//                 ),
//               ),
//               const SizedBox(height: 16),
//               TextField(
//                 controller: _manualLonController,
//                 keyboardType:
//                 const TextInputType.numberWithOptions(decimal: true),
//                 decoration: const InputDecoration(
//                   labelText: "Longitude",
//                   border: OutlineInputBorder(),
//                 ),
//               ),
//             ],
//
//             const SizedBox(height: 16),
//
//             TextField(
//               controller: _personController,
//               decoration: const InputDecoration(
//                 labelText: "Person (self or userId)",
//                 border: OutlineInputBorder(),
//               ),
//             ),
//
//             const SizedBox(height: 20),
//
//             if (_message.isNotEmpty)
//               Text(
//                 _message,
//                 style: TextStyle(
//                   color: _message.contains("❌")
//                       ? Colors.red
//                       : Colors.green,
//                 ),
//               ),
//
//             const SizedBox(height: 10),
//
//             ElevatedButton(
//               onPressed: _loading ? null : _createReminder,
//               child: _loading
//                   ? const CircularProgressIndicator(color: Colors.white)
//                   : const Text("Create Reminder"),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:math' as math;
//added by codex
import '../main.dart';

class CreateReminderScreen extends StatefulWidget {
  const CreateReminderScreen({Key? key}) : super(key: key);

  @override
  State<CreateReminderScreen> createState() => _CreateReminderScreenState();
}

class _CreateReminderScreenState extends State<CreateReminderScreen>
    with TickerProviderStateMixin {
  // ── Original variables (UNCHANGED) ──────────────────────────────────────
  final _descriptionController = TextEditingController();
  final _personController = TextEditingController();
  final _manualLatController = TextEditingController();
  final _manualLonController = TextEditingController();
  final _searchController = TextEditingController();

  bool _loading = false;
  bool _manualMode = false;
  String _message = "";

  Map<String, dynamic>? selectedPlace;

  // ── UI-only additions ────────────────────────────────────────────────────
  final _formKey = GlobalKey<FormState>();
  bool _createSuccess = false;

  late AnimationController _masterController;
  late AnimationController _orbController;
  late AnimationController _shakeController;
  late AnimationController _successController;
  late AnimationController _placeSelectController;

  late Animation<double> _fadeIn;
  late Animation<Offset> _cardSlide;
  late Animation<double> _cardScale;
  late Animation<double> _orbRotate;
  late Animation<double> _shakeAnim;
  late Animation<double> _successScale;
  late Animation<double> _successOpacity;
  late Animation<double> _placeSelectScale;

  final FocusNode _descFocus = FocusNode();
  final FocusNode _searchFocus = FocusNode();
  final FocusNode _latFocus = FocusNode();
  final FocusNode _lonFocus = FocusNode();
  final FocusNode _personFocus = FocusNode();

  final Map<FocusNode, bool> _focused = {};

  // ── Light theme palette ──────────────────────────────────────────────────
  static const _accent = Color(0xFF2563EB); // vivid blue
  static const _accentLight = Color(0xFF60A5FA); // sky blue
  static const _accentGlow = Color(0xFFBAE6FD); // pale glow
  static const _bg = Color(0xFFF0F6FF); // off-white blue tint
  static const _surface = Colors.white;
  static const _textPrimary = Color(0xFF0F172A);
  static const _textSecondary = Color(0xFF64748B);
  static const _border = Color(0xFFE2E8F0);
  static const _errorColor = Color(0xFFDC2626);
  static const _successColor = Color(0xFF16A34A);

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
    _shakeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 480),
    );
    _successController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 550),
    );
    _placeSelectController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 320),
    );

    _fadeIn = CurvedAnimation(
      parent: _masterController,
      curve: const Interval(0.0, 0.55, curve: Curves.easeOut),
    );
    _cardSlide = Tween<Offset>(
      begin: const Offset(0, 0.13),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _masterController,
      curve: const Interval(0.15, 0.8, curve: Curves.easeOutCubic),
    ));
    _cardScale = Tween<double>(begin: 0.95, end: 1.0).animate(
      CurvedAnimation(
        parent: _masterController,
        curve: const Interval(0.15, 0.8, curve: Curves.easeOutCubic),
      ),
    );
    _orbRotate = Tween<double>(begin: 0, end: 2 * math.pi).animate(
        CurvedAnimation(parent: _orbController, curve: Curves.linear));
    _shakeAnim = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _shakeController, curve: Curves.elasticIn),
    );
    _successScale = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(parent: _successController, curve: Curves.elasticOut),
    );
    _successOpacity = CurvedAnimation(
      parent: _successController,
      curve: const Interval(0.0, 0.4),
    );
    _placeSelectScale = Tween<double>(begin: 0.92, end: 1.0).animate(
      CurvedAnimation(parent: _placeSelectController, curve: Curves.easeOut),
    );

    for (final fn in [
      _descFocus,
      _searchFocus,
      _latFocus,
      _lonFocus,
      _personFocus
    ]) {
      _focused[fn] = false;
      fn.addListener(() => setState(() => _focused[fn] = fn.hasFocus));
    }

    _masterController.forward();
  }

  @override
  void dispose() {
    _masterController.dispose();
    _orbController.dispose();
    _shakeController.dispose();
    _successController.dispose();
    _placeSelectController.dispose();
    _descriptionController.dispose();
    _personController.dispose();
    _manualLatController.dispose();
    _manualLonController.dispose();
    _searchController.dispose();
    _descFocus.dispose();
    _searchFocus.dispose();
    _latFocus.dispose();
    _lonFocus.dispose();
    _personFocus.dispose();
    super.dispose();
  }

  // ── Original backend methods (UNCHANGED) ──────────────────────────────────
  Stream<QuerySnapshot> _searchPlaces(String query) {
    return FirebaseFirestore.instance
        .collection("places")
        .where("name_lower", isGreaterThanOrEqualTo: query.toLowerCase())
        .where("name_lower",
        isLessThanOrEqualTo: query.toLowerCase() + '\uf8ff')
        .snapshots();
  }

  Future<void> _createReminder() async {
    setState(() {
      _loading = true;
      _message = "";
    });

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        setState(() => _message = "User not logged in");
        _triggerShake();
        return;
      }

      String targetUserId =
      (_personController.text.trim().isEmpty || _personController.text == "self")
          ? user.uid
          : _personController.text.trim();

      if (selectedPlace == null) {
        setState(() {
          _message = "Please select a place";
          _loading = false;
        });
        _triggerShake();
        return;
      }

      final latitude = selectedPlace!["latitude"];
      final longitude = selectedPlace!["longitude"];
      final locationName = selectedPlace!["name"];

      await FirebaseFirestore.instance.collection("reminders").add({
        "creatorUserId": user.uid,
        "userId": targetUserId,
        "personName": _personController.text == "self"
            ? "Self"
            : _personController.text,

        "description": _descriptionController.text.trim(),
        "locationName": locationName,
        "latitude": latitude,
        "longitude": longitude,

        "status": "pending",

        "approvalStatus":
        targetUserId == user.uid ? "accepted" : "pending",

        "createdAt": FieldValue.serverTimestamp(),
      });

      await FirebaseFirestore.instance.collection("users").doc(user.uid).update({
        "pendingReminders": FieldValue.increment(1),
      });
      await debugDriver.syncAndRefreshCache(); //added codex

      setState(() {
        _message = "✅ Reminder Created Successfully";
        _createSuccess = true;
        selectedPlace = null;
        _searchController.clear();
      });

      await _successController.forward();
      HapticFeedback.lightImpact();
      await Future.delayed(const Duration(milliseconds: 400));

      // Clear form
      _descriptionController.clear();
      _personController.clear();

      if (mounted) {
        setState(() => _createSuccess = false);
        _successController.reset();
      }
    } catch (e) {
      setState(() {
        _message = "❌ Failed to create reminder";
      });
      _triggerShake();
      HapticFeedback.mediumImpact();
    } finally {
      setState(() {
        _loading = false;
      });
    }
  }

  void _triggerShake() {
    _shakeController.forward(from: 0).then((_) => _shakeController.reverse());
  }

  // ── Build ─────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark,
      child: Scaffold(
        backgroundColor: _bg,
        body: Stack(
          children: [
            _buildAnimatedBackground(size),
            SafeArea(
              child: FadeTransition(
                opacity: _fadeIn,
                child: SlideTransition(
                  position: _cardSlide,
                  child: ScaleTransition(
                    scale: _cardScale,
                    child: Column(
                      children: [
                        _buildTopBar(),
                        Expanded(
                          child: SingleChildScrollView(
                            physics: const BouncingScrollPhysics(),
                            padding: const EdgeInsets.fromLTRB(20, 4, 20, 20),
                            child: Form(
                              key: _formKey,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  _buildMainCard(),
                                  const SizedBox(height: 14),
                                  _buildLocationCard(),
                                  const SizedBox(height: 14),
                                  _buildPersonCard(),
                                  const SizedBox(height: 18),
                                  _buildCreateButton(),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Animated background ────────────────────────────────────────────────────
  Widget _buildAnimatedBackground(Size size) {
    return AnimatedBuilder(
      animation: _orbRotate,
      builder: (_, __) => CustomPaint(
        size: size,
        painter: _LightBackgroundPainter(rotation: _orbRotate.value),
      ),
    );
  }

  // ── Top bar ───────────────────────────────────────────────────────────────
  Widget _buildTopBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(22, 14, 22, 10),
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
                  "New Reminder",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: _textPrimary,
                    letterSpacing: -0.5,
                  ),
                ),
                Text(
                  "Set up your location reminder",
                  style: TextStyle(fontSize: 12, color: _textSecondary),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── Main description card ──────────────────────────────────────────────────
  Widget _buildMainCard() {
    return AnimatedBuilder(
      animation: _shakeAnim,
      builder: (_, child) {
        final shake = math.sin(_shakeAnim.value * math.pi * 6) * 7;
        return Transform.translate(offset: Offset(shake, 0), child: child);
      },
      child: Container(
        decoration: BoxDecoration(
          color: _surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: _border, width: 1.0),
          boxShadow: [
            BoxShadow(
              color: _accent.withOpacity(0.06),
              blurRadius: 28,
              spreadRadius: 0,
              offset: const Offset(0, 8),
            ),
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        _accent.withOpacity(0.13),
                        _accentLight.withOpacity(0.09),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: _accent.withOpacity(0.18)),
                  ),
                  child: const Icon(Icons.description_outlined,
                      color: _accent, size: 18),
                ),
                const SizedBox(width: 10),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Reminder Details",
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: _textPrimary,
                        ),
                      ),
                      Text(
                        "What do you need to remember?",
                        style: TextStyle(fontSize: 11, color: _textSecondary),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            const Divider(color: _border, height: 1),
            const SizedBox(height: 14),
            _buildInputField(
              controller: _descriptionController,
              focusNode: _descFocus,
              label: "Description",
              hint: "e.g., Buy groceries, Pick up package...",
              icon: Icons.edit_note_rounded,
              maxLines: 2,
            ),
          ],
        ),
      ),
    );
  }

  // ── Location card ──────────────────────────────────────────────────────────
  Widget _buildLocationCard() {
    return Container(
      decoration: BoxDecoration(
        color: _surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _border, width: 1.0),
        boxShadow: [
          BoxShadow(
            color: _accent.withOpacity(0.06),
            blurRadius: 28,
            spreadRadius: 0,
            offset: const Offset(0, 8),
          ),
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      _accent.withOpacity(0.13),
                      _accentLight.withOpacity(0.09),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: _accent.withOpacity(0.18)),
                ),
                child: const Icon(Icons.location_on_outlined,
                    color: _accent, size: 18),
              ),
              const SizedBox(width: 10),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Location",
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: _textPrimary,
                      ),
                    ),
                    Text(
                      "Where should we remind you?",
                      style: TextStyle(fontSize: 11, color: _textSecondary),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          const Divider(color: _border, height: 1),
          const SizedBox(height: 14),
          _buildInputField(
            controller: _searchController,
            focusNode: _searchFocus,
            label: "Search Place",
            hint: "Type to search locations...",
            icon: Icons.search_rounded,
            onChanged: (_) => setState(() {}),
          ),
          const SizedBox(height: 10),
          if (_searchController.text.isNotEmpty) _buildPlaceResults(),
          if (selectedPlace != null) ...[
            const SizedBox(height: 10),
            _buildSelectedPlace(),
          ],
        ],
      ),
    );
  }

  // ── Person card ────────────────────────────────────────────────────────────
  Widget _buildPersonCard() {
    return Container(
      decoration: BoxDecoration(
        color: _surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _border, width: 1.0),
        boxShadow: [
          BoxShadow(
            color: _accent.withOpacity(0.06),
            blurRadius: 28,
            spreadRadius: 0,
            offset: const Offset(0, 8),
          ),
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      _accent.withOpacity(0.13),
                      _accentLight.withOpacity(0.09),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: _accent.withOpacity(0.18)),
                ),
                child: const Icon(Icons.person_outline_rounded,
                    color: _accent, size: 18),
              ),
              const SizedBox(width: 10),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "For Whom",
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: _textPrimary,
                      ),
                    ),
                    Text(
                      "Who is this reminder for?",
                      style: TextStyle(fontSize: 11, color: _textSecondary),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          const Divider(color: _border, height: 1),
          const SizedBox(height: 14),
          _buildPersonDropdown()
        ],
      ),
    );
  }
  Widget _buildPersonDropdown() {
    final uid = FirebaseAuth.instance.currentUser!.uid;

    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance
          .collection("users")
          .doc(uid)
          .snapshots(),
      builder: (context, snapshot) {

        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final data = snapshot.data!.data() as Map<String, dynamic>;
        List friends = data["friends"] ?? [];

        return FutureBuilder<QuerySnapshot>(
          future: friends.isEmpty
              ? FirebaseFirestore.instance
              .collection("users")
              .where(FieldPath.documentId, whereIn: ["dummy"])
              .get()
              : FirebaseFirestore.instance
              .collection("users")
              .where(FieldPath.documentId, whereIn: friends)
              .get(),
          builder: (context, friendSnapshot) {

            List<DropdownMenuItem<String>> items = [];

            // SELF option
            items.add(
              const DropdownMenuItem(
                value: "self",
                child: Text("Self"),
              ),
            );

            if (friendSnapshot.hasData) {
              for (var doc in friendSnapshot.data!.docs) {

                final friend =
                doc.data() as Map<String, dynamic>;

                final name = friend["name"] ?? "Unknown";
                final phone = friend["phone"] ?? "";

                items.add(
                  DropdownMenuItem(
                    value: doc.id,
                    child: Text("$name • $phone"),
                  ),
                );
              }
            }

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [

                const Text(
                  "PERSON",
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: _textSecondary,
                    letterSpacing: 0.7,
                  ),
                ),

                const SizedBox(height: 7),

                Container(
                  padding:
                  const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(13),
                    border: Border.all(color: _border),
                    color: const Color(0xFFF8FAFC),
                  ),
                  child: DropdownButtonFormField<String>(

                    value: _personController.text.isEmpty
                        ? "self"
                        : _personController.text,

                    decoration: const InputDecoration(
                      border: InputBorder.none,
                    ),

                    items: items,

                    onChanged: (value) {
                      setState(() {
                        _personController.text = value ?? "self";
                      });
                    },
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }
  // ── Place search results ───────────────────────────────────────────────────
  Widget _buildPlaceResults() {
    return Container(
      constraints: const BoxConstraints(maxHeight: 180),
      decoration: BoxDecoration(
        color: _bg,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: _border),
      ),
      child: StreamBuilder<QuerySnapshot>(
        stream: _searchPlaces(_searchController.text),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(20),
                child: CircularProgressIndicator(
                  strokeWidth: 2.5,
                  valueColor: AlwaysStoppedAnimation<Color>(_accent),
                ),
              ),
            );
          }

          final docs = snapshot.data!.docs;

          if (docs.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 56,
                      height: 56,
                      decoration: BoxDecoration(
                        color: _accent.withOpacity(0.08),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(Icons.search_off_rounded,
                          color: _accent.withOpacity(0.5), size: 26),
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      "No places found",
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: _textSecondary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      "Try a different search term",
                      style: TextStyle(fontSize: 12, color: _textSecondary),
                    ),
                  ],
                ),
              ),
            );
          }

          return ClipRRect(
            borderRadius: BorderRadius.circular(14),
            child: ListView.separated(
              shrinkWrap: true,
              padding: const EdgeInsets.symmetric(vertical: 8),
              itemCount: docs.length,
              separatorBuilder: (_, __) => Divider(
                color: _border,
                height: 1,
                indent: 56,
                endIndent: 16,
              ),
              itemBuilder: (context, index) {
                final data = docs[index].data() as Map<String, dynamic>;
                return Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () {
                      setState(() {
                        selectedPlace = data;
                        _searchController.text = data["name"];
                      });
                      _placeSelectController.forward(from: 0);
                      HapticFeedback.selectionClick();
                    },
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 12),
                      child: Row(
                        children: [
                          Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: _accent.withOpacity(0.10),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Icon(Icons.place_rounded,
                                color: _accent, size: 20),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  data["name"],
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: _textPrimary,
                                  ),
                                ),
                                Text(
                                  "${data["latitude"].toStringAsFixed(4)}, ${data["longitude"].toStringAsFixed(4)}",
                                  style: const TextStyle(
                                    fontSize: 11,
                                    color: _textSecondary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Icon(Icons.arrow_forward_ios_rounded,
                              size: 14, color: _textSecondary.withOpacity(0.5)),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }

  // ── Selected place display ─────────────────────────────────────────────────
  Widget _buildSelectedPlace() {
    return ScaleTransition(
      scale: _placeSelectScale,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              _successColor.withOpacity(0.08),
              _successColor.withOpacity(0.05),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: _successColor.withOpacity(0.25)),
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: _successColor.withOpacity(0.15),
                borderRadius: BorderRadius.circular(11),
              ),
              child: const Icon(Icons.check_circle_rounded,
                  color: _successColor, size: 20),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Selected Location",
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      color: _successColor,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    selectedPlace!["name"],
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: _textPrimary,
                    ),
                  ),
                  Text(
                    "${selectedPlace!["latitude"].toStringAsFixed(5)}, ${selectedPlace!["longitude"].toStringAsFixed(5)}",
                    style: const TextStyle(fontSize: 10, color: _textSecondary),
                  ),
                ],
              ),
            ),
            GestureDetector(
              onTap: () => setState(() {
                selectedPlace = null;
                _searchController.clear();
              }),
              child: Container(
                padding: const EdgeInsets.all(5),
                decoration: BoxDecoration(
                  color: _errorColor.withOpacity(0.12),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.close_rounded,
                    color: _errorColor, size: 14),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Input field helper ─────────────────────────────────────────────────────
  Widget _buildInputField({
    required TextEditingController controller,
    required FocusNode focusNode,
    required String label,
    required String hint,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    int maxLines = 1,
    void Function(String)? onChanged,
  }) {
    final focused = _focused[focusNode] ?? false;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AnimatedDefaultTextStyle(
          duration: const Duration(milliseconds: 180),
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.7,
            color: focused ? _accent : _textSecondary,
          ),
          child: Text(label.toUpperCase()),
        ),
        const SizedBox(height: 7),
        AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(13),
            color: focused ? _accent.withOpacity(0.04) : const Color(0xFFF8FAFC),
            border: Border.all(
              color: focused ? _accent : _border,
              width: focused ? 1.5 : 1.0,
            ),
          ),
          child: TextField(
            controller: controller,
            focusNode: focusNode,
            keyboardType: keyboardType,
            maxLines: maxLines,
            onChanged: onChanged,
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
                fontWeight: FontWeight.w400,
              ),
              prefixIcon: Icon(
                icon,
                size: 19,
                color: focused ? _accent : const Color(0xFFCBD5E1),
              ),
              border: InputBorder.none,
              contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
            ),
          ),
        ),
      ],
    );
  }

  // ── Create button ──────────────────────────────────────────────────────────
  Widget _buildCreateButton() {
    return Column(
      children: [
        AnimatedSize(
          duration: const Duration(milliseconds: 280),
          curve: Curves.easeOutCubic,
          child: _message.isNotEmpty
              ? Padding(
            padding: const EdgeInsets.only(bottom: 14),
            child: _buildMessageBanner(),
          )
              : const SizedBox.shrink(),
        ),
        LayoutBuilder(
          builder: (context, constraints) {
            final fullWidth = constraints.maxWidth;
            return AnimatedContainer(
              duration: const Duration(milliseconds: 380),
              curve: Curves.easeInOutCubic,
              width: _loading ? 50 : fullWidth,
              height: 50,
              alignment: Alignment.center,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 380),
                curve: Curves.easeInOutCubic,
                width: _loading ? 50 : fullWidth,
                height: 50,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(_loading ? 25 : 13),
                  gradient: _createSuccess
                      ? const LinearGradient(
                      colors: [_successColor, Color(0xFF4ADE80)])
                      : const LinearGradient(
                    colors: [_accent, Color(0xFF3B82F6)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: (_createSuccess ? _successColor : _accent)
                          .withOpacity(0.32),
                      blurRadius: 18,
                      offset: const Offset(0, 7),
                    ),
                  ],
                ),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(_loading ? 25 : 13),
                    onTap: _loading ? null : _createReminder,
                    splashColor: Colors.white.withOpacity(0.18),
                    child: Center(child: _buildButtonContent()),
                  ),
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildButtonContent() {
    if (_createSuccess) {
      return ScaleTransition(
        scale: _successScale,
        child: FadeTransition(
          opacity: _successOpacity,
          child: const Icon(Icons.check_rounded, color: Colors.white, size: 26),
        ),
      );
    }
    if (_loading) {
      return const SizedBox(
        width: 22,
        height: 22,
        child: CircularProgressIndicator(
          strokeWidth: 2.5,
          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
        ),
      );
    }
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: const [
        Icon(Icons.add_circle_outline_rounded, color: Colors.white, size: 19),
        SizedBox(width: 8),
        Text(
          "Create Reminder",
          style: TextStyle(
            color: Colors.white,
            fontSize: 15,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.3,
          ),
        ),
      ],
    );
  }

  // ── Message banner ─────────────────────────────────────────────────────────
  Widget _buildMessageBanner() {
    final isSuccess = _message.contains("✅");
    final color = isSuccess ? _successColor : _errorColor;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(13),
        color: color.withOpacity(0.08),
        border: Border.all(color: color.withOpacity(0.25)),
      ),
      child: Row(
        children: [
          Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: color.withOpacity(0.15),
            ),
            child: Icon(
              isSuccess ? Icons.check_circle_rounded : Icons.warning_amber_rounded,
              color: color,
              size: 16,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              _message.replaceAll("✅ ", "").replaceAll("❌ ", ""),
              style: TextStyle(
                color: color,
                fontSize: 13,
                fontWeight: FontWeight.w600,
                height: 1.4,
              ),
            ),
          ),
          GestureDetector(
            onTap: () => setState(() => _message = ""),
            child: Icon(Icons.close_rounded, color: color.withOpacity(0.5), size: 16),
          ),
        ],
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