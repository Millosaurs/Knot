import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class ProfilePageSetup extends StatefulWidget {
  const ProfilePageSetup({Key? key}) : super(key: key);

  @override
  _ProfilePageSetupState createState() => _ProfilePageSetupState();
}

class _ProfilePageSetupState extends State<ProfilePageSetup> {
  final _nameController = TextEditingController();
  final _bioController = TextEditingController();
  String? _selectedAvatar;
  File? _localAvatar;
  bool _isLoading = false;
  String _status = "Online"; // Default status

  final List<String> _avatars = [
    'assets/avatar/1.png',
    'assets/avatar/2.png',
    'assets/avatar/3.png',
    'assets/avatar/4.png',
    'assets/avatar/5.png',
    'assets/avatar/6.png',
    'assets/avatar/7.png',
    'assets/avatar/8.png',
    'assets/avatar/9.png',
    // Add more avatar URLs here
  ];

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final userId = FirebaseAuth.instance.currentUser!.uid;
    final userData =
        await FirebaseFirestore.instance.collection('users').doc(userId).get();
    if (userData.exists) {
      setState(() {
        _nameController.text = userData['name'] ?? '';
        _bioController.text = userData['bio'] ?? '';
        _selectedAvatar = userData['avatar'];
        _status = userData['status'] ?? 'Online';
      });
    }
  }

  Future<void> _saveProfile() async {
    if (_nameController.text.isEmpty ||
        (_selectedAvatar == null && _localAvatar == null)) {
      _showSnackBar('Please select an avatar and enter a name');
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final userId = FirebaseAuth.instance.currentUser!.uid;
      String avatarUrl = _selectedAvatar ?? '';

      if (_localAvatar != null) {
        // TODO: Implement file upload to a storage service and get the URL
        // avatarUrl = await uploadFile(_localAvatar!);
      }

      final userRef =
          FirebaseFirestore.instance.collection('users').doc(userId);
      final userSnapshot = await userRef.get();

      final userData = {
        'name': _nameController.text.trim(),
        'bio': _bioController.text.trim(),
        'avatar': avatarUrl,
        'status': _status,
      };

      if (userSnapshot.exists) {
        await userRef.update(userData);
      } else {
        await userRef.set(userData);
      }

      _showSnackBar('Profile updated successfully');
      Navigator.of(context).pushReplacementNamed('/home');
    } catch (e) {
      _showSnackBar('Error updating profile: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);

    if (image != null) {
      setState(() {
        _localAvatar = File(image.path);
        _selectedAvatar = null;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Profile'),
        automaticallyImplyLeading: false,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Text(
                'Avatar',
                style: Theme.of(context).textTheme.titleLarge,
              ),
            ),
            const SizedBox(height: 16),
            _buildAvatarSelection(),
            const SizedBox(height: 32),
            _buildTextField(_nameController, 'Name', Icons.person),
            const SizedBox(height: 24),
            _buildTextField(_bioController, 'Bio', Icons.info, maxLines: 3),
            const SizedBox(height: 24),
            _buildStatusSelection(),
            const SizedBox(height: 32),
            _buildSaveButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildAvatarSelection() {
    return Wrap(
      alignment: WrapAlignment.center,
      spacing: 16,
      runSpacing: 16,
      children: [
        ..._avatars.map((avatarUrl) => _buildAvatarOption(avatarUrl)),
        _buildLocalAvatarOption(),
      ],
    );
  }

  Widget _buildAvatarOption(String avatarUrl) {
    final isSelected = _selectedAvatar == avatarUrl;
    return GestureDetector(
      onTap: () => setState(() {
        _selectedAvatar = avatarUrl;
        _localAvatar = null;
      }),
      child: CircleAvatar(
        backgroundImage: AssetImage(avatarUrl),
        radius: 40,
        child: isSelected
            ? Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.black.withOpacity(0.5),
                ),
                child: const Icon(Icons.check, color: Colors.white),
              )
            : null,
      ),
    );
  }

  Widget _buildLocalAvatarOption() {
    return GestureDetector(
      onTap: _pickImage,
      child: CircleAvatar(
        radius: 40,
        backgroundColor: Theme.of(context).colorScheme.surfaceVariant,
        child: _localAvatar != null
            ? ClipOval(
                child: Image.file(
                  _localAvatar!,
                  width: 80,
                  height: 80,
                  fit: BoxFit.cover,
                ),
              )
            : Icon(
                Icons.add_photo_alternate,
                size: 30,
                color: Theme.of(context).colorScheme.primary,
              ),
      ),
    );
  }

  Widget _buildTextField(
    TextEditingController controller,
    String label,
    IconData icon, {
    int maxLines = 1,
  }) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      color: Theme.of(context).colorScheme.surfaceVariant,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        child: TextFormField(
          controller: controller,
          maxLines: maxLines,
          decoration: InputDecoration(
            labelText: label,
            icon: Icon(icon),
            border: InputBorder.none,
          ),
        ),
      ),
    );
  }

  Widget _buildStatusSelection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Status', style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          children: [
            _buildStatusChip('Online', Icons.circle, Colors.green),
            _buildStatusChip('Away', Icons.access_time, Colors.orange),
            _buildStatusChip('Offline', Icons.circle_outlined, Colors.grey),
          ],
        ),
      ],
    );
  }

  Widget _buildStatusChip(String status, IconData icon, Color color) {
    return ChoiceChip(
      label: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 18, color: _status == status ? Colors.white : color),
          const SizedBox(width: 8),
          Text(status),
        ],
      ),
      selected: _status == status,
      onSelected: (selected) {
        if (selected) {
          setState(() {
            _status = status;
          });
        }
      },
      selectedColor: color,
      backgroundColor: Theme.of(context).colorScheme.surface,
    );
  }

  Widget _buildSaveButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _isLoading ? null : _saveProfile,
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: _isLoading
            ? const CircularProgressIndicator()
            : const Text('Save Profile', style: TextStyle(fontSize: 16)),
      ),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _bioController.dispose();
    super.dispose();
  }
}
