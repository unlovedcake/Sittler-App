import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:sittler_app/Controller-Provider/Booking-Provider/booking-provider.dart';
import 'package:sittler_app/Controller-Provider/User-Controller/user-signup-signin.dart';
import 'package:sittler_app/Model/book-model.dart';
import 'package:sittler_app/Model/staff-model.dart';
import 'package:sittler_app/Model/user-model.dart';
import 'package:sittler_app/Widgets/elevated-button.dart';
import 'package:sittler_app/Widgets/sizebox.dart';
import 'package:sittler_app/Widgets/textformfield-date.dart';
import 'package:flutter_clean_calendar/clean_calendar_event.dart';
import 'package:flutter_clean_calendar/flutter_clean_calendar.dart';
import 'package:uuid/uuid.dart';

class BookASittler extends StatefulWidget {
  @override
  _BookASittlerState createState() => _BookASittlerState();
}

class _BookASittlerState extends State<BookASittler> {
  User? user = FirebaseAuth.instance.currentUser;
  UserModel loggedInUser = UserModel();

  final _formKey = GlobalKey<FormState>();

  final TextEditingController _serviceNeedText = TextEditingController();

  DateTime _selectedDate = DateTime.now();
  String _endTime = DateFormat("hh:mm a").format(DateTime.now());
  String _startTime = DateFormat("hh:mm a").format(DateTime.now());

  String bookingDate = "";

  bool isEventEmpty = false;

