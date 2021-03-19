import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:eacre/controller/ago_controller.dart';
import 'package:get/get.dart';

class ChatInfoController extends GetxController{
  RxString content = "로딩중".obs;
  RxString ago = "로딩중".obs;

  void getContent(chatId){
    FirebaseFirestore.instance.collection('chat').doc(chatId).collection(chatId).get().then((value) {
      content(value.docs.toList().last['content']);
    });
  }

  // void getContent(chatId){
  //   FirebaseFirestore.instance.collection('chat').doc(chatId).collection(chatId).snapshots().listen((event) {
  //     print(event.docs.toList().last['content']);
  //     // content(event.docs.toList().last['content']);
  //   });
  // }

  void getAgo(chatId){
    FirebaseFirestore.instance.collection('chat').doc(chatId).collection(chatId).get().then((value) {
      ago(convertToAgo(value.docs.toList().last['sendTime'].toDate()));
    });
  }

}