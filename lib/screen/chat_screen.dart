import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:eacre/constants.dart';
import 'package:eacre/screen/message_screen.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ChatScreen extends StatefulWidget {
  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _filter = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  String _searchText = "";

  _ChatScreenState() {
    _filter.addListener(() {
      setState(() {
        _searchText = _filter.text;
      });
    });
  }

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
          Text("Chats", style: TextStyle(color: Colors.white, fontSize: 25)),
          searchBar(),
        ],
      ),
    );
  }

  Expanded searchBar() {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.only(left: 20),
        decoration: BoxDecoration(
          color: kScaffoldColor.withOpacity(0.12),
          borderRadius: BorderRadius.circular(10),
        ),
        child: TextField(
          controller: _filter,
          focusNode: _focusNode,
          style: TextStyle(
            color: Colors.white,
          ),
          textAlignVertical: TextAlignVertical.center,
          decoration: InputDecoration(
            border: InputBorder.none,
            hintText: "팀 명으로 검색",
            hintStyle: TextStyle(
              color: Colors.white.withOpacity(0.4),
              fontSize: 13,
            ),
            contentPadding: const EdgeInsets.only(left: 10),
            suffixIcon: _focusNode.hasFocus
                ? IconButton(
                    icon: Icon(Icons.cancel_outlined),
                    color: Colors.white,
                    onPressed: () {
                      _filter.clear();
                      _searchText = "";
                      _focusNode.unfocus();
                    },
                  )
                : IconButton(
                    icon: Icon(Icons.search),
                    color: Colors.white,
                    onPressed: () {},
                  ),
          ),
        ),
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
    List searchResult = [];
    for (DocumentSnapshot d in snapshot) {
      if (d['team_name'].contains(_searchText)) {
        searchResult.add(d);
      }
    }
    return ListView.builder(
      padding: EdgeInsets.only(top: 2),
      physics: BouncingScrollPhysics(),
      itemCount: searchResult.length,
      itemBuilder: (context, index) {
        return buildTeamListItem(searchResult[index]);
      },
    );
  }

  GestureDetector buildTeamListItem(team) {
    return GestureDetector(
      onTap: () => Get.to(
        () => MessageScreen(
          peerUserImgUrl: team['imageUrl'],
          peerUserUid: team['uid'],
          peerUserTeamName: team['team_name'],
        ),
      ),
      child: Container(
        color: Colors.white,
        margin: const EdgeInsets.symmetric(vertical: 1),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
        child: Row(
          children: [
            CircleAvatar(
                radius: 20,
                backgroundImage: Image.network(team['imageUrl']).image),
            SizedBox(width: 20),
            Expanded(
              child: Text(team['team_name'],
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            ),
            IconButton(
              icon: Icon(Icons.send),
              onPressed: () => Get.to(
                () => MessageScreen(
                  peerUserImgUrl: team['imageUrl'],
                  peerUserUid: team['uid'],
                  peerUserTeamName: team['team_name'],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
