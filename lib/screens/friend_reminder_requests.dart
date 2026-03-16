import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FriendReminderRequests extends StatelessWidget {
  const FriendReminderRequests({Key? key}) : super(key: key);

  Future acceptReminder(String docId) async {

    await FirebaseFirestore.instance
        .collection("reminders")
        .doc(docId)
        .update({
      "approvalStatus": "accepted"
    });
  }

  Future rejectReminder(String docId) async {

    await FirebaseFirestore.instance
        .collection("reminders")
        .doc(docId)
        .update({
      "approvalStatus": "rejected"
    });
  }

  @override
  Widget build(BuildContext context) {

    final uid = FirebaseAuth.instance.currentUser!.uid;

    return Scaffold(
      appBar: AppBar(title: const Text("Friend Reminders")),

      body: StreamBuilder<QuerySnapshot>(

        stream: FirebaseFirestore.instance
            .collection("reminders")
            .where("targetUserId", isEqualTo: uid)
            .where("approvalStatus", isEqualTo: "pending")
            .snapshots(),

        builder: (context, snapshot) {

          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final docs = snapshot.data!.docs;

          if (docs.isEmpty) {
            return const Center(
                child: Text("No reminder requests"));
          }

          return ListView.builder(
            itemCount: docs.length,
            itemBuilder: (context, index) {

              final data = docs[index];

              return Card(
                child: ListTile(

                  title: Text(data["description"]),

                  subtitle:
                  Text(data["locationName"]),

                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [

                      IconButton(
                        icon: const Icon(Icons.check,
                            color: Colors.green),
                        onPressed: () =>
                            acceptReminder(data.id),
                      ),

                      IconButton(
                        icon: const Icon(Icons.close,
                            color: Colors.red),
                        onPressed: () =>
                            rejectReminder(data.id),
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
}