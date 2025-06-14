import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:safe_space_app/models/chat_message.dart';
import 'package:safe_space_app/services/chat_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';

class DoctorChatPage extends StatefulWidget {
  const DoctorChatPage({Key? key}) : super(key: key);

  @override
  State<DoctorChatPage> createState() => _DoctorChatPageState();
}

class _DoctorChatPageState extends State<DoctorChatPage> {
  final ChatService _chatService = ChatService();
  final TextEditingController _messageController = TextEditingController();
  final User? _currentUser = FirebaseAuth.instance.currentUser;
  String? _selectedChatId;
  String? _selectedPatientId;
  String? _doctorType;
  bool _isLoading = true;
  bool _showConversation = false;

  @override
  void initState() {
    super.initState();
    _loadDoctorType();
  }

  Future<void> _loadDoctorType() async {
    if (_currentUser != null) {
      final doc = await FirebaseFirestore.instance
          .collection('doctors')
          .doc(_currentUser!.uid)
          .get();
      if (doc.exists) {
        setState(() {
          _doctorType = doc.data()?['doctorType'] as String?;
          _isLoading = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  Future<void> _sendMessage() async {
    if (_messageController.text.trim().isEmpty ||
        _selectedPatientId == null ||
        _currentUser == null) return;

    print('[DoctorChatPage] Sending message to patient: $_selectedPatientId');
    print('[DoctorChatPage] Doctor type: $_doctorType');

    await _chatService.sendMessageToChat(
      senderId: _currentUser!.uid,
      receiverId: _selectedPatientId!,
      content: _messageController.text.trim(),
      senderType: 'doctor',
      receiverType: _doctorType?.toLowerCase() == 'human' ? 'patient' : 'petpatient',
    );

    _messageController.clear();
  }

  Widget _buildChatList() {
    if (_currentUser == null) return const SizedBox.shrink();

    return Stack(
      children: [
        StreamBuilder<List<Map<String, dynamic>>>(
          stream: _chatService.getUserChats(_currentUser!.uid),
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            }

            if (!snapshot.hasData) {
              return const Center(child: CircularProgressIndicator());
            }

            final chats = snapshot.data!;
            if (chats.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.chat_bubble_outline, size: 64, color: Colors.grey[400]),
                    const SizedBox(height: 16),
                    Text(
                      'No chats yet',
                      style: TextStyle(
                        fontSize: 18,
                        color: Colors.grey[600],
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Start a conversation with a patient',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[500],
                      ),
                    ),
                  ],
                ),
              );
            }

            print('[DoctorChatPage] Loading chat list. Doctor type: $_doctorType');
            for (var chat in chats) {
              print('[DoctorChatPage] Chat data: ${chat.toString()}');
            }

            return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: chats.length,
              itemBuilder: (context, index) {
                final chat = chats[index];
                return Card(
                  elevation: 2,
                  margin: const EdgeInsets.only(bottom: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: InkWell(
                    onTap: () {
                      setState(() {
                        _selectedChatId = chat['chatId'];
                        _selectedPatientId = chat['otherParticipantId'];
                        _showConversation = true;
                      });
                      _chatService.markMessagesAsRead(
                        chat['chatId'],
                        _currentUser!.uid,
                      );
                    },
                    borderRadius: BorderRadius.circular(12),
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Row(
                        children: [
                          CircleAvatar(
                            radius: 28,
                            backgroundColor: Colors.teal[100],
                            child: Icon(
                              _doctorType?.toLowerCase() == 'human'
                                  ? Icons.person
                                  : Icons.pets,
                              color: Colors.teal,
                              size: 32,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                FutureBuilder<DocumentSnapshot>(
                                  future: FirebaseFirestore.instance
                                      .collection(_doctorType?.toLowerCase() == 'human' ? 'humanpatients' : 'pets')
                                      .doc(chat['otherParticipantId'])
                                      .get(),
                                  builder: (context, snapshot) {
                                    if (snapshot.hasData && snapshot.data!.exists) {
                                      final patientData = snapshot.data!.data() as Map<String, dynamic>;
                                      return Row(
                                        children: [
                                          Expanded(
                                            child: Text(
                                              patientData['name'] ?? 'Unknown',
                                              style: const TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 16,
                                              ),
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                          Text(
                                            chat['lastMessageTime'] != null
                                                ? DateFormat('HH:mm').format(
                                                    (chat['lastMessageTime'] as Timestamp).toDate())
                                                : '',
                                            style: TextStyle(
                                              color: Colors.grey[500],
                                              fontSize: 12,
                                            ),
                                          ),
                                        ],
                                      );
                                    }
                                    return const Text('Loading...');
                                  },
                                ),
                                const SizedBox(height: 4),
                                Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        chat['lastMessage'] ?? 'No messages yet',
                                        style: TextStyle(
                                          color: Colors.grey[600],
                                          fontSize: 14,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                    StreamBuilder<int>(
                                      stream: _chatService.getUnreadMessageCount(
                                        chat['chatId'],
                                        _currentUser!.uid,
                                      ),
                                      builder: (context, snapshot) {
                                        if (snapshot.hasData && snapshot.data! > 0) {
                                          return Container(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 8,
                                              vertical: 4,
                                            ),
                                            decoration: BoxDecoration(
                                              color: Colors.teal,
                                              borderRadius: BorderRadius.circular(12),
                                            ),
                                            child: Text(
                                              snapshot.data.toString(),
                                              style: const TextStyle(
                                                color: Colors.white,
                                                fontSize: 12,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          );
                                        }
                                        return const SizedBox.shrink();
                                      },
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            );
          },
        ),
        Positioned(
          right: 16,
          bottom: 16,
          child: FloatingActionButton(
            onPressed: _showNewChatDialog,
            backgroundColor: Colors.teal,
            child: const Icon(Icons.add, color: Colors.white),
          ),
        ),
      ],
    );
  }

  Future<void> _showNewChatDialog() async {
    if (_currentUser == null || _doctorType == null) {
      print('[DoctorChatPage] Cannot show dialog: User or doctor type is null');
      return;
    }

    print('[DoctorChatPage] Showing new chat dialog for doctor type: $_doctorType');
    
    // Validate doctor type
    if (_doctorType?.toLowerCase() != 'human' && _doctorType?.toLowerCase() != 'veterinary') {
      print('[DoctorChatPage] Invalid doctor type: $_doctorType');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Invalid doctor type'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final collection = _doctorType?.toLowerCase() == 'human' ? 'humanpatients' : 'pets';
    print('[DoctorChatPage] Fetching patients from collection: $collection');

    try {
      // First get all existing chats to filter out patients who already have chats
      final existingChats = await FirebaseFirestore.instance
          .collection('chats')
          .where('participants', arrayContains: _currentUser!.uid)
          .get();

      final existingPatientIds = existingChats.docs
          .map((doc) => (doc.data()['participants'] as List)
              .firstWhere((id) => id != _currentUser!.uid))
          .toSet();

      // Get all patients
      final patientsSnapshot = await FirebaseFirestore.instance
          .collection(collection)
          .get();

      // Filter out patients who already have chats
      final availablePatients = patientsSnapshot.docs
          .where((doc) => !existingPatientIds.contains(doc.id))
          .toList();

      if (!mounted) return;

      if (availablePatients.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('No available ${_doctorType?.toLowerCase() == 'human' ? 'patients' : 'pet owners'} to chat with'),
            backgroundColor: Colors.orange,
          ),
        );
        return;
      }

      showDialog(
        context: context,
        builder: (context) => Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Container(
            width: 400,
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.teal[50],
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(Icons.person_add, color: Colors.teal[700]),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      'New Chat',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.teal[700],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  'Select a ${_doctorType?.toLowerCase() == 'human' ? 'patient' : 'pet owner'} to start chatting',
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 16),
                Container(
                  height: 300,
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey[300]!),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: ListView.builder(
                    padding: const EdgeInsets.all(8),
                    itemCount: availablePatients.length,
                    itemBuilder: (context, index) {
                      final patient = availablePatients[index];
                      return Card(
                        elevation: 0,
                        margin: const EdgeInsets.only(bottom: 8),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                          side: BorderSide(color: Colors.grey[200]!),
                        ),
                        child: ListTile(
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          leading: CircleAvatar(
                            radius: 24,
                            backgroundColor: Colors.teal[100],
                            child: Icon(
                              _doctorType?.toLowerCase() == 'human'
                                  ? Icons.person
                                  : Icons.pets,
                              color: Colors.teal,
                              size: 28,
                            ),
                          ),
                          title: Text(
                            patient['name'] ?? 'Unknown',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          subtitle: _doctorType?.toLowerCase() == 'human'
                              ? Text(
                                  'Patient',
                                  style: TextStyle(
                                    color: Colors.grey[600],
                                    fontSize: 14,
                                  ),
                                )
                              : Text(
                                  'Pet Owner',
                                  style: TextStyle(
                                    color: Colors.grey[600],
                                    fontSize: 14,
                                  ),
                                ),
                          onTap: () async {
                            Navigator.pop(context);
                            await _createNewChat(patient.id);
                          },
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: Text(
                        'Cancel',
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      );
    } catch (e) {
      print('[DoctorChatPage] Error fetching patients: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading patients: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _createNewChat(String patientId) async {
    if (_currentUser == null || _doctorType == null) {
      print('[DoctorChatPage] Cannot create chat: User or doctor type is null');
      return;
    }

    print('[DoctorChatPage] Creating new chat with patient: $patientId');
    print('[DoctorChatPage] Doctor type: $_doctorType');

    try {
      final chatId = _chatService.getChatId(_currentUser!.uid, patientId);
      
      // Check if chat already exists
      final existingChat = await FirebaseFirestore.instance
          .collection('chats')
          .doc(chatId)
          .get();

      if (existingChat.exists) {
        print('[DoctorChatPage] Chat already exists: $chatId');
        setState(() {
          _selectedChatId = chatId;
          _selectedPatientId = patientId;
          _showConversation = true;
        });
        return;
      }

      // Create chat metadata
      await FirebaseFirestore.instance.collection('chats').doc(chatId).set({
        'participants': [_currentUser!.uid, patientId],
        'participantTypes': ['doctor', _doctorType?.toLowerCase() == 'human' ? 'patient' : 'petpatient'],
        'createdAt': FieldValue.serverTimestamp(),
        'doctorType': _doctorType?.toLowerCase(),
      });

      print('[DoctorChatPage] Successfully created chat: $chatId');

      setState(() {
        _selectedChatId = chatId;
        _selectedPatientId = patientId;
        _showConversation = true;
      });
    } catch (e) {
      print('[DoctorChatPage] Error creating chat: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error creating chat: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Widget _buildConversationView() {
    if (_selectedChatId == null) {
      return const Center(
        child: Text('Select a chat to start messaging'),
      );
    }

    return Column(
      children: [
        // Chat Header
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.1),
                spreadRadius: 1,
                blurRadius: 3,
                offset: const Offset(0, 1),
              ),
            ],
          ),
          child: Row(
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () {
                  setState(() {
                    _showConversation = false;
                  });
                },
              ),
              FutureBuilder<DocumentSnapshot>(
                future: FirebaseFirestore.instance
                    .collection(_doctorType?.toLowerCase() == 'human'
                        ? 'humanpatients'
                        : 'pets')
                    .doc(_selectedPatientId)
                    .get(),
                builder: (context, snapshot) {
                  if (snapshot.hasData && snapshot.data!.exists) {
                    final patientData = snapshot.data!.data() as Map<String, dynamic>;
                    return Expanded(
                      child: Row(
                        children: [
                          CircleAvatar(
                            radius: 20,
                            backgroundColor: Colors.teal[100],
                            child: Icon(
                              _doctorType?.toLowerCase() == 'human'
                                  ? Icons.person
                                  : Icons.pets,
                              color: Colors.teal,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  patientData['name'] ?? 'Unknown',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                                if (_doctorType?.toLowerCase() == 'human')
                                  Text(
                                    'Patient',
                                    style: TextStyle(
                                      color: Colors.grey[600],
                                      fontSize: 12,
                                    ),
                                  )
                                else
                                  Text(
                                    'Pet Owner',
                                    style: TextStyle(
                                      color: Colors.grey[600],
                                      fontSize: 12,
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  }
                  return const SizedBox.shrink();
                },
              ),
            ],
          ),
        ),
        // Messages
        Expanded(
          child: StreamBuilder<List<ChatMessage>>(
            stream: _chatService.getMessagesStream(_selectedChatId!),
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                return Center(child: Text('Error: ${snapshot.error}'));
              }

              if (!snapshot.hasData) {
                return const Center(child: CircularProgressIndicator());
              }

              final messages = snapshot.data!;
              if (messages.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.chat_bubble_outline, size: 64, color: Colors.grey[400]),
                      const SizedBox(height: 16),
                      Text(
                        'No messages yet',
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.grey[600],
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Start the conversation!',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[500],
                        ),
                      ),
                    ],
                  ),
                );
              }

              // Sort messages by timestamp in ascending order
              messages.sort((a, b) => a.timestamp.compareTo(b.timestamp));

              return ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                itemCount: messages.length,
                itemBuilder: (context, index) {
                  final message = messages[index];
                  final isMe = message.senderId == _currentUser?.uid;
                  final showDate = index == 0 ||
                      !_isSameDay(
                        messages[index - 1].timestamp,
                        message.timestamp,
                      );

                  return Column(
                    children: [
                      if (showDate)
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          child: Text(
                            _formatMessageDate(message.timestamp),
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 12,
                            ),
                          ),
                        ),
                      Align(
                        alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
                        child: Container(
                          margin: const EdgeInsets.symmetric(
                            horizontal: 4,
                            vertical: 4,
                          ),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 10,
                          ),
                          decoration: BoxDecoration(
                            color: isMe ? Colors.teal : Colors.grey[200],
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                message.content,
                                style: TextStyle(
                                  color: isMe ? Colors.white : Colors.black,
                                  fontSize: 15,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                DateFormat('HH:mm').format(message.timestamp),
                                style: TextStyle(
                                  color: isMe
                                      ? Colors.white.withOpacity(0.7)
                                      : Colors.grey[600],
                                  fontSize: 11,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  );
                },
              );
            },
          ),
        ),
        // Message Input
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.1),
                spreadRadius: 1,
                blurRadius: 3,
                offset: const Offset(0, -1),
              ),
            ],
          ),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _messageController,
                  decoration: InputDecoration(
                    hintText: 'Type a message...',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(24),
                      borderSide: BorderSide.none,
                    ),
                    filled: true,
                    fillColor: Colors.grey[100],
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 10,
                    ),
                  ),
                  maxLines: null,
                ),
              ),
              const SizedBox(width: 8),
              Container(
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.teal,
                ),
                child: IconButton(
                  onPressed: _sendMessage,
                  icon: const Icon(Icons.send),
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  bool _isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year &&
        date1.month == date2.month &&
        date1.day == date2.day;
  }

  String _formatMessageDate(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final messageDate = DateTime(date.year, date.month, date.day);

    if (messageDate == today) {
      return 'Today';
    } else if (messageDate == today.subtract(const Duration(days: 1))) {
      return 'Yesterday';
    } else {
      return DateFormat('MMM d, yyyy').format(date);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return _showConversation ? _buildConversationView() : _buildChatList();
  }
} 