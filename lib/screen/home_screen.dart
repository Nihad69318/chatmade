import 'package:chatmade/screen/user_list_screen.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'login_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  Future<void> logoutUser() async {
    await FirebaseAuth.instance.signOut();
    Get.offAll(() => const LoginScreen());
  }

  Future<void> sendTestMessage() async {
    final currentUser = FirebaseAuth.instance.currentUser;
    await FirebaseFirestore.instance.collection('messages').add({
      'senderId': currentUser!.uid,
      'receiverId': 'TEST_RECEIVER_ID',
      'message': 'Hello from Lesson 4!',
      'createdAt': FieldValue.serverTimestamp(),
    });
    Get.snackbar('Sent', 'Test message created in Firestore!');
  }

  // UPDATE — edit the logged-in user's name field
  // UPDATE (auto-creates if missing) — edit the logged-in user's name field
  Future<void> editName(BuildContext context) async {
    final nameEditController = TextEditingController();
    final uid = FirebaseAuth.instance.currentUser!.uid;

    await Get.dialog(
      AlertDialog(
        title: const Text('Edit Your Name'),
        content: TextField(
          controller: nameEditController,
          decoration: const InputDecoration(hintText: 'Enter new name'),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              final newName = nameEditController.text.trim();
              if (newName.isEmpty) return;

              try {
                await FirebaseFirestore.instance
                    .collection('users')
                    .doc(uid)
                    .set(
                  {'name': newName},
                  SetOptions(merge: true), // update if exists, create if missing
                );

                Get.back();
                Get.snackbar('Updated', 'Your name has been changed.');
              } catch (e) {
                print('UPDATE ERROR: $e');
                Get.snackbar('Error', 'Failed to update name: $e');
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }
  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Home'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: logoutUser,
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Logged in as: ${user?.email}'),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: sendTestMessage,
              child: const Text('Send Test Message'),
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: () => Get.to(() => const UsersListScreen()),
              child: const Text('View All Users'),
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: () => editName(context),
              child: const Text('Edit My Name'),
            ),
          ],
        ),
      ),
    );
  }
}