import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:datetime_picker_formfield/datetime_picker_formfield.dart';
import 'package:eacre/components/components.dart';
import 'package:eacre/constants.dart';
import 'package:eacre/model/area_model.dart';
import 'package:eacre/screen/nav_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class CreatePostScreen extends StatefulWidget {
  final User currentUser;

  const CreatePostScreen({
    Key key,
    @required this.currentUser,
  }) : super(key: key);

  @override
  _CreatePostScreenState createState() => _CreatePostScreenState();
}

class _CreatePostScreenState extends State<CreatePostScreen> {
  String teamName = "";
  String imageUrl;
  String dropdownValue = "서울";
  final locationController = TextEditingController();
  final targetController = TextEditingController();
  DateTime dateTime;
  final format = DateFormat("yyyy-MM-dd HH:mm");
  bool isMatched = false;

  // 유저 정보 가져오기
  Future<void> getUser() async {
    await FirebaseFirestore.instance
        .collection("team")
        .where('uid', isEqualTo: FirebaseAuth.instance.currentUser.uid)
        .snapshots()
        .listen((event) {
      setState(() {
        teamName = event.docs[0]["team_name"];
        imageUrl = event.docs[0]["imageUrl"];
      });
    });
  }

//  게시물 firestore에 인풋
  void add() {
    FirebaseFirestore.instance.collection("post").add({
      "area": dropdownValue,
      "createTime": DateTime.now(),
      "imageUrl": imageUrl,
      "location": locationController.text,
      "target": targetController.text,
      "team_name": teamName,
      "time": dateTime,
      "isMatched": isMatched,
      "uid": widget.currentUser.uid,
    });
  }

  @override
  void initState() {
    getUser();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: customAppBar(),
      body: SingleChildScrollView(
        child: Container(
          margin: EdgeInsets.symmetric(vertical: 15),
          padding: EdgeInsets.symmetric(vertical: 10, horizontal: 10),
          color: Colors.white,
          height: MediaQuery.of(context).size.height * 0.8,
          child: Column(
            children: [
              Text("매치 등록",
                  style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold)),
              Divider(height: 30, thickness: 0.5),
              teamInfo(),
              SizedBox(height: 30),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  areaField(),
                  // timeDate Field
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("경기 일시", style: TextStyle(fontSize: 16)),
                      SizedBox(height: 10),
                      Container(
                        padding:
                            EdgeInsets.symmetric(horizontal: 5, vertical: 5),
                        width: 200,
                        decoration: BoxDecoration(
                            border: Border.all(
                                color: Colors.black.withOpacity(0.4)),
                            borderRadius: BorderRadius.circular(10)),
                        child: DateTimeField(
                          decoration: InputDecoration(border: InputBorder.none),
                          format: format,
                          onShowPicker: (context, currentValue) async {
                            final date = await showDatePicker(
                                context: context,
                                firstDate: DateTime(1900),
                                initialDate: currentValue ?? DateTime.now(),
                                lastDate: DateTime(2100));
                            if (date != null) {
                              final time = await showTimePicker(
                                context: context,
                                initialTime: TimeOfDay.fromDateTime(
                                    currentValue ?? DateTime.now()),
                              );
                              setState(() {
                                dateTime = DateTimeField.combine(date, time);
                              });
                              return DateTimeField.combine(date, time);
                            } else {
                              return currentValue;
                            }
                          },
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              SizedBox(height: 30),
              Field(
                  controller: locationController,
                  labelText: "경기 장소",
                  hintText: "ex) 서울 OO학교 운동장"),
              SizedBox(height: 30),
              Field(
                  controller: targetController,
                  labelText: "경기 대상",
                  hintText: "ex) 5,6 학년"),
              SizedBox(height: 30),
              RaisedButton(
                child: Text("매치 등록하기",
                    style: TextStyle(color: Colors.white, fontSize: 15)),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: EdgeInsets.symmetric(vertical: 20, horizontal: 30),
                color: kShadowColor,
                elevation: 0,
                onPressed: () {
                  add();
                  Get.offAll(NavScreen());
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Row teamInfo() {
    return Row(
      children: [
        CircleAvatar(
          backgroundImage: imageUrl == null
              ? Image.network(
                      "https://www.freeiconspng.com/thumbs/login-icon/user-login-icon-14.png")
                  .image
              : Image.network(imageUrl).image,
        ),
        SizedBox(width: 5),
        Text(teamName, style: TextStyle(fontSize: 20)),
      ],
    );
  }

  Widget areaField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("경기 지역", style: TextStyle(fontSize: 16)),
        SizedBox(height: 10),
        Container(
          width: 180,
          padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          decoration: BoxDecoration(
              border: Border.all(color: Colors.black.withOpacity(0.4)),
              borderRadius: BorderRadius.circular(10)),
          child: DropdownButton<String>(
            value: dropdownValue,
            icon: Icon(Icons.arrow_downward),
            iconSize: 24,
            underline: Container(),
            style: TextStyle(color: Colors.black, fontSize: 16),
            onChanged: (String newValue) {
              setState(() {
                dropdownValue = newValue;
              });
            },
            items: formAreaList.map<DropdownMenuItem<String>>((String value) {
              return DropdownMenuItem<String>(
                value: value,
                child: Text(value),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }
}
