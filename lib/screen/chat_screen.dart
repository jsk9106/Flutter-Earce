import 'package:eacre/constants.dart';
import 'package:eacre/screen/message_screen.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'all_team_screen.dart';

class ChatScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            buildChatAppBar(size),
            buildChatList(),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.person_add),
        backgroundColor: kShadowColor,
        onPressed: () => Get.to(AllTeamScreen()),
      ),
    );
  }

  Container buildChatAppBar(Size size) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      height: size.height * 0.1,
      color: kShadowColor,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text("Chats", style: TextStyle(color: Colors.white, fontSize: 25)),
          IconButton(
              icon: Icon(Icons.search),
              color: Colors.white,
              onPressed: () {
                print("search");
              }),
        ],
      ),
    );
  }

  Expanded buildChatList() {
    return Expanded(
      child: ListView.builder(
        padding: EdgeInsets.only(top: 2),
        physics: BouncingScrollPhysics(),
        itemCount: 5,
        itemBuilder: (context, index) {
          return buildChatListItem();
        },
      ),
    );
  }

  GestureDetector buildChatListItem() {
    return GestureDetector(
      onTap: () => Get.to(MessageScreen()),
      child: Container(
        color: Colors.white,
        margin: const EdgeInsets.symmetric(vertical: 1),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
        child: Row(
          children: [
            CircleAvatar(radius: 20),
            SizedBox(width: 20),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("팀 명", style: TextStyle(fontSize: 16)),
                  Text("채팅 내용",
                      style: TextStyle(
                          fontSize: 13, color: Colors.black.withOpacity(0.6))),
                ],
              ),
            ),
            Text("3m ago", style: TextStyle(fontSize: 13)),
          ],
        ),
      ),
    );
  }
}
