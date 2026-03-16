import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FriendListScreen extends StatelessWidget {
  const FriendListScreen({Key? key}) : super(key: key);

  Future<List<DocumentSnapshot>> getFriends() async {

    final uid = FirebaseAuth.instance.currentUser!.uid;

    final userDoc = await FirebaseFirestore.instance
        .collection("users")
        .doc(uid)
        .get();

    List friends = userDoc.data()?["friends"] ?? [];

    if (friends.isEmpty) return [];

    final friendDocs = await FirebaseFirestore.instance
        .collection("users")
        .where(FieldPath.documentId, whereIn: friends)
        .get();

    return friendDocs.docs;
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        title: const Text("My Friends"),
      ),

      body: FutureBuilder<List<DocumentSnapshot>>(

        future: getFriends(),

        builder: (context, snapshot) {

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(
              child: Text("No friends added yet"),
            );
          }

          final friends = snapshot.data!;

          return ListView.builder(
            itemCount: friends.length,
            itemBuilder: (context, index) {

              final data = friends[index];

              return Card(
                margin: const EdgeInsets.symmetric(
                    horizontal: 12, vertical: 6),

                child: ListTile(

                  leading: const CircleAvatar(
                    child: Icon(Icons.person),
                  ),

                  title: Text(data["name"] ?? ""),

                  subtitle: Text(
                      "${data["phone"] ?? ""} • ${data["city"] ?? ""}"),

                  trailing: IconButton(
                    icon: const Icon(Icons.message),
                    onPressed: () {

                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                              "Send reminder to ${data["name"]}"),
                        ),
                      );
                    },
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