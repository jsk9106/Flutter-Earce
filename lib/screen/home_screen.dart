import 'package:eacre/components/components.dart';
import 'package:eacre/controller/post_stream_controller.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key key}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final PostStreamController controller = Get.put(PostStreamController());

  // final ScrollController _scrollController = ScrollController();
  // int limit = 4;
  // int limitIncrement = 4;
  // int maxLimit;
  // bool load = false;
  //
  // Future<void> getMexLimit() async {
  //   await FirebaseFirestore.instance.collection('post').get().then((value) {
  //     print(value.docs.length);
  //     setState(() {
  //       maxLimit = value.docs.length;
  //       print(maxLimit);
  //     });
  //   });
  // }
  //
  // void scrollListener() {
  //   if (_scrollController.offset >=
  //           _scrollController.position.maxScrollExtent &&
  //       !_scrollController.position.outOfRange) {
  //     print("limit: $limit");
  //     if (maxLimit >= limit) {
  //       setState(() {
  //         limit += limitIncrement;
  //       });
  //       Get.find<PostStreamController>().addLimit(limit);
  //     }
  //   }
  // }

  // @override
  // void initState() {
  //   super.initState();
  //   getMexLimit();
  //   _scrollController.addListener(scrollListener);
  // }

  @override
  Widget build(BuildContext context) {
    User currentUser = FirebaseAuth.instance.currentUser;
    return Scaffold(
      appBar: customAppBar(),
      body: SingleChildScrollView(
        controller: controller.scrollController,
        child: Column(
          children: [
            CreatePostContainer(currentUser: currentUser),
            PostContainer(),
          ],
        ),
      ),
    );
  }
}
