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
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({Key? key}) : super(key: key);

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _cityController = TextEditingController();
  final _stateController = TextEditingController();
  final _countryController = TextEditingController();
  final _ageController = TextEditingController();

  bool _loading = false;
  String _error = "";

  Future<void> _signup() async {
    if (_passwordController.text != _confirmPasswordController.text) {
      setState(() => _error = "Passwords do not match");
      return;
    }

    setState(() {
      _loading = true;
      _error = "";
    });

    try {
      // 1️⃣ Create Auth user
      UserCredential userCredential =
      await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      String uid = userCredential.user!.uid;

      // 2️⃣ Store user data in Firestore
      await FirebaseFirestore.instance.collection("users").doc(uid).set({
        "name": _nameController.text.trim(),
        "phone": _phoneController.text.trim(),
        "city": _cityController.text.trim(),
        "state": _stateController.text.trim(),
        "country": _countryController.text.trim(),
        "age": int.tryParse(_ageController.text.trim()) ?? 0,
        "friends": [],
        "noOfFriends": 0,
        "pendingReminders": 0,
        "createdAt": FieldValue.serverTimestamp(),
      });

      debugPrint("✅ User registered and stored in Firestore");

      Navigator.pop(context);

    } on FirebaseAuthException catch (e) {
      setState(() => _error = e.message ?? "Signup failed");
    } catch (e) {
      setState(() => _error = "Something went wrong");
    } finally {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Sign Up")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [

            TextField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: "Name",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),

            TextField(
              controller: _phoneController,
              keyboardType: TextInputType.phone,
              decoration: const InputDecoration(
                labelText: "Phone",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),

            TextField(
              controller: _cityController,
              decoration: const InputDecoration(
                labelText: "City",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),

            TextField(
              controller: _stateController,
              decoration: const InputDecoration(
                labelText: "State",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),

            TextField(
              controller: _countryController,
              decoration: const InputDecoration(
                labelText: "Country",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),

            TextField(
              controller: _ageController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: "Age",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),

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
            const SizedBox(height: 16),

            TextField(
              controller: _confirmPasswordController,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: "Confirm Password",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),

            if (_error.isNotEmpty)
              Text(_error, style: const TextStyle(color: Colors.red)),

            const SizedBox(height: 10),

            ElevatedButton(
              onPressed: _loading ? null : _signup,
              child: _loading
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text("Create Account"),
            ),
          ],
        ),
      ),
    );
  }
}