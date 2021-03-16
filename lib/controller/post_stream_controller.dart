import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';

class PostStreamController {
  Rx<Stream<QuerySnapshot>> stream = FirebaseFirestore.instance.collection('post').where('time', isGreaterThan: DateTime.now()).snapshots().obs;
  void areaChange (String value) {
    if(value != "전체") stream(FirebaseFirestore.instance.collection('post').where('time', isGreaterThan: DateTime.now()).where('area', isEqualTo: value).snapshots());
    else stream(FirebaseFirestore.instance.collection('post').where('time', isGreaterThan: DateTime.now()).snapshots());
  }

  void areaInit() {
    stream(FirebaseFirestore.instance.collection('post').where('time', isGreaterThan: DateTime.now()).snapshots());
  }
}