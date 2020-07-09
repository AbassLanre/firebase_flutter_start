import 'package:firebase_database/firebase_database.dart';

class Board {
  String key;
  String subject;
  String body;

  Board(this.subject, this.body);

  Board.fromSnapshot(DataSnapshot snapshot)
      : key = snapshot.key,
        body = snapshot.value["body"],
        subject = snapshot.value["subject"];

  toJson() {
    return {
      "subject": subject,
      "body": body,
    };
  }
}
