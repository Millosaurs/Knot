import 'package:cloud_firestore/cloud_firestore.dart';

class ChatMessage {
  final String senderId;
  final String receiverId;
  final String content;
  final Timestamp timestamp;

  // Constructor for ChatMessage
  ChatMessage({
    required this.senderId,
    required this.receiverId,
    required this.content,
    required this.timestamp,
  });

  // Factory constructor to create a ChatMessage from Firestore data
  factory ChatMessage.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return ChatMessage(
      senderId: data['senderId'],
      receiverId: data['receiverId'],
      content: data['content'],
      timestamp: data['timestamp'],
    );
  }

  // Convert ChatMessage to a map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'senderId': senderId,
      'receiverId': receiverId,
      'content': content,
      'timestamp': timestamp,
    };
  }
}
