import 'package:cloud_firestore/cloud_firestore.dart';

class ChatUser {
  final String id;
  final String name;
  final String avatar;
  final String status;
  String lastMessage;
  DateTime lastMessageTime;
  final String? bio;
  final String? phoneNumber;
  final String? email;
  final String? facebook;
  final String? twitter;
  final String? instagram;
  final String? linkedin;

  // Constructor
  ChatUser({
    required this.id,
    required this.name,
    required this.avatar,
    required this.status,
    this.lastMessage = '',
    DateTime? lastMessageTime,
    this.bio,
    this.phoneNumber,
    this.email,
    this.facebook,
    this.twitter,
    this.instagram,
    this.linkedin,
  }) : lastMessageTime = lastMessageTime ?? DateTime.now();

  // Factory constructor to create ChatUser from Firestore data
  factory ChatUser.fromFirestore(Map<String, dynamic> data, String documentId) {
    return ChatUser(
      id: documentId,
      name: data['name'] ?? 'No name', // Ensure there is a fallback
      avatar: data['avatar'] ??
          '', // Default to an empty string if no avatar is provided
      status: data['status'] ?? 'Offline',
      lastMessage: data['lastMessage'] ?? '',
      lastMessageTime:
          (data['lastMessageTime'] as Timestamp?)?.toDate() ?? DateTime.now(),
      bio: data['bio'],
      phoneNumber: data['phoneNumber'],
      email: data['email'],
      facebook: data['facebook'],
      twitter: data['twitter'],
      instagram: data['instagram'],
      linkedin: data['linkedin'],
    );
  }

  // Method to convert ChatUser to a map
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'avatar': avatar,
      'status': status,
      'lastMessage': lastMessage,
      'lastMessageTime': lastMessageTime,
      'bio': bio,
      'phoneNumber': phoneNumber,
      'email': email,
      'facebook': facebook,
      'twitter': twitter,
      'instagram': instagram,
      'linkedin': linkedin,
    };
  }

  // Method to convert a Map<String, dynamic> to ChatUser
  static ChatUser fromMap(Map<String, dynamic> map) {
    return ChatUser(
      id: map['id'],
      name: map['name'],
      avatar: map['avatar'],
      status: map['status'] ?? 'Offline',
      lastMessage: map['lastMessage'] ?? '',
      lastMessageTime:
          (map['lastMessageTime'] as Timestamp?)?.toDate() ?? DateTime.now(),
      bio: map['bio'],
      phoneNumber: map['phoneNumber'],
      email: map['email'],
      facebook: map['facebook'],
      twitter: map['twitter'],
      instagram: map['instagram'],
      linkedin: map['linkedin'],
    );
  }
}
