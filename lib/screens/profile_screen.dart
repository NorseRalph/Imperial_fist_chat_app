import 'dart:io';
import 'package:chat_app/providers/user_profile_provider.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

class ProfileScreen extends StatefulWidget {
  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  TextEditingController? _userNameController;

  @override
  void initState() {
    super.initState();
    final userProfile =
        Provider.of<UserProfileProvider>(context, listen: false);
    userProfile.loadUserProfile().then((_) {
      // Initialize the TextEditingController with the current username
      setState(() {
        _userNameController = TextEditingController(text: userProfile.userName);
      });
    });
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedImage = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 50,
      maxWidth: 150,
    );
    if (pickedImage != null) {
      final userProfileProvider =
          Provider.of<UserProfileProvider>(context, listen: false);
      await userProfileProvider.updateProfileImage(File(pickedImage.path));
    }
  }

  Future<void> _saveForm() async {
    final userProfileProvider =
        Provider.of<UserProfileProvider>(context, listen: false);
    if (!_userNameController!.text.isNotEmpty ||
        userProfileProvider.userName == _userNameController!.text) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('No changes detected')));
      return;
    }
    await userProfileProvider.updateUserName(_userNameController!.text);
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text('Username updated successfully')));
  }

  @override
  Widget build(BuildContext context) {
    final userProfileProvider = Provider.of<UserProfileProvider>(context);

    return Scaffold(
      body: userProfileProvider.isLoading
          ? Center(child: CircularProgressIndicator())
          : _buildUserProfileContent(),
    );
  }

  Widget _buildUserProfileContent() {
    final user = _auth.currentUser;
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          SizedBox(height: 20),
          _buildProfileImage(),
          SizedBox(height: 10),
          ElevatedButton.icon(
            onPressed: _pickImage,
            icon: Icon(Icons.image),
            label: Text('Change Profile Picture'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Color(0xFFFEB81C),
              foregroundColor: Colors.white,
            ),
          ),
          SizedBox(height: 20),
          TextFormField(
            controller: _userNameController,
            decoration: InputDecoration(
              labelText: 'Username',
              border: OutlineInputBorder(),
            ),
          ),
          SizedBox(height: 20),
          if (user != null)
            Text(
              'Email: ${user.email}',
              style: TextStyle(fontSize: 16),
            ),
          SizedBox(height: 10),
          ElevatedButton(
            onPressed: _saveForm,
            child: Text('Save Changes'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Color(0xFFFEB81C),
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileImage() {
    // Correctly access the UserProfileProvider from the context
    String? userImageUrl =
        Provider.of<UserProfileProvider>(context).userImageUrl;

    return CircleAvatar(
      radius: 60,
      backgroundImage: userImageUrl != null
          ? NetworkImage(userImageUrl)
          : AssetImage('assets/images/imperial_logo.png') as ImageProvider,
    );
  }

  @override
  void dispose() {
    _userNameController?.dispose();
    super.dispose();
  }
}
