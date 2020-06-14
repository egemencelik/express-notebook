import 'dart:async';

import 'package:after_init/after_init.dart';
import 'package:express_notebook/helpers/colorhelper.dart';
import 'package:express_notebook/widgets/newnotepage.dart';
import 'package:express_notebook/widgets/notecard.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import 'db/database.dart';

void main() => runApp(MyApp());

class NoteStream extends ChangeNotifier {
  Stream stream;
  int index = -1;
  bool isColorSelected = false;

  void updateStream(Stream newStream) {
    stream = newStream;
    notifyListeners();
  }

  void updateIndex(int value) {
    index = value;
    notifyListeners();
  }

  void updateIsColorSelected(bool value) {
    isColorSelected = value;
    notifyListeners();
  }
}

class MyApp extends StatelessWidget {
  static DateFormat dateFormat = DateFormat("dd-MM-yyyy HH:mm");

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<NoteStream>(
          create: (_) => NoteStream(),
        ),
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
  static final streamBuilderKey = GlobalKey<State<StreamBuilderBase>>();

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage>
    with AfterInitMixin<MyHomePage> {
  @override
  void didInitState() {
    final database = Provider.of<MyDatabase>(context);
    Provider.of<NoteStream>(context).updateStream(database.getAllNotes());
  }

  static final refreshIndicatorKey = GlobalKey<RefreshIndicatorState>();

  @override
  Widget build(BuildContext context) {
    final database = Provider.of<MyDatabase>(context);
    return Scaffold(
      appBar: CustomAppBar(),
      body: StreamBuilder(
        key: MyHomePage.streamBuilderKey,
        stream: Provider.of<NoteStream>(context).stream,
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
            return Center(child: CircularProgressIndicator());
          }
        },
      ),
    );
  }

  Future<Null> _handleRefresh() async {
    await new Future.delayed(new Duration(seconds: 0));

    return null;
  }
}

class CustomAppBar extends StatefulWidget implements PreferredSizeWidget {
  @override
  _CustomAppBarState createState() => _CustomAppBarState();

  @override
  Size get preferredSize => Size.fromHeight(50);

  var isSearching = false;
}

class _CustomAppBarState extends State<CustomAppBar>
    with SingleTickerProviderStateMixin {
  AnimationController _animationController;
  AnimationController _iconRotateController;
  Animation _animation;

  @override
  void initState() {
    super.initState();
    _animationController =
        AnimationController(duration: Duration(milliseconds: 200), vsync: this);
    _animation = IntTween(begin: 100, end: 0).animate(_animationController);
    _animation.addListener(() => setState(() {}));
  }

  @override
  Widget build(BuildContext context) {
    final database = Provider.of<MyDatabase>(context);
    final streamP = Provider.of<NoteStream>(context);
    var textController = TextEditingController();

    void _onSelectedColor(int choice) {
      setState(() {
        if (choice == -1) {
          streamP.updateIsColorSelected(false);
          streamP.updateStream(database.getAllNotes());
        } else {
          streamP.updateIsColorSelected(true);
          streamP.updateStream(database.getNotesByCategory(choice));
        }
        streamP.updateIndex(choice);
      });
    }

    return PreferredSize(
      preferredSize: Size.fromHeight(50),
      child: AnimatedContainer(
        alignment: Alignment.bottomCenter,
        color: Colors.transparent,
        duration: Duration(milliseconds: 100),
        child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Expanded(
                flex: _animation.value,
                child: SizedBox(
                  width: 0.0,
                  child: FittedBox(
                    child: Row(
                      children: <Widget>[
                        IconButton(
                          enableFeedback: false,
                          icon: Icon(Icons.settings),
                          onPressed: () {},
                        ),
                        PopupMenuButton(
                          onSelected: _onSelectedColor,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30)),
                          child: Container(
                            width: 25,
                            height: 25,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(15),
                              color: getCategoryColor(streamP.index),
                            ),
                            child: Icon(
                              Icons.color_lens,
                              color: Colors.white,
                              size: 15,
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
                                                    fontWeight:
                                                        FontWeight.bold),
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
                        Padding(
                          padding:
                              const EdgeInsets.fromLTRB(14.0, 8.0, 8.0, 8.0),
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
                          onPressed: () {
                            setState(() {
                              _animationController.forward();
                              widget.isSearching = true;
                            });
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              Expanded(
                flex: 100 - _animation.value,
                child: Padding(
                  padding: _animation.value == 100
                      ? const EdgeInsets.all(0)
                      : const EdgeInsets.fromLTRB(11, 0, 0, 0),
                  child: SizedBox(
                    width: 0,
                    child: Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.rectangle,
                        borderRadius: BorderRadius.circular(15),
                        color: Colors.black12,
                      ),
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(11, 0, 0, 0),
                        child: TextField(
                          minLines: 1,
                          maxLines: 1,
                          controller: textController,
                          style: TextStyle(
                            fontFamily: 'RobotoMono',
                          ),
                          decoration: InputDecoration.collapsed(
                              hintText: "Search by title or content..."),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              RotationTransition(
                turns:
                    Tween(begin: 0.0, end: 0.12).animate(_animationController),
                child: SizedBox(
                  width: 40,
                  child: Hero(
                    tag: 'add_note',
                    child: MaterialButton(
                      padding: EdgeInsets.all(0),
                      enableFeedback: false,
                      child: Icon(Icons.add),
                      onPressed: () {
                        if (widget.isSearching) {
                          widget.isSearching = false;
                          _animationController.reverse();
                          return;
                        }
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
              ),
            ]),
      ),
    );
  }
}
