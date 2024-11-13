import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class SettingsPage extends StatelessWidget {
  SettingsPage({Key? key}) : super(key: key);

  ImageProvider _getImageProvider(String avatarUrl) {
    if (avatarUrl.startsWith('http')) {
      // Use NetworkImage if it’s a valid URL
      return NetworkImage(avatarUrl);
    } else if (avatarUrl.isNotEmpty) {
      // Use AssetImage if it’s a local path
      return AssetImage(avatarUrl);
    } else {
      // Fallback image or icon if avatar is empty or invalid
      return const AssetImage('assets/placeholder.png');
    }
  }

  final user = FirebaseAuth.instance.currentUser!;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        elevation: 0,
      ),
      body: SafeArea(
        child: Column(
          children: [
            _buildUserProfileSection(context),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(16.0),
                children: [
                  Card(
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      children: [
                        _buildSettingsTile(
                          icon: Icons.person,
                          title: 'Account',
                          onTap: () {
                            // TODO: Navigate to account settings
                          },
                        ),
                        _buildDivider(),
                        _buildSettingsTile(
                          icon: Icons.lock,
                          title: 'Privacy',
                          onTap: () {
                            // TODO: Navigate to privacy settings
                          },
                        ),
                        _buildDivider(),
                        _buildSettingsTile(
                          icon: Icons.security,
                          title: 'Security',
                          onTap: () {
                            // TODO: Navigate to security settings
                          },
                        ),
                        _buildDivider(),
                        _buildSettingsTile(
                          icon: Icons.notifications,
                          title: 'Notifications',
                          onTap: () {
                            // TODO: Navigate to notification settings
                          },
                        ),
                        _buildDivider(),
                        _buildSettingsTile(
                          icon: Icons.info,
                          title: 'About',
                          onTap: () {
                            // TODO: Show app info
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () async {
                    await FirebaseAuth.instance.signOut();
                    Navigator.of(context).pushReplacementNamed('/login');
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color.fromARGB(214, 255, 125, 3),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: const Text(
                    'Logout',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text("Logged In as: ${user.email!}"),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUserProfileSection(BuildContext context) {
    return FutureBuilder<DocumentSnapshot>(
      future:
          FirebaseFirestore.instance.collection('users').doc(user.uid).get(),
      builder:
          (BuildContext context, AsyncSnapshot<DocumentSnapshot> snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const CircularProgressIndicator();
        }

        if (snapshot.hasError) {
          return Text("Error: ${snapshot.error}");
        }

        if (snapshot.hasData && snapshot.data!.exists) {
          Map<String, dynamic> userData =
              snapshot.data!.data() as Map<String, dynamic>;

          String avatarUrl =
              userData['avatar'] ?? ''; // Get the avatar URL from Firestore

          return Card(
            margin: const EdgeInsets.all(16.0),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 30, // Adjust the radius to make it larger
                        backgroundImage: _getImageProvider(avatarUrl),
                        child: avatarUrl.isEmpty
                            ? const Icon(Icons.person, size: 30)
                            : null,
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              userData['name'] ?? 'No Name',
                              style: Theme.of(context).textTheme.titleLarge,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              userData['bio'] ?? 'No Bio',
                              style: Theme.of(context).textTheme.bodyMedium,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.of(context).pushNamed('/profile_setup');
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Theme.of(context).primaryColor,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text('Edit Profile'),
                    ),
                  ),
                ],
              ),
            ),
          );
        }

        return const Text("No user data found.");
      },
    );
  }

  Widget _buildSettingsTile({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(icon),
      title: Text(title),
      trailing: const Icon(Icons.chevron_right),
      onTap: onTap,
    );
  }

  Widget _buildDivider() {
    return const Divider(
      height: 1,
      thickness: 1,
      indent: 16,
      endIndent: 16,
    );
  }
}
