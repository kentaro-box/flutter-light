import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_auth_buttons/flutter_auth_buttons.dart';
import 'package:flutter_facebook_login/flutter_facebook_login.dart';
import 'anonymous_authorization.dart';
import 'bottom_navigation.dart';
import 'consulter_registration_screen.dart';
import 'home_screen.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  AnonymousAuthorization _anonymousAuthorization = AnonymousAuthorization();
  FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  bool isLogged = false;
  var userId;

  // facebookログイン　<アドバイザー用>
  Future<FirebaseUser> _loginWithFacebook() async {
    var facebookLogin = FacebookLogin();
    var result = await facebookLogin.logIn(['email']);

    debugPrint(result.status.toString());

    if (result.status == FacebookLoginStatus.loggedIn) {
      final AuthCredential credential = FacebookAuthProvider.getCredential(
          accessToken: result.accessToken.token);
      final FirebaseUser user =
          (await _firebaseAuth.signInWithCredential(credential)).user;
      return user;
    }
    return null;
  }

  final _userCollectionRef = Firestore.instance.collection('users');

  void logOut() async {
    await _firebaseAuth.signOut().then((responce) {
      isLogged = false;
      setState(() {});
    });
  }

  void _loggedIn() async {
    final user = await _loginWithFacebook();
    if (user != null) {
      isLogged = true;
      userId = user.uid;
      final usersSnapshot = await _userCollectionRef.document(userId).get();
      if (!usersSnapshot.exists) {
        _userCollectionRef.document(userId).setData({
          'userName': user.displayName,
          'userId': user.uid,
          'userEmail': user.email,
          'userImageUrl': user.photoUrl,
          'createdAt': new DateTime.now(),
          'category': 'advisor',
        });
      }

      setState(() {});

      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) => BottomNavigation(),
        ),
      );
    }
  }

  Widget build(BuildContext context) {
    return Scaffold(
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
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.only(bottom: 64.0),
              child: Image.asset(
                'assets/images/logo.png',
                width: 200.0,
              ),
            ),
            SizedBox(
              width: 236,
              child: RaisedButton(
                color: Colors.lightBlue[100],
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(
                    Radius.circular(8.0),
                  ),
                ),
                onPressed: () async {
                  await _anonymousAuthorization.signInAnonymously();
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => BottomNavigation(),
                    ),
                  );
                },
                child: Text('Consulter Login'),
              ),
            ),
            SizedBox(
              width: 236,
              child: Container(
                child: isLogged
                    ? Center(
                        child: CircularProgressIndicator(
                        strokeWidth: 30.0,
                      ))
                    : FacebookSignInButton(
                        text: 'Advisor Login',
                        onPressed: _loggedIn,
                      ),
              ),
            ),

            SizedBox(
              width: 236,
              child: RaisedButton(
                color: Colors.lightBlueAccent,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(
                    Radius.circular(8.0),
                  ),
                ),
                onPressed: () => logOut(),
                child: Text('Login'),
              ),
            ),
            // Container(
            //   child: FacebookSignInButton(
            //     onPressed: _loggedIn,
            //   ),
            // ),
          ],
        ),
      ),
    );
  }
}
