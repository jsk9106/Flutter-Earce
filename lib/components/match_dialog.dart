import 'package:eacre/constants.dart';
import 'package:eacre/controller/match_controller.dart';
import 'package:eacre/model/match_do_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

Widget matchDialog(BuildContext context, String id, MatchDo matchDo) {
  MatchController mathController = MatchController();

  return Column(
    crossAxisAlignment: CrossAxisAlignment.end,
    children: [
      Expanded(
        child: Container(color: Colors.transparent),
      ),
      Container(
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 30),
        height: Get.size.height * 0.3,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topRight: Radius.circular(50),
            topLeft: Radius.circular(50),
          ),
        ),
        child: Column(
          children: [
            RaisedButton(
              onPressed: () {},
              elevation: 0,
              color: Colors.white,
              textColor: Colors.black,
              child: Text(
                changeString(matchDo),
                style: TextStyle(fontSize: 18),
              ),
            ),
            SizedBox(height: 40),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                customButton(
                  "네",
                  () {
                    switch (matchDo) {
                      case MatchDo.delete:
                        mathController.delete(id);
                        break;
                      case MatchDo.completed:
                        mathController.completed(id);
                        break;
                    }
                    // Scaffold.of(context).showSnackBar(SnackBar(
                    //   content: Text(changeToastString(matchDo)),
                    // ));
                    Get.back();
                    Get.snackbar("알림", changeSnackbatText(matchDo), colorText: Colors.white);
                  },
                ),
                customButton(
                  "아니요",
                  () => Get.back(),
                ),
              ],
            ),
          ],
        ),
      ),
    ],
  );
}

RaisedButton customButton(String text, Function press) {
  return RaisedButton(
    onPressed: press,
    textColor: Colors.white,
    elevation: 0,
    color: kShadowColor,
    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
    child: Text(text, style: TextStyle(fontSize: 16)),
  );
}

String changeString(MatchDo matchDo) {
  switch (matchDo) {
    case MatchDo.delete:
      return "정말 삭제하시겠습니까?";
      break;
    case MatchDo.completed:
      return "매치완료 하시겠습니까?";
      break;
  }
}

String changeSnackbatText(MatchDo matchDo) {
  switch (matchDo) {
    case MatchDo.delete:
      return "매치 삭제가 완료되었습니다.";
      break;
    case MatchDo.completed:
      return "매치완료 처리되었습니다.";
      break;
  }
}
