import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:sittler_app/Model/book-model.dart';
import 'package:uuid/uuid.dart';

class BookingProvider extends ChangeNotifier {
  String selectedDate = "";

  setSelectedDate(String date) {
    selectedDate = date;
    notifyListeners();
  }

  String get getSelectedDate => selectedDate;

  bookingAdd(BookModel bookModel) async {
    User? user = FirebaseAuth.instance.currentUser;
    String? id = Uuid().v4();

    await FirebaseFirestore.instance.collection("table-book").add({
      'id': id,
      'serviceNeed': bookModel.serviceNeed,
      'dateToBook': bookModel.dateToBook,
      'startTime': bookModel.startTime,
      'endTime': bookModel.endTime,
      'status': bookModel.appointmentStatus,
      'userModel': bookModel.userModel,
      'userStaff': bookModel.userStaff,
    }).then((result) {
      notifyListeners();
      Fluttertoast.showToast(msg: "Booking created successfully ");
      print("Success!");
    }).catchError((error) {
      print("Error!");
    });
  }
}
