import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:eacre/constants.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class MatchController {
  Future<dynamic> deleteMatch(String id) async{
    await dialog(id);
  }

  Future dialog(String id) {
    return Get.dialog(
      Column(
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
                  child: Text("정말 삭제하시겠습니까?", style: TextStyle(fontSize: 18)),
                ),
                SizedBox(height: 40),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    customButton(
                      "삭제",
                      () {
                        delete(id);
                        Get.back();
                      },
                    ),
                    customButton(
                      "취소",
                      () => Get.back(),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
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

  Future<dynamic> delete(String id) async{
    await FirebaseFirestore.instance
        .collection('post')
        .doc(id)
        .delete()
        .then((value) => print("delete Complete"))
        .catchError(
          (error) => print("Failed to delete user: $error")
        );
  }
}
