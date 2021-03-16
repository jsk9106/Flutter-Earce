import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:eacre/constants.dart';
import 'package:eacre/screen/message_screen.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AllTeamScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            buildChatAppBar(size),
            buildTeam(),
          ],
        ),
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
          Text("Team List",
              style: TextStyle(color: Colors.white, fontSize: 25)),
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

  Expanded buildTeam() {
    return Expanded(
      child: StreamBuilder(
        stream: FirebaseFirestore.instance.collection('team').snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData)
            return Center(child: CircularProgressIndicator());
          return buildTeamList(snapshot.data.docs);
        },
      ),
    );
  }

  ListView buildTeamList(snapshot) {
    return ListView.builder(
          padding: EdgeInsets.only(top: 2),
          physics: BouncingScrollPhysics(),
          itemCount: snapshot.length,
          itemBuilder: (context, index) {
            return buildTeamListItem(snapshot[index]);
          },
        );
  }

  GestureDetector buildTeamListItem(team) {
    return GestureDetector(
      onTap: () => Get.to(MessageScreen()),
      child: Container(
        color: Colors.white,
        margin: const EdgeInsets.symmetric(vertical: 1),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
        child: Row(
          children: [
            CircleAvatar(radius: 20, backgroundImage: Image.network(team['imageUrl']).image),
            SizedBox(width: 20),
            Expanded(
              child: Text(team['team_name'], style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            ),
            IconButton(icon: Icon(Icons.send), onPressed: () => Get.to(MessageScreen())),
          ],
        ),
      ),
    );
  }
}
