import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:eacre/components/chat_input_field.dart';
import 'package:eacre/components/components.dart';
import 'package:eacre/components/image_message.dart';
import 'package:eacre/components/message_status_dot.dart';
import 'package:eacre/components/text_message.dart';
import 'package:eacre/constants.dart';
import 'package:eacre/controller/message_controller.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class MessageScreen extends StatefulWidget {
  final String peerUserUid;
  final String peerUserTeamName;
  final String peerUserImgUrl;

  const MessageScreen({
    Key key,
    @required this.peerUserUid,
    @required this.peerUserTeamName,
    @required this.peerUserImgUrl,
  }) : super(key: key);

  @override
  _MessageScreenState createState() => _MessageScreenState();
}

class _MessageScreenState extends State<MessageScreen> {
  final MessageController controller = Get.put(MessageController());
  String currentUserUid = FirebaseAuth.instance.currentUser.uid;
  String chatId;
  bool isSender;
  int maxLimit;
  String currentUserTeamName;

  void createChatId() {
    if (currentUserUid.hashCode <= widget.peerUserUid.hashCode) {
      chatId = '$currentUserUid-${widget.peerUserUid}';
    } else {
      chatId = '${widget.peerUserUid}-$currentUserUid';
    }
  }

  // void getMaxLimit() {
  //   FirebaseFirestore.instance
  //       .collection('chat')
  //       .doc(chatId)
  //       .collection(chatId)
  //       .snapshots()
  //       .listen((event) {
  //       maxLimit = event.docs.length;
  //     print(maxLimit);
  //     controller.getMaxLimit(event.docs.length);
  //   });
  // }

  // 메세지의 총 갯수 가져오기
  Future<void> getMaxLimit() async {
    await FirebaseFirestore.instance
        .collection('chat')
        .doc(chatId)
        .collection(chatId)
        .get()
        .then((value) {
      print(value.docs.length);
      maxLimit = value.docs.length;
      controller.getMaxLimit(maxLimit);
    });
  }

  // 현재 유저의 팀 이름 가져오기
  Future<void> getCurrentUserTeamName() async{
    await FirebaseFirestore.instance.collection('team').where('uid', isEqualTo: currentUserUid).get().then((value) {
      print(value.docs[0]['team_name']);
      setState(() {
        currentUserTeamName = value.docs[0]['team_name'];
      });
    }).catchError((error) => print("error: $error"));
  }

