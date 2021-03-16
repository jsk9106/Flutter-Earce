import 'package:eacre/components/components.dart';
import 'package:eacre/controller/post_stream_controller.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    User currentUser = FirebaseAuth.instance.currentUser;
    Get.put(PostStreamController());
    return Scaffold(
      appBar: customAppBar(),
      body: SingleChildScrollView(
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
