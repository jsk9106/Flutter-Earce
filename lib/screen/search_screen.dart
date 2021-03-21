import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:eacre/components/components.dart';
import 'package:eacre/constants.dart';
import 'package:flutter/material.dart';

class SearchScreen extends StatefulWidget {
  @override
  _SearchScreenState createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final ScrollController scrollController = ScrollController();
  final TextEditingController _filter = TextEditingController();
  FocusNode focusNode = FocusNode();
  String _searchText = "";

  _SearchScreenState() {
    _filter.addListener(() {
      setState(() {
        _searchText = _filter.text;
      });
    });
  }

  @override
  void initState() {
    scrollController.addListener(() {
      print('position.pixels = ${scrollController.position.pixels}');
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        controller: scrollController,
        child: Column(
          children: [
            customSearchBar(),
            _buildBody(),
          ],
        ),
      ),
    );
  }

  Container customSearchBar() {
    return Container(
      color: Colors.white,
      padding: EdgeInsets.symmetric(horizontal: 5, vertical: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            flex: 6,
            child: TextField(
              focusNode: focusNode,
              style: TextStyle(
                fontSize: 15,
              ),
              // autofocus: true,
              controller: _filter,
              decoration: InputDecoration(
                filled: true,
                fillColor: Colors.grey[200],
                prefixIcon: Icon(Icons.search, color: kShadowColor, size: 20),
                suffixIcon: focusNode.hasFocus
                    ? IconButton(
                        icon: Icon(Icons.cancel_outlined, color: kShadowColor),
                        onPressed: () {
                          setState(() {
                            _filter.clear();
                            _searchText = "";
                          });
                        })
                    : Container(),
                hintText: '매치 검색',
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.transparent),
                  borderRadius: BorderRadius.all(Radius.circular(10)),
                ),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.transparent),
                  borderRadius: BorderRadius.all(Radius.circular(10)),
                ),
                border: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.transparent),
                  borderRadius: BorderRadius.all(Radius.circular(10)),
                ),
              ),
            ),
          ),
          focusNode.hasFocus
              ? FlatButton(
                  child: Text('취소'),
                  onPressed: () {
                    setState(() {
                      _filter.clear();
                      _searchText = "";
                      focusNode.unfocus();
                    });
                  },
                )
              : Expanded(
                  flex: 0,
                  child: Container(),
                ),
        ],
      ),
    );
  }

  Widget _buildBody() {
    return StreamBuilder(
      stream: FirebaseFirestore.instance
          .collection('post')
          .where('time', isGreaterThan: DateTime.now())
          .orderBy('time')
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return LinearProgressIndicator();
        return _buildList(context, snapshot.data.docs);
      },
    );
  }

  Widget _buildList(BuildContext context, snapshot) {
    List<DocumentSnapshot> searchResult = [];
    if (_searchText.isNotEmpty) {
      for (DocumentSnapshot d in snapshot) {
        if (d['location'].contains(_searchText) |
            d['team_name'].contains(_searchText) |
            d['target'].contains(_searchText)) {
          searchResult.add(d);
        }
      }
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: BouncingScrollPhysics(),
      itemCount: searchResult.length,
      itemBuilder: (context, index) {
        final QueryDocumentSnapshot item = searchResult[index];
        return BuildPostListItem(item: item);
      },
    );
  }
}
