import 'package:eacre/constants.dart';
import 'package:flutter/material.dart';

Container textMessage(message, bool isSender) {
  return Container(
    padding: EdgeInsets.symmetric(horizontal: 10, vertical: 7),
    decoration: BoxDecoration(
      color: kShadowColor.withOpacity(isSender ? 1 : 0.3),
      borderRadius: BorderRadius.circular(10),
    ),
    child: Text(
      message['content'],
      style:
      TextStyle(color: isSender ? Colors.white : Colors.black),
    ),
  );
}