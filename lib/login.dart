import 'dart:async';

import 'package:flutter/material.dart';
import 'package:Steps4Cause/services/user.dart';
import 'package:password/password.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
// import 'package:flutter_dotenv/flutter_dotenv.dart';

class myLoginPage extends StatefulWidget {
  myLoginPage({Key key, this.title}) : super(key: key);
  final String title;
  // This widget is the root of your application.
  @override
  myLoginPageState createState() => myLoginPageState();
}

class myLoginPageState extends State<myLoginPage> {
  TextStyle style =
      TextStyle(fontFamily: 'Montserrat', fontSize: 20.0, color: Colors.white);

  String token;
  var ip;
  var port;

  void initState() {
    super.initState();
    setEnv();
  }

  Future setEnv() async {
    // await DotEnv().load('.env');
    // port = DotEnv().env['PORT'];
    // ip = DotEnv().env['SERVER_IP'];
  }

  final unController = TextEditingController();
  final pwController = TextEditingController();
  final algorithm = PBKDF2();

  @override
  void dispose() {
    // Clean up the controller when the widget is disposed.
    unController.dispose();
    pwController.dispose();
    super.dispose();
  }

  String hashPassword(pw) {
    final hash = Password.hash(pw, algorithm);
    return hash;
  }

  @override
  Widget build(BuildContext context) {
    final emailField = TextField(
      controller: unController,
      obscureText: false,
      style: style,
      decoration: InputDecoration(
          contentPadding: EdgeInsets.fromLTRB(20.0, 15.0, 20.0, 15.0),
          hintStyle: TextStyle(fontSize: 20.0, color: Colors.white),
          hintText: "Email",
          enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(32.0),
              borderSide: const BorderSide(color: Colors.white))),
    );
    final passwordField = TextField(
      controller: pwController,
      obscureText: true,
      style: style,
      decoration: InputDecoration(
          contentPadding: EdgeInsets.fromLTRB(20.0, 15.0, 20.0, 15.0),
          hintText: "Password",
          hintStyle: TextStyle(fontSize: 20.0, color: Colors.white),
          enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(32.0),
              borderSide: const BorderSide(color: Colors.white))),
    );
    final loginButton = Material(
      elevation: 5.0,
      borderRadius: BorderRadius.circular(30.0),
      color: Color(0xff01A0C7),
      child: MaterialButton(
        minWidth: MediaQuery.of(context).size.width,
        padding: EdgeInsets.fromLTRB(20.0, 15.0, 20.0, 15.0),
        onPressed: () {
          login(unController.text, pwController.text);
        },
        child: Text("Login",
            textAlign: TextAlign.center,
            style: style.copyWith(
                color: Colors.white, fontWeight: FontWeight.bold)),
      ),
    );

    return Scaffold(
      body: Center(
        child: Container(
          decoration: BoxDecoration(
            image: DecorationImage(
              image: AssetImage("assets/background.jpeg"),
              fit: BoxFit.cover,
            ),
          ),
          child: Padding(
              padding: const EdgeInsets.all(36.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  SizedBox(height: 45.0),
                  emailField,
                  SizedBox(height: 25.0),
                  passwordField,
                  SizedBox(
                    height: 35.0,
                  ),
                  loginButton,
                  SizedBox(
                    height: 15.0,
                  ),
                ],
              )),
        ),
      ),
    );
  }

  void setToken(t) async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setString('token', t);
  }

  void login(email, pw) async {
//    var ip = await EnvironmentUtil.getEnvValueForKey('SERVER_IP');
//    print(ip)
    final userService = Provider.of<UserService>(context, listen: false);

    try {
      var u = await userService.signInWithEmailandPassword(email, pw);
      if (!u.isEmailVerified)
        _showDialog("Verification", "Please verify your email first.");
      else
        Navigator.pop(context);
    } catch (e) {
      _showDialog("Incorrect!", "Email or Password is incorrect!");
    }
  }

  void _showDialog(head, err) {
    // flutter defined function
    showDialog(
      context: context,
      builder: (BuildContext context) {
        // return object of type Dialog
        return AlertDialog(
          title: new Text(head),
          content: new Text(err),
          actions: <Widget>[
            // usually buttons at the bottom of the dialog
            new FlatButton(
              child: new Text("Close"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}
