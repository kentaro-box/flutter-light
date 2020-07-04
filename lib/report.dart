import 'package:flutter/material.dart';
import 'package:flutter_bbs/notice.dart';

import 'block.dart';

class Report extends StatelessWidget {
  String postId;
  Report({this.postId});

  List menu = ['通報する', 'ブロックする'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('home'),
        flexibleSpace: Container(
          decoration: BoxDecoration(
              gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: <Color>[Colors.lightBlue[300], Colors.cyan[100]])),
        ),
      ),
      body: ListView(
        children: <Widget>[
          Column(
            children: <Widget>[
              GestureDetector(
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => Notice(),
                    ),
                  );
                },
                child: Container(
                    padding: EdgeInsets.all(8.0), child: Text('${menu[0]}')),
              ),
              Divider(),
              GestureDetector(
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => Block(),
                    ),
                  );
                },
                child: Container(
                    padding: EdgeInsets.all(8.0), child: Text('${menu[1]}')),
              ),
              Divider(),
            ],
          ),
        ],
      ),
    );
  }
}
