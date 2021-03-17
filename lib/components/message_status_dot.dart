import 'package:flutter/material.dart';

import '../constants.dart';

Widget messageStatusDot(bool messageStatus) {
  return Container(
    margin: EdgeInsets.only(right: 10),
    height: 12,
    width: 12,
    decoration: BoxDecoration(
      color: messageStatus ? kShadowColor : Colors.red,
      shape: BoxShape.circle,
    ),
    child: Icon(
      messageStatus ? Icons.done : Icons.close,
      color: Colors.white,
      size: 8,
    ),
  );
}