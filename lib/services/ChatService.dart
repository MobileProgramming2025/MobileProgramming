import 'package:cloud_firestore/cloud_firestore.dart';
<<<<<<< Updated upstream
import 'package:mobileprogramming/models/message.dart';

class ChatService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Send a message
  Future<void> sendMessage(String senderId, String receiverId, String message) async {
    try {
      // Create chat ID based on user IDs to ensure unique chat
      String chatId = senderId.compareTo(receiverId) < 0 ? '$senderId _$receiverId' : '$receiverId _$senderId';

      // Reference to the specific chat document
      DocumentReference chatDocRef = _firestore.collection('chats').doc(chatId);

      // Send the message to the messages collection under that chat
      await chatDocRef.collection('messages').add({
        'senderId': senderId,
        'receiverId': receiverId,
        'message': message,
        'timestamp': FieldValue.serverTimestamp(),  // Automatically set server timestamp
      });
    } catch (e) {
      print("Error sending message: $e");
    }
  }

Stream<List<Message>> getMessages(String senderId, String receiverId) {
  return FirebaseFirestore.instance
      .collection('chats')
      .doc(senderId)
      .collection(receiverId)
      .orderBy('timestamp')
      .snapshots()
      .map((snapshot) {
        return snapshot.docs.map((doc) => Message.fromFirestore(doc.data())).toList();
      });
}

  // Stream to get real-time messages between two users
  Stream<List<Message>> getMessagesStream(String senderId, String receiverId) {
    try {
      // Create chat ID based on user IDs
      String chatId = senderId.compareTo(receiverId) < 0 ? '$senderId _$receiverId' : '$receiverId _$senderId';

      // Stream of messages from Firestore
      return _firestore
          .collection('chats')
          .doc(chatId)
          .collection('messages')
          .orderBy('timestamp')
          .snapshots()
          .map((querySnapshot) {
            // Map Firestore documents to Message objects
            return querySnapshot.docs.map((doc) {
              return Message.fromFirestore(doc.data() as Map<String, dynamic>);
            }).toList();
          });
    } catch (e) {
      print("Error streaming messages: $e");
      return Stream.empty();
    }
=======
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
>>>>>>> Stashed changes
  }
}
