import 'package:flutter/material.dart';

import '../constants.dart';

Widget videoMessage(context, message) {
  return SizedBox(
    width: MediaQuery.of(context).size.width * 0.45,
    child: AspectRatio(
      aspectRatio: 1.6,
      child: Stack(
        alignment: Alignment.center,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.network(
                "https://images.unsplash.com/photo-1459865264687-595d652de67e?ixid=MXwxMjA3fDB8MHxzZWFyY2h8OXx8Zm9vdGJhbGx8ZW58MHx8MHw%3D&ixlib=rb-1.2.1&auto=format&fit=crop&w=500&q=60"),
          ),
          Container(
            height: 25,
            width: 25,
            decoration: BoxDecoration(
              color: kShadowColor,
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.play_arrow, size: 16, color: Colors.white),
          ),
        ],
      ),
    ),
  );
}