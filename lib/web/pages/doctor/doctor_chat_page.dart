import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:safe_space_app/models/chat_message.dart';
import 'package:safe_space_app/services/chat_service.dart';
import 'package:firebase_auth/firebase_auth.dart';

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
              return const Center(
                child: Text('No chats yet. Start a conversation!'),
              );
            }

            return ListView.builder(
              itemCount: chats.length,
              itemBuilder: (context, index) {
                final chat = chats[index];
                return ListTile(
                  selected: chat['chatId'] == _selectedChatId,
                  leading: CircleAvatar(
                    backgroundColor: Colors.teal[100],
                    child: Icon(
                      chat['otherParticipantType'] == 'patient'
                          ? Icons.person
                          : Icons.pets,
                      color: Colors.teal,
                    ),
                  ),
                  title: FutureBuilder<DocumentSnapshot>(
                    future: FirebaseFirestore.instance
                        .collection(chat['otherParticipantType'] == 'patient'
                            ? 'humanpatients'
                            : 'pets')
                        .doc(chat['otherParticipantId'])
                        .get(),
                    builder: (context, snapshot) {
                      if (snapshot.hasData && snapshot.data!.exists) {
                        return Text(snapshot.data!['name'] ?? 'Unknown');
                      }
                      return const Text('Loading...');
                    },
                  ),
                  subtitle: Text(
                    chat['lastMessage'] ?? 'No messages yet',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  trailing: StreamBuilder<int>(
                    stream: _chatService.getUnreadMessageCount(
                      chat['chatId'],
                      _currentUser!.uid,
                    ),
                    builder: (context, snapshot) {
                      if (snapshot.hasData && snapshot.data! > 0) {
                        return Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: Colors.teal,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            snapshot.data.toString(),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                            ),
                          ),
                        );
                      }
                      return const SizedBox.shrink();
                    },
                  ),
                  onTap: () {
                    setState(() {
                      _selectedChatId = chat['chatId'];
                      _selectedPatientId = chat['otherParticipantId'];
                    });
                    _chatService.markMessagesAsRead(
                      chat['chatId'],
                      _currentUser!.uid,
                    );
                  },
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

      print('[DoctorChatPage] Raw existing chats data: ${existingChats.docs.map((doc) => doc.data()).toList()}');

      final existingPatientIds = existingChats.docs
          .map((doc) => (doc.data()['participants'] as List)
              .firstWhere((id) => id != _currentUser!.uid))
          .toSet();

      print('[DoctorChatPage] Found ${existingPatientIds.length} existing chats');
      print('[DoctorChatPage] Existing patient IDs: $existingPatientIds');

      // Get all patients
      final patientsSnapshot = await FirebaseFirestore.instance
          .collection(collection)
          .get();

      print('[DoctorChatPage] Raw patients data: ${patientsSnapshot.docs.map((doc) => {'id': doc.id, 'data': doc.data()}).toList()}');

      // Filter out patients who already have chats
      final availablePatients = patientsSnapshot.docs
          .where((doc) => !existingPatientIds.contains(doc.id))
          .toList();

      print('[DoctorChatPage] Found ${availablePatients.length} available patients');
      print('[DoctorChatPage] Available patient IDs: ${availablePatients.map((doc) => doc.id).toList()}');

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
        builder: (context) => AlertDialog(
          title: Row(
            children: [
              Icon(Icons.person_add, color: Colors.teal),
              const SizedBox(width: 8),
              Text('New Chat with ${_doctorType?.toLowerCase() == 'human' ? 'Patient' : 'Pet Owner'}'),
            ],
          ),
          content: SizedBox(
            width: double.maxFinite,
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: availablePatients.length,
              itemBuilder: (context, index) {
                final patient = availablePatients[index];
                return ListTile(
                  leading: CircleAvatar(
                    backgroundColor: Colors.teal[100],
                    child: Icon(
                      _doctorType?.toLowerCase() == 'human' ? Icons.person : Icons.pets,
                      color: Colors.teal,
                    ),
                  ),
                  title: Text(patient['name'] ?? 'Unknown'),
                  onTap: () async {
                    Navigator.pop(context);
                    await _createNewChat(patient.id);
                  },
                );
              },
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                'Cancel',
                style: TextStyle(color: Colors.grey[600]),
              ),
            ),
          ],
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

  Widget _buildChatMessages() {
    if (_selectedChatId == null) {
      return const Center(
        child: Text('Select a chat to start messaging'),
      );
    }

    return StreamBuilder<List<ChatMessage>>(
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
          return const Center(
            child: Text('No messages yet. Start the conversation!'),
          );
        }

        // Sort messages by timestamp in ascending order
        messages.sort((a, b) => a.timestamp.compareTo(b.timestamp));

        return ListView.builder(
          itemCount: messages.length,
          itemBuilder: (context, index) {
            final message = messages[index];
            final isMe = message.senderId == _currentUser?.uid;

            return Align(
              alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
              child: Container(
                margin: const EdgeInsets.symmetric(
                  horizontal: 8,
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
                child: Text(
                  message.content,
                  style: TextStyle(
                    color: isMe ? Colors.white : Colors.black,
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return Row(
      children: [
        // Chat List
        Container(
          width: 300,
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border(
              right: BorderSide(
                color: Colors.grey[300]!,
              ),
            ),
          ),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border(
                    bottom: BorderSide(
                      color: Colors.grey[300]!,
                    ),
                  ),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.message, color: Colors.teal),
                    const SizedBox(width: 8),
                    Text(
                      'Messages',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                  ],
                ),
              ),
              Expanded(child: _buildChatList()),
            ],
          ),
        ),
        // Chat Messages
        Expanded(
          child: Column(
            children: [
              if (_selectedChatId != null)
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border(
                      bottom: BorderSide(
                        color: Colors.grey[300]!,
                      ),
                    ),
                  ),
                  child: FutureBuilder<DocumentSnapshot>(
                    future: FirebaseFirestore.instance
                        .collection(_doctorType?.toLowerCase() == 'human' ? 'humanpatients' : 'pets')
                        .doc(_selectedPatientId)
                        .get(),
                    builder: (context, snapshot) {
                      if (snapshot.hasData && snapshot.data!.exists) {
                        return Row(
                          children: [
                            CircleAvatar(
                              backgroundColor: Colors.teal[100],
                              child: Icon(
                                _doctorType?.toLowerCase() == 'human'
                                    ? Icons.person
                                    : Icons.pets,
                                color: Colors.teal,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Text(
                              snapshot.data!['name'] ?? 'Unknown',
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                          ],
                        );
                      }
                      return const SizedBox.shrink();
                    },
                  ),
                ),
              Expanded(child: _buildChatMessages()),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border(
                    top: BorderSide(
                      color: Colors.grey[300]!,
                    ),
                  ),
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
                    IconButton(
                      onPressed: _sendMessage,
                      icon: const Icon(Icons.send),
                      color: Colors.teal,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
} 