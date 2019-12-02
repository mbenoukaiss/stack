import 'package:flutter/material.dart';

import 'notes_menu.dart';

void main() => runApp(App());

class App extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    TextStyle textStyle = TextStyle(color: Colors.white, fontFamily: 'Stylish');

    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        fontFamily: 'Stylish',
        primaryColor: Color.fromARGB(255, 40, 40, 40),
        accentColor: Color.fromARGB(255, 45, 45, 45),
        canvasColor: Color.fromARGB(255, 40, 40, 40),
        textTheme: TextTheme(
          body1: textStyle,
          button: textStyle,
        ),
        cardTheme: CardTheme(
          color: Color.fromARGB(255, 51, 51, 51),
          elevation: 4,
        ),
        dialogTheme: DialogTheme(
            backgroundColor: Color.fromARGB(255, 30, 30, 30),
            titleTextStyle: textStyle.copyWith(fontSize: 20),
            contentTextStyle: textStyle,
            elevation: 8,
            shape: BeveledRectangleBorder()),
      ),
      home: Home(title: 'Notes'),
    );
  }
}

class Home extends StatefulWidget {
  Home({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  @override
  Widget build(BuildContext context) {
    NotesManager manager = NotesManager();

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Container(
        color: Color.fromARGB(255, 40, 40, 40),
        child: manager,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          manager.pushNoteEditor(context);
        },
        child: Icon(Icons.note_add),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(16.0)),
        ),
      ),
    );
  }
}
