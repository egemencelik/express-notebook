import 'package:express_notebook/widgets/notecard.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:moor_flutter/moor_flutter.dart' as moor;
import 'package:provider/provider.dart';
import 'package:express_notebook/widgets/notepage.dart';

import 'package:express_notebook/db/database.dart';

class NotePage extends StatefulWidget {
  NotePage({Key key, @required this.note}) : super(key: key) {
    category = note.category;
  }
  final Note note;

  int category;
  @override
  _NotePageState createState() => _NotePageState();
}

class _NotePageState extends State<NotePage> {
  int category = 0;
  final titleController = TextEditingController();
  final contentController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    category = widget.category;
    titleController.text = widget.note.title;
    contentController.text = widget.note.content;
    final database = Provider.of<MyDatabase>(context);

    return Scaffold(
      appBar: AppBar(
        title: TextField(
          controller: titleController,
          decoration:
              InputDecoration.collapsed(hintText: "Enter note title..."),
        ),
        actions: <Widget>[
          IconButton(
            color: getCategoryColor(category),
            enableFeedback: false,
            padding: EdgeInsets.fromLTRB(20, 8, 20, 8),
            icon: Icon(Icons.color_lens),
            onPressed: () {
              setState(() {
                widget.category += 1;
                widget.category %= 6;
                category = widget.category;
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
                  decoration:
                      InputDecoration.collapsed(hintText: 'Enter your note...'),
                ),
              ],
            ),
          ),
          /* Expanded(
            child: Container(),
          ), */
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 8),
            child: Hero(
              tag: 'edit_note' + widget.note.id.toString(),
              child: ButtonTheme(
                minWidth: double.infinity,
                child: RaisedButton(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                  elevation: 10.0,
                  padding: const EdgeInsets.all(10.0),
                  color: getCategoryColor(category),
                  onPressed: () {
                    Note editedNote = new Note(
                        content: contentController.text,
                        title: titleController.text,
                        category: category,
                        date: DateTime.now(),
                        id: widget.note.id);
                    database.updateNote(editedNote);
                    Navigator.pop(context);
                  },
                  child: Icon(
                    Icons.edit,
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
}
