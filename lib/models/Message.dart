import 'package:cloud_firestore/cloud_firestore.dart';

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
}
