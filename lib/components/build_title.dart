import 'package:eacre/constants.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

buildTitle(String title) {
  return Container(
    padding: const EdgeInsets.symmetric(horizontal: 15),
    height: Get.size.height * 0.08,
    width: double.infinity,
    color: kShadowColor,
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 25,
            color: Colors.white,
          ),
        ),
        IconButton(
          color: Colors.white,
          icon: Icon(
            Icons.logout,
            color: Colors.white,
          ),
          onPressed: () => FirebaseAuth.instance.signOut(),
        ),
      ],
    ),
  );
}