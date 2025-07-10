
import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Future<void> addUser({
    required String userId,
    required String name,
    required String email,
  }) async {
    try {
      await _db.collection('users').doc(userId).set({
        'name': name,
        'email': email,
        'createdAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      // In a real app, you'd want more robust error handling
      print('Error adding user to Firestore: $e');
      rethrow;
    }
  }

  // We can add more methods here later, for example, to manage chat messages.
}
