import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:eacre/components/chat_input_field.dart';
import 'package:eacre/components/message_status_dot.dart';
import 'package:eacre/components/text_message.dart';
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
      padding: const EdgeInsets.only(top: 30),
      child: Row(
        mainAxisAlignment:
            isSender ? MainAxisAlignment.end : MainAxisAlignment.start,
        children: [
          if (!isSender) ...[
            ClipOval(
              child: CachedNetworkImage(
                imageUrl: widget.peerUserImgUrl,
                width: 40,
                height: 40,
                placeholder: (context, url) =>
                    Center(child: CircularProgressIndicator()),
                errorWidget: (context, url, error) => Icon(Icons.error),
              ),
            ),
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
      toolbarHeight: 70,
      leading: IconButton(
        icon: Icon(Icons.arrow_back_ios),
        color: Colors.white,
        onPressed: () => Get.back(),
      ),
      title: Row(
        children: [
          ClipOval(
            child: CachedNetworkImage(
              imageUrl: widget.peerUserImgUrl,
              width: 40,
              height: 40,
              placeholder: (context, url) =>
                  Center(child: CircularProgressIndicator()),
              errorWidget: (context, url, error) => Icon(Icons.error),
            ),
          ),
          SizedBox(width: 15),
          Text(
            widget.peerUserTeamName,
            style: TextStyle(fontWeight: FontWeight.w400),
          ),
        ],
      ),
    );
  }
}
