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
  void dispose() {
    _filter.dispose();
    super.dispose();
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
            hintText: "??? ????????? ??????",
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
        // ?????? ??? ?????? ????????????
        stream: FirebaseFirestore.instance.collection('chat').snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData)
            return Center(child: CircularProgressIndicator(valueColor: AlwaysStoppedAnimation(kShadowColor)));
          return buildChatList(snapshot.data.docs);
        },
      ),
    );
  }

  ListView buildChatList(snapshot) {
    User currentUser = FirebaseAuth.instance.currentUser;
    List searchResult = [];
    for (DocumentSnapshot d in snapshot) {
      if(_searchText.isEmpty){ // ?????? ?????? ?????????
        if (d.id.contains(currentUser.uid)) { // ????????? ?????? ??? ???????????? ?????? ????????? uid?????? ????????? ????????? ???????????? ??????
          searchResult.add(d);
        }
      } else{ // ?????? ?????? ?????????
        if(d.id.contains(currentUser.uid) && d['team_name'].contains(_searchText)){ // ????????? ????????? ??? ?????? ?????? ????????? ?????? ?????????(??? ??????)
          searchResult.add(d);
        }
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
    return Dismissible(
      key: Key(chat.id),
      direction: DismissDirection.endToStart,
      confirmDismiss: (DismissDirection direction) async {
        return await showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text("??????"),
              content: const Text("???????????? ?????????????????????????"),
              actions: <Widget>[
                FlatButton(
                    onPressed: () => Navigator.of(context).pop(true),
                    child: const Text("??????")
                ),
                FlatButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  child: const Text("??????"),
                ),
              ],
            );
          },
        );
      },
      onDismissed: (direction) {
        Get.find<ChatInfoController>().deleteChatRoom(chat.id);
      },
      background: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        decoration: BoxDecoration(
          color: kDismissColor,
          borderRadius: BorderRadius.circular(15),
        ),
        child: Row(
          children: [
            Spacer(),
            Icon(Icons.delete, color: kShadowColor),
          ],
        ),
      ),
      child: Container(
        color: Colors.white,
        child: StreamBuilder(
          // ????????? ????????? ????????? ?????? ?????? uid?????? ????????? ????????? ????????? ??? ????????? ??????
          stream: FirebaseFirestore.instance
              .collection('team')
              .where('uid', isEqualTo: result2)
              .snapshots(),
          builder: (context, snapshot) {
            if (!snapshot.hasData)
              return Center(child: CircularProgressIndicator(valueColor: AlwaysStoppedAnimation(kShadowColor)));
            return _buildTeamInfo(snapshot.data.docs, chat.id);
          },
        ),
      ),
    );
  }

  Widget _buildTeamInfo(snapshot, chatId) {
    // ????????? chatId????????? ?????? ?????? ???????????? Get?????? ????????????(????????? ????????????, ????????? ?????? ??????)
    Get.put(ChatInfoController());
    Get.find<ChatInfoController>().getContent(chatId);
    Get.find<ChatInfoController>().getAgo(chatId);
    var teamInfo = snapshot[0];

    // ????????? ?????? ?????? ????????? ????????? ?????????(??? ??????, ??? ???)
    return GestureDetector(
      onTap: () => Get.to(
        () => MessageScreen(
          peerUserUid: teamInfo['uid'],
          peerUserTeamName: teamInfo['team_name'],
          peerUserImgUrl: teamInfo['imageUrl'],
          peerUserMessageToken: teamInfo['messageToken'],
        ),
      ),
      child: Container(
        color: Colors.transparent, // ????????? ????????????????????? ????????? ??? ?????? ???????????? ????????? ?????????????????? ?????? ???
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
