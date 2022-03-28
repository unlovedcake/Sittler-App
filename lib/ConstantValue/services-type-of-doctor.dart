import 'package:flutter/material.dart';

class ServicesTypesOfDoctor {
  static List<Map<String, dynamic>> gender = [
    {
      'value': "Female",
      'label': "Female",
      'icon': Icon(Icons.stop),
    },
    {
      'value': "Male",
      'label': "Male",
      'icon': Icon(Icons.adjust),
      'textStyle': TextStyle(color: Colors.orange),
    },
  ];
}
