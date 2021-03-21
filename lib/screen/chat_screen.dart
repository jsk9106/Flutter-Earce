import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:eacre/components/components.dart';
import 'package:eacre/constants.dart';
import 'package:eacre/controller/chatInfo_controller.dart';
import 'package:eacre/screen/message_screen.dart';
import 'package:eacre/screen/team_list_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
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
  String chatResult;

  _ChatScreenState() {
    _filter.addListener(() {
      setState(() {
        _searchText = _filter.text;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            buildChatAppBar(),
            buildChat(),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Get.to(() => TeamListScreen()),
        child: Icon(Icons.person_add),
        backgroundColor: kShadowColor,
      ),
    );
  }

  Container buildChatAppBar() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      height: Get.size.height * 0.1,
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

  Expanded buildChat() {
    return Expanded(
      child: StreamBuilder(
        // 채팅 방 목록 가져오기
        stream: FirebaseFirestore.instance.collection('chat').snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData)
            return Center(child: CircularProgressIndicator());
          return buildChatList(snapshot.data.docs);
        },
      ),
    );
  }

  ListView buildChatList(snapshot) {
    User currentUser = FirebaseAuth.instance.currentUser;
    List searchResult = [];
    // 가져온 채팅 방 목록에서 현재 유저의 uid값이 들어간 문서만 리스트에 담기
    for (DocumentSnapshot d in snapshot) {
      if (d.id.contains(currentUser.uid)) {
        searchResult.add(d);
      }
    }

    return ListView.builder(
      padding: EdgeInsets.only(top: 2),
      physics: BouncingScrollPhysics(),
      itemCount: searchResult.length,
      itemBuilder: (context, index) {
        return buildChatListItem(searchResult[index], currentUser);
      },
    );
  }

  Widget buildChatListItem(chat, User currentUser) {
    String result1 = chat.id.replaceAll(currentUser.uid, "");
    String result2 = result1.replaceAll("-", "");
    return Container(
      color: Colors.white,
      child: StreamBuilder(
        // 받아온 리스트 값으로 채팅 방 목록 만든 뒤 상대 유저 uid값을 구해서 스트림 빌더로 팀 콜렉션 호출
        stream: FirebaseFirestore.instance
            .collection('team')
            .where('uid', isEqualTo: result2)
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData)
            return Center(child: CircularProgressIndicator());
          return _buildTeamInfo(snapshot.data.docs, chat.id);
        },
      ),
    );
  }

  Widget _buildTeamInfo(snapshot, chatId) {
    // 가져온 chatId값으로 채팅 정보 가져와서 Get으로 뿌려주기(마지막 채팅내용, 마지막 채팅 시간)
    Get.put(ChatInfoController());
    Get.find<ChatInfoController>().getContent(chatId);
    Get.find<ChatInfoController>().getAgo(chatId);
    var teamInfo = snapshot[0];

    // 받아온 상대 유저 정보를 화면에 그리기(팀 로고, 팀 명)
    return GestureDetector(
      onTap: () => Get.to(
        () => MessageScreen(
          peerUserUid: teamInfo['uid'],
          peerUserTeamName: teamInfo['team_name'],
          peerUserImgUrl: teamInfo['imageUrl'],
        ),
      ),
      child: Container(
        color: Colors.transparent, // 컬러를 지정해줌으로써 공간을 다 먹고 아무데나 눌러도 네비게이터가 되게 함
        margin: const EdgeInsets.only(bottom: 5),
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
        child: Obx(
          () => Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              buildTeamImg(teamInfo['imageUrl'], 50),
              SizedBox(width: 10),
              Expanded(
                child: Column(
                  // mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(teamInfo['team_name'], style: TextStyle(fontSize: 18)),
                    SizedBox(height: 3),
                    Text(
                      Get.find<ChatInfoController>().content.value,
                      style: TextStyle(fontSize: 13, color: Colors.black45),
                    ),
                  ],
                ),
              ),
              Text(
                Get.find<ChatInfoController>().ago.value,
                style: TextStyle(fontSize: 13, color: Colors.black45),
              ),
            ],
          ),
        ),
      ),
    );
  }

}
