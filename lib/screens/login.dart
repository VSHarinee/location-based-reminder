// import 'package:flutter/material.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:locationbasedreminder/screens/home.dart';
// import 'package:locationbasedreminder/screens/signup.dart';
// import 'package:locationbasedreminder/screens/location_status_screen.dart';
//
// class LoginScreen extends StatefulWidget {
//   const LoginScreen({Key? key}) : super(key: key);
//
//   @override
//   State<LoginScreen> createState() => _LoginScreenState();
// }
//
// class _LoginScreenState extends State<LoginScreen> {
//   final TextEditingController _emailController = TextEditingController();
//   final TextEditingController _passwordController = TextEditingController();
//
//   bool _loading = false;
//   String _error = "";
//
//   Future<void> _login() async {
//     setState(() {
//       _loading = true;
//       _error = "";
//     });
//
//     try {
//       await FirebaseAuth.instance.signInWithEmailAndPassword(
//         email: _emailController.text.trim(),
//         password: _passwordController.text.trim(),
//       );
//
//       debugPrint("✅ User logged in");
//
//       // ✅ GO TO HOME & CLEAR STACK
//       Navigator.pushAndRemoveUntil(
//         context,
//         MaterialPageRoute(
//           builder: (_) => const HomeScreen(),
//         ),
//             (route) => false,
//       );
//     } on FirebaseAuthException catch (e) {
//       setState(() {
//         _error = e.message ?? "Login failed";
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
//       appBar: AppBar(title: const Text("Login")),
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
//
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
//               onPressed: _loading ? null : _login,
//               child: _loading
//                   ? const CircularProgressIndicator()
//                   : const Text("Login"),
//             ),
//
//             const SizedBox(height: 12),
//
//             TextButton(
//               onPressed: () {
//                 Navigator.push(
//                   context,
//                   MaterialPageRoute(
//                     builder: (_) => const SignupScreen(),
//                   ),
//                 );
//               },
//               child: const Text("Don’t have an account? Sign up"),
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
import 'package:locationbasedreminder/screens/home.dart';
import 'package:locationbasedreminder/screens/signup.dart';
import 'dart:math' as math;

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with TickerProviderStateMixin {
  // ── Original variables (UNCHANGED) ──────────────────────────────────────
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _loading = false;
  String _error = "";

  // ── UI-only additions ────────────────────────────────────────────────────
  final _formKey = GlobalKey<FormState>();
  bool _obscurePassword = true;
  bool _emailFocused = false;
  bool _passwordFocused = false;
  bool _loginSuccess = false;

  late AnimationController _masterController;
  late AnimationController _orbController;
  late AnimationController _shakeController;
  late AnimationController _successController;

  late Animation<double> _fadeIn;
  late Animation<Offset> _cardSlide;
  late Animation<double> _cardScale;
  late Animation<double> _orbRotate;
  late Animation<double> _shakeAnim;
  late Animation<double> _successScale;
  late Animation<double> _successOpacity;

  final FocusNode _emailFocus = FocusNode();
  final FocusNode _passwordFocus = FocusNode();

  // ── Light theme palette ──────────────────────────────────────────────────
  static const _accent       = Color(0xFF2563EB); // vivid blue
  static const _accentLight  = Color(0xFF60A5FA); // sky blue
  static const _accentGlow   = Color(0xFFBAE6FD); // pale glow
  static const _bg           = Color(0xFFF0F6FF); // off-white blue tint
  static const _surface      = Colors.white;
  static const _textPrimary  = Color(0xFF0F172A);
  static const _textSecondary= Color(0xFF64748B);
  static const _border       = Color(0xFFE2E8F0);
  static const _errorColor   = Color(0xFFDC2626);
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
    _orbRotate = Tween<double>(begin: 0, end: 2 * math.pi)
        .animate(CurvedAnimation(parent: _orbController, curve: Curves.linear));
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

    _emailFocus.addListener(
            () => setState(() => _emailFocused = _emailFocus.hasFocus));
    _passwordFocus.addListener(
            () => setState(() => _passwordFocused = _passwordFocus.hasFocus));

    _masterController.forward();
  }

  @override
  void dispose() {
    _masterController.dispose();
    _orbController.dispose();
    _shakeController.dispose();
    _successController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _emailFocus.dispose();
    _passwordFocus.dispose();
    super.dispose();
  }

  // ── Original _login() — backend UNCHANGED ───────────────────────────────
  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) {
      _triggerShake();
      return;
    }
    setState(() {
      _loading = true;
      _error = "";
    });
    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );
      debugPrint("✅ User logged in");

      setState(() => _loginSuccess = true);
      await _successController.forward();
      await Future.delayed(const Duration(milliseconds: 380));

      if (!mounted) return;
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const HomeScreen()),
            (route) => false,
      );
    } on FirebaseAuthException catch (e) {
      setState(() => _error = _mapFirebaseError(e.code));
      _triggerShake();
      HapticFeedback.mediumImpact();
    } finally {
      if (mounted) {
        setState(() {
          _loading = false;
          _loginSuccess = false;
        });
        _successController.reset();
      }
    }
  }

  void _triggerShake() {
    _shakeController.forward(from: 0).then((_) => _shakeController.reverse());
  }

  String _mapFirebaseError(String code) {
    switch (code) {
      case 'user-not-found':   return 'No account found with this email address.';
      case 'wrong-password':   return 'Incorrect password. Please try again.';
      case 'invalid-email':    return 'Please enter a valid email address.';
      case 'user-disabled':    return 'This account has been disabled.';
      case 'too-many-requests':return 'Too many attempts. Please wait and try again.';
      case 'network-request-failed': return 'Network error. Check your connection.';
      default:                 return 'Sign in failed. Please try again.';
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark, // dark icons on light bg
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
                    child: Center(
                      child: SingleChildScrollView(
                        physics: const BouncingScrollPhysics(),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 24, vertical: 32),
                        child: Form(
                          key: _formKey,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              _buildHeader(),
                              const SizedBox(height: 36),
                              _buildCard(),
                              const SizedBox(height: 24),
                              _buildFooter(),
                            ],
                          ),
                        ),
                      ),
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

  // ── Header ─────────────────────────────────────────────────────────────────
  Widget _buildHeader() {
    return Column(
      children: [
        Container(
          width: 76,
          height: 76,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            gradient: const LinearGradient(
              colors: [_accent, _accentLight],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            boxShadow: [
              BoxShadow(
                color: _accent.withOpacity(0.30),
                blurRadius: 24,
                spreadRadius: 2,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: const Icon(
            Icons.my_location_rounded,
            color: Colors.white,
            size: 36,
          ),
        ),
        const SizedBox(height: 20),
        const Text(
          "Welcome Back",
          style: TextStyle(
            fontSize: 30,
            fontWeight: FontWeight.w800,
            color: _textPrimary,
            letterSpacing: -0.8,
            height: 1.1,
          ),
        ),
        const SizedBox(height: 7),
        const Text(
          "Sign in to your reminders",
          style: TextStyle(
            fontSize: 15,
            color: _textSecondary,
            fontWeight: FontWeight.w400,
          ),
        ),
      ],
    );
  }

  // ── Card ───────────────────────────────────────────────────────────────────
  Widget _buildCard() {
    return AnimatedBuilder(
      animation: _shakeAnim,
      builder: (_, child) {
        final shake = math.sin(_shakeAnim.value * math.pi * 6) * 7;
        return Transform.translate(offset: Offset(shake, 0), child: child);
      },
      child: Container(
        decoration: BoxDecoration(
          color: _surface,
          borderRadius: BorderRadius.circular(28),
          border: Border.all(color: _border, width: 1.0),
          boxShadow: [
            BoxShadow(
              color: _accent.withOpacity(0.06),
              blurRadius: 40,
              spreadRadius: 0,
              offset: const Offset(0, 12),
            ),
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 16,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        padding: const EdgeInsets.all(28),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildInputField(
              controller: _emailController,
              focusNode: _emailFocus,
              isFocused: _emailFocused,
              label: "Email Address",
              hint: "you@example.com",
              icon: Icons.alternate_email_rounded,
              keyboardType: TextInputType.emailAddress,
              validator: (v) {
                if (v == null || v.trim().isEmpty) return 'Email required';
                if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(v.trim())) {
                  return 'Enter a valid email';
                }
                return null;
              },
            ),
            const SizedBox(height: 18),
            _buildInputField(
              controller: _passwordController,
              focusNode: _passwordFocus,
              isFocused: _passwordFocused,
              label: "Password",
              hint: "Enter your password",
              icon: Icons.lock_outline_rounded,
              obscureText: _obscurePassword,
              suffixWidget: _buildEyeToggle(),
              validator: (v) {
                if (v == null || v.isEmpty) return 'Password required';
                if (v.length < 6) return 'At least 6 characters';
                return null;
              },
            ),
            AnimatedSize(
              duration: const Duration(milliseconds: 280),
              curve: Curves.easeOutCubic,
              child: _error.isNotEmpty
                  ? Padding(
                padding: const EdgeInsets.only(top: 16),
                child: _buildErrorBanner(),
              )
                  : const SizedBox.shrink(),
            ),
            const SizedBox(height: 26),
            _buildLoginButton(),
          ],
        ),
      ),
    );
  }

  // ── Input field ────────────────────────────────────────────────────────────
  Widget _buildInputField({
    required TextEditingController controller,
    required FocusNode focusNode,
    required bool isFocused,
    required String label,
    required String hint,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    bool obscureText = false,
    Widget? suffixWidget,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AnimatedDefaultTextStyle(
          duration: const Duration(milliseconds: 180),
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.7,
            color: isFocused ? _accent : _textSecondary,
          ),
          child: Text(label.toUpperCase()),
        ),
        const SizedBox(height: 8),
        AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(13),
            color: isFocused
                ? _accent.withOpacity(0.04)
                : const Color(0xFFF8FAFC),
            border: Border.all(
              color: isFocused ? _accent : _border,
              width: isFocused ? 1.5 : 1.0,
            ),
          ),
          child: TextFormField(
            controller: controller,
            focusNode: focusNode,
            keyboardType: keyboardType,
            obscureText: obscureText,
            validator: validator,
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
                color: isFocused ? _accent : const Color(0xFFCBD5E1),
              ),
              suffixIcon: suffixWidget,
              border: InputBorder.none,
              contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
              errorStyle: const TextStyle(
                color: _errorColor,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ),
      ],
    );
  }

  // ── Eye toggle ─────────────────────────────────────────────────────────────
  Widget _buildEyeToggle() {
    return GestureDetector(
      onTap: () => setState(() => _obscurePassword = !_obscurePassword),
      child: Padding(
        padding: const EdgeInsets.only(right: 4),
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 180),
          child: Icon(
            _obscurePassword
                ? Icons.visibility_off_outlined
                : Icons.visibility_outlined,
            key: ValueKey(_obscurePassword),
            size: 19,
            color: const Color(0xFFCBD5E1),
          ),
        ),
      ),
    );
  }

  // ── Error banner ───────────────────────────────────────────────────────────
  Widget _buildErrorBanner() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(11),
        color: _errorColor.withOpacity(0.06),
        border: Border.all(color: _errorColor.withOpacity(0.20)),
      ),
      child: Row(
        children: [
          Container(
            width: 26,
            height: 26,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: _errorColor.withOpacity(0.12),
            ),
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
                height: 1.4,
              ),
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

  // ── Login button ───────────────────────────────────────────────────────────
  Widget _buildLoginButton() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final fullWidth = constraints.maxWidth;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 380),
          curve: Curves.easeInOutCubic,
          width: _loading ? 56 : fullWidth,
          height: 52,
          alignment: Alignment.center,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 380),
            curve: Curves.easeInOutCubic,
            width: _loading ? 56 : fullWidth,
            height: 52,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(_loading ? 26 : 13),
              gradient: _loginSuccess
                  ? const LinearGradient(
                  colors: [_successColor, Color(0xFF4ADE80)])
                  : const LinearGradient(
                colors: [_accent, Color(0xFF3B82F6)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              boxShadow: [
                BoxShadow(
                  color: (_loginSuccess ? _successColor : _accent)
                      .withOpacity(0.28),
                  blurRadius: 18,
                  offset: const Offset(0, 7),
                ),
              ],
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(_loading ? 26 : 13),
                onTap: _loading ? null : _login,
                splashColor: Colors.white.withOpacity(0.18),
                child: Center(child: _buildButtonContent()),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildButtonContent() {
    if (_loginSuccess) {
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
    return const Text(
      "Sign In",
      style: TextStyle(
        color: Colors.white,
        fontSize: 16,
        fontWeight: FontWeight.w700,
        letterSpacing: 0.3,
      ),
    );
  }

  // ── Footer ─────────────────────────────────────────────────────────────────
  Widget _buildFooter() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text(
          "New here? ",
          style: TextStyle(color: _textSecondary, fontSize: 14),
        ),
        GestureDetector(
          onTap: () => Navigator.push(
            context,
            PageRouteBuilder(
              pageBuilder: (_, anim, __) => FadeTransition(
                opacity: anim,
                child: const SignupScreen(),
              ),
              transitionDuration: const Duration(milliseconds: 320),
            ),
          ),
          child: Container(
            padding:
            const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: _accent.withOpacity(0.3)),
              color: _accent.withOpacity(0.07),
            ),
            child: const Text(
              "Create account",
              style: TextStyle(
                color: _accent,
                fontSize: 14,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.1,
              ),
            ),
          ),
        ),
      ],
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
      ..shader = LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          const Color(0xFFEFF6FF),
          const Color(0xFFF0F6FF),
          const Color(0xFFE8F0FE),
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
  bool shouldRepaint(_LightBackgroundPainter old) =>
      old.rotation != rotation;
}