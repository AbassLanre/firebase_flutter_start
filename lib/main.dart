import 'package:firebase_database/ui/firebase_animated_list.dart';
import 'package:firebase_flutter_start/model/board.dart';
import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Community Board',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  List<Board> boardMessages = List();
  Board board;
  final FirebaseDatabase database = FirebaseDatabase.instance;
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  DatabaseReference databaseReference;

  @override
  void initState() {
    super.initState();
    board = Board("", "");
    databaseReference = database.reference().child("Community Board");
    databaseReference.onChildAdded.listen(_onEntryAdded);
    databaseReference.onChildAdded.listen(_onEntryChanged);
  } //  void _incrementCounter() {
//    database.reference().child("Message").set({
//      "firstname": "Abass"
//    });
//    setState(() {
//      database.reference().child("Message").once().then((DataSnapshot datasnapshot){
//        Map<dynamic, dynamic> list =datasnapshot.value;
//        print(list.values);
//      });
//      _counter++;
//    });
//  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text("Community Board"),
        ),
        body: Column(
          children: <Widget>[
            Flexible(
                flex: 0,
                child: Form(
                    key: formKey,
                    child: Flex(
                      direction: Axis.vertical,
                      children: <Widget>[
                        ListTile(
                            leading: Icon(Icons.subject),
                            title: TextFormField(
                              initialValue: "",
                              onSaved: (val) => board.subject = val,
                              validator: (val) => val == "" ? val : null,
                            )),
                        ListTile(
                            leading: Icon(Icons.message),
                            title: TextFormField(
                              initialValue: "",
                              onSaved: (val) => board.body = val,
                              validator: (val) => val == "" ? val : null,
                            )),
                        //send button
                        FlatButton(
                            onPressed: () {
                              handleSubmit();
                            },
                            child: Text("Post"))
                      ],
                    ))),
            Flexible(
                child: FirebaseAnimatedList(
                  query: databaseReference,
                  itemBuilder: (_, DataSnapshot snapshot, Animation<double> animation, int index){
                    return Card(
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: Colors.red,
                        ),
                        title: Text(boardMessages[index].subject),
                        subtitle:Text(boardMessages[index].body),
                      ),
                    );
                  },
                ),
            )
          ],
        ));
  }

  void _onEntryAdded(Event event) {
    setState(() {
      boardMessages.add(Board.fromSnapshot(event.snapshot));
    });
  }

  void handleSubmit() {
    final FormState form =formKey.currentState;
    if (form.validate()){
      form.save();
      form.reset();
      //save to database
      databaseReference.push().set(board.toJson());
    }
  }

  void _onEntryChanged(Event event) {
    var oldEntry = boardMessages.singleWhere((element) => element.key==event.snapshot.key);
    setState(() {
      boardMessages[boardMessages.indexOf(oldEntry)]= Board.fromSnapshot(event.snapshot);
    });
  }
}
