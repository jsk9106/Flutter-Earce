import 'package:eacre/components/components.dart';
import 'package:eacre/constants.dart';
import 'package:eacre/controller/home_controller.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key key}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final HomeController controller = Get.put(HomeController());
  final TextEditingController _filter = TextEditingController();
  User currentUser = FirebaseAuth.instance.currentUser;
  FocusNode _focusNode = FocusNode();
  String _searchText = "";
  bool isFinish = false;
  int maxLimitInt;
  String currentUserImageUrl;

  Future<void> getMaxLimit() async{
    await FirebaseFirestore.instance
        .collection('post')
        .where('time', isGreaterThan: DateTime.now())
        .get().then((value) {
          print(value.docs.length);
       maxLimitInt = value.docs.length;
       controller.getMaxLimit(maxLimitInt);
    });
  }

  _HomeScreenState() {
    _filter.addListener(() {
      setState(() {
        _searchText = _filter.text;
      });
    });
  }

  @override
  void initState() {
    controller.limitInit();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // appBar: customAppBar(),
      body: SafeArea(
        child: Column(
          children: [
            buildTitle('Eacre'),
            buildAppBar(),
            CreatePostContainer(currentUser: currentUser),
            _buildBody()
          ],
        ),
      ),
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
        cursorColor: Colors.white,
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

  Widget _buildBody() {
    return Expanded(
      child: Obx(
        () => StreamBuilder(
          stream: FirebaseFirestore.instance
              .collection('post')
              .where('time', isGreaterThan: DateTime.now())
              .limit(controller.limit.value)
              .snapshots(),
          builder: (context, snapshot) {
            if (!snapshot.hasData)
              return Center(child: CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(kShadowColor)));
            return _buildPostList(snapshot.data.docs);
          },
        ),
      ),
    );
  }

  Widget _buildPostList(snapshot) {
    getMaxLimit();
    List postResult = [];
    for (DocumentSnapshot d in snapshot) {
      if (d['location'].contains(_searchText) |
          d['team_name'].contains(_searchText) |
          d['area'].contains(_searchText) |
          d['target'].contains(_searchText)) {
        postResult.add(d);
      }
    }
    return ListView.builder(
      physics: BouncingScrollPhysics(),
      controller: controller.scrollController,
      itemCount: postResult.length + 1,
      itemBuilder: (context, index) {
        if (index == postResult.length) {
          if (index == maxLimitInt) {
            return Container(
              alignment: Alignment.center,
              padding: const EdgeInsets.symmetric(vertical: 10),
              child: Text("마지막 매치입니다.", style: TextStyle(color: Colors.grey)),
            );
          } else if (_searchText.isNotEmpty) {
            return Container(
              alignment: Alignment.center,
              padding: const EdgeInsets.symmetric(vertical: 10),
              child: Text("'$_searchText' 검색 결과",
                  style: TextStyle(color: Colors.grey)),
            );
          }
          return Center(
            child: Padding(
              padding: const EdgeInsets.only(top: 15),
              child: CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(kShadowColor)),
            ),
          );
        }
        return BuildPostListItem(item: postResult[index]);
      },
    );
  }
}
