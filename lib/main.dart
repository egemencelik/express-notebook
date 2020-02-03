import 'package:flutter/material.dart';
import 'package:moor_flutter/moor_flutter.dart';
import 'package:provider/provider.dart';

import 'db/database.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
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
        theme: ThemeData(
          primarySwatch: Colors.amber,
        ),
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
  int _counter = 0;

  void _incrementCounter() {
    setState(() {
      final database = Provider.of<MyDatabase>(context);
      database.addNote(NotesCompanion(
          title: Value("asdddddd"), category: Value(2), content: Value("sss")));
    });
  }

  @override
  Widget build(BuildContext context) {
    final database = Provider.of<MyDatabase>(context);
    return Scaffold(
      appBar: AppBar(
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
                  return Dismissible(
                    child: Hero(
                      child: Card(
                        elevation: 5,
                        child: Container(
                          height: 50.0,
                          child: InkWell(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) {
                                    return new NotePage(note: list[index]);
                                  },
                                  fullscreenDialog: true,
                                ),
                              );
                            },
                            child: Row(
                              children: <Widget>[
                                Text(list.elementAt(index).title),
                                Text(list.elementAt(index).id.toString()),
                                Text(list.elementAt(index).content),
                              ],
                            ),
                          ),
                        ),
                      ),
                      tag: list[index].id,
                    ),
                    key: Key(list[index].id.toString()),
                    background:
                        Container(alignment: AlignmentDirectional.centerEnd),
                    onDismissed: (direction) {
                      setState(() async {
                        database.deleteNote(list[index].id);
                      });
                    },
                    direction: DismissDirection.horizontal,
                    confirmDismiss: (DismissDirection direction) async {
                      final bool res = await showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return AlertDialog(
                            title: const Text("Confirm"),
                            content: const Text(
                                "Are you sure you wish to delete this note?"),
                            actions: <Widget>[
                              FlatButton(
                                  onPressed: () =>
                                      Navigator.of(context).pop(true),
                                  child: const Text("DELETE")),
                              FlatButton(
                                onPressed: () =>
                                    Navigator.of(context).pop(false),
                                child: const Text("CANCEL"),
                              ),
                            ],
                          );
                        },
                      );
                      return res;
                    },
                  );
                });
          } else {
            return Container();
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _incrementCounter,
        tooltip: 'Increment',
        child: Icon(Icons.add),
      ),
    );
  }

  void _delete() {
    setState(() {
      final database = Provider.of<MyDatabase>(context);
      database.deleteAllNotes();
    });
  }
}

class NotePage extends StatelessWidget {
  final Note note;

  const NotePage({Key key, this.note}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Stack(children: <Widget>[
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
    ]);
  }
}
