import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bbs/login_screen.dart';
import 'package:flutter_bbs/main.dart';
import 'package:flutter_facebook_login/flutter_facebook_login.dart';

class Menu extends StatefulWidget {
  @override
  _MenuState createState() => _MenuState();
}

class _MenuState extends State<Menu> {
  bool logged;
  final FacebookLogin facebookSignIn = new FacebookLogin();

  void logout() {
    setState(() {
      logged = false;
    });
  }

  // void signOutFacebook() async {
  //   await facebookSignIn.logOut();
  //   logout();
  //   // TODO ログインしてなければトップ画面を表示のしかた
  //   setState(() {
  //     Navigator.of(context).pushReplacement(
  //       MaterialPageRoute(
  //         builder: (context) => LoginScreen(),
  //       ),
  //     );
  //   });
  //   print("User Sign Out Facebook");
  // }

  @override
  Widget build(BuildContext context) {
    LoginScreen _loginScreen = LoginScreen();
    return Scaffold(
      appBar: AppBar(
        title: Text('menu'),
        flexibleSpace: Container(
          decoration: BoxDecoration(
              gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: <Color>[Colors.lightBlue[300], Colors.cyan[100]])),
        ),
      ),
      body: Column(
        children: <Widget>[
          ListTile(
            title: Text('ログアウト'),
            // onTap: signOutFacebook,
            onTap: () async {
              await FirebaseAuth.instance.signOut();
              Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (context) => SplashScreen()),
                  (Route<dynamic> route) => false);
            },
          ),
        ],
      ),
    );
  }
}
