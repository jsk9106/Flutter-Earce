import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:eacre/constants.dart';
import 'package:eacre/controller/ago_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ChatInfoController extends GetxController{
  RxString content = "로딩중".obs;
  RxString ago = "로딩중".obs;

  void getContent(String chatId){
    FirebaseFirestore.instance.collection('chat').doc(chatId).collection(chatId).snapshots().listen((event) {
      if(event.docs.length == 0){
        return;
      } else if(event.docs.toList().last['type'] == 1){
        content('사진');
      } else{
        content(event.docs.toList().last['content']);
      }
    });
  }

  void getAgo(String chatId){
    FirebaseFirestore.instance.collection('chat').doc(chatId).collection(chatId).snapshots().listen((event) {
      if(event.docs.length == 0){
        return;
      }
      ago(convertToAgo(event.docs.toList().last['sendTime'].toDate()));
    });
  }
  
  void deleteChatRoom(String chatId){
    CollectionReference chatRoom = FirebaseFirestore.instance.collection('chat').doc(chatId).collection(chatId);

    FirebaseFirestore.instance.collection('chat').doc(chatId).delete(); // 채팅방 삭제

    chatRoom.get().then((value) { // 채팅 내용 삭제
      for(DocumentSnapshot d in value.docs){
        d.reference.delete();
      }
    }).catchError((error) => print("error: $error"));

    Get.snackbar("알림", "채팅방 삭제완료", backgroundColor: kShadowColor.withOpacity(0.5), colorText: Colors.white, snackPosition: SnackPosition.BOTTOM);
  }

  // Future<void> listExample(String chatId) async { // storage 에 있는 사진 삭제
  //   firebase_storage.ListResult result =
  //   await firebase_storage.FirebaseStorage.instance.ref('chatImage/$chatId/').listAll();
  //
  //   result.items.forEach((firebase_storage.Reference ref) {
  //     ref.delete();
  //   });
  // }

}