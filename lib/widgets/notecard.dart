import 'package:flutter/material.dart';
import 'package:moor_flutter/moor_flutter.dart' as moor;
import 'package:provider/provider.dart';
import 'package:express_notebook/widgets/notepage.dart';
import 'package:express_notebook/main.dart';

import 'package:express_notebook/db/database.dart';

class NoteCard extends StatefulWidget {
  const NoteCard({
    Key key,
    @required this.database,
    @required this.note,
  }) : super(key: key);

  final Note note;
  final MyDatabase database;

  @override
  _NoteCardState createState() => _NoteCardState();
}

class _NoteCardState extends State<NoteCard> {
  double height = 80.0;
  bool expanded = false;
  @override
  Widget build(BuildContext context) {
    return Dismissible(
      child: Card(
        elevation: 5,
        child: AnimatedContainer(
          height: height,
          child: Column(
            children: <Widget>[
              Container(
                height: 30,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: <Widget>[
                    IconButton(
                      alignment: Alignment.bottomLeft,
                      icon: setArrowIcon(expanded),
                      onPressed: () {
                        setState(() {
                          if (expanded) {
                            height = 80;
                            expanded = false;
                          } else {
                            height = 180;
                            expanded = true;
                          }
                        });
                      },
                    ),
                    Text(
                      widget.note.title,
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Text(MyApp.dateFormat.format(widget.note.date)),
                    IconButton(
                      iconSize: 17,
                      alignment: Alignment.topCenter,
                      icon: Icon(Icons.edit),
                      onPressed: () {
                        setState(() {
                          if (expanded) {
                            height = 80;
                            expanded = false;
                          } else {
                            height = 180;
                            expanded = true;
                          }
                        });
                      },
                    ),
                  ],
                ),
                color: Colors.amber,
              ),
              InkWell(
                onTap: () {
                  setState(() {
                    if (expanded) {
                      height = 80;
                      expanded = false;
                    } else {
                      height = 180;
                      expanded = true;
                    }
                  });
                },
                child: Row(
                  children: <Widget>[
                    Text(widget.note.title),
                    Text(widget.note.id.toString()),
                    Text(widget.note.content),
                  ],
                ),
              ),
            ],
          ),
          duration: Duration(milliseconds: 200),
        ),
      ),
      key: Key(widget.note.id.toString()),
      background: Container(alignment: AlignmentDirectional.centerEnd),
      onDismissed: (direction) async {
        widget.database.deleteNote(widget.note.id);
      },
      direction: DismissDirection.horizontal,
      confirmDismiss: (DismissDirection direction) async {
        final bool res = await showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text("Confirm"),
              content: const Text("Are you sure you wish to delete this note?"),
              actions: <Widget>[
                FlatButton(
                    onPressed: () => Navigator.of(context).pop(true),
                    child: const Text("DELETE")),
                FlatButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  child: const Text("CANCEL"),
                ),
              ],
            );
          },
        );
        return res;
      },
    );
  }
}

Widget setArrowIcon(bool isExpanded) {
  Icon icon;

  if (isExpanded) {
    icon = Icon(Icons.arrow_drop_up);
  } else {
    icon = Icon(Icons.arrow_drop_down);
  }
  return icon;
}
