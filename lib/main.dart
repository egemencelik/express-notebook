import 'dart:async';

import 'package:express_notebook/widgets/newnotepage.dart';
import 'package:express_notebook/widgets/notecard.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:moor_flutter/moor_flutter.dart' as moor;
import 'package:express_notebook/helpers/colorhelper.dart';
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
        home: MyHomePage(title: 'Express Notebook'),
      ),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  final String title;
  static Stream stream;
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  static final refreshIndicatorKey = GlobalKey<RefreshIndicatorState>();
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    final database = Provider.of<MyDatabase>(context);
    MyHomePage.stream = database.getAllNotes();
  }

  @override
  Widget build(BuildContext context) {
    final database = Provider.of<MyDatabase>(context);
    return Scaffold(
      appBar: CustomAppBar(),
      /* AppBar(
        backgroundColor: Colors.transparent,
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
                color: Colors.black,
              ),
            ),
          )
        ],
        title: Text(
          widget.title,
          style: TextStyle(color: Colors.black),
        ),
        elevation: 0,
      ), */
      body: StreamBuilder(
        stream: CustomAppBar.isColorSelected
            ? database.getNotesByCategory(CustomAppBar.selectedIndex)
            : database.getAllNotes(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            List<Note> list = snapshot.data;
            return RefreshIndicator(
              key: _MyHomePageState.refreshIndicatorKey,
              onRefresh: _handleRefresh,
              child: ListView.builder(
                  itemCount: list.length,
                  itemBuilder: (ctx, index) {
                    return NoteCard(
                      note: list[index],
                      database: database,
                    );
                  }),
            );
          } else {
            return CircularProgressIndicator();
          }
        },
      ),
    );
  }

  Future<Null> _handleRefresh() async {
    await new Future.delayed(new Duration(seconds: 0));

    setState(() {
      MyHomePage.stream = CustomAppBar.newStream;
    });

    return null;
  }
}

class CustomAppBar extends StatefulWidget implements PreferredSizeWidget {
  @override
  _CustomAppBarState createState() => _CustomAppBarState();

  static bool isColorSelected = false;
  static int selectedIndex = -1;
  static Stream newStream;
  Color selectedColor = getCategoryColor(selectedIndex);

  @override
  Size get preferredSize => Size.fromHeight(50);
}

class _CustomAppBarState extends State<CustomAppBar> {
  @override
  Widget build(BuildContext context) {
    final database = Provider.of<MyDatabase>(context);
    return PreferredSize(
      preferredSize: Size.fromHeight(50),
      child: Container(
        alignment: Alignment.bottomCenter,
        color: Colors.transparent,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: <Widget>[
            IconButton(
              enableFeedback: false,
              icon: Icon(Icons.settings),
              onPressed: () {},
            ),
            PopupMenuButton(
              onSelected: (choice) {
                setState(() {
                  widget.selectedColor = getCategoryColor(choice);
                  if (choice == -1) {
                    CustomAppBar.isColorSelected = false;
                    CustomAppBar.newStream = database.getAllNotes();
                  } else {
                    CustomAppBar.isColorSelected = true;
                    CustomAppBar.newStream =
                        database.getNotesByCategory(choice);
                  }

                  CustomAppBar.selectedIndex = choice;

                  _MyHomePageState.refreshIndicatorKey.currentState.show();
                });
              },
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30)),
              child: Container(
                width: 30,
                height: 30,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(15),
                  color: widget.selectedColor,
                ),
                child: Icon(
                  Icons.color_lens,
                  color: Colors.white,
                  size: 18,
                ),
              ),
              itemBuilder: (context) {
                return ColorHelper.colors.map((int choice) {
                  return PopupMenuItem<int>(
                    value: choice,
                    child: Container(
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
                          color: getCategoryColor(choice)),
                      width: 80,
                      child: Center(
                        child: Container(
                          width: 80,
                          height: 30,
                          child: choice == -1
                              ? Center(
                                  child: Text(
                                    'ALL',
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold),
                                  ),
                                )
                              : null,
                        ),
                      ),
                    ),
                  );
                }).toList();
              },
            ),
            /* RawMaterialButton(
              enableFeedback: false,
              constraints: BoxConstraints.tight(Size.fromRadius(14)),
              shape: new CircleBorder(),
              elevation: 2.0,
              onPressed: () {
                setState(() {
                  if (widget.isColorSelected)
                    widget.isColorSelected = false;
                  else
                    widget.isColorSelected = true;
                });
              },
              fillColor: widget.isColorSelected ? Colors.amber : null,
              child: !widget.isColorSelected
                  ? Ink(
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(15),
                          //shape: new CircleBorder(),
                          gradient: LinearGradient(
                              colors: [
                                new Color(0xffE0E0E0),
                                new Color(0xff424242)
                              ],
                              begin: Alignment.centerLeft,
                              end: Alignment.centerRight)),
                    )
                  : null,
            ), */
            Padding(
              padding: const EdgeInsets.fromLTRB(14.0, 8.0, 8.0, 8.0),
              child: Text(
                'Express Notebook',
                style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 2),
              ),
            ),
            IconButton(
              enableFeedback: false,
              icon: Icon(Icons.search),
              onPressed: () {},
            ),
            SizedBox(
              width: 40,
              child: Hero(
                tag: 'add_note',
                child: MaterialButton(
                  padding: EdgeInsets.all(0),
                  enableFeedback: false,
                  child: Icon(Icons.add),
                  onPressed: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) {
                              return new NewNotePage();
                            },
                            fullscreenDialog: true));
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

Stream<List<Note>> getNoteStream(context) {
  final database = Provider.of<MyDatabase>(context);
  setState() {
    return CustomAppBar.isColorSelected
        ? database.getNotesByCategory(CustomAppBar.selectedIndex)
        : database.getAllNotes();
  }
}
