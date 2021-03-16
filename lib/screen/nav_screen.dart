import 'package:eacre/components/custom_tab_bar.dart';
import 'package:eacre/screen/home_screen.dart';
import 'package:eacre/screen/match_screen.dart';
import 'package:eacre/screen/chat_screen.dart';
import 'package:eacre/screen/search_screen.dart';
import 'package:flutter/material.dart';

class NavScreen extends StatefulWidget {
  const NavScreen({Key key}) : super(key: key);

  @override
  _NavScreenState createState() => _NavScreenState();
}

class _NavScreenState extends State<NavScreen> {
  final List<Widget> _screens = [
    HomeScreen(),
    ChatScreen(),
    SearchScreen(),
    MatchScreen(),
  ];
  final List<IconData> _icons = [
    Icons.home,
    Icons.send,
    Icons.search,
    Icons.sports_soccer,
  ];
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: _icons.length,
      child: Scaffold(
        body: _screens[_selectedIndex],
        bottomNavigationBar: CustomTabBar(
          icons: _icons,
          selectedIndex: _selectedIndex,
          onTap: (index) => setState(() => _selectedIndex = index),
        ),
      ),
    );
  }
}
