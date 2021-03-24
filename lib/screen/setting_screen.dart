import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:eacre/components/components.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

import '../constants.dart';

class SettingScreen extends StatefulWidget {
  @override
  _SettingScreenState createState() => _SettingScreenState();
}

class _SettingScreenState extends State<SettingScreen> {
  final TextEditingController textEditingController = TextEditingController();
  final FocusNode focusNode = FocusNode();
  User currentUser = FirebaseAuth.instance.currentUser;
  String imageUrl;
  String teamName;
  String docId;
  File _image;
  String _editTeamName;
  bool loading = false;

  // 유저 정보가져오기
  Future<void> getUserInfo() async {
    await FirebaseFirestore.instance
        .collection('team')
        .where('uid', isEqualTo: currentUser.uid)
        .get()
        .then((value) {
      if (value.docs.length != 0) {
        setState(() {
          docId = value.docs[0].reference.id;
          imageUrl = value.docs[0]['imageUrl'];
          teamName = value.docs[0]['team_name'];
        });
      }
    }).catchError((error) => print("error: $error"));
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
                imageUrl = fileURL;
              });
            }));
  }

//  수정된 정보 업로드
  Future<void> edit() async {
    FirebaseFirestore.instance.collection('team').doc(docId).update({
      "imageUrl": imageUrl,
      "team_name": _editTeamName,
    }).catchError((error) => print("error: $error"));
  }

  // 수정 완료 눌렀을 때 처리
  Future<void> finalEdit() async{
    if(_image == null && textEditingController.text == '') return Get.snackbar("알림", "변경 된 값이 없습니다.", backgroundColor: kShadowColor.withOpacity(0.5), colorText: Colors.white, snackPosition: SnackPosition.BOTTOM);
    if(focusNode.hasFocus) focusNode.unfocus();
    setState(() => loading = true);
    if (textEditingController.text == '') {
      _editTeamName = teamName;
    } else {
      _editTeamName = textEditingController.text;
    }
    if (_image != null) await uploadFile();
    await edit();
    await getUserInfo();
    setState(() => loading = false);
    textEditingController.clear();
    Get.snackbar("알림", "정보수정 완료!!", backgroundColor: kShadowColor.withOpacity(0.5), colorText: Colors.white, snackPosition: SnackPosition.BOTTOM);
  }

  @override
  void initState() {
    getUserInfo();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        child: Column(
          children: [
            _buildTitle(),
            const SizedBox(height: 50),
            loading
                ? Center(
                    child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation(kShadowColor)))
                : _buildBody(),
          ],
        ),
      ),
    );
  }

  Widget _buildBody() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        _buildTeamLogo(),
        const SizedBox(height: 50),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 60),
          child: Field(
            controller: textEditingController,
            labelText: teamName,
            hintText: teamName,
            focusNode: focusNode,
          ),
        ),
        const SizedBox(height: 50),
        RaisedButton(
          onPressed: finalEdit,
          color: kShadowColor,
          textColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
          child: Text("정보수정"),
        )
      ],
    );
  }

  Widget _buildTeamLogo() {
    return GestureDetector(
      onTap: getImage,
      child: Stack(
        alignment: Alignment.bottomRight,
        children: [
          ClipOval(
            child: _image != null
                ? Image.file(_image, width: 120, height: 120, fit: BoxFit.cover)
                : CachedNetworkImage(
                    imageUrl: imageUrl != null
                        ? imageUrl
                        : "https://www.freeiconspng.com/thumbs/login-icon/user-login-icon-14.png",
                    width: 120,
                    height: 120,
                    fit: BoxFit.cover,
                    placeholder: (context, url) =>
                        Container(color: Colors.grey[200]),
                    errorWidget: (context, url, error) =>
                        Center(child: Icon(Icons.error)),
                  ),
          ),
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: kShadowColor,
            ),
            child: Icon(Icons.add, color: Colors.white),
          ),
        ],
      ),
    );
  }

  Container _buildTitle() {
    return Container(
      alignment: Alignment.center,
      height: Get.size.height * 0.1,
      width: double.infinity,
      color: kShadowColor,
      child: const Text("마이 페이지",
          style: TextStyle(color: Colors.white, fontSize: 25)),
    );
  }
}
