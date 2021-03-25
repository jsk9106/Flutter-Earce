import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:eacre/constants.dart';
import 'package:eacre/screen/message_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class TeamListScreen extends StatefulWidget {
  @override
  _TeamListScreenState createState() => _TeamListScreenState();
}

class _TeamListScreenState extends State<TeamListScreen> {
  final TextEditingController _filter = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  String _searchText = '';
  User currentUser = FirebaseAuth.instance.currentUser;

  _TeamListScreenState(){
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
            _buildAppbar(),
            _buildBody(),
          ],
        ),
      ),
    );
  }

  Widget _buildBody() {
    return Expanded(
      child: FutureBuilder(
        future: FirebaseFirestore.instance.collection('team').where('uid', isNotEqualTo: currentUser.uid).get(),
        builder: (context, snapshot) {
          if (!snapshot.hasData)
            return Center(child: CircularProgressIndicator());
          return _buildTeamList(snapshot.data.docs);
        },
      ),
    );
  }

  _buildTeamList(List<QueryDocumentSnapshot> snapshot) {
    List searchResult = [];
    for(DocumentSnapshot d in snapshot){
      if(d['team_name'].contains(_searchText)){
        searchResult.add(d);
      }
    }
    return ListView.builder(
      itemCount: searchResult.length,
      itemBuilder: (context, index) => _buildTeamListItem(searchResult[index]),
    );
  }

  _buildTeamListItem(data) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
      margin: const EdgeInsets.only(bottom: 5),
      child: Row(
        children: [
          ClipOval(
            child: CachedNetworkImage(
              imageUrl: data['imageUrl'],
              width: 60,
              height: 60,
              placeholder: (context, url) =>
                  Center(child: CircularProgressIndicator()),
              errorWidget: (context, url, error) => Icon(Icons.error),
            ),
          ),
          SizedBox(width: 10),
          Expanded(
            child: Text(
              data['team_name'],
              style: TextStyle(fontSize: 19),
            ),
          ),
          IconButton(
            icon: Icon(
              Icons.send,
            ),
            onPressed: () => Get.to(
              () => MessageScreen(
                peerUserUid: data['uid'],
                peerUserTeamName: data['team_name'],
                peerUserImgUrl: data['imageUrl'],
                peerUserMessageToken: data['messageToken'],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAppbar() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      height: Get.size.height * 0.1,
      color: kShadowColor,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text("팀 목록", style: TextStyle(color: Colors.white, fontSize: 25)),
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
}
