import 'package:flutter/material.dart';

class RouteNavigator {
  static gotoPage(BuildContext context, Widget widget) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => widget),
    );
  }
}
