import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:eacre/components/chat_input_field.dart';
import 'package:eacre/components/components.dart';
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

  @override
  void initState() {
    createChatId();
    controller.initLimit();
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
                    return Center(child: CircularProgressIndicator());
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
          ),
        ],
      ),
    );
  }

  Widget buildMessageList(context, snapshot) {
    getMaxLimit();
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
    // print(sendTimeResult);
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
          return buildMessageListItem(
              context, snapshot[index], sendTimeResult[index]);
        },
      ),
    );
  }

  Widget buildMessageListItem(context, message, sendTimeResultItem) {
    if (currentUserUid == message['idFrom']) {
      isSender = true;
    } else {
      isSender = false;
    }

    String sendTime;
    if (sendTimeResultItem.contains("AM")) {
      sendTime = sendTimeResultItem.replaceAll("AM", "오전");
    } else {
      sendTime = sendTimeResultItem.replaceAll("PM", "오후");
    }

    Widget messageCheck() {
      if (message['type'] == 0) {
        return textMessage(message, isSender);
      }
      // else if (message['messageType']['audio']) {
      //   return audioMessage(context, message);
      // } else if (message['messageType']['video']) {
      //   return videoMessage(context, message);
      // } else {
      //   return SizedBox();
      // }
      else
        return SizedBox();
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Row(
        mainAxisAlignment:
            isSender ? MainAxisAlignment.end : MainAxisAlignment.start,
        children: [
          if (!isSender) ...[
            buildTeamImg(widget.peerUserImgUrl, 40),
            SizedBox(width: 10),
          ],
          Container(
            height: 35,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                if (isSender) messageStatusDot(message['messageStatus']),
                if (isSender)
                  Container(
                    margin: const EdgeInsets.only(right: 3),
                    child: Text(
                      sendTime,
                      style: TextStyle(color: Colors.black54, fontSize: 10),
                    ),
                  ),
              ],
            ),
          ),
          messageCheck(),
          if (!isSender)
            Container(
              height: 35,
              alignment: Alignment.bottomCenter,
              margin: const EdgeInsets.only(left: 3),
              child: Text(
                sendTime,
                style: TextStyle(color: Colors.black54, fontSize: 10),
              ),
            ),
        ],
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
