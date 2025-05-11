import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:safe_space_app/pages/chatpages/message.dart';

class ChatService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Stream to fetch doctors
  Stream<List<Map<String, dynamic>>> getDoctorsStream() {
    try {
      return _firestore.collection("doctors").snapshots().map((snapshot) {
        return snapshot.docs.map((doc) {
          final user = doc.data();
          return user;
        }).toList();
      });
    } catch (e) {
      print('Error fetching doctors: $e');
      return Stream.value([]);
    }
  }

  // Function to send a message
  Future<void> sendMessage(String receiverId, String message) async {
    try {
      final User? currentUser = _auth.currentUser;
      if (currentUser == null) {
        throw Exception('User not authenticated');
      }

      final String currentUserId = currentUser.uid;
      final String currentUserEmail = currentUser.email ?? 'unknown@domain.com';
      final Timestamp timestamp = Timestamp.now();

      // Create a new message object
      Message newMessage = Message(
        senderId: currentUserId,
        senderEmail: currentUserEmail,
        receiverId: receiverId,
        message: message,
        timestamp: timestamp,
      );

      // Generate a sorted conversation ID
      List<String> ids = [currentUserId, receiverId];
      ids.sort();
      String chatRoomId = ids.join("_");

      // Add the message to the Firestore collection
      await _firestore
          .collection("chat_rooms")
          .doc(chatRoomId)
          .collection("messages")
          .add(newMessage.toMap());
    } catch (e) {
      print('Error sending message: $e');
      rethrow;
    }
  }

  // Stream to retrieve messages between two users
  Stream<List<Message>> getMessages(String receiverId) {
    try {
      final User? currentUser = _auth.currentUser;
      if (currentUser == null) {
        throw Exception('User not authenticated');
      }

      final String currentUserId = currentUser.uid;

      // Generate a sorted conversation ID
      List<String> ids = [currentUserId, receiverId];
      ids.sort();
      String chatRoomId = ids.join("_");

      // Listen to Firestore updates
      return _firestore
          .collection("chat_rooms")
          .doc(chatRoomId)
          .collection("messages")
          .orderBy("timestamp", descending: false)
          .snapshots()
          .map((snapshot) {
        return snapshot.docs.map((doc) {
          return Message.fromMap(doc.data() as Map<String, dynamic>);
        }).toList();
      });
    } catch (e) {
      print('Error fetching messages: $e');
      return Stream.value([]);
    }
  }
}
