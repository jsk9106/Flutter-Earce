import 'package:eacre/constants.dart';
import 'package:flutter/material.dart';

class CircleButton extends StatelessWidget {
  final IconData icon;
  final double iconSize;
  final Function press;

  const CircleButton({
    Key key,
    @required this.icon,
    @required this.iconSize,
    @required this.press,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.all(6.0),
      decoration: BoxDecoration(
        color: kShadowColor,
        shape: BoxShape.circle,
      ),
      child: IconButton(
        icon: Icon(icon),
        iconSize: iconSize,
        color: kPrimaryIconLightColor,
        onPressed: press,
      ),
    );
  }
}
