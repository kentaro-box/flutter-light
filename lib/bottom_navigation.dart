import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bbs/home_screen.dart';
import 'package:flutter_bbs/register_name_screen.dart';
import 'package:flutter_bbs/word_of_today.dart';

import 'menu.dart';

class BottomNavigation extends StatefulWidget {
  final int pageNumber;
  BottomNavigation({this.pageNumber});

  @override
  _BottomNavigationState createState() => _BottomNavigationState();
}

class _BottomNavigationState extends State<BottomNavigation> {
  PageController _pageController;
  int _pageNumber = BottomNavigation().pageNumber;
  int _page = 0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    print(_pageNumber);
    if (_pageNumber != null) {
      _page = _pageNumber;
    }
    print(_page);
  }

  @override
  void dispose() {
    super.dispose();
    _pageController.dispose();
  }

  void onTapBottomNavigation(int page) {
    _pageController.animateToPage(page,
        duration: const Duration(milliseconds: 300), curve: Curves.ease);
  }

  @override
  Widget build(BuildContext context) {
    return TabInherited(
      openTab: (int index) {
        setState(() {
          _page = index;
        });
      },
      child: Scaffold(
        body: IndexedStack(
          index: _page,
          children: <Widget>[
            HomeScreen(),
            WordOfToday(),
            Menu(),
          ],
        ),
        bottomNavigationBar: BottomNavigationBar(
            type: BottomNavigationBarType.fixed,
            items: const [
              BottomNavigationBarItem(
                icon: Icon(Icons.home),
                title: Text('home'),
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.local_library),
                title: Text('今日の一言'),
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.dehaze),
                title: Text('menu'),
              ),
            ],
            currentIndex: _page,
            selectedItemColor: Colors.lightBlue[200],
            onTap: (int index) {
              setState(() {
                _page = index;
              });
            }),
      ),
    );
  }
}

class BottomSplashScreen extends StatefulWidget {
  @override
  _BottomSplashScreenState createState() => _BottomSplashScreenState();
}

class _BottomSplashScreenState extends State<BottomSplashScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }

  @override
  void didChangeDependencies() {
    checkName();
    super.didChangeDependencies();
  }

  Future<void> checkName() async {
    final user = await FirebaseAuth.instance.currentUser();

    final userDoc =
        await Firestore.instance.collection('users').document(user.uid).get();
    final userName = await userDoc.data['userName'] == null
        ? null
        : userDoc.data['userName'];

    if (userName == null) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => RegisterNameScreen()),
      );
    } else {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => BottomNavigation()),
      );
    }
  }
}
