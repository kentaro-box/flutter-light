import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class IsCheckPost {
  final Map<String, dynamic> post;
  final String uid;
  final String category;

  const IsCheckPost({Key key, this.post, this.uid, this.category});

  bool isMyPost(post, uid) {
    return post == uid;
  }

  bool isUserCategory(category) {
    return category == 'advisor';
  }
}
