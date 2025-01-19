import 'package:cloud_firestore/cloud_firestore.dart';

<<<<<<< Updated upstream
class Message {
  final String senderId;
  final String receiverId;
  final String message;
  final DateTime timestamp;

  Message({
    required this.senderId,
    required this.receiverId,
    required this.message,
    required this.timestamp,
  });

  // Factory method to create a Message object from Firestore data
  factory Message.fromFirestore(Map<String, dynamic> data) {
    return Message(
      senderId: data['senderId'],
      receiverId: data['receiverId'],
      message: data['message'],
      timestamp: (data['timestamp'] as Timestamp).toDate(), // Convert Firestore timestamp to DateTime
    );
  }

  // Convert Message object to Map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'senderId': senderId,
      'receiverId': receiverId,
      'message': message,
      'timestamp': Timestamp.fromDate(timestamp), // Convert DateTime to Firestore timestamp
    };
  }
=======
class ChatMessage {
  final String senderId;
  final String messageContent;
  final Timestamp timestamp;
  final String? receiverId;

  ChatMessage({
    required this.senderId,
    required this.messageContent,
    required this.timestamp,
    this.receiverId,
  });

  Map<String, dynamic> toMap() {
    return {
      'senderId': senderId,
      'messageContent': messageContent,
      'timestamp': timestamp,
      'receiverId': receiverId,
    };
  }

  static ChatMessage fromMap(Map<String, dynamic> map) {
    return ChatMessage(
      senderId: map['senderId'],
      messageContent: map['messageContent'],
      timestamp: map['timestamp'],
      receiverId: map['receiverId'],
    );
  }
>>>>>>> Stashed changes
}
