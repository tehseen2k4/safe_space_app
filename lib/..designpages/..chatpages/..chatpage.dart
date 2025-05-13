
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ChatPage extends StatelessWidget {
  final String receiverEmail;
  final String receiverId;

  ChatPage({
    super.key,
    required this.receiverEmail,
    required this.receiverId,
  })  : assert(
            receiverEmail.isNotEmpty, 'Receiver email cannot be null or empty'),
        assert(receiverId.isNotEmpty, 'Receiver ID cannot be null or empty');

  @override
  Widget build(BuildContext context) {
    final TextEditingController messageController = TextEditingController();
    final FirebaseFirestore _firestore = FirebaseFirestore.instance;
    final FirebaseAuth _auth = FirebaseAuth.instance;

    // Check if user is authenticated
    if (_auth.currentUser == null) {
      return Scaffold(
        body: Center(child: Text("User is not authenticated")),
      );
    }

    void sendMessage() async {
      if (messageController.text.trim().isEmpty) return;

      final String senderId = _auth.currentUser!.uid;
      final String senderEmail = _auth.currentUser?.email ??
          'unknown@domain.com'; // Default email if null
      final Timestamp timestamp = Timestamp.now();

      // Sort the user IDs to create a unique conversation ID
      List<String> ids = [senderId, receiverId];
      ids.sort();
      String conversationId = ids.join("_");

      try {
        await _firestore
            .collection("chats")
            .doc(conversationId)
            .collection("messages")
            .add({
          'senderId': senderId,
          'senderEmail': senderEmail,
          'receiverId': receiverId,
          'message': messageController.text.trim(),
          'timestamp': timestamp,
        });
        messageController.clear();
      } catch (e) {
        print('Error sending message: $e');
      }
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(receiverEmail),
        backgroundColor: const Color.fromARGB(255, 2, 93, 98),
        foregroundColor: Colors.white,
        centerTitle: true,
        elevation: 4,
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: _firestore
                  .collection("chats")
                  .doc([_auth.currentUser!.uid, receiverId].join("_"))
                  .collection("messages")
                  .orderBy('timestamp', descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Center(
                    child: Text('No messages yet.'),
                  );
                }

                final messages = snapshot.data!.docs;

                return ListView.builder(
                  reverse: true,
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    final messageData = messages[index];
                    final isMe =
                        messageData['senderId'] == _auth.currentUser!.uid;

                    return Align(
                      alignment:
                          isMe ? Alignment.centerRight : Alignment.centerLeft,
                      child: Container(
                        margin: const EdgeInsets.symmetric(
                            vertical: 8.0, horizontal: 12.0),
                        padding: const EdgeInsets.symmetric(
                            vertical: 10.0, horizontal: 16.0),
                        decoration: BoxDecoration(
                          color: isMe
                              ? const Color.fromARGB(255, 2, 93, 98)
                              : Colors.grey[300],
                          borderRadius: BorderRadius.circular(15.0),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black26,
                              blurRadius: 4.0,
                              offset: Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Text(
                          messageData['message'] ?? 'No message',
                          style: TextStyle(
                            color: isMe ? Colors.white : Colors.black87,
                            fontSize: 16.0,
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: messageController,
                    decoration: InputDecoration(
                      hintText: 'Type a message...',
                      filled: true,
                      fillColor: Colors.grey[200],
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                          vertical: 12, horizontal: 16),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  onPressed: sendMessage,
                  icon: const Icon(Icons.send),
                  color: const Color.fromARGB(255, 2, 93, 98),
                  iconSize: 28.0,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
