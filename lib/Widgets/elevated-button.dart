import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class ElevatedButtonStyle {
  static Widget elevatedButton(String label, {required void Function()? onPressed}) {
    return ElevatedButton(child: Text(label), onPressed: onPressed);
  }
}
