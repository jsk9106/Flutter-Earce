import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:eacre/constants.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:eacre/components/build_post_list_item.dart';
import 'package:get/get.dart';

class MatchScreen extends StatefulWidget {
  @override
  _MatchScreenState createState() => _MatchScreenState();
}

class _MatchScreenState extends State<MatchScreen> {
  final TextEditingController _filter = TextEditingController();
  FocusNode _focusNode = FocusNode();
  String _searchText = "";
  User currentUser = FirebaseAuth.instance.currentUser;

  _MatchScreenState() {
    _filter.addListener(() {
      setState(() {
        _searchText = _filter.text;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        children: [
          _buildTitle(),
          // Divider(thickness: 2, height: 2, color: Colors.white),
          buildAppBar(),
          buildBody(),
        ],
      ),
    );
  }

  Expanded buildBody() {
    return Expanded(
      child: StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection('post')
            .where('uid', isEqualTo: currentUser.uid)
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData)
            return Center(child: CircularProgressIndicator());
          return buildList(snapshot.data.docs);
        },
      ),
    );
  }

  ListView buildList(snapshot) {
    List searchResult = [];
    for (DocumentSnapshot d in snapshot) {
      if (d["location"].contains(_searchText) |
          d['target'].contains(_searchText) |
          d['time'].toDate().toString().contains(_searchText)) {
        print(d.id);
        searchResult.add(d);
      }
    }
    return ListView.builder(
      physics: BouncingScrollPhysics(),
      itemCount: searchResult.length,
      itemBuilder: (context, index) {
        return BuildPostListItem(item: searchResult[index], isMyMatch: true);
      },
    );
  }

  Container buildAppBar() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      height: Get.size.height * 0.1,
      width: double.infinity,
      color: kShadowColor,
      child: searchBar(),
    );
  }

  Widget searchBar() {
    return Container(
      alignment: Alignment.center,
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
    );
  }

  _buildTitle() {
    return Container(
      height: Get.size.height * 0.08,
      width: double.infinity,
      color: kShadowColor,
      alignment: Alignment.center,
      child: Text(
        "마이 매치",
        style: TextStyle(
          fontSize: 25,
          color: Colors.white,
        ),
      ),
    );
  }
}
