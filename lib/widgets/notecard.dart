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
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        elevation: 8,
        child: AnimatedContainer(
          height: height,
          child: Column(
            children: <Widget>[
              GestureDetector(
                onTap: () {
                  setState(() {
                    if (expanded) {
                      height = 80;
                      expanded = false;
                    } else {
                      height = calculateHeight(widget.note.content);
                      expanded = true;
                    }
                  });
                },
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(10),
                        topRight: Radius.circular(10)),
                    color: getCategoryColor(widget.note.category),
                  ),
                  height: 30,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: <Widget>[
                      setArrowIcon(expanded),
                      Text(
                        widget.note.title,
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      Text(MyApp.dateFormat.format(widget.note.date)),
                      Hero(
                        tag: 'edit_note' + widget.note.id.toString(),
                        child: MaterialButton(
                          child: Icon(
                            Icons.edit,
                            size: 17,
                          ),
                          onPressed: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) {
                                      return new NotePage(
                                        note: widget.note,
                                      );
                                    },
                                    fullscreenDialog: true));
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Row(
                children: <Widget>[
                  Flexible(
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        widget.note.content,
                        softWrap: true,
                        overflow: TextOverflow.fade,
                        style: TextStyle(fontSize: 15),
                      ),
                    ),
                  ),
                ],
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

double calculateHeight(String text) {
  double multFactor;
  double divFactor;

  if (text.length > 1000) {
    multFactor = 2.95;
    divFactor = 9.2;
  } else {
    multFactor = 3;
    divFactor = 8;
  }

  double newLength = (text.length * multFactor) / divFactor;

  return newLength < 80 ? 80 : newLength;
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

Color getCategoryColor(int id) {
  Color color;
  switch (id) {
    case 0:
      color = Colors.amber;
      break;
    case 1:
      color = Colors.lightBlue;
      break;
    case 2:
      color = Colors.lightGreen;
      break;
    case 3:
      color = new Color(0xffFF7043);
      break;
    case 4:
      color = new Color(0xffF48FB1);
      break;
    case 5:
      color = new Color(0xffCE93D8);
      break;

    default:
      color = Colors.grey;
  }

  return color;
}
