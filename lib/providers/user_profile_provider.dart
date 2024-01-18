import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';

class UserProfileProvider with ChangeNotifier {
  String? _userImageUrl;
  String? _userName;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  bool _isLoading = false;
  bool get isLoading => _isLoading;
  String? get userImageUrl => _userImageUrl;
  String? get userName => _userName;

  void setUserImageUrl(String? imageUrl) {
    _userImageUrl = imageUrl;
    notifyListeners();
  }

  void setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void setUserName(String? userName) {
    _userName = userName;
    notifyListeners();
  }

  Future<void> loadUserProfile() async {
    final user = _auth.currentUser;
    if (user != null) {
      final userData = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();
      _userName = userData.data()?['username'] as String?;
      _userImageUrl = userData.data()?['imageUrl'] as String?;

      notifyListeners();
    }
  }

  Future<void> updateUserName(String newUserName) async {
    final user = _auth.currentUser;
    if (user != null) {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .update({'username': newUserName});
      setUserName(newUserName);
    }
  }

  Future<void> updateProfileImage(File newImage) async {
    final user = _auth.currentUser;
    if (user != null) {
      setLoading(true);
      try {
        final ref = FirebaseStorage.instance
            .ref()
            .child('user_images')
            .child('${user.uid}.jpg');

        await ref.putFile(newImage);
        final url = await ref.getDownloadURL();

        await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .update({'imageUrl': url});

        setUserImageUrl(url);
      } catch (e) {
        // Handle any errors here
      } finally {
        setLoading(false);
      }
    }
  }
}

  // Include any other methods that are needed for updating the user profile data
