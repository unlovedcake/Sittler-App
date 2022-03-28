import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:provider/src/provider.dart';
import 'package:sittler_app/Controller-Provider/User-Controller/user-signup-signin.dart';
import 'package:sittler_app/Pages/User/book-a-sittler.dart';

class BookAnAppointment extends StatefulWidget {
  const BookAnAppointment({Key? key}) : super(key: key);

  @override
  _BookAnAppointmentState createState() => _BookAnAppointmentState();
}

class _BookAnAppointmentState extends State<BookAnAppointment> {
  Position? _currentUserPosition;
  double? distanceImMeter = 0.0;
  double defualtValue = 1.0;
  List listUsers = [];
  String? _currentAddress;

  List<int> res = [];
  List rateStar = [];
  String ratings = "0";
  int max_index = 0;
  int max_value = 0;

  Future getAlluser() async {
    try {
      final res = await FirebaseFirestore.instance.collection("table-staff").get();

      res.docs.forEach((doc) {
        listUsers.add(doc.data());
      });

      return res;
    } catch (e) {
      return null;
    }
  }

  Future getDis() async {
    try {
      _currentUserPosition =
          await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);

      if (listUsers.length != 0) {
        for (int i = 0; i < listUsers.length; i++) {
          double? storelat = listUsers[i]['position']['latitude'];
          double? storelng = listUsers[i]['position']['longitude'];

          distanceImMeter = await Geolocator.distanceBetween(
            _currentUserPosition!.latitude,
            _currentUserPosition!.longitude,
            storelat!,
            storelng!,
          );
          double? distance = distanceImMeter?.round().toDouble();

          listUsers[i]['distance'] = (distance! / 1000).round().toDouble();
          double? dis = listUsers[i]['distance'];

          // print("${listUsers[i]['position']['latitude'].toString()}" "Distance");
          // print("${_currentUserPosition!.latitude}" "Sincere Distance");

          setState(() {});
        }
      }

      listUsers.sort((a, b) => a["distance"].compareTo(b["distance"]));
    } catch (e) {}

    //getRate();
  }

  Future _getAddressFromLatLng() async {
    try {
      _currentUserPosition =
          await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);

      if (listUsers.length != 0) {
        for (int i = 0; i < listUsers.length; i++) {
          double? storelat = listUsers[i]['position']['latitude'];
          double? storelng = listUsers[i]['position']['longitude'];

          List<Placemark> placemarks = await placemarkFromCoordinates(
              listUsers[i]['position']['latitude'],
              listUsers[i]['position']['longitude']);

          Placemark place = placemarks[0];

          _currentAddress = "${place.locality}, ${place.postalCode}, ${place.country}";

          setState(() {
            listUsers[i]['address'] = _currentAddress;
          });
        }
      }

      print("${_currentAddress}" "Address");
    } catch (e) {
      print("ERROR");
      print(e);
    }
  }

  Future getUserClientDetails() async {
    var snapshots =
        await FirebaseFirestore.instance.collection('table-user-service').get();
    var snapshotDocuments = snapshots.docs;

    for (var docs in snapshotDocuments) {
      double? storelat = docs.data()['position']['latitude'];
      double? storelng = docs.data()['position']['longitude'];

      distanceImMeter = await Geolocator.distanceBetween(
        _currentUserPosition!.latitude,
        _currentUserPosition!.longitude,
        storelat!,
        storelng!,
      );
      double? distance = distanceImMeter?.round().toDouble();

      docs.data()['distance'] = (distance! / 1000)..toStringAsFixed(1);

      print(docs.data()['fullName']);
    }
  }

  @override
  void initState() {
    super.initState();

    getAlluser();
    _getAddressFromLatLng();
    getDis();
  }

  @override
  void setState(VoidCallback fn) {
    // TODO: implement setState
    if (mounted) {
      super.setState(fn);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text("Booking List"),
      ),
      body: FutureBuilder(
        future: getDis(),
        builder: (context, projectSnap) {
          // if (projectSnap.connectionState == ConnectionState.waiting) {
          //   return Center(child: CircularProgressIndicator(color: Colors.black));
          // }

          if (listUsers.length == 0) {
            //print('project snapshot data is: ${projectSnap.data}');
            return Center(
                child: CircularProgressIndicator(
              color: Colors.orange,
            ));
          } else {
            return ListView.builder(
              itemCount: listUsers.length,
              itemBuilder: (context, index) {
                return Card(
                  margin: EdgeInsets.all(12),
                  child: ListTile(
                    leading: Hero(
                      tag: listUsers[index]['uid'],
                      child: CachedNetworkImage(
                        width: 50,
                        height: 50,
                        fit: BoxFit.cover,
                        imageUrl: listUsers[index]['imageUrl'],
                        progressIndicatorBuilder: (context, url, downloadProgress) =>
                            CircularProgressIndicator(value: downloadProgress.progress),
                        errorWidget: (context, url, error) => Icon(
                          Icons.error,
                          size: 20,
                          color: Colors.red,
                        ),
                      ),
                    ),
                    //title: Text(listUsers[index]['fullName']),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          listUsers[index]['fullName'],
                          style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w500,
                              color: Colors.black),
                        ),
                        SizedBox(
                          height: 4,
                        ),
                        Text(listUsers[index]['address'] == null
                            ? "Philippines"
                            : listUsers[index]['address']),
                        SizedBox(
                          height: 4,
                        ),
                        Divider(
                          thickness: 1,
                        ),
                      ],
                    ),
                    trailing: SizedBox(
                      width: 100,
                      child: Column(
                        children: [
                          Expanded(
                            child: Text("${listUsers[index]['distance']}"
                                'KM Away'),
                          ),
                          RatingBarIndicator(
                            rating: 3,
                            //rating: 3,
                            itemBuilder: (context, index) => Icon(
                              Icons.star,
                              color: Colors.amber,
                            ),
                            itemCount: 5,
                            itemSize: 20.0,
                            direction: Axis.horizontal,
                          ),
                        ],
                      ),
                    ),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => BookASittler()),
                      );

                      context
                          .read<SignUpSignInController>()
                          .setUserServiceEmail(listUsers[index]['email']);
                    },
                  ),
                );
              },
            );
          }
        },
      ),
    );
  }
}
