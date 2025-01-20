import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:mobileprogramming/models/Message.dart';

class ChatService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final firebase_auth.FirebaseAuth _auth = firebase_auth.FirebaseAuth.instance;

  // Send a message to Firestore
  Future<void> sendMessage(String messageContent, {String? receiverId}) async {
    final user = _auth.currentUser;
    if (user == null) return; // User must be signed in to send messages

    final message = ChatMessage(
      senderId: user.uid,
      messageContent: messageContent,
      timestamp: Timestamp.now(),
      receiverId: receiverId,
    );

    await _firestore.collection('messages').add(message.toMap());
  }

  // Stream to listen for new messages in real-time
  Stream<List<ChatMessage>> getMessages({String? receiverId}) {
    final query = receiverId != null
        ? _firestore
            .collection('messages')
            .where('receiverId', isEqualTo: receiverId)
            .orderBy('timestamp', descending: true)
        : _firestore.collection('messages').orderBy('timestamp', descending: true);

    return query.snapshots().map((querySnapshot) {
      return querySnapshot.docs
          .map((doc) => ChatMessage.fromMap(doc.data()))
          .toList();
    });
  }
}
