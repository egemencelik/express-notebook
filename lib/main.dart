import 'package:express_notebook/widgets/newnotepage.dart';
import 'package:express_notebook/widgets/notecard.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:moor_flutter/moor_flutter.dart' as moor;
import 'package:provider/provider.dart';

import 'db/database.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  static Color color = Colors.black;
  static DateFormat dateFormat = DateFormat("dd-MM-yyyy HH:mm");
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider<MyDatabase>(
          create: (_) => MyDatabase(),
        ),
      ],
      child: MaterialApp(
        title: 'Express Notebook',
        theme: ThemeData(primaryColor: color, buttonColor: Colors.amber),
        home: MyHomePage(title: 'Express Notebook'),
      ),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  void _addNote() {
    setState(() {
      final database = Provider.of<MyDatabase>(context);
      database.addNote(NotesCompanion(
          title: moor.Value("asdddddd"),
          category: moor.Value(6),
          content: moor.Value("sss"),
          date: moor.Value(DateTime.now())));
    });
  }

  void _addNewNote() {
    setState(() {
      final database = Provider.of<MyDatabase>(context);
    });
  }

  @override
  Widget build(BuildContext context) {
    final database = Provider.of<MyDatabase>(context);
    return Scaffold(
      appBar: AppBar(
        iconTheme: IconThemeData(color: Colors.amber),
        actions: <Widget>[
          Hero(
            tag: 'add_note',
            child: MaterialButton(
              onPressed: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) {
                          return new NewNotePage();
                        },
                        fullscreenDialog: true));
              },
              child: Icon(
                Icons.note_add,
                color: Colors.white,
              ),
            ),
          )
        ],
        title: Text(widget.title),
      ),
      body: StreamBuilder(
        stream: database.getAllNotes(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            List<Note> list = snapshot.data;
            return ListView.builder(
                itemCount: list.length,
                itemBuilder: (ctx, index) {
                  return NoteCard(
                    note: list[index],
                    database: database,
                  );
                });
          } else {
            return Container();
          }
        },
      ),
    );
  }
}
