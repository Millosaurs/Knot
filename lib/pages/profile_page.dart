import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:knot/models/chat_user.dart'; // Adjust the import path if needed
import 'package:url_launcher/url_launcher.dart';

class ProfilePage extends StatelessWidget {
  final String userId;

  const ProfilePage({Key? key, required this.userId}) : super(key: key);

  Future<ChatUser> _getUserData(String userId) async {
    final userDoc =
        await FirebaseFirestore.instance.collection('users').doc(userId).get();
    if (userDoc.exists) {
      return ChatUser.fromFirestore(userDoc.data()!, userDoc.id);
    } else {
      throw Exception('User not found');
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<ChatUser>(
      future: _getUserData(userId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        } else if (!snapshot.hasData) {
          return Center(child: Text('No user data found'));
        }

        final user = snapshot.data!;
        return Scaffold(
          appBar: AppBar(
            title: Text(user.name),
          ),
          body: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  CircleAvatar(
                    radius: 30,
                    backgroundImage: _getImageProvider(user.avatar),
                    child: user.avatar.isEmpty
                        ? const Icon(Icons.person, size: 30)
                        : null,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    user.name,
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    user.status, // Display the status
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color:
                              _getStatusColor(user.status), // Use dynamic color
                        ),
                  ),
                  const SizedBox(height: 20),
                  _buildSocialMediaRow(context),
                  const SizedBox(height: 20),
                  _buildInfoCard(context, user),
                  const SizedBox(height: 20),
                  _buildActionList(context),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  ImageProvider _getImageProvider(String avatarUrl) {
    if (avatarUrl.startsWith('http')) {
      return NetworkImage(avatarUrl);
    } else if (avatarUrl.isNotEmpty) {
      return AssetImage(avatarUrl);
    } else {
      return const AssetImage('assets/placeholder.png');
    }
  }

  Widget _buildSocialMediaRow(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildSocialIcon(
            context, Icons.facebook, 'Facebook', 'https://facebook.com'),
        _buildSocialIcon(context, Icons.link, 'Twitter', 'https://twitter.com'),
        _buildSocialIcon(
            context, Icons.camera_alt, 'Instagram', 'https://instagram.com'),
        _buildSocialIcon(
            context, Icons.link, 'LinkedIn', 'https://linkedin.com'),
      ],
    );
  }

  Widget _buildSocialIcon(
      BuildContext context, IconData icon, String label, String link) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: IconButton(
        icon: Icon(icon),
        onPressed: () => _launchUrl(link),
        color: Theme.of(context).colorScheme.primary,
      ),
    );
  }

  Future<void> _launchUrl(String url) async {
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  Widget _buildInfoCard(BuildContext context, ChatUser user) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildInfoRow(
                context, Icons.info, 'Bio', user.bio ?? 'No bio available'),
            const Divider(),
            _buildInfoRow(context, Icons.phone, 'Phone',
                user.phoneNumber ?? 'Not provided'),
            const Divider(),
            _buildInfoRow(context, Icons.email, 'Email',
                user.email ?? 'No email provided'),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(
      BuildContext context, IconData icon, String title, String content) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: Theme.of(context).colorScheme.secondary),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 4),
                Text(
                  content,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionList(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Column(
        children: [
          _buildActionItem(
            context,
            'Block',
            Icons.block,
            () => _showAlert(
                context, 'Block user functionality to be implemented'),
          ),
          _buildDivider(),
          _buildActionItem(
            context,
            'Report',
            Icons.flag,
            () => _showAlert(
                context, 'Report user functionality to be implemented'),
          ),
          _buildDivider(),
          _buildActionItem(
            context,
            'Delete Chat',
            Icons.delete,
            () => _showAlert(
                context, 'Delete chat functionality to be implemented'),
          ),
        ],
      ),
    );
  }

  Widget _buildActionItem(
      BuildContext context, String label, IconData icon, VoidCallback onTap) {
    final Color veryLightRedColor =
        Colors.redAccent.withOpacity(1); // Lighter red

    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 16.0),
        child: Row(
          children: [
            Icon(icon, color: veryLightRedColor),
            const SizedBox(width: 16),
            Text(
              label,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: veryLightRedColor,
                    fontWeight: FontWeight.w600, // Increased font weight
                  ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDivider() {
    return Padding(
      padding: const EdgeInsets.symmetric(
          horizontal: 16.0), // Add horizontal padding
      child: const Divider(height: 1),
    );
  }

  void _showAlert(BuildContext context, String message) {
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
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
}
