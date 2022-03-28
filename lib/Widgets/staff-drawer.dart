import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/src/provider.dart';
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
    return StreamBuilder(
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
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(10),
                  topRight: Radius.circular(10),
                  bottomLeft: Radius.circular(10),
                  bottomRight: Radius.circular(10)),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.5),
                  spreadRadius: 5,
                  blurRadius: 7,
                  offset: Offset(0, 3), // changes position of shadow
                ),
              ],
            ),
            padding: EdgeInsets.only(top: 50, bottom: 70, left: 10),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Hero(
                      tag: "tag1",
                      child: CircleAvatar(
                        radius: 30.0,
                        backgroundImage: NetworkImage("${currentUser![0]['imageUrl']}"),
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
                            style: const TextStyle(
                                color: Colors.black, fontWeight: FontWeight.bold),
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
                const SizedBox(
                  height: 300.0,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    const SizedBox(
                      width: 10,
                    ),
                    ActionChip(
                        label: const Text("  Logout  "),
                        onPressed: () async {
                          context.read<SignUpSignInController>().logout(context);
                        }),
                  ],
                )
              ],
            ),
          ),
        );
      },
    );
  }
}
