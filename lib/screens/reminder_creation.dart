import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
//added by codex
import '../main.dart';
class CreateReminderScreen extends StatefulWidget {
  const CreateReminderScreen({Key? key}) : super(key: key);

  @override
  State<CreateReminderScreen> createState() =>
      _CreateReminderScreenState();
}

class _CreateReminderScreenState
    extends State<CreateReminderScreen> {

  final _descriptionController = TextEditingController();
  final _personController = TextEditingController();
  final _manualLatController = TextEditingController();
  final _manualLonController = TextEditingController();
  final _searchController = TextEditingController();

  bool _loading = false;
  bool _manualMode = false;
  String _message = "";

  Map<String, dynamic>? selectedPlace;

  Stream<QuerySnapshot> _searchPlaces(String query) {
    return FirebaseFirestore.instance
        .collection("places")
        .where("name_lower",
        isGreaterThanOrEqualTo: query.toLowerCase())
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
        return;
      }

      double latitude;
      double longitude;
      String locationName;

      if (_manualMode) {
        latitude = double.parse(_manualLatController.text.trim());
        longitude = double.parse(_manualLonController.text.trim());
        locationName = "Custom Location";
      } else {
        if (selectedPlace == null) {
          setState(() {
            _message = "Please select a place";
            _loading = false;
          });
          return;
        }

        latitude = selectedPlace!["latitude"];
        longitude = selectedPlace!["longitude"];
        locationName = selectedPlace!["name"];
      }

      await FirebaseFirestore.instance.collection("reminders").add({
        "userId": user.uid,
        "description": _descriptionController.text.trim(),
        "locationName": locationName,
        "latitude": latitude,
        "longitude": longitude,
        "person": _personController.text.trim(),
        "status": "pending",
        "createdAt": FieldValue.serverTimestamp(),
        "triggeredAt": null,
      });

      await FirebaseFirestore.instance
          .collection("users")
          .doc(user.uid)
          .update({
        "pendingReminders": FieldValue.increment(1),
      });
      await debugDriver.syncAndRefreshCache();//added codex

      setState(() {
        _message = "✅ Reminder Created Successfully";
        selectedPlace = null;
        _searchController.clear();
      });

    } catch (e) {
      setState(() {
        _message = "❌ Failed to create reminder";
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
      appBar: AppBar(title: const Text("Create Reminder")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [

            TextField(
              controller: _descriptionController,
              decoration: const InputDecoration(
                labelText: "Description",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),

            if (!_manualMode) ...[
              TextField(
                controller: _searchController,
                decoration: const InputDecoration(
                  labelText: "Search Place",
                  border: OutlineInputBorder(),
                ),
                onChanged: (_) => setState(() {}),
              ),
              const SizedBox(height: 5),

              if (_searchController.text.isNotEmpty)
                Container(
                  constraints: const BoxConstraints(maxHeight: 200),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: StreamBuilder<QuerySnapshot>(
                    stream: _searchPlaces(_searchController.text),
                    builder: (context, snapshot) {
                      if (!snapshot.hasData) {
                        return const SizedBox();
                      }

                      final docs = snapshot.data!.docs;

                      if (docs.isEmpty) {
                        return const Padding(
                          padding: EdgeInsets.all(10),
                          child: Text("No places found"),
                        );
                      }

                      return ListView.builder(
                        shrinkWrap: true,
                        itemCount: docs.length,
                        itemBuilder: (context, index) {
                          final data = docs[index].data()
                          as Map<String, dynamic>;

                          return ListTile(
                            title: Text(data["name"]),
                            onTap: () {
                              setState(() {
                                selectedPlace = data;
                                _searchController.text =
                                data["name"];
                              });
                            },
                          );
                        },
                      );
                    },
                  ),
                ),
            ],

            const SizedBox(height: 10),

            Row(
              children: [
                Checkbox(
                  value: _manualMode,
                  onChanged: (value) {
                    setState(() {
                      _manualMode = value!;
                      selectedPlace = null;
                      _searchController.clear();
                    });
                  },
                ),
                const Text("Enter Latitude/Longitude Manually"),
              ],
            ),

            if (_manualMode) ...[
              const SizedBox(height: 10),
              TextField(
                controller: _manualLatController,
                keyboardType:
                const TextInputType.numberWithOptions(decimal: true),
                decoration: const InputDecoration(
                  labelText: "Latitude",
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _manualLonController,
                keyboardType:
                const TextInputType.numberWithOptions(decimal: true),
                decoration: const InputDecoration(
                  labelText: "Longitude",
                  border: OutlineInputBorder(),
                ),
              ),
            ],

            const SizedBox(height: 16),

            TextField(
              controller: _personController,
              decoration: const InputDecoration(
                labelText: "Person (self or userId)",
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 20),

            if (_message.isNotEmpty)
              Text(
                _message,
                style: TextStyle(
                  color: _message.contains("❌")
                      ? Colors.red
                      : Colors.green,
                ),
              ),

            const SizedBox(height: 10),

            ElevatedButton(
              onPressed: _loading ? null : _createReminder,
              child: _loading
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text("Create Reminder"),
            ),
          ],
        ),
      ),
    );
  }
}