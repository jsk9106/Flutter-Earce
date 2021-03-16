import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../constants.dart';

Container chatInputField() {
  User currentUser = FirebaseAuth.instance.currentUser;
  TextEditingController inputMessage = TextEditingController();

  void send() {
    FirebaseFirestore.instance.collection("message").add({
      "isSender": true,
      "messageStatus": {
        "notSent": false,
        "view": false,
      },
      "messageType": {
        "audio": false,
        "image": false,
        "text": true,
        "video": false
      },
      "text": inputMessage.text,
      "sendTime": DateTime.now(),
      "uid": currentUser.uid,
    });
  }

  return Container(
    padding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
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