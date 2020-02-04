import 'package:express_notebook/widgets/notecard.dart';
import 'package:flutter/material.dart';
import 'package:moor_flutter/moor_flutter.dart' as moor;
import 'package:provider/provider.dart';

import 'package:express_notebook/db/database.dart';

class NotePage extends StatelessWidget {
  final Note note;
  const NotePage({Key key, this.note}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: Icon(Icons.arrow_back),
            color: Colors.white,
            onPressed: () {
              Navigator.pop(context);
            },
          ),
          title: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                note.title,
                style: TextStyle(fontSize: 17),
              ),
              Text(
                note.category.toString(),
                style: TextStyle(fontSize: 15),
              ),
            ],
          ),
        ),
        body: Stack(children: <Widget>[
          Hero(
            tag: note.id,
            child: Material(
                child: Center(
              child: GestureDetector(
                onTap: () {
                  Navigator.pop(context);
                },
                child: Container(
                  height: 50,
                  width: 50,
                  color: Colors.white,
                  child: Text(note.id.toString()),
                ),
              ),
            )),
          ),
        ]),
      ),
    );
  }
}
