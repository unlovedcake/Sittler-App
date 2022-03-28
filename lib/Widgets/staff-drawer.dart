import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/src/provider.dart';
import 'package:sittler_app/Controller-Provider/Theme-Controller/theme-controler-provider.dart';
import 'package:sittler_app/Controller-Provider/User-Controller/user-signup-signin.dart';

import 'package:sittler_app/Route-Navigator/route-navigator.dart';
import 'package:sittler_app/Widgets/sizebox.dart';

import 'list-tiles.dart';

class StaffDrawer extends StatefulWidget {
  const StaffDrawer({Key? key}) : super(key: key);

  @override
  _StaffDrawerState createState() => _StaffDrawerState();
}

class _StaffDrawerState extends State<StaffDrawer> {
  User? user = FirebaseAuth.instance.currentUser;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection("table-staff")
            .where('email', isEqualTo: user!.email)
            .snapshots(),
        builder: (context, AsyncSnapshot<QuerySnapshot?> snapshot) {
          final currentUser = snapshot.data?.docs;

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          return SingleChildScrollView(
            child: Container(
              width: 300.0,
              height: MediaQuery.of(context).size.height,
              decoration: BoxDecoration(
                borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(10),
                    topRight: Radius.circular(10),
                    bottomLeft: Radius.circular(10),
                    bottomRight: Radius.circular(10)),
                boxShadow: [
                  BoxShadow(
                    color:
                        Provider.of<ThemeManager>(context, listen: false).getDarkMode ==
                                true
                            ? Colors.black.withOpacity(1)
                            : Colors.white.withOpacity(1),
                    spreadRadius: 5,
                    blurRadius: 7,
                    offset: Offset(0, 3), // changes position of shadow
                  ),
                ],
              ),
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.only(left: 10.0, top: 24),
                    child: Row(
                      children: [
                        Hero(
                          tag: "tag1",
                          child: CircleAvatar(
                            radius: 30.0,
                            backgroundImage:
                                NetworkImage("${currentUser![0]['imageUrl']}"),
                            backgroundColor: Colors.transparent,
                          ),
                        ),
                        addVerticalSpace(20),
                        Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "${currentUser[0]['fullName']}",
                                style: const TextStyle(fontWeight: FontWeight.bold),
                              ),
                              const Icon(
                                Icons.circle,
                                size: 10,
                                color: Colors.green,
                              ),
                            ],
                          ),
                        )
                      ],
                    ),
                  ),
                  addVerticalSpace(20),
                  const Divider(
                    color: Colors.grey,
                  ),
                  ListTiles.listTile(
                    label: "Profile",
                    icon: IconButton(
                      icon: const Icon(Icons.account_circle),
                      color: Colors.orange,
                      onPressed: () {},
                    ),
                    onTap: () {},
                  ),
                  const Divider(
                    color: Colors.grey,
                  ),
                  ListTiles.listTile(
                    label: "Booking List",
                    icon: IconButton(
                      icon: const Icon(Icons.three_p),
                      color: Colors.blue,
                      onPressed: () {},
                    ),
                    onTap: () {},
                  ),
                  const Divider(
                    color: Colors.grey,
                  ),
                  ListTiles.listTile(
                    label: "Chat",
                    icon: IconButton(
                      icon: const Icon(Icons.message),
                      color: Colors.green,
                      onPressed: () {},
                    ),
                    onTap: () {},
                  ),
                  const Divider(
                    color: Colors.grey,
                  ),
                  ListTiles.listTile(
                    label: "Sign Out",
                    icon: IconButton(
                      icon: const Icon(Icons.logout),
                      color: Colors.redAccent,
                      onPressed: () {},
                    ),
                    onTap: () {
                      SignUpSignInController.logout(context);
                    },
                  ),
                  const Divider(
                    color: Colors.grey,
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
