import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/src/provider.dart';
import 'package:sittler_app/Controller-Provider/User-Controller/user-signup-signin.dart';
import 'package:sittler_app/Pages/User/user-signup.dart';
import 'package:sittler_app/Routes/routes.dart';
import 'package:sittler_app/Widgets/elevated-button.dart';
import 'package:sittler_app/Widgets/sizebox.dart';
import 'package:sittler_app/Widgets/textformfied.dart';

class UserClientLoginPage extends StatefulWidget {
  const UserClientLoginPage({Key? key}) : super(key: key);

  @override
  _UserClientLoginPageState createState() => _UserClientLoginPageState();
}

class _UserClientLoginPageState extends State<UserClientLoginPage> {
  final TextEditingController _emailText = TextEditingController();
  final TextEditingController _passwordText = TextEditingController();

  final _formKey = GlobalKey<FormState>();
  bool _isHidden = true;
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
          appBar: AppBar(
            centerTitle: true,
            title: Text("Log In"),
          ),
          body: SingleChildScrollView(
            reverse: true,
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  AspectRatio(
                    aspectRatio: 3 / 2,
                    child: Container(
                      width: double.infinity,
                      decoration: const BoxDecoration(
                        image: DecorationImage(
                            image: AssetImage("images/logo.png"), fit: BoxFit.cover),
                        // boxShadow: <BoxShadow>[
                        //   BoxShadow(
                        //       color: Colors.black54,
                        //       blurRadius: 15.0,
                        //       offset: Offset(0.0, 0.75))
                        // ],
                        //color: Colors.white60,
                      ),
                    ),
                  ),
                  addVerticalSpace(20),
                  TextFormFields.textFormFields("Email", "Email", _emailText,
                      widget: null,
                      sufixIcon: null,
                      obscureText: false,
                      keyboardType: TextInputType.emailAddress,
                      textInputAction: TextInputAction.next, validator: (value) {
                    if (value!.isEmpty) {
                      return ("Email is required");
                    } else if (!value!.contains("@")) {
                      return ("Invalid Email Format");
                    }
                  }),
                  addVerticalSpace(20),
                  TextFormFields.textFormFields("Password", "Password", _passwordText,
                      widget: null,
                      sufixIcon: IconButton(
                        icon: Icon(
                          _isHidden ? Icons.visibility : Icons.visibility_off,
                          color: Colors.orange,
                        ),
                        onPressed: () {
                          // This is the trick

                          _isHidden = !_isHidden;

                          (context as Element).markNeedsBuild();
                        },
                      ),
                      obscureText: _isHidden,
                      keyboardType: TextInputType.text,
                      textInputAction: TextInputAction.done, validator: (value) {
                    if (value!.isEmpty) {
                      return ("Password is required ");
                    }
                  }),
                  addVerticalSpace(20),
                  ElevatedButtonStyle.elevatedButton("Login", onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      context
                          .read<SignUpSignInController>()
                          .signIn(_emailText.text, _passwordText.text, context);
                    }
                  }),

                  // ElevatedButton(
                  //     child: Text("Login "),
                  //     onPressed: () {
                  //       // Navigator.pushNamed(context, '/user-client-login-page');
                  //     }),
                  addVerticalSpace(20),
                  Row(mainAxisAlignment: MainAxisAlignment.center, children: <Widget>[
                    Text("Don't have an account? "),
                    GestureDetector(
                      onTap: () {
                        NavigateRoute.gotoPage(context, const UserClientRegisterPage());
                      },
                      child: const Text(
                        "SignUp",
                        style: TextStyle(
                            color: Colors.redAccent,
                            fontWeight: FontWeight.bold,
                            fontSize: 15),
                      ),
                    )
                  ]),
                  addVerticalSpace(20),
                ],
              ),
            ),
          )),
    );
  }
}
