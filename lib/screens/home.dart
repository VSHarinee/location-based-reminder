import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:locationbasedreminder/screens/place.dart';
import 'package:locationbasedreminder/screens/reminder_creation.dart';
import 'package:locationbasedreminder/screens/viewreminder.dart';
import '../main.dart';
import 'debug_dashboard_screen.dart';
import 'location_status_screen.dart';
import 'voice_input_page.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({Key? key}) : super(key: key);

  void _logout(BuildContext context) async {
    await FirebaseAuth.instance.signOut();

    Navigator.pushReplacementNamed(context, "/login");
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Home"),
      ),

      drawer: Drawer(
        child: Column(
          children: [

            // 🔹 Drawer Header
            UserAccountsDrawerHeader(
              accountName: const Text("Welcome"),
              accountEmail: Text(user?.email ?? ""),
              currentAccountPicture: const CircleAvatar(
                child: Icon(Icons.person, size: 40),
              ),
            ),

            // 🔹 Location Status Page
            // ListTile(
            //   leading: const Icon(Icons.location_on),
            //   title: const Text("Location Status"),
            //   onTap: () {
            //     Navigator.push(
            //       context,
            //       MaterialPageRoute(
            //         builder: (_) => const LocationStatusScreen(),
            //       ),
            //     );
            //   },
            // ),
            ListTile(
              leading: const Icon(Icons.bug_report, color: Colors.deepPurple),
              title: const Text("Engine Debug Dashboard"),
              onTap: () {
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

            // 🔹 Voice Input Page
            ListTile(
              leading: const Icon(Icons.mic),
              title: const Text("Voice Reminder"),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const VoiceInputPage(),
                  ),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.add_circle_outline),
              title: const Text("Create Reminder"),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const CreateReminderScreen(),
                  ),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.list),
              title: const Text("My Reminders"),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const ReminderListScreen(),
                  ),
                );
              },
            ),

            ListTile(
              leading: const Icon(Icons.place),
              title: const Text("Add Place"),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const CreatePlaceScreen(),
                  ),
                );
              },
            ),
            const Spacer(),

            const Divider(),

            // 🔹 Logout
            ListTile(
              leading: const Icon(Icons.logout, color: Colors.red),
              title: const Text("Logout",
                  style: TextStyle(color: Colors.red)),
              onTap: () => _logout(context),
            ),
          ],
        ),
      ),



      body: const Center(
        child: Text(
          "Welcome to Adaptive Location Reminder App 🚀",
          style: TextStyle(fontSize: 18),
        ),
      ),
    );
  }
}