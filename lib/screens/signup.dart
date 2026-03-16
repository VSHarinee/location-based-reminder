// import 'package:flutter/material.dart';
// import 'package:firebase_auth/firebase_auth.dart';
//
// class SignupScreen extends StatefulWidget {
//   const SignupScreen({Key? key}) : super(key: key);
//
//   @override
//   State<SignupScreen> createState() => _SignupScreenState();
// }
//
// class _SignupScreenState extends State<SignupScreen> {
//   final TextEditingController _emailController = TextEditingController();
//   final TextEditingController _passwordController = TextEditingController();
//   final TextEditingController _confirmPasswordController =
//   TextEditingController();
//
//   bool _loading = false;
//   String _error = "";
//
//   Future<void> _signup() async {
//     if (_passwordController.text != _confirmPasswordController.text) {
//       setState(() {
//         _error = "Passwords do not match";
//       });
//       return;
//     }
//
//     setState(() {
//       _loading = true;
//       _error = "";
//     });
//
//     try {
//       await FirebaseAuth.instance.createUserWithEmailAndPassword(
//         email: _emailController.text.trim(),
//         password: _passwordController.text.trim(),
//       );
//
//       debugPrint("✅ User registered");
//
//       Navigator.pop(context); // back to login
//     } on FirebaseAuthException catch (e) {
//       setState(() {
//         _error = e.message ?? "Signup failed";
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
//     return Scaffold(
//       appBar: AppBar(title: const Text("Sign Up")),
//       body: Padding(
//         padding: const EdgeInsets.all(20),
//         child: Column(
//           children: [
//             TextField(
//               controller: _emailController,
//               keyboardType: TextInputType.emailAddress,
//               decoration: const InputDecoration(
//                 labelText: "Email",
//                 border: OutlineInputBorder(),
//               ),
//             ),
//             const SizedBox(height: 16),
//
//             TextField(
//               controller: _passwordController,
//               obscureText: true,
//               decoration: const InputDecoration(
//                 labelText: "Password",
//                 border: OutlineInputBorder(),
//               ),
//             ),
//             const SizedBox(height: 16),
//
//             TextField(
//               controller: _confirmPasswordController,
//               obscureText: true,
//               decoration: const InputDecoration(
//                 labelText: "Confirm Password",
//                 border: OutlineInputBorder(),
//               ),
//             ),
//             const SizedBox(height: 20),
//
//             if (_error.isNotEmpty)
//               Text(
//                 _error,
//                 style: const TextStyle(color: Colors.red),
//               ),
//
//             const SizedBox(height: 10),
//
//             ElevatedButton(
//               onPressed: _loading ? null : _signup,
//               child: _loading
//                   ? const CircularProgressIndicator()
//                   : const Text("Create Account"),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
// import 'package:flutter/material.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
//
// class SignupScreen extends StatefulWidget {
//   const SignupScreen({Key? key}) : super(key: key);
//
//   @override
//   State<SignupScreen> createState() => _SignupScreenState();
// }
//
// class _SignupScreenState extends State<SignupScreen> {
//   final _emailController = TextEditingController();
//   final _passwordController = TextEditingController();
//   final _confirmPasswordController = TextEditingController();
//
//   final _nameController = TextEditingController();
//   final _phoneController = TextEditingController();
//   final _cityController = TextEditingController();
//   final _stateController = TextEditingController();
//   final _countryController = TextEditingController();
//   final _ageController = TextEditingController();
//
//   bool _loading = false;
//   String _error = "";
//
//   Future<void> _signup() async {
//     if (_passwordController.text != _confirmPasswordController.text) {
//       setState(() => _error = "Passwords do not match");
//       return;
//     }
//
//     setState(() {
//       _loading = true;
//       _error = "";
//     });
//
//     try {
//       // 1️⃣ Create Auth user
//       UserCredential userCredential =
//       await FirebaseAuth.instance.createUserWithEmailAndPassword(
//         email: _emailController.text.trim(),
//         password: _passwordController.text.trim(),
//       );
//
//       String uid = userCredential.user!.uid;
//
//       // 2️⃣ Store user data in Firestore
//       await FirebaseFirestore.instance.collection("users").doc(uid).set({
//         "name": _nameController.text.trim(),
//         "phone": _phoneController.text.trim(),
//         "city": _cityController.text.trim(),
//         "state": _stateController.text.trim(),
//         "country": _countryController.text.trim(),
//         "age": int.tryParse(_ageController.text.trim()) ?? 0,
//         "friends": [],
//         "noOfFriends": 0,
//         "pendingReminders": 0,
//         "createdAt": FieldValue.serverTimestamp(),
//       });
//
//       debugPrint("✅ User registered and stored in Firestore");
//
//       Navigator.pop(context);
//
//     } on FirebaseAuthException catch (e) {
//       setState(() => _error = e.message ?? "Signup failed");
//     } catch (e) {
//       setState(() => _error = "Something went wrong");
//     } finally {
//       setState(() => _loading = false);
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: const Text("Sign Up")),
//       body: SingleChildScrollView(
//         padding: const EdgeInsets.all(20),
//         child: Column(
//           children: [
//
//             TextField(
//               controller: _nameController,
//               decoration: const InputDecoration(
//                 labelText: "Name",
//                 border: OutlineInputBorder(),
//               ),
//             ),
//             const SizedBox(height: 16),
//
//             TextField(
//               controller: _phoneController,
//               keyboardType: TextInputType.phone,
//               decoration: const InputDecoration(
//                 labelText: "Phone",
//                 border: OutlineInputBorder(),
//               ),
//             ),
//             const SizedBox(height: 16),
//
//             TextField(
//               controller: _cityController,
//               decoration: const InputDecoration(
//                 labelText: "City",
//                 border: OutlineInputBorder(),
//               ),
//             ),
//             const SizedBox(height: 16),
//
//             TextField(
//               controller: _stateController,
//               decoration: const InputDecoration(
//                 labelText: "State",
//                 border: OutlineInputBorder(),
//               ),
//             ),
//             const SizedBox(height: 16),
//
//             TextField(
//               controller: _countryController,
//               decoration: const InputDecoration(
//                 labelText: "Country",
//                 border: OutlineInputBorder(),
//               ),
//             ),
//             const SizedBox(height: 16),
//
//             TextField(
//               controller: _ageController,
//               keyboardType: TextInputType.number,
//               decoration: const InputDecoration(
//                 labelText: "Age",
//                 border: OutlineInputBorder(),
//               ),
//             ),
//             const SizedBox(height: 16),
//
//             TextField(
//               controller: _emailController,
//               keyboardType: TextInputType.emailAddress,
//               decoration: const InputDecoration(
//                 labelText: "Email",
//                 border: OutlineInputBorder(),
//               ),
//             ),
//             const SizedBox(height: 16),
//
//             TextField(
//               controller: _passwordController,
//               obscureText: true,
//               decoration: const InputDecoration(
//                 labelText: "Password",
//                 border: OutlineInputBorder(),
//               ),
//             ),
//             const SizedBox(height: 16),
//
//             TextField(
//               controller: _confirmPasswordController,
//               obscureText: true,
//               decoration: const InputDecoration(
//                 labelText: "Confirm Password",
//                 border: OutlineInputBorder(),
//               ),
//             ),
//             const SizedBox(height: 20),
//
//             if (_error.isNotEmpty)
//               Text(_error, style: const TextStyle(color: Colors.red)),
//
//             const SizedBox(height: 10),
//
//             ElevatedButton(
//               onPressed: _loading ? null : _signup,
//               child: _loading
//                   ? const CircularProgressIndicator(color: Colors.white)
//                   : const Text("Create Account"),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:math' as math;

