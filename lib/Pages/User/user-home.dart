import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';

import 'package:provider/src/provider.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:sittler_app/Controller-Provider/Theme-Controller/theme-controler-provider.dart';
import 'package:sittler_app/Route-Navigator/route-navigator.dart';
import 'package:sittler_app/Widgets/elevated-button.dart';
import 'package:sittler_app/Widgets/gridview.dart';
import 'package:sittler_app/Widgets/sizebox.dart';
import 'package:sittler_app/Widgets/user-drawer.dart';

import 'book-an-appointment-list.dart';

class UserHome extends StatefulWidget {
  const UserHome();

  @override
  _UserHomeState createState() => _UserHomeState();
}

class _UserHomeState extends State<UserHome> {
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
          title: const Text("Home"),

          actions: [
            Switch(
                value: isDark,
                onChanged: (newValue) {
                  context.read<ThemeManager>().toggleTheme(newValue);
                })
          ],
        ),
        drawer: const UserDrawer(),
        body: StreamBuilder(
          stream: FirebaseFirestore.instance
              .collection("table-user-client")
              .where('email', isEqualTo: user!.email)
              .snapshots(),
          //stream: context.watch<SignUpSignInController>().getUserInfo(),
          builder: (BuildContext context, AsyncSnapshot<QuerySnapshot?> snapshot) {
            final currentUser = snapshot.data;

            if (snapshot.hasData) {
              return SingleChildScrollView(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    AspectRatio(
                      aspectRatio: 3 / 2,
                      child: Container(
                        width: MediaQuery.of(context).size.width,
                        decoration: const BoxDecoration(
                          image: DecorationImage(
                            fit: BoxFit.fill,
                            image: NetworkImage(
                                "https://media.istockphoto.com/photos/team-of-doctors-and-nurses-in-hospital-picture-id1307543618?b=1&k=20&m=1307543618&s=170667a&w=0&h=hXpYmNYXnhdD36C-8taPQvdpM9Oj-woEdge8nvPrsZY="),
                          ),
                        ),
                      ),
                    ),
                    addVerticalSpace(100),
                    ElevatedButtonStyle.elevatedButton("Book An Appointment",
                        onPressed: () {
                      RouteNavigator.gotoPage(context, BookAnAppointment());
                    }),
                    addVerticalSpace(10),
                    // Expanded(
                    //   flex: 1,
                    //   child: Container(
                    //     color: Colors.white,
                    //   ),
                    // ),
                  ],
                ),
              );
              //   Container(
              //   height: 400,
              //   child: GridView(
              //       gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              //           crossAxisCount: 3, mainAxisSpacing: 16, crossAxisSpacing: 16),
              //       children: [
              //         Image.network('https://picsum.photos/250?image=1'),
              //         Image.network('https://picsum.photos/250?image=2'),
              //         Image.network('https://picsum.photos/250?image=3'),
              //         Image.network('https://picsum.photos/250?image=1'),
              //         Image.network('https://picsum.photos/250?image=2'),
              //         Image.network('https://picsum.photos/250?image=3'),
              //       ]),
              // );
            } else {
              return const Center(
                  child: CircularProgressIndicator(
                color: Colors.black,
              ));
            }
          },
        ),
      ),
    );
  }
}
