import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';

class HomeController extends GetxController {
  static HomeController get to => Get.find();
  final ScrollController scrollController = ScrollController();
  RxInt limit = 4.obs;
  int limitIncrement = 4;
  int maxLimit;
  RxString dropdownValue = ''.obs;

  @override
  void onInit() {
    getMaxLimit();
    scrollController.addListener(scrollListener);
    super.onInit();
  }

  @override
  void onClose() {
    scrollController.dispose();
    super.onClose();
  }

  void limitInit(){
    limit(4);
  }

  void scrollListener() {
    if (scrollController.offset >= scrollController.position.maxScrollExtent &&
        !scrollController.position.outOfRange) {
      if (maxLimit > limit.value) {
        print("scroll Event!!");
        limit += limitIncrement;
        print(limit);
      }
    }
  }

  // Future<void> getMaxLimit() async {
  //   await FirebaseFirestore.instance.collection('post').get().then((value) {
  //     maxLimit = value.docs.length;
  //     print("maxLimit: $maxLimit");
  //   });
  // }

  void getMaxLimit() {
    FirebaseFirestore.instance.collection('post').where('time', isGreaterThan: DateTime.now()).snapshots().listen((event) {
      maxLimit = event.docs.length;
    });
  }

  void areaChange(String value){
    dropdownValue(value);
  }
}
