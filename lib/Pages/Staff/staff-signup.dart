import 'package:select_form_field/select_form_field.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/src/provider.dart';
import 'package:sittler_app/ConstantValue/services-type-of-doctor.dart';
import 'package:sittler_app/Controller-Provider/Staff-Controller/signin-signup-controller-staff.dart';
import 'package:sittler_app/Model/staff-model.dart';
import 'package:sittler_app/Widgets/elevated-button.dart';
import 'package:sittler_app/Widgets/sizebox.dart';
import 'package:sittler_app/Widgets/textformfied.dart';

class StaffSignUp extends StatefulWidget {
  const StaffSignUp({Key? key}) : super(key: key);

  @override
  _StaffSignUpState createState() => _StaffSignUpState();
}

class _StaffSignUpState extends State<StaffSignUp> {
  final TextEditingController _nameText = TextEditingController();
  final TextEditingController _emailText = TextEditingController();
  final TextEditingController _addressText = TextEditingController();
  final TextEditingController _contactText = TextEditingController();
  final TextEditingController _passwordText = TextEditingController();
  final TextEditingController _confirmPasswordText = TextEditingController();
  final TextEditingController _servicesText = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  bool _isHidden = true;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          centerTitle: true,
          title: const Text("Sign Up"),
        ),
        body: SingleChildScrollView(
          reverse: true,
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                addVerticalSpace(20),
                TextFormFields.textFormFields("Name", "Full Name", _nameText,
                    widget: null,
                    sufixIcon: null,
                    obscureText: false,
                    keyboardType: TextInputType.name,
                    textInputAction: TextInputAction.next, validator: (value) {
                  if (value!.isEmpty) {
                    return ("Name is required ");
                  }
                }),
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
                TextFormFields.textFormFields("Address", "Address", _addressText,
                    widget: null,
                    sufixIcon: null,
                    obscureText: false,
                    keyboardType: TextInputType.streetAddress,
                    textInputAction: TextInputAction.next, validator: (value) {
                  if (value!.isEmpty) {
                    return ("Address is required ");
                  }
                }),
                addVerticalSpace(20),
                TextFormFields.textFormFields(
                    "Contact Number", "Contact Number", _contactText,
                    widget: null,
                    sufixIcon: null,
                    obscureText: false,
                    keyboardType: TextInputType.number,
                    textInputAction: TextInputAction.next, validator: (value) {
                  if (value!.isEmpty) {
                    return ("Contact is required ");
                  }
                }),
                addVerticalSpace(20),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: SelectFormField(
                    controller: _servicesText,
                    validator: (value) {
                      if (value!.isEmpty) {
                        return ("Enter you expertise");
                      }
                    },
                    decoration: InputDecoration(
                      contentPadding: EdgeInsets.fromLTRB(20, 15, 20, 15),
                      hintText: 'Service',
                      labelText: 'Service Type',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    type: SelectFormFieldType.dropdown, // or can be dialog
                    //initialValue: "One",
                    // icon: Icon(Icons.format_shapes),

                    items: ServicesTypesOfDoctor.items,
                    onChanged: (val) {
                      print(val);
                    },
                    // onSaved: (val) {
                    //   print(val);
                    // },
                  ),
                ),
                addVerticalSpace(20),
                TextFormFields.textFormFields("Password", "Password", _passwordText,
                    widget: null,
                    sufixIcon: IconButton(
                      icon: Icon(_isHidden ? Icons.visibility : Icons.visibility_off),
                      onPressed: () {
                        // This is the trick

                        _isHidden = !_isHidden;

                        (context as Element).markNeedsBuild();
                      },
                    ),
                    obscureText: _isHidden,
                    keyboardType: TextInputType.text,
                    textInputAction: TextInputAction.next, validator: (value) {
                  if (value!.isEmpty) {
                    return ("Password is required for login");
                  }
                }),
                addVerticalSpace(20),
                TextFormFields.textFormFields(
                    "Confirm Password", "Confirm Password", _confirmPasswordText,
                    widget: null,
                    sufixIcon: IconButton(
                      icon: Icon(_isHidden ? Icons.visibility : Icons.visibility_off),
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
                    return ("Confirm Password is required");
                  } else if (_confirmPasswordText.text != _passwordText.text) {
                    return "Password don't match";
                  }
                  return null;
                }),
                addVerticalSpace(20),
                ElevatedButtonStyle.elevatedButton("Sign Up", onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    StaffModel? user = StaffModel();
                    user.fullName = _nameText.text;
                    user.email = _emailText.text;
                    user.address = _addressText.text;
                    user.contactNumber = _contactText.text;
                    user.services = _servicesText.text;

                    context
                        .read<SignUpSignInControllerStaff>()
                        .signUp(_emailText.text, _passwordText.text, user, context);
                  }
                  print("Success!!!");
                  // Navigator.pushNamed(context, '/user-client-login-page');
                }),
                addVerticalSpace(20),
              ],
            ),
          ),
        ));
  }
}
