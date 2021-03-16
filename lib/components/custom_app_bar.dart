import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../constants.dart';
import 'components.dart';

AppBar customAppBar() {
  return AppBar(
    iconTheme: IconThemeData(color: kShadowColor),
    toolbarHeight: 70,
    centerTitle: false,
    backgroundColor: Colors.white,
    elevation: 0,
    title: Text(
      "Eacre",
      style: TextStyle(
        color: kTitleTextLightColor,
        fontSize: 30.0,
        fontWeight: FontWeight.w400,
        letterSpacing: -1.2,
      ),
    ),
    actions: [
      CircleButton(
        icon: Icons.logout,
        iconSize: 30.0,
        press: () {
          FirebaseAuth.instance.signOut();
        },
      ),
    ],
  );
}