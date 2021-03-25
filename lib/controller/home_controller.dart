import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';

class HomeController extends GetxController {
  static HomeController get to => Get.find();
  final ScrollController scrollController = ScrollController();
  RxInt limit = 4.obs;
  int limitIncrement = 4;
  int _maxLimit;
  RxString dropdownValue = ''.obs;

  @override
  void onInit() {
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
      if (_maxLimit > limit.value) {
        limit += limitIncrement;
      }
    }
  }

  void getMaxLimit(int maxLimit){
    _maxLimit = maxLimit;
  }

  void areaChange(String value){
    dropdownValue(value);
  }
}
