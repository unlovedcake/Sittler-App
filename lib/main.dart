import 'dart:convert';
import 'dart:typed_data';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:geolocator/geolocator.dart';
import 'package:provider/provider.dart';
import 'package:sittler_app/Controller-Provider/Booking-Provider/booking-provider.dart';
import 'package:sittler_app/Pages/Staff/booking-list.dart';

import 'Controller-Provider/Staff-Controller/signin-signup-controller-staff.dart';
import 'Controller-Provider/Theme-Controller/theme-controler-provider.dart';

import 'Controller-Provider/User-Controller/user-signup-signin.dart';
import 'Pages/Onboarding-Screen/onboarding.dart';
import 'Pages/Staff/staff-home.dart';
import 'Pages/User/my-booking-list.dart';
import 'Pages/User/user-home.dart';
import 'Route-Navigator/route-navigator.dart';
import 'Theme/Theme-Constant/theme-constant.dart';
import 'package:http/http.dart' as http;

// Initialize our global NavigatorKey
GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  /// On click listner
  // await Firebase.initializeApp();
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeManager()),
        ChangeNotifierProvider(create: (_) => SignUpSignInController()),
        ChangeNotifierProvider(create: (_) => SignUpSignInControllerStaff()),
        ChangeNotifierProvider(create: (_) => BookingProvider()),
      ],
      child: MyApp(),
    ),
  );
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  var userLoggedIn;

  late AndroidNotificationChannel channel;
  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;

  Future<Position> _determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Test if location services are enabled.
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      // Location services are not enabled don't continue
      // accessing the position and request users of the
      // App to enable the location services.
      return Future.error('Location services are disabled.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        // Permissions are denied, next time you could try
        // requesting permissions again (this is also where
        // Android's shouldShowRequestPermissionRationale
        // returned true. According to Android guidelines
        // your App should show an explanatory UI now.
        return Future.error('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      // Permissions are denied forever, handle appropriately.
      return Future.error(
          'Location permissions are permanently denied, we cannot request permissions.');
    }

    // When we reach here, permissions are granted and we can
    // continue accessing the position of the device.
    return await Geolocator.getCurrentPosition();
  }

  tapNotificationBar() {
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      if (message.data.isNotEmpty) {
        // navigatorKey.currentState
        //     ?.push(MaterialPageRoute(builder: (_) => const MyBookingList()));
        navigatorKey.currentState!.pushNamed('/user-mybookinglist');
        print("Navigate To My Booking List");
      } else {
        print("Navigate To Home Page");
      }
      print(message.notification!.body);
      setState(() {});
    });
  }

  @override
  void initState() {
    tapNotificationBar();
    super.initState();

    _determinePosition();

    requestPermission();
    loadFCM();
    listenFCM();
    userLoggedIn = FirebaseAuth.instance.currentUser;
    if (userLoggedIn == null) {
      userLoggedIn = null;
    } else if (FirebaseAuth.instance.currentUser!.displayName == "User Client") {
      userLoggedIn = "User Client";
    } else if (FirebaseAuth.instance.currentUser!.displayName == "Staff") {
      userLoggedIn = "Staff";
    }

    // else if (FirebaseAuth.instance.currentUser!.displayName != "User Client" &&
    //     FirebaseAuth.instance.currentUser!.email != "admin@gmail.com") {
    //   userLoggedIn = "User Service";
    // }
  }

  void requestPermission() async {
    FirebaseMessaging messaging = FirebaseMessaging.instance;

    NotificationSettings settings = await messaging.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      print('User granted permission');
    } else if (settings.authorizationStatus == AuthorizationStatus.provisional) {
      print('User granted provisional permission');
    } else {
      print('User declined or has not accepted permission');
    }
  }

  void listenFCM() async {
    FirebaseMessaging.onMessage.listen((RemoteMessage message) async {
      RemoteNotification? notification = message.notification;
      AndroidNotification? android = message.notification?.android;

      final ByteArrayAndroidBitmap largeIcon = ByteArrayAndroidBitmap(
          await _getByteArrayFromUrl('https://via.placeholder.com/48x48'));
      final ByteArrayAndroidBitmap bigPicture = ByteArrayAndroidBitmap(
          await _getByteArrayFromUrl('https://via.placeholder.com/400x800'));

      final BigPictureStyleInformation bigPictureStyleInformation =
          BigPictureStyleInformation(bigPicture,
              largeIcon: largeIcon,
              contentTitle: notification?.title,
              htmlFormatContentTitle: true,
              summaryText: notification?.body,
              htmlFormatSummaryText: true);

      if (notification != null && android != null && !kIsWeb) {
        flutterLocalNotificationsPlugin.show(
          notification.hashCode,
          notification.title,
          notification.body,
          NotificationDetails(
            android: AndroidNotificationDetails(
              channel.id,
              channel.name,
              // TODO add a proper drawable resource to android, for now using
              //      one that already exists in example app.
              //styleInformation: bigPictureStyleInformation,  // it will display the url image
              icon: 'blog',

              //largeIcon: const DrawableResourceAndroidBitmap('ic_launcher'),
            ),
          ),
        );
      }
    });
  }

  void loadFCM() async {
    if (!kIsWeb) {
      channel = const AndroidNotificationChannel(
        'high_importance_channel', // id
        'High Importance Notifications', // title
        importance: Importance.high,
        enableVibration: true,
      );

      flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

      /// Create an Android Notification Channel.
      ///
      /// We use this channel in the `AndroidManifest.xml` file to override the
      /// default FCM channel to enable heads up notifications.
      await flutterLocalNotificationsPlugin
          .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
          ?.createNotificationChannel(channel);

      /// Update the iOS foreground notification presentation options to allow
      /// heads up notifications.
      await FirebaseMessaging.instance.setForegroundNotificationPresentationOptions(
        alert: true,
        badge: true,
        sound: true,
      );
    }
  }

  Future<Uint8List> _getByteArrayFromUrl(String url) async {
    final http.Response response = await http.get(Uri.parse(url));
    return response.bodyBytes;
  }

  Future<void> _showBigPictureNotificationURL() async {
    final ByteArrayAndroidBitmap largeIcon = ByteArrayAndroidBitmap(
        await _getByteArrayFromUrl('https://via.placeholder.com/48x48'));
    final ByteArrayAndroidBitmap bigPicture = ByteArrayAndroidBitmap(
        await _getByteArrayFromUrl('https://via.placeholder.com/400x800'));

    final BigPictureStyleInformation bigPictureStyleInformation =
        BigPictureStyleInformation(bigPicture,
            largeIcon: largeIcon,
            contentTitle: 'overridden <b>big</b> content title',
            htmlFormatContentTitle: true,
            summaryText: 'summary <i>text</i>',
            htmlFormatSummaryText: true);
    final AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails('big text channel id', 'big text channel name',
            channelDescription: 'big text channel description',
            styleInformation: bigPictureStyleInformation);
    final NotificationDetails platformChannelSpecifics =
        NotificationDetails(android: androidPlatformChannelSpecifics);
    await flutterLocalNotificationsPlugin.show(
        0, 'big text title', 'silent body', platformChannelSpecifics);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      themeMode: context.watch<ThemeManager>().themeMode,
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: lightTheme,
      darkTheme: darkTheme,
      navigatorKey: navigatorKey,
      home: userLoggedIn == "User Client"
          ? const UserHome()
          : userLoggedIn == "Staff"
              ? const StaffHome()
              : const Onboarding(),
      routes: {
        '/user-mybookinglist': (context) => MyBookingList(),
      },
    );
  }
}
