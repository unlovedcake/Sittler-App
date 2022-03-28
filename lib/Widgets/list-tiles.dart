import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class ListTiles {
  static Widget listTile(
      {required String? label, required IconButton? icon, required Function() onTap}) {
    return ListTile(title: Text(label!), leading: icon!, onTap: onTap);
  }
}
