
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:safe_space_app/services/auth_service.dart';
import 'package:safe_space_app/services/chat_service.dart';
import 'package:safe_space_app/pages/chatpages/user_tile.dart';
import 'package:safe_space_app/pages/chatpages/chatpage.dart';

class HomePage extends StatelessWidget {
  HomePage({super.key});
  final ChatService _chatService = ChatService();
  final AuthService _authService = AuthService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Home",
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: const Color.fromARGB(255, 2, 93, 98),
        foregroundColor: Colors.white,
        centerTitle: true,
        elevation: 4,
      ),
      body: _buildDoctorsList(),
    );
  }

  Widget _buildDoctorsList() {
    return StreamBuilder(
      stream: _chatService.getDoctorsStream(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(
              child: Text("Error: ${snapshot.error}",
                  style: TextStyle(color: Colors.red)));
        }
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }
        return ListView(
          padding: const EdgeInsets.symmetric(vertical: 10.0),
          children: (snapshot.data! as List<Map<String, dynamic>>)
              .map<Widget>(
                  (userData) => _buildDoctorsListItem(userData, context))
              .toList(),
        );
      },
    );
  }

  Widget _buildDoctorsListItem(
      Map<String, dynamic> userData, BuildContext context) {
    final String email = userData["email"] ?? "No email provided";
    String userId = userData["id"] ?? ""; // Ensure userData contains the 'id'
    final User? user = FirebaseAuth.instance.currentUser;
    userId = user!.uid;

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.0),
        side: BorderSide(color: Colors.grey.shade300),
      ),
      elevation: 4,
      child: ListTile(
        contentPadding: const EdgeInsets.all(16.0),
        title: Text(
          email,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 18.0,
            color: Colors.black87,
          ),
        ),
        subtitle: Text(
          "Tap to start a conversation",
          style: TextStyle(color: Colors.grey[600]),
        ),
        trailing:
            Icon(Icons.message, color: const Color.fromARGB(255, 2, 93, 98)),
        onTap: () {
          if (userId.isNotEmpty) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ChatPage(
                  receiverEmail: email,
                  receiverId: userId,
                ),
              ),
            );
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text("User ID is missing.")),
            );
          }
        },
      ),
    );
  }
}
