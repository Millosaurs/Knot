import 'package:flutter/material.dart';
import 'package:knot/models/chat_user.dart';
import 'package:knot/models/chat_message.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ChatPage extends StatefulWidget {
  final ChatUser selectedUser;
  final User currentUser;

  const ChatPage({
    Key? key,
    required this.selectedUser,
    required this.currentUser,
  }) : super(key: key);

  @override
  _ChatPageState createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final FocusNode _focusNode = FocusNode();
  // FocusNode to detect keyboard visibility

  // Get avatar for the user, checking URL or using placeholder
  ImageProvider _getImageProvider(String avatarUrl) {
    if (avatarUrl.startsWith('http')) {
      return NetworkImage(avatarUrl);
    } else if (avatarUrl.isNotEmpty) {
      return AssetImage(avatarUrl);
    } else {
      return const AssetImage('assets/placeholder.png');
    }
  }

  // Function to send a message to Firestore
  void _sendMessage() async {
    if (_messageController.text.isNotEmpty) {
      final message = ChatMessage(
        senderId: widget.currentUser.uid, // Current user as sender
        receiverId: widget.selectedUser.id, // Selected user as receiver
        content: _messageController.text,
        timestamp: Timestamp.now(),
      );

      // Chat ID for currentUser -> selectedUser
      String chatId1 =
          'chat_${widget.currentUser.uid}_${widget.selectedUser.id}';
      // Chat ID for selectedUser -> currentUser
      String chatId2 =
          'chat_${widget.selectedUser.id}_${widget.currentUser.uid}';

      // Save message to Firestore in both directions
      await FirebaseFirestore.instance
          .collection('chats')
          .doc(chatId1)
          .collection('messages')
          .add(message.toMap());

      await FirebaseFirestore.instance
          .collection('chats')
          .doc(chatId2)
          .collection('messages')
          .add(message.toMap());

      _messageController.clear();
      _scrollToBottom();
    }
  }

  // Scroll to the bottom of the message list
  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: GestureDetector(
          onTap: () {
            // Navigate to the profile page
            Navigator.pushNamed(
              context,
              '/profile',
              arguments: widget
                  .selectedUser.id, // Pass the selected user's ID as a String
            );
          },
          child: Row(
            children: [
              Hero(
                tag: 'avatar_${widget.selectedUser.id}',
                child: CircleAvatar(
                  radius: 20,
                  backgroundImage:
                      _getImageProvider(widget.selectedUser.avatar),
                ),
              ),
              const SizedBox(width: 8),
              Text(widget.selectedUser.name),
            ],
          ),
        ),
      ),
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: Column(
          children: [
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('chats')
                    .doc(
                        'chat_${widget.selectedUser.id}_${widget.currentUser.uid}')
                    .collection('messages')
                    .orderBy('timestamp',
                        descending: true) // Keep descending order for now
                    .snapshots(),
                builder: (context, snapshot) {
                  // Remove the loading indicator entirely
                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return const Center(child: Text('No messages.'));
                  }

                  // Reverse the order of messages here
                  final messages = snapshot.data!.docs
                      .map((doc) => ChatMessage.fromFirestore(doc))
                      .toList()
                      .reversed
                      .toList(); // Reverse the order to display newer messages below

                  return ListView.builder(
                    controller: _scrollController,
                    padding:
                        const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                    itemCount: messages.length,
                    itemBuilder: (context, index) {
                      final message = messages[index];
                      final isMe = message.senderId == widget.currentUser.uid;
                      return _buildMessageBubble(message, isMe);
                    },
                  );
                },
              ),
            ),
            _buildMessageInput(),
          ],
        ),
      ),
    );
  }

  // Builds the message bubbles in the chat UI
  Widget _buildMessageBubble(ChatMessage message, bool isMe) {
    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.75,
        ),
        child: Card(
          color: isMe
              ? Theme.of(context).colorScheme.primary
              : Theme.of(context).colorScheme.surfaceContainerHighest,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  message.content,
                  style: TextStyle(
                    color: isMe
                        ? Theme.of(context).colorScheme.onPrimary
                        : Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _formatMessageTime(message.timestamp),
                  style: TextStyle(
                    fontSize: 10,
                    color: isMe
                        ? Theme.of(context)
                            .colorScheme
                            .onPrimary
                            .withOpacity(0.7)
                        : Theme.of(context)
                            .colorScheme
                            .onSurfaceVariant
                            .withOpacity(0.7),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Input area for the message
  Widget _buildMessageInput() {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -3),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            IconButton(
              icon: const Icon(Icons.image),
              onPressed: () {},
            ),
            Expanded(
              child: TextField(
                controller: _messageController,
                focusNode: _focusNode, // Attach the focus node to the TextField
                decoration: InputDecoration(
                  hintText: 'Type a message...',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(24),
                    borderSide: BorderSide.none,
                  ),
                  filled: true,
                  fillColor:
                      Theme.of(context).colorScheme.surfaceContainerHighest,
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                ),
              ),
            ),
            IconButton(
              icon: const Icon(Icons.send),
              onPressed: _sendMessage,
            ),
          ],
        ),
      ),
    );
  }

  // Format the message timestamp
  String _formatMessageTime(Timestamp timestamp) {
    DateTime time = timestamp.toDate();
    return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
  }
}
