import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'bottom_navigation.dart';

class RegisterNameScreen extends StatefulWidget {
  @override
  _RegisterNameScreenState createState() => _RegisterNameScreenState();
}

class _RegisterNameScreenState extends State<RegisterNameScreen> {
  TextEditingController _textEditingController = TextEditingController();

  Future<String> getCurrentUserId() async {
    var user = await FirebaseAuth.instance.currentUser();
    final userId = user.uid;

    return userId;
  }

  // getUserDoc() async {
  //   final uid = await getCurrentUserId();
  //   final getUserDoc = Firestore.instance.collection('users').document(uid);

  //   return getUserDoc;
  // }

  // validateAndSubmitName(name) {
  //   getUserDoc.setData({
  //     'userName': name,
  //   });
  // }

  String name;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Container(
          padding: EdgeInsets.fromLTRB(16.0, 120.0, 16.0, 0),
          child: Column(
            mainAxisSize: MainAxisSize.max,
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.only(bottom: 24.0),
                child: Align(
                    alignment: Alignment.topLeft, child: Text('名前を登録してください。')),
              ),
              TextFormField(
                validator: (value) =>
                    value.isEmpty ? 'Name can\'t be empty' : null,
                onSaved: (value) => name = value,
                controller: _textEditingController,
                decoration: InputDecoration(
                  fillColor: Colors.grey,
                  labelText: '匿名でもなんでもOKです！！',
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(
                      color: Colors.lightBlue[200],
                      width: 1.0,
                    ),
                  ),
                ),
              ),
              Container(
                height: 40,
                margin: EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 0),
                child: RaisedButton(
                  color: Colors.lightBlueAccent,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(
                      Radius.circular(8.0),
                    ),
                  ),
                  onPressed: () async {
                    final uid = await getCurrentUserId();
                    final getUserDoc =
                        Firestore.instance.collection('users').document(uid);
                    if (_textEditingController.text == '') {
                      _textEditingController.text = '匿名';
                    }
                    getUserDoc.setData(
                        {'userName': _textEditingController.text},
                        merge: true);
                    Navigator.of(context).pushReplacement(
                      MaterialPageRoute(
                        builder: (context) => BottomNavigation(),
                      ),
                    );
                  },
                  child: Text('登録'),
                ),
              ),
              Container(
                padding: EdgeInsets.only(top: 32.0),
                child: Column(
                  children: <Widget>[
                    Text("ご注意"),
                    Container(
                        padding: EdgeInsets.only(top: 12.0),
                        child:
                            Text('ログアウトするとご自身のデータの削除や編集ができなくなってしまうのでご注意ください！')),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
