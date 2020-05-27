import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';

class ConnectFirestorePost {
  Firestore _firestore = Firestore.instance;

  final Stream<QuerySnapshot> firestoreGetPosts = Firestore.instance
      .collection('posts')
      .orderBy('createdAt', descending: true)
      .snapshots();

  DocumentReference getPostDocumentRef =
      // getはドキュメント指定
      Firestore.instance.collection('posts').document();
}
