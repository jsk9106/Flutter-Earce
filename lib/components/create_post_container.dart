import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:eacre/controller/post_stream_controller.dart';
import 'package:eacre/model/area_model.dart';
import 'package:eacre/screen/create_post_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class CreatePostContainer extends StatefulWidget {
  final User currentUser;

  const CreatePostContainer({
    Key key,
    @required this.currentUser
  }) : super(key: key);

  @override
  _CreatePostContainerState createState() => _CreatePostContainerState();
}

class _CreatePostContainerState extends State<CreatePostContainer> {
  String imageUrl;
  String dropdownValue;

  Future<void> getPhoto() async {
    await FirebaseFirestore.instance
        .collection("team")
        .where('uid', isEqualTo: FirebaseAuth.instance.currentUser.uid)
        .snapshots()
        .listen((event) {
      setState(() {
        imageUrl = event.docs[0]["imageUrl"];
        // print(imageUrl);
      });
    });
  }

  @override
  void initState() {
    getPhoto();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 5),
      padding: const EdgeInsets.fromLTRB(12.0, 8.0, 12.0, 0.0),
      color: Colors.white,
      child: Column(
        children: [
          userImgAndCreatePost(context),
          Divider(height: 10, thickness: 0.5),
          viewButton(),
        ],
      ),
    );
  }

  Container viewButton() {
    return Container(
      height: 40.0,
      child: DropdownButton<String>(
        hint: Text("지역 선택"),
        value: dropdownValue,
        underline: Container(),
        style: TextStyle(color: Colors.black, fontSize: 14),
        onChanged: (String newValue) {
          setState(() {
            dropdownValue = newValue;
          });
          Get.find<PostStreamController>().areaChange(dropdownValue);
        },
        items: areaList.map<DropdownMenuItem<String>>((String value) {
          return DropdownMenuItem<String>(
            value: value,
            child: Text(value),
          );
        }).toList(),
      ),
    );
  }

  Row userImgAndCreatePost(BuildContext context) {
    return Row(
      children: [
        CircleAvatar(
          radius: 20.0,
          backgroundColor: Colors.grey[200],
          backgroundImage: imageUrl == null
              ? Image.network(
                      "https://www.freeiconspng.com/thumbs/login-icon/user-login-icon-14.png").image
              : Image.network(imageUrl).image,
        ),
        SizedBox(width: 12.0),
        Expanded(
            child: GestureDetector(
          onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) =>
                      CreatePostScreen(currentUser: widget.currentUser))),
          child: Text("경기 일정을 올려보세요!", style: TextStyle(color: Colors.black45)),
        )),
      ],
    );
  }
}
