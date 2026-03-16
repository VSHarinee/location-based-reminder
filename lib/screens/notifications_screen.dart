import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({Key? key}) : super(key: key);

  /// ACCEPT FRIEND REQUEST
  Future acceptFriendRequest(String requestId, String fromUid) async {
    final myUid = FirebaseAuth.instance.currentUser!.uid;
    final db = FirebaseFirestore.instance;

    final myRef = db.collection("users").doc(myUid);
    final friendRef = db.collection("users").doc(fromUid);

    await db.runTransaction((transaction) async {
      final mySnap = await transaction.get(myRef);
      final friendSnap = await transaction.get(friendRef);

      int myFriends = mySnap["noOfFriends"] ?? 0;
      int friendFriends = friendSnap["noOfFriends"] ?? 0;

      transaction.update(myRef, {
        "friends": FieldValue.arrayUnion([fromUid]),
        "noOfFriends": myFriends + 1
      });

      transaction.update(friendRef, {
        "friends": FieldValue.arrayUnion([myUid]),
        "noOfFriends": friendFriends + 1
      });
    });

    await db.collection("friend_requests").doc(requestId).delete();
  }

  /// ACCEPT REMINDER
  Future acceptReminder(String docId) async {
    await FirebaseFirestore.instance
        .collection("reminders")
        .doc(docId)
        .update({"approvalStatus": "accepted"});
  }

  /// REJECT REMINDER
  Future rejectReminder(String docId) async {
    await FirebaseFirestore.instance
        .collection("reminders")
        .doc(docId)
        .update({"approvalStatus": "rejected"});
  }

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser!.uid;

    return Scaffold(
      appBar: AppBar(title: const Text("Notifications")),

      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection("friend_requests")
            .where("toUid", isEqualTo: uid)
            .snapshots(),
        builder: (context, friendSnapshot) {

          return StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection("reminders")
                .where("userId", isEqualTo: uid)
                .where("approvalStatus", isEqualTo: "pending")
                .snapshots(),
            builder: (context, reminderSnapshot) {

              if (!friendSnapshot.hasData || !reminderSnapshot.hasData) {
                return const Center(child: CircularProgressIndicator());
              }

              final friendRequests = friendSnapshot.data!.docs;
              final reminderRequests = reminderSnapshot.data!.docs;

              if (friendRequests.isEmpty && reminderRequests.isEmpty) {
                return const Center(child: Text("No notifications"));
              }

              return ListView(
                children: [

                  /// FRIEND REQUESTS
                  for (var req in friendRequests)
                    FutureBuilder<DocumentSnapshot>(
                      future: FirebaseFirestore.instance
                          .collection("users")
                          .doc(req["fromUid"])
                          .get(),
                      builder: (context, userSnapshot) {

                        if (!userSnapshot.hasData) {
                          return const SizedBox();
                        }

                        final userData =
                        userSnapshot.data!.data() as Map<String, dynamic>?;

                        final name = userData?["name"] ?? "Unknown";
                        final phone = userData?["phone"] ?? "";

                        return Card(
                          margin: const EdgeInsets.all(8),
                          child: ListTile(
                            leading: const CircleAvatar(
                              child: Icon(Icons.person_add),
                            ),
                            title: Text("$name sent a friend request"),
                            subtitle: Text(phone),
                            trailing: ElevatedButton(
                              child: const Text("Accept"),
                              onPressed: () {
                                acceptFriendRequest(req.id, req["fromUid"]);
                              },
                            ),
                          ),
                        );
                      },
                    ),

                  /// REMINDER REQUESTS
                  for (var reminder in reminderRequests)
                    Builder(builder: (context) {

                      final data = reminder.data() as Map<String, dynamic>;

                      final creatorId = data["creatorUserId"];

                      if (creatorId == null || creatorId == "") {

                        return Card(
                          margin: const EdgeInsets.all(8),
                          child: ListTile(
                            leading: const CircleAvatar(
                              child: Icon(Icons.alarm),
                            ),
                            title: const Text("Someone set a reminder for you"),
                            subtitle: Text(
                                "${data["description"] ?? ""} • ${data["locationName"] ?? ""}"),
                          ),
                        );
                      }

                      return FutureBuilder<DocumentSnapshot>(
                        future: FirebaseFirestore.instance
                            .collection("users")
                            .doc(creatorId)
                            .get(),
                        builder: (context, userSnapshot) {

                          if (!userSnapshot.hasData) {
                            return const SizedBox();
                          }

                          final userData =
                          userSnapshot.data!.data() as Map<String, dynamic>?;

                          final creatorName = userData?["name"] ?? "Unknown";

                          return Card(
                            margin: const EdgeInsets.all(8),
                            child: ListTile(
                              leading: const CircleAvatar(
                                child: Icon(Icons.alarm),
                              ),
                              title: Text(
                                  "$creatorName set a reminder for you"),
                              subtitle: Text(
                                  "${data["description"] ?? ""} • ${data["locationName"] ?? ""}"),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [

                                  IconButton(
                                    icon: const Icon(Icons.check,
                                        color: Colors.green),
                                    onPressed: () {
                                      acceptReminder(reminder.id);
                                    },
                                  ),

                                  IconButton(
                                    icon: const Icon(Icons.close,
                                        color: Colors.red),
                                    onPressed: () {
                                      rejectReminder(reminder.id);
                                    },
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      );
                    }),
                ],
              );
            },
          );
        },
      ),
    );
  }
}