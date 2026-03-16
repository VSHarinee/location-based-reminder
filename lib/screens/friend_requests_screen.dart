import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FriendRequestsScreen extends StatelessWidget {
  const FriendRequestsScreen({Key? key}) : super(key: key);

  Future acceptRequest(String requestId, String fromUid) async {

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

  @override
  Widget build(BuildContext context) {

    final myUid = FirebaseAuth.instance.currentUser!.uid;

    return Scaffold(
      appBar: AppBar(title: const Text("Friend Requests")),

      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection("friend_requests")
            .where("toUid", isEqualTo: myUid)
            .snapshots(),
        builder: (context, snapshot) {

          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final requests = snapshot.data!.docs;

          return ListView.builder(
            itemCount: requests.length,
            itemBuilder: (context, index) {

              final data = requests[index];

              return FutureBuilder<DocumentSnapshot>(
                future: FirebaseFirestore.instance
                    .collection("users")
                    .doc(data["fromUid"])
                    .get(),
                builder: (context, userSnapshot) {

                  if (!userSnapshot.hasData) {
                    return const ListTile(
                      title: Text("Loading..."),
                    );
                  }

                  final userData =
                  userSnapshot.data!.data() as Map<String, dynamic>?;

                  final name = userData?["name"] ?? "Unknown";
                  final phone = userData?["phone"] ?? "";

                  return Card(
                    margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    child: ListTile(

                      leading: const CircleAvatar(
                        child: Icon(Icons.person),
                      ),

                      title: Text(name),

                      subtitle: Text(phone),

                      trailing: ElevatedButton(
                        child: const Text("Accept"),
                        onPressed: () {
                          acceptRequest(data.id, data["fromUid"]);
                        },
                      ),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}