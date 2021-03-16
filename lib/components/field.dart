import 'package:eacre/constants.dart';
import 'package:flutter/material.dart';

class Field extends StatelessWidget {
  final controller;
  final String labelText;
  final String hintText;

  const Field({
    Key key,
    @required this.controller,
    @required this.labelText,
    @required this.hintText,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        labelText: labelText,
        labelStyle: TextStyle(color: kBodyTextColorDark),
        hintText: hintText,
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(10.0)),
          borderSide: BorderSide(color: Colors.grey),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(10.0)),
          borderSide: BorderSide(color: Colors.grey),
        ),
      ),
    );
  }
}
