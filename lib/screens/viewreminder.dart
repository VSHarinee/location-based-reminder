import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
//add
import '../main.dart';
class ReminderListScreen extends StatelessWidget {
  const ReminderListScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: const Text("My Reminders"),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection("reminders")
            .where("userId", isEqualTo: user!.uid)
            .orderBy("createdAt", descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const Center(child: Text("Error loading reminders"));
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final reminders = snapshot.data!.docs;

          if (reminders.isEmpty) {
            return const Center(child: Text("No reminders found"));
          }

          return ListView.builder(
            itemCount: reminders.length,
            itemBuilder: (context, index) {
              final doc = reminders[index];
              final data = doc.data() as Map<String, dynamic>;

              return Card(
                margin: const EdgeInsets.all(10),
                child: ListTile(
                  title: Text(data["description"] ?? ""),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Location: ${data["locationName"]}"),
                      Text("Status: ${data["status"]}"),
                    ],
                  ),
                  trailing: PopupMenuButton<String>(
                    onSelected: (value) {
                      if (value == "edit") {
                        _editReminder(context, doc.id, data);
                      } else if (value == "delete") {
                        _deleteReminder(context, doc.id);
                      }
                    },
                    itemBuilder: (context) => const [
                      PopupMenuItem(
                        value: "edit",
                        child: Text("Edit"),
                      ),
                      PopupMenuItem(
                        value: "delete",
                        child: Text("Delete"),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  // 🗑 Delete Reminder
  Future<void> _deleteReminder(BuildContext context, String reminderId) async {
    final user = FirebaseAuth.instance.currentUser;

    await FirebaseFirestore.instance
        .collection("reminders")
        .doc(reminderId)
        .delete();

    // Decrement counter
    await FirebaseFirestore.instance
        .collection("users")
        .doc(user!.uid)
        .update({
      "pendingReminders": FieldValue.increment(-1),
    });
    await debugDriver.syncAndRefreshCache();

    ScaffoldMessenger.of(context)
        .showSnackBar(const SnackBar(content: Text("Reminder deleted")));
  }

  // ✏ Edit Reminder
  void _editReminder(
      BuildContext context, String reminderId, Map<String, dynamic> data) {

    final descriptionController =
    TextEditingController(text: data["description"]);
    final locationController =
    TextEditingController(text: data["locationName"]);
    final personController =
    TextEditingController(text: data["person"]);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Edit Reminder"),
        content: SingleChildScrollView(
          child: Column(
            children: [
              TextField(
                controller: descriptionController,
                decoration:
                const InputDecoration(labelText: "Description"),
              ),
              TextField(
                controller: locationController,
                decoration:
                const InputDecoration(labelText: "Location"),
              ),
              TextField(
                controller: personController,
                decoration:
                const InputDecoration(labelText: "Person"),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () async {
              await FirebaseFirestore.instance
                  .collection("reminders")
                  .doc(reminderId)
                  .update({
                "description": descriptionController.text.trim(),
                "locationName": locationController.text.trim(),
                "person": personController.text.trim(),
              });

              await debugDriver.syncAndRefreshCache();
              Navigator.pop(context);

            },


            child: const Text("Update"),
          ),
        ],
      ),
    );
  }
}