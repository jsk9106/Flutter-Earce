import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../constants.dart';

class ChatInputField extends StatelessWidget {
  final String currentUserUid;
  final String peerUserUid;
  final String chatId;
  final TextEditingController inputMessage = TextEditingController();
  final ScrollController scrollController;

  ChatInputField({
    Key key,
    @required this.currentUserUid,
    @required this.peerUserUid,
    @required this.chatId,
    @required this.scrollController,
  }) : super(key: key);

  void send() {
    // type: 0 = text, 1 = image, 2 = sticker
    if (inputMessage.text.trim() != '') {
      var content = inputMessage.text;
      inputMessage.clear();

      var documentReference = FirebaseFirestore.instance
          .collection('chat')
          .doc(chatId)
          .collection(chatId)
          .doc(DateTime.now().millisecondsSinceEpoch.toString());

      FirebaseFirestore.instance.runTransaction((transaction) async {
        await transaction.set(
          documentReference,
          {
            'idFrom': currentUserUid,
            'idTo': peerUserUid,
            'sendTime': DateTime.now(),
            'content': content,
            'type': 0,
            'messageStatus': true,
          },
        );
      });

      // 채팅방에 user정보 한 번만 업로드
      FirebaseFirestore.instance
          .collection('chat')
          .doc(chatId)
          .get()
          .then((value) {
        if (value.data() == null) {
          FirebaseFirestore.instance.collection('chat').doc(chatId).set({
            'user1': currentUserUid,
            'user2': peerUserUid,
          });
        }
      });

      scrollController.animateTo(0.0, duration: Duration(milliseconds: 300), curve: Curves.easeOut);
    } else {
      // Fluttertoast.showToast(msg: 'Nothing to send');
      Get.snackbar("알림", "메세지가 없습니다", colorText: Colors.white);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            offset: Offset(0, 4),
            color: Colors.black.withOpacity(0.05),
            blurRadius: 32,
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            IconButton(
              icon: Icon(Icons.attach_file),
              color: kShadowColor,
              onPressed: () {},
            ),
            Expanded(
              child: Container(
                padding: EdgeInsets.only(right: 15),
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    color: kShadowColor.withOpacity(0.1)),
                child: Row(
                  children: [
                    IconButton(
                      icon: Icon(Icons.emoji_emotions_outlined),
                      color: Colors.black45,
                      onPressed: () {},
                    ),
                    Expanded(
                      child: TextField(
                        controller: inputMessage,
                        decoration: InputDecoration(
                          hintText: "메세지를 입력하세요",
                          border: InputBorder.none,
                        ),
                      ),
                    ),
                    InkWell(
                      onTap: () => send(),
                      child: Icon(Icons.send),
                    )
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