class SignupScreen extends StatefulWidget {
  const SignupScreen({Key? key}) : super(key: key);

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen>
    with TickerProviderStateMixin {

  // ── Original variables (UNCHANGED) ──────────────────────────────────────
  final _emailController           = TextEditingController();
  final _passwordController        = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _nameController            = TextEditingController();
  final _phoneController           = TextEditingController();
  final _cityController            = TextEditingController();
  final _stateController           = TextEditingController();
  final _countryController         = TextEditingController();
  final _ageController             = TextEditingController();
  bool   _loading = false;
  String _error   = "";

  // ── UI-only additions ────────────────────────────────────────────────────
  final _formKey      = GlobalKey<FormState>();
  int  _currentStep   = 0;
  bool _obscurePass    = true;
  bool _obscureConfirm = true;
  bool _signupSuccess  = false;

  late AnimationController _masterController;
  late AnimationController _orbController;
  late AnimationController _shakeController;
  late AnimationController _successController;
  late AnimationController _stepController;

  late Animation<double> _fadeIn;
  late Animation<Offset> _cardSlide;
  late Animation<double> _cardScale;
  late Animation<double> _orbRotate;
  late Animation<double> _shakeAnim;
  late Animation<double> _successScale;
  late Animation<double> _successOpacity;
  late Animation<double> _stepFade;
  late Animation<Offset>  _stepSlide;

  final _nameFocus    = FocusNode();
  final _phoneFocus   = FocusNode();
  final _ageFocus     = FocusNode();
  final _cityFocus    = FocusNode();
  final _stateFocus   = FocusNode();
  final _countryFocus = FocusNode();
  final _emailFocus   = FocusNode();
  final _passFocus    = FocusNode();
  final _confirmFocus = FocusNode();
  final Map<FocusNode, bool> _focused = {};

  // ── Light theme palette ──────────────────────────────────────────────────
  static const _accent        = Color(0xFF2563EB);
  static const _accentLight   = Color(0xFF60A5FA);
  static const _bg            = Color(0xFFF0F6FF);
  static const _surface       = Colors.white;
  static const _textPrimary   = Color(0xFF0F172A);
  static const _textSecondary = Color(0xFF64748B);
  static const _border        = Color(0xFFE2E8F0);
  static const _errorColor    = Color(0xFFDC2626);
  static const _successColor  = Color(0xFF16A34A);

  final _steps = const [
    {'title': 'Personal', 'subtitle': 'Tell us about yourself'},
    {'title': 'Location', 'subtitle': 'Where are you based?'},
    {'title': 'Account',  'subtitle': 'Secure your account'},
  ];

  final _stepIcons = const [
    Icons.person_outline_rounded,
    Icons.location_on_outlined,
    Icons.shield_outlined,
  ];

  @override
  void initState() {
    super.initState();

    _masterController  = AnimationController(vsync: this,
        duration: const Duration(milliseconds: 1100));
    _orbController     = AnimationController(vsync: this,
        duration: const Duration(seconds: 14))..repeat();
    _shakeController   = AnimationController(vsync: this,
        duration: const Duration(milliseconds: 480));
    _successController = AnimationController(vsync: this,
        duration: const Duration(milliseconds: 580));
    _stepController    = AnimationController(vsync: this,
        duration: const Duration(milliseconds: 360));

    _fadeIn = CurvedAnimation(
        parent: _masterController,
        curve: const Interval(0.0, 0.55, curve: Curves.easeOut));

    _cardSlide = Tween<Offset>(
        begin: const Offset(0, 0.13), end: Offset.zero)
        .animate(CurvedAnimation(
        parent: _masterController,
        curve: const Interval(0.15, 0.8, curve: Curves.easeOutCubic)));

    _cardScale = Tween<double>(begin: 0.95, end: 1.0)
        .animate(CurvedAnimation(
        parent: _masterController,
        curve: const Interval(0.15, 0.8, curve: Curves.easeOutCubic)));

    _orbRotate = Tween<double>(begin: 0, end: 2 * math.pi)
        .animate(CurvedAnimation(
        parent: _orbController, curve: Curves.linear));

    _shakeAnim = Tween<double>(begin: 0, end: 1)
        .animate(CurvedAnimation(
        parent: _shakeController, curve: Curves.elasticIn));

    _successScale = Tween<double>(begin: 0.5, end: 1.0)
        .animate(CurvedAnimation(
        parent: _successController, curve: Curves.elasticOut));

    _successOpacity = CurvedAnimation(
        parent: _successController,
        curve: const Interval(0.0, 0.4));

    _stepFade = CurvedAnimation(
        parent: _stepController, curve: Curves.easeOut);

    _stepSlide = Tween<Offset>(
        begin: const Offset(0.07, 0), end: Offset.zero)
        .animate(CurvedAnimation(
        parent: _stepController, curve: Curves.easeOutCubic));

    for (final fn in [
      _nameFocus, _phoneFocus, _ageFocus, _cityFocus,
      _stateFocus, _countryFocus, _emailFocus, _passFocus, _confirmFocus
    ]) {
      _focused[fn] = false;
      fn.addListener(() => setState(() => _focused[fn] = fn.hasFocus));
    }

    _passwordController.addListener(() => setState(() {}));

    _masterController.forward();
    _stepController.forward();
  }

  @override
  void dispose() {
    for (final c in [
      _masterController, _orbController, _shakeController,
      _successController, _stepController
    ]) { c.dispose(); }

    for (final t in [
      _emailController, _passwordController, _confirmPasswordController,
      _nameController, _phoneController, _cityController,
      _stateController, _countryController, _ageController
    ]) { t.dispose(); }

    for (final fn in [
      _nameFocus, _phoneFocus, _ageFocus, _cityFocus,
      _stateFocus, _countryFocus, _emailFocus, _passFocus, _confirmFocus
    ]) { fn.dispose(); }

    super.dispose();
  }

  // ── Original _signup() — backend UNCHANGED ───────────────────────────────
  Future<void> _signup() async {
    if (_passwordController.text != _confirmPasswordController.text) {
      setState(() => _error = "Passwords do not match");
      _triggerShake();
      return;
    }

    setState(() { _loading = true; _error = ""; });

    try {
      // 1. Create Auth user
      UserCredential userCredential =
      await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      String uid = userCredential.user!.uid;

      // 2. Store user data in Firestore
      await FirebaseFirestore.instance.collection("users").doc(uid).set({
        "name":             _nameController.text.trim(),
        "phone":            _phoneController.text.trim(),
        "city":             _cityController.text.trim(),
        "state":            _stateController.text.trim(),
        "country":          _countryController.text.trim(),
        "age":              int.tryParse(_ageController.text.trim()) ?? 0,
        "friends":          [],
        "noOfFriends":      0,
        "pendingReminders": 0,
        "createdAt":        FieldValue.serverTimestamp(),
      });

      debugPrint("User registered and stored in Firestore");

      setState(() => _signupSuccess = true);
      await _successController.forward();
      await Future.delayed(const Duration(milliseconds: 420));

      if (!mounted) return;
      Navigator.pop(context);

    } on FirebaseAuthException catch (e) {
      setState(() => _error = _mapError(e.code));
      _triggerShake();
      HapticFeedback.mediumImpact();
    } catch (e) {
      setState(() => _error = "Something went wrong. Please try again.");
      _triggerShake();
    } finally {
      if (mounted) {
        setState(() { _loading = false; _signupSuccess = false; });
        _successController.reset();
      }
    }
  }

  void _triggerShake() =>
      _shakeController.forward(from: 0)
          .then((_) => _shakeController.reverse());

  String _mapError(String code) {
    switch (code) {
      case 'email-already-in-use':
        return 'An account already exists for this email.';
      case 'invalid-email':
        return 'Please enter a valid email address.';
      case 'weak-password':
        return 'Password must be at least 6 characters.';
      case 'network-request-failed':
        return 'Network error. Check your connection.';
      default:
        return 'Signup failed. Please try again.';
    }
  }

  // ── Step navigation ───────────────────────────────────────────────────────
  void _nextStep() {
    if (!_validateStep()) { _triggerShake(); return; }
    if (_currentStep < 2) {
      setState(() => _currentStep++);
      _stepController.forward(from: 0);
    } else {
      _signup();
    }
  }

  void _prevStep() {
    if (_currentStep > 0) {
      setState(() { _currentStep--; _error = ""; });
      _stepController.forward(from: 0);
    }
  }

  bool _validateStep() {
    switch (_currentStep) {
      case 0:
        if (_nameController.text.trim().isEmpty) {
          setState(() => _error = "Please enter your full name.");
          return false;
        }
        if (_ageController.text.trim().isEmpty) {
          setState(() => _error = "Please enter your age.");
          return false;
        }
        final age = int.tryParse(_ageController.text.trim());
        if (age == null || age < 1 || age > 120) {
          setState(() => _error = "Please enter a valid age.");
          return false;
        }
        break;
      case 1:
        if (_cityController.text.trim().isEmpty) {
          setState(() => _error = "Please enter your city.");
          return false;
        }
        if (_countryController.text.trim().isEmpty) {
          setState(() => _error = "Please enter your country.");
          return false;
        }
        break;
      case 2:
        if (!_formKey.currentState!.validate()) return false;
        break;
    }
    setState(() => _error = "");
    return true;
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
            AnimatedBuilder(
              animation: _orbRotate,
              builder: (_, __) => CustomPaint(
                size: size,
                painter: _LightBgPainter(rotation: _orbRotate.value),
              ),
            ),
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
                            padding:
                            const EdgeInsets.fromLTRB(22, 4, 22, 36),
                            child: Form(
                              key: _formKey,
                              child: Column(
                                crossAxisAlignment:
                                CrossAxisAlignment.stretch,
                                children: [
                                  _buildStepRail(),
                                  const SizedBox(height: 20),
                                  _buildCard(),
                                  const SizedBox(height: 18),
                                  _buildButtons(),
                                  const SizedBox(height: 18),
                                  _buildFooter(),
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

  // ── Top bar ───────────────────────────────────────────────────────────────
  Widget _buildTopBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(22, 14, 22, 10),
      child: Row(
        children: [
          _iconBtn(Icons.arrow_back_ios_new_rounded,
                  () => Navigator.pop(context)),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Create Account",
                  style: TextStyle(
                      fontSize: 19,
                      fontWeight: FontWeight.w800,
                      color: _textPrimary,
                      letterSpacing: -0.4),
                ),
                Text(
                  "Step ${_currentStep + 1} of 3 · "
                      "${_steps[_currentStep]['subtitle']}",
                  style: const TextStyle(
                      fontSize: 12, color: _textSecondary),
                ),
              ],
            ),
          ),
          Container(
            width: 40, height: 40,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                  colors: [_accent, _accentLight],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight),
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                    color: _accent.withOpacity(0.30),
                    blurRadius: 10,
                    offset: const Offset(0, 4))
              ],
            ),
            child: const Icon(Icons.my_location_rounded,
                color: Colors.white, size: 19),
          ),
        ],
      ),
    );
  }

  Widget _iconBtn(IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 40, height: 40,
        decoration: BoxDecoration(
          color: _surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: _border),
          boxShadow: [
            BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 6,
                offset: const Offset(0, 2))
          ],
        ),
        child: Icon(icon, size: 15, color: _textPrimary),
      ),
    );
  }

  // ── Step rail ─────────────────────────────────────────────────────────────
  Widget _buildStepRail() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      decoration: BoxDecoration(
        color: _surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: _border),
        boxShadow: [
          BoxShadow(
              color: _accent.withOpacity(0.05),
              blurRadius: 14,
              offset: const Offset(0, 4))
        ],
      ),
      child: Row(
        children: List.generate(_steps.length, (i) {
          final active   = i == _currentStep;
          final complete = i < _currentStep;
          return Expanded(
            child: Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: complete
                        ? () {
                      setState(() {
                        _currentStep = i;
                        _error = "";
                      });
                      _stepController.forward(from: 0);
                    }
                        : null,
                    child: Column(
                      children: [
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          width: 36, height: 36,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: complete
                                ? _successColor
                                : active ? _accent : _bg,
                            border: Border.all(
                              color: complete
                                  ? _successColor
                                  : active ? _accent : _border,
                              width: active ? 2 : 1,
                            ),
                            boxShadow: active
                                ? [BoxShadow(
                                color: _accent.withOpacity(0.28),
                                blurRadius: 10,
                                spreadRadius: 1)]
                                : null,
                          ),
                          child: Center(
                            child: complete
                                ? const Icon(Icons.check_rounded,
                                color: Colors.white, size: 16)
                                : Icon(_stepIcons[i],
                                size: 16,
                                color: active
                                    ? Colors.white
                                    : _textSecondary),
                          ),
                        ),
                        const SizedBox(height: 5),
                        AnimatedDefaultTextStyle(
                          duration: const Duration(milliseconds: 200),
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.4,
                            color: active
                                ? _accent
                                : complete
                                ? _successColor
                                : _textSecondary,
                          ),
                          child: Text(
                              (_steps[i]['title']!).toUpperCase()),
                        ),
                      ],
                    ),
                  ),
                ),
                if (i < _steps.length - 1)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 20),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 400),
                      width: 20, height: 2,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(2),
                        color: i < _currentStep
                            ? _successColor
                            : _border,
                      ),
                    ),
                  ),
              ],
            ),
          );
        }),
      ),
    );
  }

  // ── Main card ─────────────────────────────────────────────────────────────
  Widget _buildCard() {
    return AnimatedBuilder(
      animation: _shakeAnim,
      builder: (_, child) => Transform.translate(
        offset: Offset(
            math.sin(_shakeAnim.value * math.pi * 6) * 7, 0),
        child: child,
      ),
      child: FadeTransition(
        opacity: _stepFade,
        child: SlideTransition(
          position: _stepSlide,
          child: Container(
            decoration: BoxDecoration(
              color: _surface,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: _border),
              boxShadow: [
                BoxShadow(
                    color: _accent.withOpacity(0.06),
                    blurRadius: 32,
                    offset: const Offset(0, 10)),
                BoxShadow(
                    color: Colors.black.withOpacity(0.04),
                    blurRadius: 10,
                    offset: const Offset(0, 3)),
              ],
            ),
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    Container(
                      width: 42, height: 42,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(colors: [
                          _accent.withOpacity(0.13),
                          _accentLight.withOpacity(0.09),
                        ]),
                        borderRadius: BorderRadius.circular(13),
                        border: Border.all(
                            color: _accent.withOpacity(0.18)),
                      ),
                      child: Icon(_stepIcons[_currentStep],
                          color: _accent, size: 20),
                    ),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _steps[_currentStep]['title']!,
                          style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: _textPrimary),
                        ),
                        Text(
                          _steps[_currentStep]['subtitle']!,
                          style: const TextStyle(
                              fontSize: 12, color: _textSecondary),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                const Divider(color: _border, height: 1),
                const SizedBox(height: 20),
                ..._stepFields(),
                AnimatedSize(
                  duration: const Duration(milliseconds: 260),
                  curve: Curves.easeOutCubic,
                  child: _error.isNotEmpty
                      ? Padding(
                    padding: const EdgeInsets.only(top: 14),
                    child: _buildErrorBanner(),
                  )
                      : const SizedBox.shrink(),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ── Fields per step — BUG FIXED: switch keyword added, case 0 corrected ──
  List<Widget> _stepFields() {
    switch (_currentStep) {
      case 0:
        return [
          _field(_nameController, _nameFocus,
              "Full Name", "John Doe",
              Icons.badge_outlined),
          const SizedBox(height: 14),
          _field(_phoneController, _phoneFocus,
              "Phone Number", "+1 234 567 8900",
              Icons.phone_outlined,
              keyboard: TextInputType.phone),
          const SizedBox(height: 14),
          _field(_ageController, _ageFocus,
              "Age", "25",
              Icons.cake_outlined,
              keyboard: TextInputType.number),
        ];

      case 1:
        return [
          _field(_cityController, _cityFocus,
              "City", "New York",
              Icons.location_city_outlined),
          const SizedBox(height: 14),
          _field(_stateController, _stateFocus,
              "State / Province", "New York",
              Icons.map_outlined),
          const SizedBox(height: 14),
          _field(_countryController, _countryFocus,
              "Country", "United States",
              Icons.public_outlined),
        ];

      case 2:
        return [
          _field(
            _emailController, _emailFocus,
            "Email Address", "you@example.com",
            Icons.alternate_email_rounded,
            keyboard: TextInputType.emailAddress,
            validator: (v) {
              if (v == null || v.trim().isEmpty) {
                return 'Email is required';
              }
              if (!RegExp(r'^[^@]+@[^@]+\.[^@]+')
                  .hasMatch(v.trim())) {
                return 'Enter a valid email';
              }
              return null;
            },
          ),
          const SizedBox(height: 14),
          _field(
            _passwordController, _passFocus,
            "Password", "Min. 6 characters",
            Icons.lock_outline_rounded,
            obscure: _obscurePass,
            suffix: _eyeBtn(_obscurePass,
                    () => setState(
                        () => _obscurePass = !_obscurePass)),
            validator: (v) {
              if (v == null || v.isEmpty) {
                return 'Password is required';
              }
              if (v.length < 6) return 'At least 6 characters';
              return null;
            },
          ),
          if (_passwordController.text.isNotEmpty) ...[
            const SizedBox(height: 10),
            _strengthMeter(),
          ],
          const SizedBox(height: 14),
          _field(
            _confirmPasswordController, _confirmFocus,
            "Confirm Password", "Re-enter password",
            Icons.lock_outline_rounded,
            obscure: _obscureConfirm,
            suffix: _eyeBtn(_obscureConfirm,
                    () => setState(
                        () => _obscureConfirm = !_obscureConfirm)),
            validator: (v) {
              if (v == null || v.isEmpty) {
                return 'Please confirm your password';
              }
              if (v != _passwordController.text) {
                return 'Passwords do not match';
              }
              return null;
            },
          ),
        ];

      default:
        return [];
    }
  }

  // ── Password strength meter ───────────────────────────────────────────────
  Widget _strengthMeter() {
    final pw = _passwordController.text;
    int s = 0;
    if (pw.length >= 6)  s++;
    if (pw.length >= 10) s++;
    if (pw.contains(RegExp(r'[A-Z]')))        s++;
    if (pw.contains(RegExp(r'[0-9]')))        s++;
    if (pw.contains(RegExp(r'[!@#\$%^&*]'))) s++;

    final colors = [
      Colors.red, Colors.orange, Colors.amber,
      _accentLight, _successColor
    ];
    final labels = [
      'Very Weak', 'Weak', 'Fair', 'Good', 'Strong'
    ];
    final idx = (s - 1).clamp(0, 4);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: List.generate(5, (i) => Expanded(
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 280),
              height: 4,
              margin: const EdgeInsets.only(right: 3),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(2),
                color: i < s ? colors[idx] : _border,
              ),
            ),
          )),
        ),
        const SizedBox(height: 5),
        Text(
          "Strength: ${labels[idx]}",
          style: TextStyle(
              fontSize: 11,
              color: colors[idx],
              fontWeight: FontWeight.w600),
        ),
      ],
    );
  }

  // ── Input field helper ────────────────────────────────────────────────────
  Widget _field(
      TextEditingController controller,
      FocusNode focusNode,
      String label,
      String hint,
      IconData icon, {
        TextInputType keyboard = TextInputType.text,
        bool obscure = false,
        Widget? suffix,
        String? Function(String?)? validator,
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
            color: focused
                ? _accent.withOpacity(0.04)
                : const Color(0xFFF8FAFC),
            border: Border.all(
              color: focused ? _accent : _border,
              width: focused ? 1.5 : 1.0,
            ),
          ),
          child: TextFormField(
            controller: controller,
            focusNode: focusNode,
            keyboardType: keyboard,
            obscureText: obscure,
            validator: validator,
            style: const TextStyle(
                color: _textPrimary,
                fontSize: 15,
                fontWeight: FontWeight.w500),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: const TextStyle(
                  color: Color(0xFFCBD5E1), fontSize: 15),
              prefixIcon: Icon(icon,
                  size: 18,
                  color: focused
                      ? _accent
                      : const Color(0xFFCBD5E1)),
              suffixIcon: suffix,
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16, vertical: 14),
              errorStyle: const TextStyle(
                  color: _errorColor,
                  fontSize: 11,
                  fontWeight: FontWeight.w500),
            ),
          ),
        ),
      ],
    );
  }

  // ── Eye toggle button ─────────────────────────────────────────────────────
  Widget _eyeBtn(bool obscured, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.only(right: 4),
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 180),
          child: Icon(
            obscured
                ? Icons.visibility_off_outlined
                : Icons.visibility_outlined,
            key: ValueKey(obscured),
            size: 18,
            color: const Color(0xFFCBD5E1),
          ),
        ),
      ),
    );
  }

  // ── Error banner ──────────────────────────────────────────────────────────
  Widget _buildErrorBanner() {
    return Container(
      padding:
      const EdgeInsets.symmetric(horizontal: 13, vertical: 11),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(11),
        color: _errorColor.withOpacity(0.06),
        border: Border.all(color: _errorColor.withOpacity(0.20)),
      ),
      child: Row(
        children: [
          Container(
            width: 26, height: 26,
            decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: _errorColor.withOpacity(0.12)),
            child: const Icon(Icons.warning_amber_rounded,
                color: _errorColor, size: 15),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              _error,
              style: const TextStyle(
                  color: _errorColor,
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  height: 1.4),
            ),
          ),
          GestureDetector(
            onTap: () => setState(() => _error = ""),
            child: Icon(Icons.close_rounded,
                color: _errorColor.withOpacity(0.5), size: 15),
          ),
        ],
      ),
    );
  }

  // ── Navigation buttons ────────────────────────────────────────────────────
  Widget _buildButtons() {
    final isLast = _currentStep == 2;
    return Row(
      children: [
        if (_currentStep > 0) ...[
          Expanded(
            flex: 2,
            child: GestureDetector(
              onTap: _prevStep,
              child: Container(
                height: 52,
                decoration: BoxDecoration(
                  color: _surface,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: _border),
                  boxShadow: [
                    BoxShadow(
                        color: Colors.black.withOpacity(0.04),
                        blurRadius: 8,
                        offset: const Offset(0, 2))
                  ],
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.arrow_back_ios_new_rounded,
                        size: 13, color: _textSecondary),
                    SizedBox(width: 5),
                    Text("Back",
                        style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: _textSecondary)),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
        ],
        Expanded(flex: 3, child: _primaryBtn(isLast)),
      ],
    );
  }

  // ── Primary button ────────────────────────────────────────────────────────
  Widget _primaryBtn(bool isLast) {
    return LayoutBuilder(builder: (context, c) {
      return AnimatedContainer(
        duration: const Duration(milliseconds: 360),
        curve: Curves.easeInOutCubic,
        width: _loading ? 54 : c.maxWidth,
        height: 52,
        alignment: Alignment.center,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 360),
          curve: Curves.easeInOutCubic,
          width: _loading ? 54 : c.maxWidth,
          height: 52,
          decoration: BoxDecoration(
            borderRadius:
            BorderRadius.circular(_loading ? 27 : 14),
            gradient: _signupSuccess
                ? const LinearGradient(
                colors: [_successColor, Color(0xFF4ADE80)])
                : LinearGradient(
              colors: isLast
                  ? [_accent, const Color(0xFF3B82F6)]
                  : [
                const Color(0xFF334155),
                const Color(0xFF475569)
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            boxShadow: [
              BoxShadow(
                color: (_signupSuccess
                    ? _successColor
                    : isLast
                    ? _accent
                    : const Color(0xFF334155))
                    .withOpacity(0.28),
                blurRadius: 16,
                offset: const Offset(0, 6),
              )
            ],
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius:
              BorderRadius.circular(_loading ? 27 : 14),
              onTap: _loading ? null : _nextStep,
              splashColor: Colors.white.withOpacity(0.15),
              child: Center(child: _btnContent(isLast)),
            ),
          ),
        ),
      );
    });
  }

  // ── Button content ────────────────────────────────────────────────────────
  Widget _btnContent(bool isLast) {
    if (_signupSuccess) {
      return ScaleTransition(
        scale: _successScale,
        child: FadeTransition(
          opacity: _successOpacity,
          child: const Icon(Icons.check_rounded,
              color: Colors.white, size: 26),
        ),
      );
    }
    if (_loading) {
      return const SizedBox(
        width: 22, height: 22,
        child: CircularProgressIndicator(
            strokeWidth: 2.5,
            valueColor:
            AlwaysStoppedAnimation<Color>(Colors.white)),
      );
    }
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          isLast ? "Create Account" : "Continue",
          style: const TextStyle(
              color: Colors.white,
              fontSize: 15,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.2),
        ),
        const SizedBox(width: 6),
        Icon(
          isLast
              ? Icons.check_circle_outline_rounded
              : Icons.arrow_forward_ios_rounded,
          color: Colors.white,
          size: isLast ? 17 : 13,
        ),
      ],
    );
  }

  // ── Footer ────────────────────────────────────────────────────────────────
  Widget _buildFooter() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text(
          "Already have an account? ",
          style: TextStyle(color: _textSecondary, fontSize: 14),
        ),
        GestureDetector(
          onTap: () => Navigator.pop(context),
          child: Container(
            padding: const EdgeInsets.symmetric(
                horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              border:
              Border.all(color: _accent.withOpacity(0.30)),
              color: _accent.withOpacity(0.07),
            ),
            child: const Text(
              "Sign in",
              style: TextStyle(
                  color: _accent,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.1),
            ),
          ),
        ),
      ],
    );
  }
}

