import 'package:flutter/material.dart';

import 'database.dart';
import 'note.dart';

typedef void Callback();

class NotesManager extends StatefulWidget {
  final NotesManagerState state = NotesManagerState();

  void pushNoteEditor(BuildContext context, {Note note}) {
    if (note == null) {
      note = Note();
    }

    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => NoteEditor(note)),
    );
  }

  @override
  NotesManagerState createState() => state;
}

class NotesManagerState extends State<NotesManager> {
  void forceRefresh() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: DatabaseHelper.instance.findAll(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          var widgets = <Widget>[];

          for (var note in snapshot.data) {
            widgets.add(NoteCard(note, forceRefresh));
          }

          return ListView(children: widgets);
        } else {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[Center(child: Text('Loading notes...'))],
          );
        }
      },
    );
  }
}

class NoteCard extends StatefulWidget {
  final Note note;
  final Callback deleteCallback;

  NoteCard(this.note, this.deleteCallback);

  @override
  NoteCardState createState() => NoteCardState(note, deleteCallback);
}

class NoteCardState extends State<NoteCard> {
  final Note note;
  final Callback deleteCallback;

  NoteCardState(this.note, this.deleteCallback);

  void editNote(BuildContext context) {
    Navigator.push(
        context, MaterialPageRoute(builder: (context) => NoteEditor(note)));
  }

  void deleteItself() {
    var db = DatabaseHelper.instance;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
            title: Text("Exit without saving"),
            content: Text(
                "You are about to close the note without saving it."),
            actions: <Widget>[
              FlatButton(
                child: Text("Cancel"),
                textColor: Colors.white,
                onPressed: () {
                  Navigator.pop(context);
                },
              ),
              FlatButton(
                child: Text("Delete"),
                textColor: Colors.red,
                onPressed: () {
                  db.delete(note);
                  deleteCallback();
                  Navigator.pop(context);
                },
              ),
            ]);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    MediaQueryData mq = MediaQuery.of(context);

    return Container(
        width: mq.size.width,
        height: mq.size.height * 0.25,
        margin: EdgeInsets.only(left: 20, right: 20, top: 10),
        child: new GestureDetector(
          onTap: () => editNote(context),
          child: Card(
            child: Padding(
              padding:
                  EdgeInsets.only(left: 20, top: 10, right: 20, bottom: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: <Widget>[
                      Expanded(
                          child: Text(
                        note.title.toUpperCase(),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(fontSize: 20),
                      )),
                      IconButton(
                        icon: Icon(Icons.delete_forever),
                        color: Colors.redAccent,
                        onPressed: deleteItself,
                      ),
                    ],
                  ),
                  Expanded(
                    child: Padding(
                      padding: EdgeInsets.only(top: 5),
                      child: Text(
                        note.content,
                        overflow: TextOverflow.fade,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ));
  }
}
