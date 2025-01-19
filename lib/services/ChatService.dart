import 'package:cloud_firestore/cloud_firestore.dart';
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
  }
}
