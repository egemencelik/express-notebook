import 'package:express_notebook/widgets/notecard.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:moor_flutter/moor_flutter.dart' as moor;
import 'package:provider/provider.dart';
import 'package:express_notebook/widgets/notepage.dart';

import 'package:express_notebook/db/database.dart';

class NewNotePage extends StatefulWidget {
  @override
  _NewNotePageState createState() => _NewNotePageState();
}

class _NewNotePageState extends State<NewNotePage> {
  int category = 0;
  final titleController = TextEditingController();
  final contentController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final database = Provider.of<MyDatabase>(context);
    return Scaffold(
      appBar: AppBar(
        title: TextField(
          controller: titleController,
          decoration: InputDecoration.collapsed(hintText: "Enter note title"),
        ),
        actions: <Widget>[
          IconButton(
            color: getCategoryColor(category),
            enableFeedback: false,
            padding: EdgeInsets.fromLTRB(20, 8, 20, 8),
            icon: Icon(Icons.color_lens),
            onPressed: () {
              setState(() {
                category += 1;
                category %= 6;
              });
            },
          )
        ],
        backgroundColor: Colors.transparent,
        elevation: 0.0,
        iconTheme: IconThemeData(
          color: Colors.black,
        ),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.max,
        children: <Widget>[
          Expanded(
            child: ListView(
              shrinkWrap: true,
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              children: <Widget>[
                TextField(
                  controller: contentController,
                  autofocus: true,
                  maxLines: 34,
                  decoration: InputDecoration.collapsed(
                      hintText: 'What do you want to add now ?'),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 8),
            child: Hero(
              tag: 'add_note',
              child: ButtonTheme(
                minWidth: double.infinity,
                child: RaisedButton(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                  elevation: 10.0,
                  padding: const EdgeInsets.all(10.0),
                  color: getCategoryColor(category),
                  onPressed: _onAddNote,
                  /* () {
                                      _showAlertDialog('text', 'text', context);
                                      /* database.addNote(NotesCompanion(
                                          title: moor.Value(titleController.text),
                                          category: moor.Value(category),
                                          content: moor.Value(contentController.text),
                                          date: moor.Value(DateTime.now())));
                                      Navigator.pop(context); */
                                    }, */
                  child: Icon(
                    Icons.add,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          )
        ],
      ),
    );
  }

  void _onAddNote() {
    final database = Provider.of<MyDatabase>(context);

    if (titleController.text.isEmpty) {
      _showAlertDialog(
          "Title cannot be empty", "Title cannot be empty", context);
    } else if (titleController.text.length > 32) {
      _showAlertDialog("Title is too long", "Title is too long", context);
    } else if (contentController.text.isEmpty) {
      _showAlertDialog("Note cannot be empty", "Note cannot be empty", context);
    } else {
      database.addNote(NotesCompanion(
          title: moor.Value(titleController.text),
          category: moor.Value(category),
          content: moor.Value(contentController.text),
          date: moor.Value(DateTime.now())));
      Navigator.pop(context);
    }
  }
}

_showAlertDialog(String title, String content, context) {
  showDialog(
      context: context,
      builder: (BuildContext context) {
        return SimpleDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          children: <Widget>[],
          title: Text(
            title,
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
          contentPadding: EdgeInsets.fromLTRB(10, 0, 10, 10),
          titlePadding: EdgeInsets.fromLTRB(10, 35, 10, 30),
        );
      });
}
