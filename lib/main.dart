import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:eacre/constants.dart';
import 'package:eacre/screen/create_team_screen.dart';
import 'package:eacre/screen/nav_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'screen/login_screen.dart';
import 'screen/home_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final User currentUser = FirebaseAuth.instance.currentUser;
  String isUid = "load";

  void uidCheck() {
    FirebaseFirestore.instance
        .collection('team')
        .where('uid', isEqualTo: FirebaseAuth.instance.currentUser.uid)
        .snapshots()
        .listen((event) {
      setState(() {
        if (event.docs.length == 0) {
          isUid = 'false';
        } else {
          isUid = 'true';
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Eacre',
      theme: ThemeData(
        primaryColor: kShadowColor,
        visualDensity: VisualDensity.adaptivePlatformDensity,
        scaffoldBackgroundColor: kScaffoldColor,
      ),
      home: StreamBuilder(
        stream: _auth.authStateChanges(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return LoginScreen(); // 로그인이 되어있지 않다면 로그인 페이지로
          } else {
            uidCheck();
            if (isUid == 'load') { // 로그인이 되어있지만 아직 uid 값을 못가져왔을 때
              return Scaffold(
                body: Center(
                  child: CircularProgressIndicator(),
                ),
              );
            } else if (isUid == 'false') { // 콜렉션 팀에 uid 값이 없을 때
              return CreateTeamScreen();
            } else {
              return NavScreen(); // 콜렉션 팀에 uid 값이 있을 때
            }
          }
        },
      ),
    );
  }
}
