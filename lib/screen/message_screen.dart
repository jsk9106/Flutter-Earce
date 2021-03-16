import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:eacre/components/audio_message.dart';
import 'package:eacre/components/chat_input_field.dart';
import 'package:eacre/components/message_status_dot.dart';
import 'package:eacre/components/text_message.dart';
import 'package:eacre/components/video_message.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class MessageScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: messageAppBar(),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder(
                stream: FirebaseFirestore.instance
                    .collection('message')
                    .orderBy('sendTime')
                    .snapshots(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData)
                    return Center(child: CircularProgressIndicator());
                  return buildMessageList(context, snapshot.data.docs);
                }),
          ),
          chatInputField(),
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

    Widget messageCheck() {
      if (message['messageType']['text']) {
        return textMessage(message);
      } else if (message['messageType']['audio']) {
        return audioMessage(context, message);
      } else if (message['messageType']['video']) {
        return videoMessage(context, message);
      } else {
        return SizedBox();
      }
    }
    return Padding(
      padding: const EdgeInsets.only(top: 30),
      child: Row(
        mainAxisAlignment: message['isSender']
            ? MainAxisAlignment.end
            : MainAxisAlignment.start,
        children: [
          if (!message['isSender']) ...[
            CircleAvatar(radius: 12),
            SizedBox(width: 10),
          ],
          if (message['isSender']) messageStatusDot(message['messageStatus']),
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
          CircleAvatar(),
          SizedBox(width: 15),
          Text("팀 명", style: TextStyle(fontWeight: FontWeight.w400)),
        ],
      ),
    );
  }
}
