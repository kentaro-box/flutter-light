import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bbs/home_screen.dart';
import 'bottom_navigation.dart';
import 'firestore/connect_firestore_user.dart';

class ConsulterRegistrationScreen extends StatefulWidget {
  @override
  _ConsulterRegistrationScreenState createState() =>
      _ConsulterRegistrationScreenState();
}

class _ConsulterRegistrationScreenState
    extends State<ConsulterRegistrationScreen> {
  bool isLogged = false;
  var userId;

  String email;
  String password;
  String name;
  // TextEditingController _passwordTextController = TextEditingController();
  // TextEditingController _nameTextController = TextEditingController();
  // TextEditingController _emailTextController = TextEditingController();
  // ConnectFirestoreUser _connectFirestore = ConnectFirestoreUser();
  FirebaseAuth _firebaseAuth;

  final formKey = new GlobalKey<FormState>();

  bool validateAndSave() {
    final form = formKey.currentState;
    if (form.validate()) {
      form.save();
      return true;
    } else {
      return false;
    }
  }

  final _userCollectionRef = Firestore.instance.collection('users');

  void validateAndSubmit() async {
    if (validateAndSave()) {
      try {
        FirebaseUser user = (await FirebaseAuth.instance
                .createUserWithEmailAndPassword(
                    email: email.trim(), password: password))
            .user;
        print('Registered User: ${user.uid}');

        if (user != null) {
          isLogged = true;
          userId = user.uid;
          final snapshot = await _userCollectionRef.document(userId).get();
          if (!snapshot.exists) {
            _userCollectionRef.document(userId).setData({
              'userName': name,
              'userId': userId,
              'createdAt': new DateTime.now(),
              'userEmail': user.email,
              'category': 'consulter'
            });
          }
          setState(() {});
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(
              builder: (context) => BottomNavigation(),
            ),
          );
        }
      } catch (e) {
        print('Error: $e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: Text('相談者登録画面'),
        flexibleSpace: Container(
          decoration: BoxDecoration(
              gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: <Color>[Colors.lightBlue[300], Colors.cyan[100]])),
        ),
      ),
      body: Container(
        alignment: Alignment.center,
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/feather.png'),
            fit: BoxFit.cover,
            alignment: Alignment.center,
          ),
        ),
        child: Column(
          children: <Widget>[
            Form(
              key: formKey,
              child: Container(
                width: MediaQuery.of(context).size.width,
                height: MediaQuery.of(context).size.height - 80,
                child: ListView(
                  children: <Widget>[
                    Container(
                      margin: EdgeInsets.fromLTRB(16.0, 64.0, 16.0, 0),
                      color: Colors.white.withOpacity(0.7),
                      child: Padding(
                        padding: EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 16.0),
                        child: TextFormField(
                          validator: (value) =>
                              value.isEmpty ? 'Name can\'t be empty' : null,
                          onSaved: (value) => name = value,
                          // controller: _nameTextController,
                          // onChanged: (String name) {
                          //   name = _nameTextController.text;
                          // },
                          decoration: InputDecoration(
                            labelText: 'Please enter your name',
                            focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                                color: Colors.lightBlue[200],
                                width: 1.0,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    Container(
                      margin: EdgeInsets.fromLTRB(16.0, 0.2, 16.0, 0),
                      color: Colors.white.withOpacity(0.7),
                      child: Padding(
                        padding: EdgeInsets.fromLTRB(16.0, 0, 16.0, 16.0),
                        child: TextFormField(
                          validator: (value) =>
                              value.isEmpty ? 'Email can\'t be empty' : null,
                          onSaved: (value) => email = value,
                          // controller: _emailTextController,
                          // onChanged: (String email) {
                          //   email = _emailTextController.text;
                          // },
                          decoration: InputDecoration(
                            fillColor: Colors.grey,
                            labelText: 'Please enter your email',
                            focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                                color: Colors.lightBlue[200],
                                width: 1.0,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    Container(
                      margin: EdgeInsets.fromLTRB(16.0, 0.2, 16.0, 0),
                      color: Colors.white.withOpacity(0.7),
                      child: Padding(
                        padding: EdgeInsets.fromLTRB(16.0, 0, 16.0, 16.0),
                        child: TextFormField(
                          obscureText: true,
                          validator: (value) =>
                              value.isEmpty ? 'Password can\'t be empty' : null,
                          onSaved: (value) => password = value,
                          // controller: _passwordTextController,
                          // onChanged: (String password) {
                          //   password = _passwordTextController.text;
                          // },
                          decoration: InputDecoration(
                            fillColor: Colors.grey,
                            labelText: 'Please enter your password',
                            focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                                color: Colors.lightBlue[200],
                                width: 1.0,
                              ),
                            ),
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
                        onPressed: validateAndSubmit,
                        //   var collectionName = 'users';
                        //   _connectFirestore.createUser(collectionName, data);
                        //   Navigator.of(context).pushReplacement(
                        //     MaterialPageRoute(builder: (context) {
                        //       return HomeScreen();
                        //     }),
                        //   );
                        // },
                        child: Text('登録'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
