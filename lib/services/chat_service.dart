import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:safe_space_app/mobile/pages/chatpages/message.dart';
import 'package:safe_space_app/models/chat_message.dart';

class ChatService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Stream to fetch doctors
  Stream<List<Map<String, dynamic>>> getDoctorsStream() {
    print('[ChatService] Fetching doctors stream');
    return _firestore.collection("doctors").snapshots().map((snapshot) {
      print('[ChatService] Retrieved ${snapshot.docs.length} doctors');
      return snapshot.docs.map((doc) {
        final user = doc.data();
        return user;
      }).toList();
    });
  }

  // Function to send a message
  Future<void> sendMessage(String receiverId, String message) async {
    try {
      print('[ChatService] Attempting to send message to receiver: $receiverId');
      final String currentUserId = _auth.currentUser!.uid;
      print('[ChatService] Current user ID: $currentUserId');

      // Check if email is null and assign a default value
      final String currentUserEmail =
          _auth.currentUser?.email ?? 'unknown@domain.com';
      print('[ChatService] Current user email: $currentUserEmail');

      final Timestamp timestamp = Timestamp.now();
      print('[ChatService] Message timestamp: $timestamp');

      // Create a new message object
      Message newMessage = Message(
        senderId: currentUserId,
        senderEmail: currentUserEmail,
        receiverId: receiverId,
        message: message,
        timestamp: timestamp,
      );
      print('[ChatService] Created new message object');

      // Generate a sorted conversation ID
      List<String> ids = [currentUserId, receiverId];
      ids.sort();
      String chatRoomId = ids.join("_");
      print('[ChatService] Generated chat room ID: $chatRoomId');

      // Add the message to the Firestore collection
      await _firestore
          .collection("chats")
          .doc(chatRoomId)
          .collection("messages")
          .add(newMessage.toMap());
      print('[ChatService] Successfully added message to Firestore');
    } catch (e) {
      print('[ChatService] Error sending message: $e');
      rethrow;
    }
  }

  // Stream to retrieve messages between two users
  Stream<List<Message>> getMessages(String receiverId) {
    try {
      print('[ChatService] Attempting to get messages for receiver: $receiverId');
      final String currentUserId = _auth.currentUser!.uid;
      print('[ChatService] Current user ID: $currentUserId');

      // Generate a sorted conversation ID
      List<String> ids = [currentUserId, receiverId];
      ids.sort();
      String chatRoomId = ids.join("_");
      print('[ChatService] Generated chat room ID: $chatRoomId');

      // Listen to Firestore updates
      return _firestore
          .collection("chat_rooms")
          .doc(chatRoomId)
          .collection("messages")
          .orderBy("timestamp", descending: false)
          .snapshots()
          .map((snapshot) {
        print('[ChatService] Retrieved ${snapshot.docs.length} messages');
        return snapshot.docs.map((doc) {
          return Message.fromMap(doc.data() as Map<String, dynamic>);
        }).toList();
      });
    } catch (e) {
      print('[ChatService] Error fetching messages: $e');
      rethrow;
    }
  }

  // Get chat ID for two users
  String getChatId(String userId1, String userId2) {
    print('[ChatService] Generating chat ID for users: $userId1 and $userId2');
    final chatId = userId1.compareTo(userId2) < 0
        ? '${userId1}_$userId2'
        : '${userId2}_$userId1';
    print('[ChatService] Generated chat ID: $chatId');
    return chatId;
  }

  // Stream of messages for a specific chat
  Stream<List<ChatMessage>> getMessagesStream(String chatId) {
    print('[ChatService] Getting messages stream for chat: $chatId');
    return _firestore
        .collection('chats')
        .doc(chatId)
        .collection('messages')
        .orderBy('timestamp', descending: false)
        .snapshots()
        .map((snapshot) {
      print('[ChatService] Retrieved ${snapshot.docs.length} messages for chat: $chatId');
      return snapshot.docs
          .map((doc) => ChatMessage.fromJson(doc.data()))
          .toList();
    });
  }

  // Send a message
  Future<void> sendMessageToChat({
    required String senderId,
    required String receiverId,
    required String content,
    required String senderType,
    required String receiverType,
  }) async {
    try {
      print('[ChatService] Attempting to send message to chat');
      print('[ChatService] Sender: $senderId ($senderType)');
      print('[ChatService] Receiver: $receiverId ($receiverType)');
      print('[ChatService] Content: $content');

      final chatId = getChatId(senderId, receiverId);
      final message = ChatMessage(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        senderId: senderId,
        receiverId: receiverId,
        content: content,
        timestamp: DateTime.now(),
        isRead: false,
        senderType: senderType,
        receiverType: receiverType,
      );
      print('[ChatService] Created new chat message with ID: ${message.id}');

      await _firestore
          .collection('chats')
          .doc(chatId)
          .collection('messages')
          .doc(message.id)
          .set(message.toJson());
      print('[ChatService] Successfully added message to Firestore');

      // Update last message in chat metadata
      await _firestore.collection('chats').doc(chatId).set({
        'lastMessage': content,
        'lastMessageTime': message.timestamp,
        'participants': [senderId, receiverId],
        'participantTypes': [senderType, receiverType],
      }, SetOptions(merge: true));
      print('[ChatService] Successfully updated chat metadata');
    } catch (e) {
      print('[ChatService] Error sending message to chat: $e');
      rethrow;
    }
  }

  // Get list of chats for a user
  Stream<List<Map<String, dynamic>>> getUserChats(String userId) {
    print('[ChatService] Getting chats for user: $userId');
    return _firestore
        .collection('chats')
        .where('participants', arrayContains: userId)
        .snapshots()
        .map((snapshot) {
      print('[ChatService] Retrieved ${snapshot.docs.length} chats for user: $userId');
      return snapshot.docs.map((doc) {
        final data = doc.data();
        final otherParticipantId = (data['participants'] as List)
            .firstWhere((id) => id != userId, orElse: () => '');
        final otherParticipantType = (data['participantTypes'] as List)
            .firstWhere((type) => type != data['participantTypes'][0],
                orElse: () => '');
        print('[ChatService] Chat ${doc.id}: Other participant: $otherParticipantId ($otherParticipantType)');
        return {
          'chatId': doc.id,
          'lastMessage': data['lastMessage'] ?? '',
          'lastMessageTime': data['lastMessageTime'],
          'otherParticipantId': otherParticipantId,
          'otherParticipantType': otherParticipantType,
        };
      }).toList();
    });
  }

  // Mark messages as read
  Future<void> markMessagesAsRead(String chatId, String userId) async {
    try {
      print('[ChatService] Marking messages as read for chat: $chatId, user: $userId');
      final messages = await _firestore
          .collection('chats')
          .doc(chatId)
          .collection('messages')
          .where('receiverId', isEqualTo: userId)
          .where('isRead', isEqualTo: false)
          .get();
      print('[ChatService] Found ${messages.docs.length} unread messages');

      final batch = _firestore.batch();
      for (var doc in messages.docs) {
        batch.update(doc.reference, {'isRead': true});
      }
      await batch.commit();
      print('[ChatService] Successfully marked messages as read');
    } catch (e) {
      print('[ChatService] Error marking messages as read: $e');
      rethrow;
    }
  }

  // Get unread message count
  Stream<int> getUnreadMessageCount(String chatId, String userId) {
    print('[ChatService] Getting unread message count for chat: $chatId, user: $userId');
    return _firestore
        .collection('chats')
        .doc(chatId)
        .collection('messages')
        .where('receiverId', isEqualTo: userId)
        .where('isRead', isEqualTo: false)
        .snapshots()
        .map((snapshot) {
      print('[ChatService] Found ${snapshot.docs.length} unread messages');
      return snapshot.docs.length;
    });
  }
}
