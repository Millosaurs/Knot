import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart'; // Import Firebase Auth
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:knot/models/chat_user.dart';

class HomePage extends StatefulWidget {
  final String currentUserId;

  const HomePage({Key? key, required this.currentUserId}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<ChatUser> _allUsers = [];
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();

  ImageProvider _getImageProvider(String avatarUrl) {
    if (avatarUrl.startsWith('http')) {
      return NetworkImage(avatarUrl);
    } else if (avatarUrl.isNotEmpty) {
      return AssetImage(avatarUrl);
    } else {
      return const AssetImage('assets/placeholder.png');
    }
  }

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      setState(() {}); // Trigger rebuild on search input change
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          title: const Text('Knot'),
          actions: [
            IconButton(
              icon: const Icon(Icons.settings),
              onPressed: () {
                Navigator.of(context).pushNamed('/settings');
              },
            ),
          ],
        ),
        body: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: TextField(
                    controller: _searchController,
                    focusNode: _searchFocusNode,
                    decoration: const InputDecoration(
                      hintText: 'Search chats...',
                      prefixIcon: Icon(Icons.search),
                      border: InputBorder.none,
                    ),
                  ),
                ),
              ),
            ),
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream:
                    FirebaseFirestore.instance.collection('users').snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return const Center(child: Text('No users found.'));
                  }

                  // Map Firestore documents to ChatUser objects and exclude current user
                  _allUsers = snapshot.data!.docs
                      .map((doc) {
                        final data = doc.data() as Map<String, dynamic>;
                        return ChatUser(
                          id: doc.id,
                          name: data['name'] ?? '',
                          avatar: data['avatar'] ?? '',
                          status: data['status'] ?? 'Offline',
                          lastMessage: data['lastMessage'] ?? '',
                          lastMessageTime:
                              (data['lastMessageTime'] as Timestamp?)
                                      ?.toDate() ??
                                  DateTime.now(),
                        );
                      })
                      .where((user) => user.id != widget.currentUserId)
                      .toList();

                  // Apply filter based on search query
                  final filteredUsers = _allUsers.where((user) {
                    final query = _searchController.text.toLowerCase();
                    return user.name.toLowerCase().contains(query);
                  }).toList();

                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Card(
                      elevation: 4,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: ListView.separated(
                          itemCount: filteredUsers.length,
                          separatorBuilder: (context, index) => Padding(
                            padding: const EdgeInsets.only(left: 16, right: 16),
                            child: Container(
                              height: 1,
                              decoration: BoxDecoration(
                                color: Colors.grey.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(0.5),
                              ),
                            ),
                          ),
                          itemBuilder: (context, index) {
                            final user = filteredUsers[index];
                            return ListTile(
                              leading: CircleAvatar(
                                radius: 25,
                                backgroundImage: _getImageProvider(user.avatar),
                                child: user.avatar.isEmpty
                                    ? const Icon(Icons.person, size: 25)
                                    : null,
                              ),
                              title: Text(user.name),
                              subtitle: Text(
                                user.lastMessage,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              trailing: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Text(
                                    _formatLastMessageTime(
                                        user.lastMessageTime),
                                    style:
                                        Theme.of(context).textTheme.bodySmall,
                                  ),
                                  const SizedBox(height: 4),
                                  Container(
                                    width: 12,
                                    height: 12,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: _getStatusColor(user.status),
                                    ),
                                  ),
                                ],
                              ),
                              onTap: () {
                                Navigator.pushNamed(
                                  context,
                                  '/chat',
                                  arguments: {
                                    'selectedUser': user,
                                    'currentUser':
                                        FirebaseAuth.instance.currentUser,
                                  },
                                );
                              },
                            );
                          },
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'Online':
        return Colors.green;
      case 'Away':
        return Colors.orange;
      case 'Offline':
      default:
        return Colors.grey;
    }
  }

  String _formatLastMessageTime(DateTime time) {
    final now = DateTime.now();
    final difference = now.difference(time);

    if (difference.inDays > 0) {
      return '${difference.inDays}d ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m ago';
    } else {
      return 'Just now';
    }
  }
}
