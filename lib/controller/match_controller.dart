import 'package:cloud_firestore/cloud_firestore.dart';

class MatchController {
  Future<dynamic> delete(String id) async {
    await FirebaseFirestore.instance
        .collection('post')
        .doc(id)
        .delete()
        .then((value) => print("completed delete"))
        .catchError((error) => print("Failed to delete: $error"));
  }

  Future<dynamic> completed(String id) async {
    await FirebaseFirestore.instance
        .collection('post')
        .doc(id)
        .update({
          'isMatched': true,
        })
        .then((value) => print("completed success"))
        .catchError((error) => print("Failed to delete: $error"));
  }
}
