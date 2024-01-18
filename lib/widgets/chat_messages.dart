import 'package:chat_app/providers/user_profile_provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import 'message_bubble.dart';

class ChatMessages extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final userProfile = Provider.of<UserProfileProvider>(context);

    return StreamBuilder(
      stream: FirebaseFirestore.instance
          .collection('chat')
          .orderBy('createdAt', descending: true)
          .snapshots(),
      builder: (ctx, AsyncSnapshot<QuerySnapshot> chatSnapshot) {
        if (chatSnapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }

        final chatDocs = chatSnapshot.data?.docs ?? [];

        return ListView.builder(
          reverse: true,
          itemCount: chatDocs.length,
          itemBuilder: (ctx, index) {
            var messageData = chatDocs[index].data() as Map<String, dynamic>;

            // Use data from UserProfileProvider if the message is from the current user
            String userName = messageData['userId'] == user?.uid
                ? userProfile.userName ?? ''
                : messageData['username'] ?? '';
            String userImage = messageData['userId'] == user?.uid
                ? userProfile.userImageUrl ?? ''
                : messageData['imageUrl'] ?? '';

            return MessageBubble(
              userName: userName,
              userImage: userImage,
              message: messageData['text'] ?? '',
              isMe: messageData['userId'] == user?.uid,
              key: ValueKey(chatDocs[index].id),
            );
          },
        );
      },
    );
  }
}
