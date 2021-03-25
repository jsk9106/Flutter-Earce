import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:eacre/components/match_dialog.dart';
import 'package:eacre/controller/ago_controller.dart';
import 'package:eacre/model/match_do_model.dart';
import 'package:eacre/screen/message_screen.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'components.dart';

class BuildPostListItem extends StatefulWidget {
  final QueryDocumentSnapshot item;
  final bool isMyMatch;

  const BuildPostListItem({
    Key key,
    @required this.item,
    this.isMyMatch = false,
  }) : super(key: key);

  @override
  _BuildPostListItemState createState() => _BuildPostListItemState();
}

class _BuildPostListItemState extends State<BuildPostListItem> {
  String postUserTeamName;
  String postUserImageUrl;
  String postUserMessageToken;

  Future<void> getUserInfo() async {
    await FirebaseFirestore.instance
        .collection('team')
        .where('uid', isEqualTo: widget.item['uid'])
        .get()
        .then((value) {
      if (value.docs.length == 0) {
        return;
      } else {
        if (mounted) // 이상한 에러 뜨는거 막는거
          postUserTeamName = value.docs[0]['team_name'];
          postUserImageUrl = value.docs[0]['imageUrl'];
          postUserMessageToken = value.docs[0]['messageToken'];
      }
    }).catchError((error) => "error: $error");
  }

  @override
  void initState() {
    getUserInfo();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Opacity(
          opacity: widget.item['isMatched'] ? 0.4 : 1,
          child: Container(
            color: Colors.white,
            margin: EdgeInsets.symmetric(vertical: 5),
            padding: EdgeInsets.symmetric(horizontal: 10, vertical: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    buildTeamImg(
                        postUserImageUrl == null
                            ? widget.item['imageUrl']
                            : postUserImageUrl,
                        45),
                    SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          postUserTeamName == null
                              ? widget.item['team_name']
                              : postUserTeamName,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 25,
                          ),
                        ),
                        Text(
                          convertToAgo(widget.item['createTime'].toDate()),
                          style: TextStyle(
                              color: Colors.black.withOpacity(0.5),
                              fontSize: 12),
                        )
                      ],
                    ),
                    Spacer(),
                    Container(
                      child: Text(
                        "${DateFormat("yyyy-MM-dd").format(widget.item['time'].toDate())}\n${DateFormat("HH:mm").format(widget.item['time'].toDate())}\n",
                        style: TextStyle(fontSize: 15),
                        textAlign: TextAlign.right,
                      ),
                    ),
                  ],
                ),
                Divider(height: 30, thickness: 0.5),
                SizedBox(height: 5),
                Row(
                  children: [
                    Text("경기 장소: ",
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 15)),
                    Text(widget.item['location']),
                  ],
                ),
                Row(
                  children: [
                    Text("경기 대상: ",
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 15)),
                    Text(widget.item['target']),
                    Spacer(),
                    widget.isMyMatch
                        ? Row(
                            children: [
                              IconButton(
                                icon: Icon(Icons.done),
                                onPressed: () async {
                                  // await matchController.manageMatch(context, item.id, MatchDo.completed);
                                  if (widget.item['isMatched'])
                                    return;
                                  else
                                    Get.dialog(matchDialog(
                                        widget.item.id, MatchDo.completed));
                                },
                              ),
                              IconButton(
                                icon: Icon(Icons.delete),
                                onPressed: () async {
                                  Get.dialog(matchDialog(
                                      widget.item.id, MatchDo.delete));
                                },
                              )
                            ],
                          )
                        : IconButton(
                            icon: Icon(Icons.send),
                            onPressed: () {
                              Get.to(
                                () => MessageScreen(
                                  peerUserUid: widget.item['uid'],
                                  peerUserTeamName: widget.item['team_name'],
                                  peerUserImgUrl: widget.item['imageUrl'],
                                  peerUserMessageToken: postUserMessageToken,
                                ),
                              );
                            },
                          ),
                  ],
                ),
              ],
            ),
          ),
        ),
        widget.item['isMatched']
            ? Positioned(
                top: 70,
                left: 0,
                right: 0,
                child:
                    Center(child: Text("매치완료", style: TextStyle(fontSize: 40))),
              )
            : Container(),
      ],
    );
  }
}
