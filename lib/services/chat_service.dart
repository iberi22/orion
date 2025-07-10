
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:orion/models/chat_message.dart';

class ChatService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // Send a message to a chat room
  Future<void> sendMessage({
    required String chatId,
    required ChatMessage message,
  }) async {
    try {
      await _db
          .collection('chats')
          .doc(chatId)
          .collection('messages')
          .add({
        'text': message.text,
        'sender': message.sender,
        'timestamp': message.timestamp,
      });
    } catch (e) {
      print("Error sending message: $e");
      rethrow;
    }
  }

  // Stream messages from a chat room
  Stream<QuerySnapshot> getMessages({required String chatId}) {
    return _db
        .collection('chats')
        .doc(chatId)
        .collection('messages')
        .orderBy('timestamp', descending: true)
        .snapshots();
  }
}
