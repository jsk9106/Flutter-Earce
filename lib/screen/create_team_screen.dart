import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:eacre/components/components.dart';
import 'package:eacre/constants.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

import 'nav_screen.dart';

class CreateTeamScreen extends StatefulWidget {
  @override
  _CreateTeamScreenState createState() => _CreateTeamScreenState();
}

class _CreateTeamScreenState extends State<CreateTeamScreen> {
  final User currentUser = FirebaseAuth.instance.currentUser;
  final teamNameController = TextEditingController();
  final imageController = TextEditingController();
  final FocusNode focusNode = FocusNode();

  String _teamImageURL = "";
  File _image;
  String isUid = 'load';

  uidCheck() async {
    // currentUser가 collection 'team'에 등록되어있는지 확인
    if (currentUser != null) {
      FirebaseFirestore.instance
          .collection('team')
          .where('uid', isEqualTo: currentUser.uid)
          .snapshots()
          .listen((event) {
        setState(() {
          if (event.docs.length != 0) {
            isUid = 'true';
          } else {
            isUid = 'false';
          }
        });
      });
    }
  }

  @override
  void initState() {
    uidCheck();
    super.initState();
  }

  // Firestore에 유저 정보 add
  void add() {
    FirebaseFirestore.instance.collection("team").add({
      "team_name": teamNameController.text,
      "imageUrl": _teamImageURL,
      "uid": currentUser.uid,
    });
  }

  // 유저 갤러리에서 선택된 이미지 가져오기
  Future getImage() async {
    ImagePicker picker = ImagePicker();
    PickedFile pickedFile;

    // Let user select photo from gallery
    pickedFile = await picker.getImage(
      source: ImageSource.gallery,
    );

    setState(() {
      if (pickedFile != null) {
        // _images.add(File(pickedFile.path));
        _image = File(pickedFile.path); // Use if you only need a single picture
        print(pickedFile.path);
      } else {
        print('No image selected.');
      }
    });
  }

  // 선택된 이미지 storage에 업로드 후 url 가져오기 그 다음 add 함수 실행
  Future uploadFile() async {
    Reference storageReference =
        FirebaseStorage.instance.ref().child('teamImages/${currentUser.uid}}');
    UploadTask uploadTask = storageReference.putFile(_image);
    await uploadTask
        .whenComplete(() => storageReference.getDownloadURL().then((fileURL) {
              setState(() {
                _teamImageURL = fileURL;
              });
            }));
  }

  @override
  Widget build(BuildContext context) {
    if (isUid == 'false')
      return createTeamWidget();
    else if (isUid == 'true')
      return NavScreen();
    else
      return Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
  }

  Scaffold createTeamWidget() {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Container(
            color: Colors.white,
            height: Get.size.height - 90,
            margin: EdgeInsets.symmetric(vertical: 30),
            padding: EdgeInsets.symmetric(horizontal: 10, vertical: 30),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text("팀 등록하기",
                    style:
                        TextStyle(fontSize: 30, fontWeight: FontWeight.bold)),
                SizedBox(height: 70),
                imageUrlField(),
                SizedBox(height: 30),
                Field(
                  controller: teamNameController,
                  focusNode: focusNode,
                  labelText: "팀 명",
                  hintText: "팀 명을 적어주세요",
                ),
                SizedBox(height: 50),
                RaisedButton(
                  child: Text("팀 등록하기",
                      style: TextStyle(color: Colors.white, fontSize: 15)),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: EdgeInsets.symmetric(vertical: 20, horizontal: 30),
                  color: kShadowColor,
                  elevation: 0,
                  onPressed: () async{
                    if(focusNode.hasFocus) focusNode.unfocus();
                    setState(() {
                      isUid = 'load';
                    });
                    await uploadFile();
                    add();
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget imageUrlField() {
    return Container(
      width: 150,
      height: 150,
      child: InkWell(
        child: Stack(
          alignment: Alignment.center,
          children: [
            Container(
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(100),
                  boxShadow: [
                    BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        offset: Offset(0, 5),
                        blurRadius: 7)
                  ]),
              child: CircleAvatar(
                backgroundImage: _image != null
                    ? Image.file(_image).image
                    : Image.network(
                            "https://www.freeiconspng.com/thumbs/login-icon/user-login-icon-14.png")
                        .image,
                radius: 70,
                backgroundColor: Colors.grey[200],
              ),
            ),
            Align(
              alignment: Alignment.topLeft,
              child: Container(
                decoration:
                    BoxDecoration(color: Colors.white, shape: BoxShape.circle,
                        // border: Border.all(color: Colors.grey[200]),
                        boxShadow: [
                      BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          offset: Offset(0, 5),
                          blurRadius: 7)
                    ]),
                child: IconButton(
                  icon: Icon(Icons.camera_alt),
                  iconSize: 30,
                  onPressed: () {},
                ),
              ),
            )
          ],
        ),
        onTap: () {
          getImage();
        },
      ),
    );
  }

  TextField teamNameField() {
    return TextField(
      controller: teamNameController,
      decoration: InputDecoration(
        labelText: "팀 명",
        labelStyle: TextStyle(color: kBodyTextColorDark),
        hintText: "팀 명을 입력해주세요.",
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(10.0)),
          borderSide: BorderSide(color: Colors.grey),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(10.0)),
          borderSide: BorderSide(color: Colors.grey),
        ),
      ),
    );
  }
}
