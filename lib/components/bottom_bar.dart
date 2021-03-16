import 'package:eacre/constants.dart';
import 'package:flutter/material.dart';

class BottomBar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      child: Container(
        height: 50,
        child: TabBar(
          indicatorColor: kPrimaryColor,
          unselectedLabelColor: kAccentDarkColor,
          tabs: [
            Tab(
              icon: Icon(
                Icons.home,
                size: 18,
                // color: kSecondaryDarkColor,
              ),
            ),
            Tab(
              icon: Icon(
                Icons.search,
                size: 18,
              ),
            ),
            Tab(
              icon: Icon(
                Icons.save_alt,
                size: 18,
              ),
            ),
            Tab(
              icon: Icon(
                Icons.list,
                size: 18,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
