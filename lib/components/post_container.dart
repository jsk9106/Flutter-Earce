import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:eacre/controller/post_stream_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'build_post_list_item.dart';

class PostContainer extends StatefulWidget {
  const PostContainer({Key key}) : super(key: key);

  @override
  _PostContainerState createState() => _PostContainerState();
}

class _PostContainerState extends State<PostContainer> {
  @override
  void initState() {
    // stream 값 초기화
    Get.find<PostStreamController>().areaInit();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => StreamBuilder(
        stream: Get.find<PostStreamController>().stream.value,
        builder: (context, snapshot) {
          if (!snapshot.hasData) return LinearProgressIndicator();
          return buildPostList(snapshot.data.docs);
        },
      ),
    );
  }

  Widget buildPostList(snapshot) {
    return ListView.builder(
      shrinkWrap: true,
      physics: BouncingScrollPhysics(),
      itemCount: snapshot.length,
      itemBuilder: (context, index) {
        final QueryDocumentSnapshot item = snapshot[index];
        return BuildPostListItem(item: item);
      },
    );
  }
}