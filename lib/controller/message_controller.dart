import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';

class MessageController extends GetxController {
  final ScrollController scrollController = ScrollController();
  RxInt limit = 20.obs;
  int limitIncrement = 20;
  int _maxLimit;

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

  void scrollListener() {
    if (scrollController.offset >= scrollController.position.maxScrollExtent &&
        !scrollController.position.outOfRange) {
      if (_maxLimit > limit.value) {
        print(_maxLimit);
        limit += limitIncrement;
      }
    }
  }

  void getMaxLimit(int maxLimit) {
    _maxLimit = maxLimit;
  }

  void initLimit() {
    limit(20);
  }
}
