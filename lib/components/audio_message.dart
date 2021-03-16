import 'package:eacre/constants.dart';
import 'package:flutter/material.dart';

Container audioMessage(context, message) {
  return Container(
    width: MediaQuery
        .of(context)
        .size
        .width * 0.55,
    padding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
    decoration: BoxDecoration(
      color: kShadowColor.withOpacity(message['isSender'] ? 1 : 0.3),
      borderRadius: BorderRadius.circular(20),
    ),
    child: Row(
      children: [
        Icon(Icons.play_arrow,
            color: message['isSender'] ? Colors.white : Colors.black),
        Expanded(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 10),
            child: Stack(
              clipBehavior: Clip.none,
              alignment: Alignment.center,
              children: [
                Container(
                  width: double.infinity,
                  height: 2,
                  color: message['isSender'] ? Colors.white.withOpacity(0.7) : kShadowColor.withOpacity(0.6),
                ),
                Positioned(
                  left: 0,
                  child: Container(
                    height: 8,
                    width: 8,
                    decoration: BoxDecoration(
                        color: message['isSender'] ? Colors.white : kShadowColor,
                        shape: BoxShape.circle
                    ),
                  ),
                )
              ],
            ),
          ),
        ),
        Text("0:37", style: TextStyle(fontSize: 12, color: message['isSender'] ? Colors.white : Colors.black),),
      ],
    ),
  );
}