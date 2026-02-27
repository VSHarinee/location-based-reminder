import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:locationbasedreminder/screens/home.dart';
import 'package:locationbasedreminder/screens/signup.dart';
import 'package:locationbasedreminder/screens/location_status_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  bool _loading = false;
  String _error = "";

  Future<void> _login() async {
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

      // ✅ GO TO HOME & CLEAR STACK
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
          builder: (_) => const HomeScreen(),
        ),
            (route) => false,
      );
    } on FirebaseAuthException catch (e) {
      setState(() {
        _error = e.message ?? "Login failed";
      });
    } finally {
      setState(() {
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Login")),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            TextField(
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              decoration: const InputDecoration(
                labelText: "Email",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),

            TextField(
              controller: _passwordController,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: "Password",
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 20),

            if (_error.isNotEmpty)
              Text(
                _error,
                style: const TextStyle(color: Colors.red),
              ),

            const SizedBox(height: 10),

            ElevatedButton(
              onPressed: _loading ? null : _login,
              child: _loading
                  ? const CircularProgressIndicator()
                  : const Text("Login"),
            ),

            const SizedBox(height: 12),

            TextButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const SignupScreen(),
                  ),
                );
              },
              child: const Text("Don’t have an account? Sign up"),
            ),
          ],
        ),
      ),
    );
  }
}
