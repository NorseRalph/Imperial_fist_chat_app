import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:chat_app/widgets/theme_notifier.dart';

class NewMessage extends StatefulWidget {
  @override
  _NewMessageState createState() => _NewMessageState();
}

class _NewMessageState extends State<NewMessage> {
  final _controller = TextEditingController();
  var _enteredMessage = '';
  var _isSending = false; // New variable to track if a message is being sent

  Future<void> _sendMessage() async {
    if (_enteredMessage.trim().isEmpty || _isSending) {
      return;
    }
    FocusScope.of(context).unfocus();
    setState(() {
      _isSending = true;
    });
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      setState(() {
        _isSending = false;
      });
      _showErrorSnackBar("You need to be logged in to send messages.");
      return;
    }

    try {
      final userData = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();

      if (!userData.exists) {
        throw Exception("User data not found");
      }
      await FirebaseFirestore.instance.collection('chat').add({
        'text': _enteredMessage,
        'createdAt': Timestamp.now(),
        'userId': user.uid,
        'username': userData.data()?['username'], // Correct field name
        'imageUrl': userData.data()?['imageUrl'] ??
            '', // Correct field name and provide an empty string if the imageUrl is not available
      });

      _controller.clear();
      setState(() {
        _enteredMessage = '';
      });
    } catch (error) {
      _showErrorSnackBar("Failed to send message: ${error.toString()}");
    } finally {
      setState(() {
        _isSending = false;
      });
    }
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Theme.of(context).errorColor,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    var currentTheme = Provider.of<ThemeNotifier>(context).getTheme();
    return Container(
      margin: EdgeInsets.only(top: 8),
      padding: EdgeInsets.all(8),
      child: Row(
        children: <Widget>[
          Expanded(
            child: TextField(
              controller: _controller,
              textCapitalization: TextCapitalization.sentences,
              autocorrect: true,
              enableSuggestions: true,
              maxLines: null, // Allows for expansion
              keyboardType: TextInputType.multiline,
              decoration: InputDecoration(labelText: 'Send a message...'),
              onChanged: (value) {
                setState(() {
                  _enteredMessage = value;
                });
              },
            ),
          ),
          IconButton(
            color: currentTheme
                .primaryColor, // Use the primary color from the theme
            icon: _isSending ? CircularProgressIndicator() : Icon(Icons.send),
            onPressed: _enteredMessage.trim().isEmpty || _isSending
                ? null
                : _sendMessage,
          ),
        ],
      ),
    );
  }
}
