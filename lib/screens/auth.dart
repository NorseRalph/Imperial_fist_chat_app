import 'dart:io';

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:chat_app/widgets/user_image_picker.dart';

// Enum for Authentication Mode
enum AuthMode { login, signUp }

class AuthScreen extends StatefulWidget {
  const AuthScreen({Key? key}) : super(key: key);

  @override
  AuthScreenState createState() => AuthScreenState();
}

class AuthScreenState extends State<AuthScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey();
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _usernameController = TextEditingController();

  AuthMode _authMode = AuthMode.login;
  bool _isAuthenticating = false;
  File? _selectedImage;
  bool _isPasswordVisible = false;

  // Helper function to validate email
  bool _validateEmail(String? email) {
    if (email == null || email.isEmpty) {
      return false;
    }
    const pattern = r'^\w+@[a-zA-Z_]+?\.[a-zA-Z]{2,3}$';
    return RegExp(pattern).hasMatch(email);
  }

  // Helper function to validate password
  bool _validatePassword(String? password) {
    if (password == null || password.isEmpty) {
      return false;
    }
    const minLength = 6;
    return password.length >= minLength &&
        password.contains(RegExp(r'[A-Z]')) &&
        password.contains(RegExp(r'[a-z]')) &&
        password.contains(RegExp(r'[0-9]'));
  }

  // Helper function to show a SnackBar
  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.redAccent,
      ),
    );
  }

  // Function to handle form submission
  Future<void> _submitForm() async {
    final formState = _formKey.currentState;
    if (formState != null && formState.validate()) {
      formState.save();
      setState(() {
        _isAuthenticating = true;
      });

      try {
        UserCredential userCredential;
        if (_authMode == AuthMode.login) {
          userCredential = await _firebaseAuth.signInWithEmailAndPassword(
            email: _emailController.text.trim(),
            password: _passwordController.text.trim(),
          );
        } else {
          userCredential = await _firebaseAuth.createUserWithEmailAndPassword(
            email: _emailController.text.trim(),
            password: _passwordController.text.trim(),
          );
          if (userCredential.user != null) {
            // User was created, now let's upload the image and store the data
            String imageUrl = await _uploadUserImage(userCredential.user!.uid);
            await _updateFirestoreUserData(userCredential.user!.uid, imageUrl);
          } else {
            throw Exception('User could not be created');
          }
        }
      } on FirebaseAuthException catch (e) {
        _handleFirebaseAuthException(e);
      } catch (e) {
        _showErrorSnackBar(e.toString());
      } finally {
        setState(() {
          _isAuthenticating = false;
        });
      }
    }
  }

  // Function to upload user image to Firebase Storage
  Future<String> _uploadUserImage(String userId) async {
    File imageToUpload = _selectedImage ??
        File(
            'assets/images/imperial_logo.png'); // Use default if no image selected

    final storageRef = FirebaseStorage.instance
        .ref()
        .child('user_images')
        .child('$userId.jpg');
    await storageRef.putFile(imageToUpload);

    return await storageRef
        .getDownloadURL(); // This will return the URL as a String
  }

  // Function to update Firestore user data
  Future<void> _updateFirestoreUserData(String userId, String imageUrl) async {
    try {
      await FirebaseFirestore.instance.collection('users').doc(userId).set({
        'username': _usernameController.text.trim(), // Field name is 'username'
        'email': _emailController.text.trim(),
        'imageUrl': imageUrl, // Field name is 'imageUrl'
      });
    } catch (e) {
      throw Exception('Failed to store user data: ${e.toString()}');
    }
  }

  Future<void> _resetPassword(String email) async {
    if (_validateEmail(email)) {
      try {
        await _firebaseAuth.sendPasswordResetEmail(email: email);
        _showErrorSnackBar('Password reset email sent! Check your inbox.');
      } on FirebaseAuthException catch (e) {
        _handleFirebaseAuthException(e);
      }
    } else {
      _showErrorSnackBar('Invalid email format.');
    }
  }

  // Function to handle Firebase Authentication exceptions
  void _handleFirebaseAuthException(FirebaseAuthException e) {
    String errorMessage = 'An error occurred. Please try again later.';
    if (e.code == 'user-not-found') {
      errorMessage = 'No user found with that email.';
    } else if (e.code == 'wrong-password') {
      errorMessage = 'Wrong password provided.';
    } else if (e.code == 'email-already-in-use') {
      errorMessage = 'The email address is already in use by another account.';
    }
    _showErrorSnackBar(errorMessage);
  }

  // Toggle authentication mode
  void _switchAuthMode() {
    setState(() {
      _authMode =
          _authMode == AuthMode.login ? AuthMode.signUp : AuthMode.login;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFEB81C),
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                margin: const EdgeInsets.all(20),
                child:
                    Image.asset('assets/images/imperial_logo.png', width: 200),
              ),
              const Text(
                'Imperial Fist Chat App',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                ),
              ),
              Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (_authMode == AuthMode.signUp)
                          UserImagePicker(onPickImage: (image) {
                            setState(() {
                              _selectedImage = image;
                            });
                          }),
                        if (_authMode == AuthMode.signUp)
                          TextFormField(
                            controller: _usernameController,
                            decoration:
                                const InputDecoration(labelText: 'Username'),
                          ),
                        TextFormField(
                          controller: _emailController,
                          decoration: InputDecoration(labelText: 'Email'),
                          keyboardType: TextInputType.emailAddress,
                          validator: (value) => _validateEmail(value)
                              ? null
                              : 'Invalid email format',
                        ),
                        TextFormField(
                          controller: _passwordController,
                          decoration: InputDecoration(
                            labelText: 'Password',
                            // Add an icon button to toggle password visibility
                            suffixIcon: IconButton(
                              icon: Icon(
                                // Change the icon based on the password visibility
                                _isPasswordVisible
                                    ? Icons.visibility
                                    : Icons.visibility_off,
                              ),
                              onPressed: () {
                                // Update the state to toggle password visibility
                                setState(() {
                                  _isPasswordVisible = !_isPasswordVisible;
                                });
                              },
                            ),
                          ),
                          obscureText:
                              !_isPasswordVisible, // Use the boolean to obscure text
                          validator: (value) => _validatePassword(value)
                              ? null
                              : 'Password must be at least 6 characters long and include uppercase, lowercase, and numbers',
                        ),
                        if (_authMode == AuthMode.login)
                          Align(
                            alignment: Alignment.centerRight,
                            child: TextButton(
                              onPressed: () {
                                final email = _emailController.text.trim();
                                if (email.isNotEmpty) {
                                  _resetPassword(email);
                                } else {
                                  _showErrorSnackBar(
                                      'Please enter your email address.');
                                }
                              },
                              child: const Text(
                                'Forgot password?',
                                style: TextStyle(color: Colors.blue),
                              ),
                            ),
                          ),
                        const SizedBox(height: 20),
                        if (_isAuthenticating)
                          const CircularProgressIndicator(),
                        if (!_isAuthenticating)
                          ElevatedButton(
                            onPressed: _submitForm,
                            child: Text(
                              _authMode == AuthMode.login ? 'Login' : 'Sign Up',
                              style: const TextStyle(color: Colors.white),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFFFEB81C),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(40),
                              ),
                              padding: const EdgeInsets.symmetric(
                                vertical: 10,
                                horizontal: 40,
                              ),
                            ),
                          ),
                        TextButton(
                          onPressed: _switchAuthMode,
                          child: Text(
                            _authMode == AuthMode.login
                                ? 'Create an Account'
                                : 'I already have an account',
                            style: const TextStyle(color: Colors.black),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
