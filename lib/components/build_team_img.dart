import 'package:cached_network_image/cached_network_image.dart';
import 'package:eacre/constants.dart';
import 'package:flutter/material.dart';

ClipOval buildTeamImg(var item, double size) {
  return ClipOval(
    child: CachedNetworkImage(
      width: size,
      height: size,
      imageUrl: item == null ? "https://www.freeiconspng.com/thumbs/login-icon/user-login-icon-14.png" : item,
      placeholder: (context, url) =>
          Container(color: kScaffoldColor),
      errorWidget: (context, url, error) => Icon(Icons.error),
    ),
  );
}