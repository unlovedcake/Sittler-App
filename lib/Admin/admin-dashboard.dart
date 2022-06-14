import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:sittler_app/Controller-Provider/User-Controller/user-signup-signin.dart';
import 'package:http/http.dart' as http;

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({Key? key}) : super(key: key);

  @override
  _AdminDashboardState createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  void sendPushMessage(String token, String title, String body) async {
    try {
      await http.post(
        Uri.parse('https://fcm.googleapis.com/fcm/send'),
        headers: <String, String>{
          'Content-Type': 'application/json',
          'Authorization':
              'key=AAAAK-9tvqM:APA91bFSuuKsJVoTuNC19D_Tg1QkmW2Cfbfop879_daYGyvQYOa3zWBP2qcQwRfUPf5UVsJ01-xc6ZTfnz5cBjrkRQRRUPRshiflERqjCdU5byGIoHma8XrVuO2HPEE4FHCWUyTW5D9X',
        },
        body: jsonEncode(
          <String, dynamic>{
            'notification': <String, dynamic>{'body': body, 'title': title},
            'priority': 'high',
            'data': <String, dynamic>{
              'click_action': 'FLUTTER_NOTIFICATION_CLICK',
              'id': '1',
              'status': 'done'
            },
            "to": token,
          },
        ),
      );
    } catch (e) {
      print("error push notification");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          actions: [
            Padding(
              padding: const EdgeInsets.only(right: 12.0),
              child: PopupMenuButton(itemBuilder: (context) {
                return [
                  PopupMenuItem<int>(
                    value: 0,
                    child: Text("Logout"),
                  ),
                ];
              }, onSelected: (value) {
                if (value == 0) {
                  SignUpSignInController.logout(context);
                }
              }),
            )
          ],
        ),
        body: StreamBuilder(
          stream: FirebaseFirestore.instance
              .collection("table-staff")
              .orderBy('fullName')
              .snapshots(),
          builder: (
            context,
            AsyncSnapshot<QuerySnapshot?> snapshot,
          ) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(
                  child: CircularProgressIndicator(
                color: Colors.orange,
              ));
            } else if (snapshot.connectionState == ConnectionState.active ||
                snapshot.connectionState == ConnectionState.done) {
              if (snapshot.hasError) {
                return const Text('Error');
              } else if (snapshot.data!.docs.isNotEmpty) {
                return ListView.builder(
                    itemCount: snapshot.data?.docs.length,
                    itemBuilder: (ctxt, int index) {
                      final DocumentSnapshot bookingData = snapshot.data!.docs[index];

                      return Card(
                          child: ListTile(
                              onTap: () {},
                              title: Text(bookingData['fullName']),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(bookingData['email']),
                                  Text(bookingData['active'] == true
                                      ? "Active"
                                      : "Inactivate"),
                                ],
                              ),
                              leading: CachedNetworkImage(
                                fit: BoxFit.cover,
                                imageUrl: bookingData['imageUrl'],
                                imageBuilder: (context, imageProvider) => Container(
                                  height: 50,
                                  width: 50,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.all(Radius.circular(50)),
                                    image: DecorationImage(
                                      image: imageProvider,
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                ),
                                progressIndicatorBuilder:
                                    (context, url, downloadProgress) =>
                                        CircularProgressIndicator(
                                  value: downloadProgress.progress,
                                  color: Colors.orange,
                                ),
                                errorWidget: (context, url, error) => const Icon(
                                  Icons.error,
                                  size: 100,
                                  color: Colors.red,
                                ),
                              ),
                              trailing: Column(
                                children: [
                                  OutlinedButton(
                                      onPressed: () async {
                                        print(bookingData.id);
                                        if (bookingData['active'] == false) {
                                          FirebaseFirestore.instance
                                              .collection('table-staff')
                                              .doc(bookingData.id)
                                              .update({
                                            "active": true,
                                          }).whenComplete(() {
                                            sendPushMessage(
                                                bookingData['token'],
                                                "From Admin",
                                                "Your account is activate !!!");
                                            Fluttertoast.showToast(
                                                msg: "User is Activated");
                                          });
                                        } else {
                                          FirebaseFirestore.instance
                                              .collection('table-staff')
                                              .doc(bookingData.id)
                                              .update({
                                            "active": false,
                                          }).whenComplete(() {
                                            Fluttertoast.showToast(
                                                msg: "User is Deactivated");
                                          });
                                        }
                                      },
                                      child: Text(bookingData['active'] == false
                                          ? "Confirm Request"
                                          : "Deactivate")),
                                ],
                              )));
                    });
              } else {
                return Center(child: const Text('No Data'));
              }
            } else {
              return Center(child: Text('Connection State: ${snapshot.connectionState}'));
            }
          },
        ));
  }
}
