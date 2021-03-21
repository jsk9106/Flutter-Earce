import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:eacre/components/chat_input_field.dart';
import 'package:eacre/components/components.dart';
import 'package:eacre/components/message_status_dot.dart';
import 'package:eacre/components/text_message.dart';
import 'package:eacre/constants.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

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
  String currentUserUid = FirebaseAuth.instance.currentUser.uid;
  String chatId;
  bool isSender;

  void createChatId() {
    if (currentUserUid.hashCode <= widget.peerUserUid.hashCode) {
      chatId = '$currentUserUid-${widget.peerUserUid}';
    } else {
      chatId = '${widget.peerUserUid}-$currentUserUid';
    }
  }

  @override
  void initState() {
    createChatId();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: messageAppBar(),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder(
              stream: FirebaseFirestore.instance
                  .collection('chat')
                  .doc(chatId)
                  .collection(chatId)
                  .orderBy('sendTime', descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData)
                  return Center(child: CircularProgressIndicator());
                return buildMessageList(context, snapshot.data.docs);
              },
            ),
          ),
          ChatInputField(
            currentUserUid: currentUserUid,
            peerUserUid: widget.peerUserUid,
            chatId: chatId,
          ),
        ],
      ),
    );
  }

  Widget buildMessageList(context, snapshot) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 15),
      child: ListView.builder(
        reverse: true,
        physics: BouncingScrollPhysics(),
        itemCount: snapshot.length,
        itemBuilder: (context, index) {
          return buildMessageListItem(context, snapshot[index]);
        },
      ),
    );
  }

  Widget buildMessageListItem(context, message) {
    if (currentUserUid == message['idFrom']) {
      isSender = true;
    } else {
      isSender = false;
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
          if (isSender) messageStatusDot(message['messageStatus']),
          messageCheck(),
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
