import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FriendsScreen extends StatefulWidget {
  const FriendsScreen({Key? key}) : super(key: key);

  @override
  State<FriendsScreen> createState() => _FriendsScreenState();
}

class _FriendsScreenState extends State<FriendsScreen> {

  final TextEditingController phoneController = TextEditingController();
  DocumentSnapshot? searchedUser;

  final uid = FirebaseAuth.instance.currentUser!.uid;

  // SEARCH USER
  Future searchUser() async {

    final result = await FirebaseFirestore.instance
        .collection("users")
        .where("phone", isEqualTo: phoneController.text.trim())
        .get();

    if (result.docs.isNotEmpty) {
      setState(() {
        searchedUser = result.docs.first;
      });
    } else {
      setState(() {
        searchedUser = null;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("User not found")),
      );
    }
  }

  // SEND FRIEND REQUEST
  Future sendRequest(String toUid) async {

    await FirebaseFirestore.instance.collection("friend_requests").add({
      "fromUid": uid,
      "toUid": toUid,
      "status": "pending",
      "createdAt": FieldValue.serverTimestamp()
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Friend request sent")),
    );
  }

  // FETCH FRIEND LIST
  Future<List<DocumentSnapshot>> getFriends() async {

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
      appBar: AppBar(title: const Text("Friends")),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),

        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            // SEARCH BOX
            TextField(
              controller: phoneController,
              keyboardType: TextInputType.phone,
              decoration: InputDecoration(
                hintText: "Search by phone number",
                suffixIcon: IconButton(
                  icon: const Icon(Icons.search),
                  onPressed: searchUser,
                ),
              ),
            ),

            const SizedBox(height: 20),

            // SEARCH RESULT
            if (searchedUser != null)
              Card(
                child: ListTile(
                  leading: const CircleAvatar(
                    child: Icon(Icons.person),
                  ),
                  title: Text(searchedUser!["name"]),
                  subtitle: Text(searchedUser!["phone"]),
                  trailing: ElevatedButton(
                    child: const Text("Add"),
                    onPressed: () {
                      sendRequest(searchedUser!.id);
                    },
                  ),
                ),
              ),

            const SizedBox(height: 30),

            const Text(
              "My Friends",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 10),

            FutureBuilder<List<DocumentSnapshot>>(

              future: getFriends(),

              builder: (context, snapshot) {

                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Text("No friends yet");
                }

                final friends = snapshot.data!;

                return ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: friends.length,

                  itemBuilder: (context, index) {

                    final data = friends[index];

                    return Card(
                      child: ListTile(

                        leading: const CircleAvatar(
                          child: Icon(Icons.person),
                        ),

                        title: Text(data["name"] ?? ""),

                        subtitle: Text(
                            "${data["phone"] ?? ""} • ${data["city"] ?? ""}"),

                      ),
                    );
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}