  _getDateFromUser() async {
    DateTime? _pickerDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2015),
      lastDate: DateTime(2121),
    );
    if (_pickerDate != null) {
      _selectedDate = _pickerDate;
    } else {}
  }

  _showTimePicker() {
    return showTimePicker(
      initialEntryMode: TimePickerEntryMode.input,
      context: context,
      initialTime: TimeOfDay(
          hour: int.parse(_startTime.split(":")[0]),
          minute: int.parse(_startTime.split(":")[1].split(" ")[0])),
    );
  }

  _getTimeFromUser({required bool isStartTime}) async {
    var pickedTime = await _showTimePicker();
    String _formatTime = pickedTime!.format(context);

    // DateTime parsedTime = DateFormat.jm().parse(pickedTime.format(context).toString());
    // //converting to DateTime so that we can further format on different pattern.
    // print(parsedTime); //output 1970-01-01 22:53:00.000
    // String formattedTime = DateFormat('HH:mm:ss').format(parsedTime);
    // print(formattedTime); //output 14:59:00

    if (pickedTime == null) {
      print("Time Canceled");
    } else if (isStartTime) {
      _startTime = _formatTime;
      //context.read<ControllerClientProvider>().setDisplayStartTime(_startTime);

      setState(() {
        _startTime = _formatTime;
      });
    } else if (!isStartTime) {
      _endTime = _formatTime;
      // context.read<ControllerClientProvider>().setDisplayEndTime(_endTime);

      setState(() {
        _endTime = _formatTime;
      });
    }
  }

  List<String> listOfMonths = [
    "Jan",
    "Feb",
    "Mar",
    "Apr",
    "May",
    "Jun",
    "Jul",
    "Aug",
    "Sep",
    "Oct",
    "Nov",
    "Dec"
  ];

  List<String> listDays = ["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"];

  DateTime? selectedDay;
  List<CleanCalendarEvent> selectedEvent = [];

  Map<DateTime, List<CleanCalendarEvent>> events = Map();

  void _handleData(date) {
    setState(() {
      selectedDay = date;
      selectedEvent = events[date] ?? [];
    });
    //print(selectedDay);
  }

  final DateFormat formatTime = new DateFormat("hh:mm a");
  final DateFormat formatDate = new DateFormat("MMMM dd, y");
  List dataAll = [];

  Future dis() async {
    await FirebaseFirestore.instance
        .collection("table-book")
        .where("userStaff.email",
            isEqualTo: Provider.of<SignUpSignInController>(context, listen: false)
                .getServiceEmail)
        .get()
        .then((value) {
      value.docs.forEach((result) {
        dataAll.add(result.data());
        //print(dataAll.length);
      });
    });
    getAllData();
  }

  @override
  void initState() {
    super.initState();

    dis();
  }

  getAllData() {
    for (int i = 0; i < dataAll.length; i++) {
      events.addAll({
        formatDate.parse((dataAll[i]['dateToBook'])): [
          CleanCalendarEvent(dataAll[i]['userModel']['clientAddress'],
              startTime: formatTime.parse(dataAll[i]['startTime']),
              endTime: formatTime.parse(dataAll[i]['endTime']),
              description: dataAll[i]['serviceNeed'],
              color: Colors.orange),
        ]
      });
    }
    print(events.length);
  }

  @override
  Widget build(BuildContext context) {
    FirebaseFirestore.instance
        .collection("table-user-client")
        .doc(user!.uid)
        .get()
        .then((value) {
      loggedInUser = UserModel.fromMap(value.data());

      print(loggedInUser.fullName);
    });

    return StreamBuilder(
      stream: context.watch<SignUpSignInController>().getUserServiceEmail(),
      builder: (context, AsyncSnapshot<QuerySnapshot?> snapshot) {
        final currentUser = snapshot.data?.docs;
        if (snapshot.hasData) {
          return Scaffold(
            appBar: AppBar(
              centerTitle: true,
              title: Text("Book A Sittler"),
            ),
            body: SingleChildScrollView(
                child: Column(
              children: [
                Container(
                  height: 150,
                  width: double.infinity,
                  decoration: const BoxDecoration(
                    boxShadow: <BoxShadow>[
                      BoxShadow(
                          color: Colors.black54,
                          blurRadius: 15.0,
                          offset: Offset(0.0, 0.75))
                    ],
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Stack(
                        children: <Widget>[
                          Column(
                            children: [
                              Container(
                                margin: EdgeInsets.all(8),
                                width: 100,
                                height: 100,
                                child: Hero(
                                  tag: currentUser![0]['uid'],
                                  child: CachedNetworkImage(
                                    width: 50,
                                    height: 50,
                                    fit: BoxFit.cover,
                                    imageUrl: "${currentUser[0]['imageUrl']}",
                                    progressIndicatorBuilder:
                                        (context, url, downloadProgress) =>
                                            CircularProgressIndicator(
                                                value: downloadProgress.progress),
                                    errorWidget: (context, url, error) => const Icon(
                                      Icons.error,
                                      size: 100,
                                      color: Colors.red,
                                    ),
                                  ),
                                ),
                              ),
                              Container(
                                margin: EdgeInsets.all(8),
                                child: Text("${currentUser[0]['fullName']}",
                                    style: TextStyle(
                                        fontSize: 14, fontWeight: FontWeight.w500)),
                              ),
                            ],
                          ),
                        ],
                      ),
                      SizedBox(
                        width: 60,
                      ),
                    ],
                  ),
                ),
                SizedBox(
                  height: 10.0,
                ),
                SingleChildScrollView(
                  child: Column(
                    children: [
                      Container(
                        height: 380,
                        child: Calendar(
                          //todayButtonText: "Today",
                          startOnMonday: true,
                          selectedColor: Colors.blue,
                          todayColor: Colors.red,
                          eventColor: Colors.green,
                          eventDoneColor: Colors.amber,
                          bottomBarColor: Colors.deepOrange,
                          // onRangeSelected: (range) {
                          //   print('selected Day ${range.from},${range.to}');
                          // },
                          onDateSelected: (date) {
                            print(DateFormat.yMMMMd().format(date));

                            bookingDate = DateFormat.yMMMMd().format(date);
                            print(selectedEvent.isEmpty);
                            if (events[date] == null) {
                              isEventEmpty = true;
                              print("Calendar Click");
                            } else {
                              isEventEmpty = false;
                            }
                            return _handleData(date);
                          },
                          events: events,
                          isExpanded: true,
                          dayOfWeekStyle: TextStyle(
                            fontSize: 15,
                            overflow: TextOverflow.ellipsis,
                            color: Colors.orange,
                            fontWeight: FontWeight.w400,
                          ),
                          bottomBarTextStyle: TextStyle(
                            color: Colors.orange,
                          ),
                          hideBottomBar: true,
                          hideArrows: false,
                          weekDays: ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'],
                        ),
                      ),
                      isEventEmpty
                          ? Form(
                              key: _formKey,
                              child: Column(
                                children: [
                                  InputFieldDesign.inputField(
                                      "Service Need", "Service Need", _serviceNeedText,
                                      widget: null, validator: (value) {
                                    if (value!.isEmpty) {
                                      return ("Service is required");
                                    }
                                  }),
                                  Row(
                                    children: [
                                      Expanded(
                                        child: InputFieldDesign.inputField(
                                            "Start Time",
                                            //'${context.watch<ControllerClientProvider>().getDisplayStartTime}',
                                            //appState.getDisplayStartTime,
                                            _startTime,
                                            null,
                                            widget: null,
                                            suffixIcon: IconButton(
                                              icon: Icon(Icons.access_time_rounded),
                                              color: Colors.grey,
                                              onPressed: () {
                                                _getTimeFromUser(isStartTime: true);
                                              },
                                            ),
                                            validator: (value) {}),
                                      ),
                                      SizedBox(
                                        width: 10.0,
                                      ),
                                      Expanded(
                                        child: InputFieldDesign.inputField(
                                            "End Time",
                                            //'${context.watch<ControllerClientProvider>().getDisplayEndTime}',

                                            // appState.getDisplayEndTime,
                                            _endTime,
                                            null,
                                            widget: null,
                                            suffixIcon: IconButton(
                                              icon: Icon(Icons.access_time_rounded),
                                              color: Colors.grey,
                                              onPressed: () {
                                                _getTimeFromUser(isStartTime: false);
                                              },
                                            ),
                                            validator: (value) {}),
                                      ),
                                    ],
                                  ),
                                  SizedBox(
                                    height: 8,
                                  ),
                                  Container(
                                    width: 200,
                                    decoration: BoxDecoration(
                                        color: Colors.orange,
                                        borderRadius: BorderRadius.circular(12),
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.grey.shade500,
                                            offset: Offset(5, 5),
                                            blurRadius: 10,
                                            spreadRadius: 1,
                                          ),
                                          BoxShadow(
                                            color: Colors.grey[300]!,
                                            offset: Offset(-2, -2),
                                            blurRadius: 10,
                                            spreadRadius: 1,
                                          ),
                                        ]),
                                    child: TextButton(
                                      style: ElevatedButton.styleFrom(
                                        //primary: Colors.orange, // background
                                        onPrimary: Colors.white, // foreground
                                      ),
                                      onPressed: () async {
                                        BookModel bookModel = BookModel();
                                        bookModel.serviceNeed = _serviceNeedText.text;
                                        bookModel.dateToBook = bookingDate;
                                        bookModel.startTime = _startTime;
                                        bookModel.endTime = _endTime;
                                        bookModel.appointmentStatus = "Pending";
                                        bookModel.userModel = {
                                          "uid": loggedInUser.uid,
                                          "fullName": loggedInUser.fullName,
                                          "contactNumber": loggedInUser.contactNumber,
                                          "email": loggedInUser.email,
                                          "clientAddress": loggedInUser.address,
                                          "imageUrl": loggedInUser.imageUrl
                                        };
                                        bookModel.userStaff = {
                                          "uid": currentUser[0]['uid'],
                                          "fullName": currentUser[0]['fullName'],
                                          "email": currentUser[0]['email'],
                                          "imageUrl": currentUser[0]['imageUrl'],
                                        };

                                        if (_formKey.currentState!.validate()) {
                                          List listAllBooking = [];
                                          bool canBook = true;

                                          String? _dateNow = Provider.of<BookingProvider>(
                                                  context,
                                                  listen: false)
                                              .getSelectedDate;
                                          //DateFormat.yMMMMd().format(_selectedDate);
                                          final res = await FirebaseFirestore.instance
                                              .collection("table-book")
                                              .get();

                                          res.docs.forEach((doc) {
                                            listAllBooking.add(doc.data());
                                          });

                                          String sT = _startTime.split(":")[0];
                                          String eT = _endTime.split(":")[0];
                                          String _startTimeAmPm = _startTime
                                              .substring(5); // current time value
                                          String _endTimeAmPm =
                                              _endTime.substring(5); // current time value

                                          for (int i = 0;
                                              i < listAllBooking.length;
                                              i++) {
                                            String? dateToBook =
                                                listAllBooking[i]['dateToBook'];
                                            String? startTime =
                                                listAllBooking[i]['startTime'];
                                            String? endTime =
                                                listAllBooking[i]['endTime'];
                                            String? userServiceName = listAllBooking[i]
                                                ['userStaff']['fullName'];

                                            String startTimeValueToDatabase =
                                                startTime!.split(":")[0];
                                            int intStartTimeValueToDatabase =
                                                int.parse(startTimeValueToDatabase);
                                            String endTimeValueToDatabase =
                                                endTime!.split(":")[0];
                                            int intEndTimeValueToDatabase =
                                                int.parse(endTimeValueToDatabase);

                                            int startST = int.parse(sT);
                                            int endET = int.parse(eT);

                                            int limitTotalMaxBookTime = startST + endET;

                                            //int hour = int.parse(_startTime.substring(0, 1));

                                            String startTimeAmPmDB = startTime
                                                .substring(5); //databse time value
                                            String endTimeAmPmDB =
                                                endTime.substring(5); //databse time value

                                            DateTime parsedEndTime24 =
                                                DateFormat.jm().parse(endTime);
                                            String formattedTime = DateFormat('HH:mm a')
                                                .format(parsedEndTime24);

                                            String endTime24 =
                                                formattedTime.split(":")[0];
                                            int _endTimeDB24 = int.parse(endTime24);

                                            DateTime parsedStartTime24 =
                                                DateFormat.jm().parse(startTime);
                                            String formattedTimeStart =
                                                DateFormat('HH:mm a')
                                                    .format(parsedStartTime24);

                                            String startTime24 =
                                                formattedTimeStart.split(":")[0];
                                            int _startTimeDB24 = int.parse(startTime24);

                                            DateTime _parsedEndTime24 =
                                                DateFormat.jm().parse(_endTime);
                                            String _formattedTime = DateFormat('HH:mm a')
                                                .format(_parsedEndTime24);

                                            String endTime24_ =
                                                _formattedTime.split(":")[0];
                                            int endSelectedTime24 = int.parse(endTime24_);

                                            DateTime _parsedStartTime24 =
                                                DateFormat.jm().parse(_startTime);
                                            String _formattedTimeStart =
                                                DateFormat('HH:mm a')
                                                    .format(_parsedStartTime24);

                                            String startTime24_ =
                                                _formattedTimeStart.split(":")[0];
                                            int startSelectedTime24 =
                                                int.parse(startTime24_);

                                            if (sT == eT) {
                                              canBook = false;
                                              Fluttertoast.showToast(
                                                  msg:
                                                      " Start time and End Time Invalid. ");
                                              break;
                                            } else if (currentUser[0]['fullName'] ==
                                                    userServiceName &&
                                                dateToBook == _dateNow &&
                                                startSelectedTime24 >= _startTimeDB24 &&
                                                startSelectedTime24 <= _endTimeDB24) {
                                              canBook = false;
                                              //print(currentUser[0]['fullName']);
                                              Fluttertoast.showToast(
                                                  toastLength: Toast.LENGTH_LONG,
                                                  msg: "${currentUser[0]['fullName']}" +
                                                      " "
                                                          "is taken from" +
                                                      " "
                                                          "${startTime}" +
                                                      " "
                                                          "to" +
                                                      " " "${endTime}");
                                              break;
                                            } else if (currentUser[0]['fullName'] ==
                                                    userServiceName &&
                                                dateToBook == _dateNow &&
                                                startSelectedTime24 <= _startTimeDB24 &&
                                                endSelectedTime24 >= _startTimeDB24) {
                                              canBook = false;

                                              print("${_dateNow}" +
                                                  "${dateToBook}" +
                                                  "HEY");
                                              Fluttertoast.showToast(
                                                  toastLength: Toast.LENGTH_LONG,
                                                  msg: "${currentUser[0]['fullName']}" +
                                                      " "
                                                          "is taken from" +
                                                      " "
                                                          "${startTime}" +
                                                      " "
                                                          "to" +
                                                      " " "${endTime}");
                                              break;
                                            } else if (currentUser[0]['fullName'] ==
                                                    userServiceName &&
                                                dateToBook == _dateNow &&
                                                startSelectedTime24 <= _startTimeDB24 &&
                                                endSelectedTime24 >= _endTimeDB24) {
                                              canBook = false;

                                              Fluttertoast.showToast(
                                                  toastLength: Toast.LENGTH_LONG,
                                                  msg: "${currentUser[0]['fullName']}" +
                                                      " "
                                                          "is taken from" +
                                                      " "
                                                          "${startTime}" +
                                                      " "
                                                          "to" +
                                                      " " "${endTime}");
                                              break;
                                            } else if (currentUser[0]['fullName'] ==
                                                    userServiceName &&
                                                dateToBook == _dateNow &&
                                                startSelectedTime24 >=
                                                    endSelectedTime24) {
                                              canBook = false;

                                              Fluttertoast.showToast(
                                                  toastLength: Toast.LENGTH_LONG,
                                                  msg: "${currentUser[0]['fullName']}" +
                                                      " "
                                                          "is taken from" +
                                                      " "
                                                          "${startTime}" +
                                                      " "
                                                          "to" +
                                                      " " "${endTime}");
                                              break;
                                            }
                                          }

                                          if (listAllBooking.length == 0 &&
                                              sT == eT &&
                                              _startTimeAmPm == _endTimeAmPm) {
                                            canBook = false;
                                            Fluttertoast.showToast(
                                                msg:
                                                    " Start time and End Time Invalid. ");
                                          }

                                          if (canBook) {
                                            context
                                                .read<BookingProvider>()
                                                .bookingAdd(bookModel);
                                          }

                                          //Navigator.pushNamed(context, '/client-home-page');
                                        }
                                      },
                                      child: Text('Book Now'),
                                    ),
                                  ),
                                  SizedBox(
                                    height: 15,
                                  ),
                                ],
                              ),
                            )
                          : SizedBox(
                              height: 10,
                            ),
                    ],
                  ),
                ),
              ],
            )),
          );
        }

        return Text("");
      },
    );
  }
}
