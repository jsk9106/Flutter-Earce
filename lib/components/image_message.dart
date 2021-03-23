import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:eacre/constants.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:photo_view/photo_view.dart';

Widget imageMessage(DocumentSnapshot message) {
  return GestureDetector(
    onTap: () => Get.dialog(_fullPhoto(message)),
    child: SizedBox(
      width: Get.size.width * 0.45,
      child: AspectRatio(
        aspectRatio: 1,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: _buildImage(message),
        ),
      ),
    ),
  );
}

CachedNetworkImage _buildImage(DocumentSnapshot message) {
  return CachedNetworkImage(
    imageUrl: message['imageUrl'],
    fit: BoxFit.cover,
    placeholder: (context, url) => Center(
        child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(kShadowColor))),
    errorWidget: (context, url, error) => Center(child: Icon(Icons.error)),
  );
}

Widget _fullPhoto(DocumentSnapshot message){
  return PhotoView(
    imageProvider: CachedNetworkImageProvider(message['imageUrl']),
  );
}