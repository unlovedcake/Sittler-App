import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';

import 'package:provider/src/provider.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:sittler_app/Controller-Provider/Theme-Controller/theme-controler-provider.dart';
import 'package:sittler_app/Pages/User/book-an-appointment-list.dart';
import 'package:sittler_app/Route-Navigator/route-navigator.dart';
import 'package:sittler_app/Widgets/elevated-button.dart';
import 'package:sittler_app/Widgets/gridview.dart';
import 'package:sittler_app/Widgets/sizebox.dart';
import 'package:sittler_app/Widgets/staff-drawer.dart';

class StaffHome extends StatefulWidget {
  const StaffHome({Key? key}) : super(key: key);

  @override
  _StaffHomeState createState() => _StaffHomeState();
}

class _StaffHomeState extends State<StaffHome> {
  User? user;

  @override
  void initState() {
    super.initState();
    user = FirebaseAuth.instance.currentUser;
    //context.read<SignUpSignInController>().getUserInfo();
  }

  @override
  Widget build(BuildContext context) {
    TextTheme _textTheme = Theme.of(context).textTheme;
    bool isDark = Theme.of(context).brightness == Brightness.dark;

    GlobalKey<ScaffoldState> _key = GlobalKey<ScaffoldState>();
    DateTime backpress = DateTime.now();

    return WillPopScope(
      onWillPop: () async {
        final timegap = DateTime.now().difference(backpress);
        final cantExit = timegap >= Duration(seconds: 2);
        backpress = DateTime.now();
        if (cantExit) {
          Fluttertoast.showToast(msg: 'Press Back button again to Exit');

          return false;
        } else {
          SystemNavigator.pop();

          return true;
        }
      },
      child: Scaffold(
        key: _key,
        appBar: AppBar(
          //automaticallyImplyLeading: false, //remove arrow back icon
          centerTitle: true,
          title: const Text("Staff Home"),

          actions: [
            Switch(
                value: isDark,
                onChanged: (newValue) {
                  context.read<ThemeManager>().toggleTheme(newValue);
                })
          ],
        ),
        drawer: const StaffDrawer(),
        body: StreamBuilder(
          stream: FirebaseFirestore.instance
              .collection("table-staff")
              .where('email', isEqualTo: user!.email)
              .where('active', isEqualTo: true)
              .snapshots(),
          builder: (BuildContext context, AsyncSnapshot<QuerySnapshot?> snapshot) {
            //final currentUser = snapshot.data?.docs;
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                  child: CircularProgressIndicator(
                color: Colors.orange,
              ));
            }
            if (snapshot.hasError) {
              return const Text('Error');
            } else if (snapshot.data!.docs.isEmpty) {
              return const Center(
                  child: Text(
                      "The admin will confirm your request in order to activate your account."));
            } else {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    addVerticalSpace(10),
                    Text(
                      'Hi, Welcome to Baby Sittler App ',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                    // addVerticalSpace(50),
                    // ElevatedButtonStyle.elevatedButton("List of Sittlers", onPressed: () {
                    //   RouteNavigator.gotoPage(context, BookAnAppointment());
                    // }),
                  ],
                ),
              );
            }
          },
        ),
      ),
    );
  }
}