// ── Background painter ────────────────────────────────────────────────────
class _LightBgPainter extends CustomPainter {
  final double rotation;
  _LightBgPainter({required this.rotation});

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawRect(
      Rect.fromLTWH(0, 0, size.width, size.height),
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFFEFF6FF),
            Color(0xFFF0F6FF),
            Color(0xFFE8F0FE),
          ],
        ).createShader(
            Rect.fromLTWH(0, 0, size.width, size.height)),
    );

    _orb(canvas,
        Offset(size.width * 0.88 + math.cos(rotation) * 22,
            size.height * 0.12 + math.sin(rotation) * 16),
        size.width * 0.52,
        const Color(0xFF2563EB).withOpacity(0.07));

    _orb(canvas,
        Offset(
            size.width * 0.08 +
                math.cos(rotation + math.pi) * 18,
            size.height * 0.82 +
                math.sin(rotation + math.pi) * 14),
        size.width * 0.46,
        const Color(0xFF60A5FA).withOpacity(0.09));

    _orb(canvas,
        Offset(
            size.width * 0.5 +
                math.cos(rotation * 0.6) * 30,
            size.height * 0.42 +
                math.sin(rotation * 0.6) * 20),
        size.width * 0.28,
        const Color(0xFFBAE6FD).withOpacity(0.12));

    final dot = Paint()
      ..color = const Color(0xFF2563EB).withOpacity(0.05)
      ..style = PaintingStyle.fill;
    const sp = 28.0;
    for (double x = sp; x < size.width; x += sp) {
      for (double y = sp; y < size.height; y += sp) {
        canvas.drawCircle(Offset(x, y), 1.2, dot);
      }
    }
  }

  void _orb(Canvas canvas, Offset c, double r, Color color) {
    canvas.drawCircle(
      c, r,
      Paint()
        ..shader = RadialGradient(
            colors: [color, Colors.transparent])
            .createShader(
            Rect.fromCircle(center: c, radius: r)),
    );
  }

  @override
  bool shouldRepaint(_LightBgPainter o) =>
      o.rotation != rotation;
}