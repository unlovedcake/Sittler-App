import 'package:flutter/material.dart';

class Grid {
  static gridView(String label, String image) {
    return Container(
      decoration: BoxDecoration(
          color: Colors.blue,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.grey[500]!,
              offset: const Offset(8, 8),
              blurRadius: 10,
              spreadRadius: 1,
            )
          ]),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Image.asset(
            image,
            height: 50,
            width: 50,
          ),
          Text(label),
        ],
      ),
    );
  }
}
