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
          Divider(),
          ListTile(
            title: Text('アカウントを削除する'),
            // onTap: signOutFacebook,
            onTap: () async {
              var result = await showDialog<int>(
                context: context,
                barrierDismissible: false,
                builder: (BuildContext context) {
                  return AlertDialog(
                    title: Text('確認'),
                    content: Text('確認のダイアログです。'),
                    actions: <Widget>[
                      FlatButton(
                        child: Text('Cancel'),
                        onPressed: () => Navigator.of(context).pop(0),
                      ),
                      FlatButton(
                        child: Text('OK'),
                        onPressed: () async {
                          final user =
                              await FirebaseAuth.instance.currentUser();
                          user.delete();
                          Navigator.of(context).pushAndRemoveUntil(
                              MaterialPageRoute(
                                  builder: (context) => LoginScreen()),
                              (Route<dynamic> route) => false);
                        },
                      ),
                    ],
                  );
                },
              );

              // final user = await FirebaseAuth.instance.currentUser();
              // user.delete();
              // Navigator.of(context).pushAndRemoveUntil(
              //     MaterialPageRoute(builder: (context) => LoginScreen()),
              //     (Route<dynamic> route) => false);
            },
          ),
          Divider(),
          Padding(
            padding: const EdgeInsets.fromLTRB(15.0, 8.0, 15.0, 8.0),
            child: Column(
              children: <Widget>[
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text("製作者へ連絡"),
                ),
                Align(
                    alignment: Alignment.centerLeft,
                    child: Text('chickenshopgogogoアットマークgmail.com')),
              ],
            ),
          ),
          Divider(),
          Padding(
            padding: const EdgeInsets.fromLTRB(15.0, 8.0, 15.0, 8.0),
            child: Column(
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.only(bottom: 12.0),
                  child: Text('<このアプリについて>'),
                ),
                Text(
                    '昔から現代に至るまで、生きていくということはなかなか大変なことだと思っています。日々、いろいろな思念に付き纏われ、悲観したり、自分を卑下したりと余分に苦労してしまっている人々が多くいるのではないかと思いました。そこで、お坊さんたちが長い年月をかけ蓄積してきた考えなどを現代に当てはめてご教授下されば、救われる方もおられるのではないかと考えこのアプリを制作いたしました。お坊さん方には、宗派に囚われず人々の苦しみを軽減するようなお言葉をいただければありがたい限りでございます。'),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
