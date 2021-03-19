import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:flutter/material.dart';

class PostStreamController extends GetxController {
  static PostStreamController get to => Get.find();
  ScrollController scrollController = ScrollController();
  int _limit = 4;
  int limitIncrement = 4;

  @override
  void onInit() {
    scrollController.addListener(scrollListener);
    super.onInit();
  }

  void scrollListener() {
    if (scrollController.offset >= scrollController.position.maxScrollExtent &&
        !scrollController.position.outOfRange) {
      _limit += limitIncrement;
      stream(FirebaseFirestore.instance
                .collection('post')
                .where('time', isGreaterThan: DateTime.now())
                .limit(_limit)
                .snapshots());
      print(_limit);
    }
  }

  Rx<Stream<QuerySnapshot>> stream = FirebaseFirestore.instance
      .collection('post')
      .where('time', isGreaterThan: DateTime.now())
      .limit(4)
      .snapshots()
      .obs;

  void areaInit() {
    print("_limit: $_limit");
    stream(FirebaseFirestore.instance
        .collection('post')
        .where('time', isGreaterThan: DateTime.now())
        .limit(_limit)
        .snapshots());
  }

  void areaChange(String value) {
    _limit = 4;
    print("_limit: $_limit");
    if (value != "전체")
      stream(FirebaseFirestore.instance
          .collection('post')
          .where('time', isGreaterThan: DateTime.now())
          .where('area', isEqualTo: value)
          .limit(_limit)
          .snapshots());
    else
      stream(FirebaseFirestore.instance
          .collection('post')
          .where('time', isGreaterThan: DateTime.now())
          .limit(_limit)
          .snapshots());
  }

  // void addLimit(int limit) {
  //   print("addLimit event!!");
  //   _limit = limit;
  //   stream(FirebaseFirestore.instance
  //       .collection('post')
  //       .where('time', isGreaterThan: DateTime.now())
  //       .limit(_limit)
  //       .snapshots());
  //   print("_limit: $_limit");
  // }
}
