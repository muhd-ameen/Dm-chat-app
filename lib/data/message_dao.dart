import 'package:cloud_firestore/cloud_firestore.dart';
import 'message.dart';

class MessageDao {
  // 1
  final CollectionReference collection =
      FirebaseFirestore.instance.collection('messages');

  void saveMessage(Message message) {
    collection.add(message.toJson());
  }

  Stream<QuerySnapshot> getMessageStream() {
    return collection.snapshots();
  }

  void deleteMessage({String? id}) {
    collection.doc(id).delete();
  }

  void deleteAllMessages() {
    collection.get().then((QuerySnapshot snapshot) {
      snapshot.docs.forEach((f) => f.reference.delete());
    });
  }
}