  @override
  void initState() {
    createChatId();
    controller.initLimit();
    getCurrentUserTeamName();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: messageAppBar(),
      body: Column(
        children: [
          Obx(
            () => Expanded(
              child: StreamBuilder(
                stream: FirebaseFirestore.instance
                    .collection('chat')
                    .doc(chatId)
                    .collection(chatId)
                    .orderBy('sendTime', descending: true)
                    .limit(controller.limit.value)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData)
                    return Center(
                        child: CircularProgressIndicator(
                            valueColor:
                                AlwaysStoppedAnimation<Color>(kShadowColor)));
                  return buildMessageList(context, snapshot.data.docs);
                },
              ),
            ),
          ),
          ChatInputField(
            currentUserUid: currentUserUid,
            peerUserUid: widget.peerUserUid,
            chatId: chatId,
            scrollController: controller.scrollController,
            peerUserTeamName: widget.peerUserTeamName,
            currentUserTeamName: currentUserTeamName,
          ),
        ],
      ),
    );
  }

  Widget buildMessageList(context, snapshot) {
    getMaxLimit(); // 메세지 총 갯수 가져오기
    // 보낸시간 가져오기
    List sendTimeResult = [];
    String time;
    for (DocumentSnapshot d in snapshot) {
      time = DateFormat("a h:mm").format(d['sendTime'].toDate());
      if (sendTimeResult.contains(time)) {
        sendTimeResult.insert(sendTimeResult.length - 1, "");
      } else {
        sendTimeResult.add(time);
      }
    }

    // 보낸 날짜 가져오기
    List dateResult = [];
    String date;
    for (DocumentSnapshot d in snapshot) {
      date = DateFormat('yyyy년 M월 dd일 EEEE').format(d['sendTime'].toDate());
      if (dateResult.contains(date)) {
        dateResult.insert(dateResult.length - 1, '');
      } else {
        dateResult.add(date);
      }
    }

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 15),
      child: ListView.builder(
        controller: controller.scrollController,
        reverse: true,
        physics: BouncingScrollPhysics(),
        itemCount: snapshot.length + 1,
        itemBuilder: (context, index) {
          if (index == snapshot.length) {
            if (index == maxLimit || index < 20) return Container();
            return Center(
                child: Text("불러오는 중..", style: TextStyle(color: Colors.grey)));
          }
          return buildMessageListItem(context, snapshot[index],
              sendTimeResult[index], dateResult[index]);
        },
      ),
    );
  }

  Widget buildMessageListItem(
      context, message, sendTimeResultItem, dateResultItem) {
    // 보낸 사람 체크
    if (currentUserUid == message['idFrom']) {
      isSender = true;
    } else {
      isSender = false;
    }

    // 보낸 시간 리플레이스
    String sendTime;
    if (sendTimeResultItem.contains("AM")) {
      sendTime = sendTimeResultItem.replaceAll("AM", "오전");
    } else {
      sendTime = sendTimeResultItem.replaceAll("PM", "오후");
    }

    // 보낸 날짜 리플레이스
    String sendDate;
    if (dateResultItem.contains("Monday")) {
      sendDate = dateResultItem.replaceAll("Monday", "월요일");
    } else if (dateResultItem.contains("Tuesday")) {
      sendDate = dateResultItem.replaceAll("Tuesday", "화요일");
    } else if (dateResultItem.contains("Wednesday")) {
      sendDate = dateResultItem.replaceAll("Wednesday", "수요일");
    } else if (dateResultItem.contains("Thursday")) {
      sendDate = dateResultItem.replaceAll("Thursday", "목요일");
    } else if (dateResultItem.contains("Friday")) {
      sendDate = dateResultItem.replaceAll("Friday", "금요일");
    } else if (dateResultItem.contains("Saturday")) {
      sendDate = dateResultItem.replaceAll("Saturday", "토요일");
    } else if (dateResultItem.contains("Sunday")) {
      sendDate = dateResultItem.replaceAll("Sunday", "일요일");
    }

    // 메세지 타입 체크
    Widget messageCheck() {
      if (message['type'] == 0) {
        return textMessage(message, isSender);
      } else if (message['type'] == 1) {
        return imageMessage(message);
      } else {
        return SizedBox();
      }
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        children: [
          if (dateResultItem != '') _buildSendDate(sendDate),
          if (dateResultItem != '') SizedBox(height: 20),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisAlignment:
                isSender ? MainAxisAlignment.end : MainAxisAlignment.start,
            children: [
              if (!isSender) ...[
                buildTeamImg(widget.peerUserImgUrl, 40),
                SizedBox(width: 10),
              ],
              if (isSender)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    messageStatusDot(message['messageStatus']),
                    _buildSendTime(sendTime),
                  ],
                ),
              messageCheck(),
              if (!isSender) _buildSendTime(sendTime),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSendDate(String sendDate) {
    return Container(
      alignment: Alignment.center,
      width: Get.size.width * 0.4,
      height: 30,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(40),
        color: kSecondaryDarkColor,
      ),
      child: Text(
        sendDate,
        style: TextStyle(
          color: kShadowColor,
          fontSize: 12,
        ),
      ),
    );
  }

  Container _buildSendTime(String sendTime) {
    return Container(
      margin: isSender ? EdgeInsets.only(right: 3) : EdgeInsets.only(left: 3),
      child: Text(
        sendTime,
        style: TextStyle(color: Colors.black54, fontSize: 10),
      ),
    );
  }

  AppBar messageAppBar() {
    return AppBar(
      elevation: 0,
      backgroundColor: kScaffoldColor,
      toolbarHeight: Get.size.height * 0.1,
      leading: IconButton(
        icon: Icon(Icons.arrow_back_ios),
        color: Colors.black,
        onPressed: () => Get.back(),
      ),
      title: Text(
        widget.peerUserTeamName,
        style: TextStyle(fontWeight: FontWeight.w400, color: Colors.black),
      ),
    );
  }
}
