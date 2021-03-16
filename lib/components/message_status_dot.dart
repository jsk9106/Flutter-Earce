import 'package:flutter/material.dart';

import '../constants.dart';

Widget messageStatusDot(messageStatus) {
  Color dotColor () {
    if(messageStatus["notSent"]){
      return Colors.red;
    } else if(messageStatus["view"]) {
      return kShadowColor;
    } else if(!messageStatus["view"]) {
      return Colors.grey;
    } else {
      return Colors.transparent;
    }
  }
  return Container(
    margin: EdgeInsets.only(right: 10),
    height: 12,
    width: 12,
    decoration: BoxDecoration(
      color: dotColor(),
      shape: BoxShape.circle,
    ),
    child: Icon(
      messageStatus["notSent"] ? Icons.close : Icons.done,
      color: Colors.white,
      size: 8,
    ),
  );
}