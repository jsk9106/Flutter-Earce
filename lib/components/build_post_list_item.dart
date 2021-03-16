import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:eacre/screen/message_screen.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class BuildPostListItem extends StatelessWidget {
  const BuildPostListItem({
    Key key,
    @required this.item,
  }) : super(key: key);

  final QueryDocumentSnapshot item;

  String convertToAgo(DateTime input) {
    Duration diff = DateTime.now().difference(input);

    if (diff.inDays >= 1) {
      return '${diff.inDays}일 전';
    } else if (diff.inHours >= 1) {
      return '${diff.inHours}시간 전';
    } else if (diff.inMinutes >= 1) {
      return '${diff.inMinutes}분 전';
    } else if (diff.inSeconds >= 1) {
      return '${diff.inSeconds}초 전';
    } else {
      return '방금전';
    }
    // return diff.inDays.toString();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      margin: EdgeInsets.symmetric(vertical: 5),
      padding: EdgeInsets.symmetric(horizontal: 10, vertical: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              ClipOval(
                child: CachedNetworkImage(
                  width: 45,
                  height: 45,
                  imageUrl: item['imageUrl'],
                  placeholder: (context, url) => Center(child: CircularProgressIndicator()),
                  errorWidget: (context, url, error) => Icon(Icons.error),
                ),
              ),
              SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item['team_name'],
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 25,
                    ),
                  ),
                  Text(
                    convertToAgo(item['createTime'].toDate()),
                    style: TextStyle(
                        color: Colors.black.withOpacity(0.5), fontSize: 12),
                  )
                ],
              ),
              Spacer(),
              Container(
                child: Text(
                  "${DateFormat("yyyy-MM-dd").format(item['time'].toDate())}\n${DateFormat("HH:mm").format(item['time'].toDate())}\n",
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
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
              Text(item['location']),
            ],
          ),
          Row(
            children: [
              Text("경기 대상: ",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
              Text(item['target']),
              Spacer(),
              IconButton(
                  icon: Icon(Icons.send),
                  onPressed: () {
                    Get.to(MessageScreen());
                  }),
            ],
          ),
        ],
      ),
    );
  }
}
