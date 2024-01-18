import 'package:chat_app/screens/profile_screen.dart';
import 'package:chat_app/screens/settings_screen.dart';
import 'package:chat_app/widgets/chat_messages.dart';
import 'package:chat_app/widgets/new_message.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ChatScreen extends StatefulWidget {
  ChatScreen({Key? key}) : super(key: key);

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  int _selectedIndex = 0;

  AppBar _getAppBar(int index) {
    switch (index) {
      case 1:
        return AppBar(
          title: Text('Profile', style: TextStyle(color: Colors.white)),
          backgroundColor: Color(0xFFFEB81C),
          actions: [/* Profile actions if any */],
        );
      case 2:
        return AppBar(
          title: Text('Settings', style: TextStyle(color: Colors.white)),
          backgroundColor: Color(0xFFFEB81C),
          actions: [/* Settings actions if any */],
        );
      default:
        return AppBar(
          title: Text('Chat', style: TextStyle(color: Colors.white)),
          backgroundColor: Color(0xFFFEB81C),
          actions: [
            IconButton(
              icon: Icon(Icons.exit_to_app, color: Colors.white),
              onPressed: _logout,
              tooltip: 'Logout',
            ),
          ],
        );
    }
  }

  void _logout() async {
    await FirebaseAuth.instance.signOut();
    // Navigate to the AuthScreen or another page.
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _getAppBar(_selectedIndex),
      body: _getScreen(_selectedIndex),
      bottomNavigationBar: BottomNavigationBar(
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.chat, color: Colors.white),
            label: 'Chat',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person, color: Colors.white),
            label: 'Profile',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings, color: Colors.white),
            label: 'Settings',
          ),
        ],
        currentIndex: _selectedIndex,
        backgroundColor: Color(0xFFFEB81C),
        onTap: _onItemTapped,
        selectedItemColor: Colors.white,
      ),
    );
  }

  Widget _getScreen(int index) {
    switch (index) {
      case 1:
        return ProfileScreen();
      case 2:
        return SettingsScreen();
      default:
        return Column(
          children: <Widget>[
            Expanded(
              child: ChatMessages(),
            ),
            NewMessage(),
          ],
        );
    }
  }
}
