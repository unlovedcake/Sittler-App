import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:sittler_app/Model/user-model.dart';
import 'package:sittler_app/Pages/Home-Screen/home.dart';
import 'package:sittler_app/Pages/Staff/staff-home.dart';
import 'package:sittler_app/Pages/User/user-home.dart';
import 'package:sittler_app/Route-Navigator/route-navigator.dart';
import 'package:sittler_app/Widgets/progress-dialog.dart';

class SignUpSignInController with ChangeNotifier {
  User? user = FirebaseAuth.instance.currentUser;
  final _auth = FirebaseAuth.instance;

  String? errorMessage;

  String? userEmail;

  UserModel loggedInUser = UserModel();

  setUserServiceEmail(String? _email) {
    userEmail = _email;
    notifyListeners();
  }

  String get getServiceEmail => userEmail!;

  Stream<QuerySnapshot> getUserServiceEmail() {
    return FirebaseFirestore.instance
        .collection("table-staff")
        .where('email', isEqualTo: userEmail)
        .snapshots();
  }

  Stream<QuerySnapshot> getUserInfo() {
    return FirebaseFirestore.instance
        .collection("table-user-client")
        .where('email', isEqualTo: user!.email)
        .snapshots();
  }

  UserModel get displayUserInfo => loggedInUser;

  signUp(
      String email, String password, UserModel? userModel, BuildContext context) async {
    try {
      showDialog(
          context: context,
          barrierDismissible: false,
          builder: (BuildContext context) {
            return ProgressDialog(
              message: "Authenticating, Please wait...",
            );
          });

      String? token = await FirebaseMessaging.instance.getToken();

      UserCredential userCredential =
          await _auth.createUserWithEmailAndPassword(email: email, password: password);
      user = userCredential.user;
      await user!.updateDisplayName("User Client");
      await user!.reload();
      user = _auth.currentUser;

      if (user != null) {
        userModel!.uid = user!.uid;
        userModel.token = token;
        userModel.imageUrl =
            "https://cdn.pixabay.com/photo/2016/08/08/09/17/avatar-1577909_960_720.png";

        await FirebaseFirestore.instance
            .collection("table-user-client")
            .doc(user!.uid)
            .set(userModel.toMap());
        RouteNavigator.gotoPage(context, const UserHome());
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
        User? usr = FirebaseAuth.instance.currentUser;
        if (usr!.displayName != "Staff") {
          RouteNavigator.gotoPage(context, const UserHome());
        } else {
          RouteNavigator.gotoPage(context, const StaffHome());
        }

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
  static Future<void> logout(BuildContext context) async {
    await FirebaseAuth.instance.signOut();

    Navigator.of(context)
        .pushReplacement(MaterialPageRoute(builder: (context) => const MyHomeScreen()));
  }
}
