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
      } else{
        Get.snackbar('알림', '마지막 페이지입니다.', snackPosition: SnackPosition.BOTTOM);
      }
    }
  }

  Future<void> getMaxLimit() async {
    await FirebaseFirestore.instance.collection('post').get().then((value) {
      maxLimit = value.docs.length;
      print("maxLimit: $maxLimit");
    });
  }

  void areaChange(String value){
    dropdownValue(value);
  }
}
