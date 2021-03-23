import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

import '../constants.dart';

class ChatInputField extends StatefulWidget {
  final String currentUserUid;
  final String peerUserUid;
  final String chatId;
  final ScrollController scrollController;

  ChatInputField({
    Key key,
    @required this.currentUserUid,
    @required this.peerUserUid,
    @required this.chatId,
    @required this.scrollController,
  }) : super(key: key);

  @override
  _ChatInputFieldState createState() => _ChatInputFieldState();
}

class _ChatInputFieldState extends State<ChatInputField> {
  final FocusNode _focusNode = FocusNode();
  final TextEditingController inputMessage = TextEditingController();
  bool isShowImageContainer = false;
  bool isShowPreviewImage = false;
  File _image;
  String imageUrl;
  int type;

  @override
  void initState() {
    _focusNode.addListener(onFocusChange);
    super.initState();
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  // 유저 갤러리에서 선택된 이미지 가져오기
  Future getImage(String kind) async {
    ImagePicker picker = ImagePicker();
    PickedFile pickedFile;

    if (kind == 'gallery') {
      // Let user select photo from gallery
      pickedFile = await picker.getImage(
        source: ImageSource.gallery,
      );
    } else {
      // Let user select photo from gallery
      pickedFile = await picker.getImage(
        source: ImageSource.camera,
      );
    }

    setState(() {
      if (pickedFile != null) {
        // _images.add(File(pickedFile.path));
        _image = File(pickedFile.path); // Use if you only need a single picture
        isShowImageContainer = false;
        isShowPreviewImage = true;
      } else {
        print('No image selected.');
      }
    });
  }

  // storage 에 이미지 업로드
  Future uploadFile() async {
    Reference storageReference = FirebaseStorage.instance.ref().child(
        'chatImage/${widget.chatId}/${DateTime.now().millisecondsSinceEpoch.toString()}');
    UploadTask uploadTask = storageReference.putFile(_image);
    await uploadTask
        .whenComplete(() => storageReference.getDownloadURL().then((fileURL) {
              setState(() {
                imageUrl = fileURL;
              });
            }));
  }

  // 메세지 firestore 에 저장
  void send(int type) {
    // type: 0 = text, 1 = image
    if (inputMessage.text.trim() != '' || type == 1) {
      var content = inputMessage.text;
      inputMessage.clear();

      var documentReference = FirebaseFirestore.instance
          .collection('chat')
          .doc(widget.chatId)
          .collection(widget.chatId)
          .doc(DateTime.now().millisecondsSinceEpoch.toString());

      FirebaseFirestore.instance.runTransaction((transaction) async {
        await transaction.set(
          documentReference,
          {
            'idFrom': widget.currentUserUid,
            'idTo': widget.peerUserUid,
            'sendTime': DateTime.now(),
            'content': content,
            'type': type,
            'imageUrl': imageUrl,
            'messageStatus': true,
          },
        );
      }).then((value) {
        setState(() {
          imageUrl = '';
          _image = null;
        });
      });

      // 채팅방에 user 정보 한 번만 업로드
      FirebaseFirestore.instance
          .collection('chat')
          .doc(widget.chatId)
          .get()
          .then((value) {
        if (value.data() == null) {
          FirebaseFirestore.instance.collection('chat').doc(widget.chatId).set({
            'user1': widget.currentUserUid,
            'user2': widget.peerUserUid,
          });
        }
      });

      widget.scrollController.animateTo(0.0,
          duration: Duration(milliseconds: 300), curve: Curves.easeOut);
    } else {
      // Fluttertoast.showToast(msg: 'Nothing to send');
      Get.snackbar("알림", "메세지가 없습니다", backgroundColor: kShadowColor.withOpacity(0.5), colorText: Colors.white);
    }
  }

  // 키보드 나올 때 이미지 컨테이너 없애기, 프리뷰 없애기, 이미지 변수 초기화
  void onFocusChange() {
    if (_focusNode.hasFocus) {
      setState(() {
        isShowImageContainer = false;
        isShowPreviewImage = false;
        _image = null;
      });
    }
  }

  // 뒤로가기 버튼 눌렀을 때 이미지 컨테이너 없애고, 프리뷰 이미지 없애기, 이미지 변수 초기화
  Future<bool> onBackPress() async {
    if (isShowImageContainer) {
      setState(() {
        isShowImageContainer = false;
      });
    } else if (isShowPreviewImage) {
      setState(() {
        isShowPreviewImage = false;
        _image = null;
      });
    } else {
      Get.back();
    }
    return Future.value(false);
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      child: Column(
        children: [
          isShowImageContainer ? _imageContainer() : Container(),
          inputField(),
          isShowPreviewImage ? previewImage() : Container(),
        ],
      ),
      onWillPop: onBackPress,
    );
  }

  Widget inputField() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            offset: Offset(0, 4),
            color: Colors.black.withOpacity(0.05),
            blurRadius: 32,
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            IconButton(
              icon: isShowImageContainer
                  ? Icon(Icons.cancel_outlined)
                  : Icon(Icons.image),
              color: kShadowColor,
              onPressed: () {
                _focusNode.unfocus();
                setState(() {
                  isShowImageContainer = !isShowImageContainer;
                  isShowPreviewImage = false;
                  _image = null;
                });
              },
            ),
            Expanded(
              child: Container(
                padding: EdgeInsets.only(right: 15),
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    color: kShadowColor.withOpacity(0.1)),
                child: Row(
                  children: [
                    IconButton(
                      icon: Icon(Icons.emoji_emotions_outlined),
                      color: Colors.black45,
                      onPressed: () {},
                    ),
                    Expanded(
                      child: TextField(
                        focusNode: _focusNode,
                        controller: inputMessage,
                        decoration: InputDecoration(
                          hintText: "메세지를 입력하세요",
                          border: InputBorder.none,
                        ),
                      ),
                    ),
                    InkWell(
                      onTap: () async {
                        setState(() {
                          type = isShowPreviewImage ? 1 : 0;
                          isShowPreviewImage = false;
                        });
                        if (type == 1) await uploadFile();
                        send(type);
                      },
                      child: Icon(Icons.send),
                    )
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _imageContainer() {
    return Container(
      height: Get.size.height * 0.3,
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
            topRight: Radius.circular(20), topLeft: Radius.circular(20)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          imagePickButton(Icons.image, "갤러리", () => getImage('gallery')),
          imagePickButton(Icons.camera, "카메라", () => getImage('camera')),
        ],
      ),
    );
  }

  Widget imagePickButton(IconData icon, String text, Function press) {
    return GestureDetector(
      onTap: press,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: kShadowColor, size: 80),
          Text(text, style: TextStyle(color: Colors.black54)),
        ],
      ),
    );
  }

  Widget previewImage() {
    return Dismissible(
      key: Key(_image.toString()),
      direction: DismissDirection.endToStart,
      background: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        decoration: BoxDecoration(
          color: kDismissColor,
          borderRadius: BorderRadius.circular(15)
        ),
        child: Row(
          children: [
            Spacer(),
            Icon(Icons.delete, color: kShadowColor, size: 40),
          ],
        ),
      ),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 80),
        child: AspectRatio(
          aspectRatio: 1.0,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.file(_image, fit: BoxFit.cover),
          ),
        ),
      ),
      onDismissed: (direction) {
        setState(() {
          isShowPreviewImage = false;
          _image = null;
        });
      },
    );
  }
}
