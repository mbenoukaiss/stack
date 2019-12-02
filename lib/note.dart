import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'database.dart';

class Note {
  int id;
  String title;
  String content;

  Note({int id, String title, String content}) {
    this.id = id;
    this.title = title;
    this.content = content;
  }

  Note.fromMap(Map<String, dynamic> map) {
    id = map[column_id];
    title = map[column_title];
    content = map[column_content];
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      column_id: id,
      column_title: title,
      column_content: content
    };
  }

  @override
  bool operator ==(other) {
    return id == other.id;
  }

  @override
  int get hashCode {
    return id.hashCode * title.hashCode * content.hashCode;
  }

  @override
  String toString() {
    return title + "\n" + content;
  }
}

class AlwaysUppercaseFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    return TextEditingValue(
      text: newValue.text.toUpperCase(),
      selection: newValue.selection,
      composing: newValue.composing,
    );
  }
}

class NoteEditor extends StatefulWidget {
  final Note note;

  NoteEditor(this.note);

  @override
  _NoteEditorState createState() => _NoteEditorState(note);
}

class _NoteEditorState extends State<NoteEditor> {
  final Note note;
  bool edited;

  final FocusNode contentFocus = FocusNode();

  final TextStyle titleTextStyle = TextStyle(
    color: Colors.white,
    fontSize: 30,
  );

  final TextStyle contentTextStyle = TextStyle(
    color: Colors.white,
  );

  TextEditingController titleController;
  TextEditingController contentController;

  _NoteEditorState(this.note) {
    edited = false;
    titleController = TextEditingController(text: note.title);
    contentController = TextEditingController(text: note.content);
  }

  void onBarTapped(var index) async {
    switch (index) {
      case 0:
        exit();
        break;
      case 1:
        delete();
        break;
      case 2:
        save();
        break;
      case 3:
        saveAndExit();
        break;
    }
  }

  void exit() {
    if(edited) {
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
                  child: Text("Exit"),
                  textColor: Colors.red,
                  onPressed: () {
                    Navigator.pop(context);
                    Navigator.pop(context);
                  },
                ),
              ]);
        },
      );
    } else {
      Navigator.pop(context);
    }
  }

  void delete() {
    var db = DatabaseHelper.instance;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
            title: Text("Exit without saving"),
            content: Text("You are about to close the note without saving it."),
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

                  Navigator.pop(context);
                  Navigator.pop(context);
                },
              ),
            ]);
      },
    );
  }

  void save() {
    var db = DatabaseHelper.instance;

    note.title = titleController.text;
    note.content = contentController.text;

    db.persist(note);

    edited = false;
  }

  void saveAndExit() {
    save();

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: <Widget>[
          SizedBox(height: 20), //notification bar
          Container(
            child: Padding(
              padding: EdgeInsets.only(top: 20, left: 30, right: 30),
              child: TextField(
                controller: titleController,
                autofocus: true,
                maxLines: 1,
                style: titleTextStyle,
                decoration: InputDecoration(
                  border: InputBorder.none,
                  hintText: 'Title',
                  hintStyle: titleTextStyle.copyWith(color: Colors.grey),
                ),
                inputFormatters: <TextInputFormatter>[
                  new AlwaysUppercaseFormatter()
                ],
                onSubmitted: (value) =>
                    FocusScope.of(context).requestFocus(contentFocus),
                onChanged: (value) => edited = true,
              ),
            ),
          ),
          Expanded(
            child: Padding(
              padding:
                  EdgeInsets.only(top: 10, left: 30, right: 30, bottom: 20),
              child: TextField(
                controller: contentController,
                focusNode: contentFocus,
                expands: true,
                autocorrect: true,
                keyboardType: TextInputType.multiline,
                maxLines: null,
                style: contentTextStyle,
                decoration: InputDecoration(
                  border: InputBorder.none,
                  hintText: 'Content of your note',
                  hintStyle: contentTextStyle.copyWith(color: Colors.grey),
                ),
                onChanged: (value) => edited = true,
              ),
            ),
          ),
          BottomNavigationBar(
            backgroundColor: Color.fromARGB(255, 35, 35, 35),
            selectedItemColor: Color.fromARGB(255, 170, 170, 170),
            unselectedItemColor: Color.fromARGB(255, 170, 170, 170),
            showSelectedLabels: false,
            showUnselectedLabels: false,
            elevation: 16,
            type: BottomNavigationBarType.fixed,
            onTap: onBarTapped,
            items: [
              BottomNavigationBarItem(
                icon: Icon(Icons.close),
                title: Text("Cancel"),
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.delete),
                title: Text("Delete"),
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.save),
                title: Text("Save"),
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.check),
                title: Text("Save and exit"),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
