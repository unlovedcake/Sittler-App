import 'package:provider/src/provider.dart';
import 'package:flutter/material.dart';
import 'package:sittler_app/Controller-Provider/Theme-Controller/theme-controler-provider.dart';
import 'package:sittler_app/Pages/Staff/staff-signup.dart';
import 'package:sittler_app/Pages/User/user-signin.dart';
import 'package:sittler_app/Pages/User/user-signup.dart';
import 'package:sittler_app/Routes/routes.dart';
import 'package:sittler_app/Widgets/elevated-button.dart';
import 'package:sittler_app/Widgets/sizebox.dart';
import 'package:google_sign_in/google_sign_in.dart';

class MyHomeScreen extends StatefulWidget {
  const MyHomeScreen({Key? key}) : super(key: key);

  @override
  _MyHomeScreenState createState() => _MyHomeScreenState();
}

class _MyHomeScreenState extends State<MyHomeScreen> {
  final GoogleSignIn _googleSignIn = GoogleSignIn(scopes: ['email']);
  GoogleSignInAccount? _currentUser;

  @override
  void initState() {
    _googleSignIn.onCurrentUserChanged.listen((account) {
      setState(() {
        _currentUser = account;
      });
    });
    _googleSignIn.signInSilently();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    TextTheme _textTheme = Theme.of(context).textTheme;
    bool isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false, //remove arrow back icon
        centerTitle: true,
        title: Text(
          "Sittler App",
          style: _textTheme.headline4?.copyWith(
              fontSize: 20,
              color: isDark ? Colors.white : Colors.black,
              fontWeight: FontWeight.bold),
        ),
        actions: [
          Switch(
              value: isDark,
              onChanged: (newValue) {
                //u.toggleTheme(newValue);
                context.read<ThemeManager>().toggleTheme(newValue);
                //Provider.of<ThemeManager>(context).toggleTheme(newValue);
                // _themeManager.toggleTheme(newValue);
              })
        ],
      ),
      body: SingleChildScrollView(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Image.asset(
                  "images/sittler-logo.jpg",
                  width: MediaQuery.of(context).size.width,
                  height: 200,
                  fit: BoxFit.fill,
                ),

                addVerticalSpace(50),

                ElevatedButtonStyle.elevatedButton("Log In", onPressed: () {
                  NavigateRoute.gotoPage(context, const UserClientLoginPage());

                  // print("OK");
                  // Navigator.pushNamed(context, '/user-client-login-page');
                }),
                addVerticalSpace(20),

                ElevatedButtonStyle.elevatedButton("Register", onPressed: () {
                  print("OK");
                  //Navigator.pushNamed(context, '/user-service-login-page');
                  NavigateRoute.gotoPage(context, const UserClientRegisterPage());
                }),
                addVerticalSpace(20),
                ElevatedButtonStyle.elevatedButton("Register As Staff", onPressed: () {
                  print("OK");
                  //Navigator.pushNamed(context, '/user-service-login-page');
                  NavigateRoute.gotoPage(context, const StaffSignUp());
                }),

                addVerticalSpace(20),
                ElevatedButtonStyle.elevatedButton(
                  "Google Sign In",
                  onPressed: signIn,
                ),

                _buildWidget(),

                // ElevatedButton(
                //     child: Text("User Client "),
                //     onPressed: () {
                //       Navigator.pushNamed(context, '/user-client-login-page');
                //     }),
                // addVerticalSpace(20),
                // ElevatedButton(
                //     style: TextButton.styleFrom(minimumSize: Size(350.0, 50.0)),
                //     child: Text("User Service Provider"),
                //     onPressed: () {
                //       Navigator.pushNamed(context, '/user-service-login-page');
                //     }),
              ],
            ),
          ),
        ),
      ),
      // floatingActionButton: Theme(
      //   data: Theme.of(context).copyWith(splashColor: Colors.blue), // For Test
      //   child: FloatingActionButton(
      //     child: Icon(Icons.add),
      //     onPressed: () {},
      //   ),
      // ),
    );
  }

  Widget _buildWidget() {
    GoogleSignInAccount? user = _currentUser;
    if (user != null) {
      return Padding(
        padding: const EdgeInsets.fromLTRB(2, 12, 2, 12),
        child: Column(
          children: [
            ListTile(
              leading: GoogleUserCircleAvatar(identity: user),
              title: Text(
                user.displayName ?? '',
                style: TextStyle(fontSize: 22),
              ),
              subtitle: Text(user.email, style: TextStyle(fontSize: 22)),
            ),
            const SizedBox(
              height: 20,
            ),
            const Text(
              'Signed in successfully',
              style: TextStyle(fontSize: 20),
            ),
            const SizedBox(
              height: 10,
            ),
            ElevatedButton(onPressed: signOut, child: const Text('Sign out'))
          ],
        ),
      );
    } else {
      return Text("");
    }
  }

  void signOut() {
    _googleSignIn.disconnect();
  }

  Future<void> signIn() async {
    try {
      await _googleSignIn.signIn();
    } catch (e) {
      print('Error signing in $e');
    }
  }
}
