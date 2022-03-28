import 'package:flutter/material.dart';

class ServicesTypesOfDoctor {
  static List<Map<String, dynamic>> items = [
    {
      'value': "Dental Care",
      'label': "Dental Care",
      'icon': Icon(Icons.stop),
    },
    {
      'value': "Health Care",
      'label': "Health Care",
      'icon': Icon(Icons.fiber_manual_record),
      'textStyle': TextStyle(color: Colors.red),
    },
    {
      'value': "Diagnostic Care",
      'label': "Diagnostic Care",
      //'enable': false,
      'icon': Icon(Icons.grade),
      'textStyle': TextStyle(color: Colors.blue),
    },
    {
      'value': "Preventative Care",
      'label': "Preventative Care",
      //'enable': false,
      'icon': Icon(Icons.adjust),
      'textStyle': TextStyle(color: Colors.orange),
    },
    {
      'value': "Pharmaceutical Care",
      'label': "Pharmaceutical Care",
      //'enable': false,
      'icon': Icon(Icons.ac_unit_outlined),
      'textStyle': TextStyle(color: Colors.green),
    },
    {
      'value': "Prenatal Care",
      'label': "Prenatal Care",
      //'enable': false,
      'icon': Icon(Icons.ac_unit_outlined),
      'textStyle': TextStyle(color: Colors.green),
    },
  ];

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
