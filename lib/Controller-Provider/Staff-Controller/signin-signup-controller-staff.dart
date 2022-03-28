import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:sittler_app/Model/staff-model.dart';
import 'package:sittler_app/Pages/Home-Screen/home.dart';
import 'package:sittler_app/Pages/Staff/staff-home.dart';
import 'package:sittler_app/Pages/User/user-home.dart';
import 'package:sittler_app/Route-Navigator/route-navigator.dart';
import 'package:sittler_app/Widgets/progress-dialog.dart';
import 'package:geoflutterfire/geoflutterfire.dart';
import 'package:geolocator/geolocator.dart';

class SignUpSignInControllerStaff with ChangeNotifier {
  User? user = FirebaseAuth.instance.currentUser;
  final _auth = FirebaseAuth.instance;

  String? errorMessage;

  StaffModel loggedInUser = StaffModel();

  Stream<QuerySnapshot> getUserInfo() {
    return FirebaseFirestore.instance
        .collection("table-staff")
        .where('email', isEqualTo: user!.email)
        .snapshots();
  }

  StaffModel get displayUserInfo => loggedInUser;

  signUp(
      String email, String password, StaffModel? staffModel, BuildContext context) async {
    GeoFirePoint? myLocation;

    try {
      showDialog(
          context: context,
          barrierDismissible: false,
          builder: (BuildContext context) {
            return ProgressDialog(
              message: "Authenticating, Please wait...",
            );
          });
      Position? pos =
          await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);

      myLocation = GeoFirePoint(pos.latitude, pos.longitude);

      UserCredential userCredential =
          await _auth.createUserWithEmailAndPassword(email: email, password: password);
      user = userCredential.user;
      await user!.updateDisplayName("Staff");
      await user!.reload();
      user = _auth.currentUser;

      if (user != null) {
        staffModel!.uid = user!.uid;
        staffModel.imageUrl =
            "https://cdn.pixabay.com/photo/2016/08/08/09/17/avatar-1577909_960_720.png";
        staffModel.position = {
          'latitude': myLocation.latitude,
          'longitude': myLocation.longitude
        };
        await FirebaseFirestore.instance
            .collection("table-staff")
            .doc(user!.uid)
            .set(staffModel.toMap());
        RouteNavigator.gotoPage(context, const StaffHome());
        Fluttertoast.showToast(msg: "Account created successfully :) ");
      }

      notifyListeners();
    } on FirebaseAuthException catch (error) {
      Navigator.of(context).pop();
      switch (error.code) {
        case "invalid-email":
          errorMessage = "Your email address appears to be malformed.";
          break;
        case "wrong-password":
          errorMessage = "Your password is wrong.";
          break;
        case "user-not-found":
          errorMessage = "User with this email doesn't exist.";
          break;
        case "user-disabled":
          errorMessage = "User with this email has been disabled.";
          break;
        case "too-many-requests":
          errorMessage = "Too many requests";
          break;
        case "operation-not-allowed":
          errorMessage = "Signing in with Email and Password is not enabled.";
          break;
        default:
          errorMessage = "Check Your Internet Access.";
      }
      Fluttertoast.showToast(msg: errorMessage!);
      print(error.code);
    }
  }

  signIn(String email, String password, BuildContext context) async {
    try {
      showDialog(
          context: context,
          barrierDismissible: false,
          builder: (BuildContext context) {
            return ProgressDialog(
              message: "Authenticating, Please wait...",
            );
          });

      await _auth
          .signInWithEmailAndPassword(email: email, password: password)
          .then((uid) async {
        RouteNavigator.gotoPage(context, const UserHome());
        notifyListeners();
        Fluttertoast.showToast(msg: "Login Successful");

        print("Logged In");
      });
    } on FirebaseAuthException catch (error) {
      Navigator.of(context).pop();
      switch (error.code) {
        case "invalid-email":
          errorMessage = "Your email address appears to be malformed.";

          break;
        case "wrong-password":
          errorMessage = "Your password is wrong.";
          break;
        case "user-not-found":
          errorMessage = "User with this email doesn't exist.";
          break;
        case "user-disabled":
          errorMessage = "User with this email has been disabled.";
          break;
        case "too-many-requests":
          errorMessage = "Too many requests";
          break;
        case "operation-not-allowed":
          errorMessage = "Signing in with Email and Password is not enabled.";
          break;
        default:
          errorMessage = "Check Your Internet Access.";
      }
      Fluttertoast.showToast(msg: errorMessage!);
      print(error.code);
    }
  }

  // the logout function
  Future<void> logout(BuildContext context) async {
    await FirebaseAuth.instance.signOut();

    Navigator.of(context)
        .pushReplacement(MaterialPageRoute(builder: (context) => const MyHomeScreen()));
  }
}
