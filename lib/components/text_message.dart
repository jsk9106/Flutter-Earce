import 'package:eacre/constants.dart';
import 'package:flutter/material.dart';

Container textMessage(message) {
  return Container(
    padding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
    decoration: BoxDecoration(
      color: kShadowColor.withOpacity(message['isSender'] ? 1 : 0.3),
      borderRadius: BorderRadius.circular(10),
    ),
    child: Text(
      message['text'].toString(),
      style:
      TextStyle(color: message['isSender'] ? Colors.white : Colors.black),
    ),
  );
}