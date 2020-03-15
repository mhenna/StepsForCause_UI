import 'package:Steps4Cause/services/services.dart';
import 'package:flutter/material.dart';
import 'package:Steps4Cause/login.dart';
import 'package:Steps4Cause/register.dart';
import 'package:provider/provider.dart';

class MyLandingPage extends StatelessWidget {
  final style = TextStyle(fontFamily: 'Montserrat', fontSize: 20.0);

  Widget _facebookTest() {
    return Container(
      width: 60.0,
      height: 60.0,
      decoration: new BoxDecoration(
        shape: BoxShape.circle,
        image: new DecorationImage(
          image: new ExactAssetImage('assets/fb.png'),
          fit: BoxFit.cover,
        ),
      ),
    );
  }

  Widget _google() {
    return Container(
      width: 60.0,
      height: 60.0,
      decoration: new BoxDecoration(
        shape: BoxShape.circle,
        image: new DecorationImage(
          image: new ExactAssetImage('assets/google.png'),
          fit: BoxFit.cover,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
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
                child: new Text("OK"),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        },
      );
    }

    final loginButton = Material(
      elevation: 5.0,
      borderRadius: BorderRadius.circular(30.0),
      color: Color(0xff01A0C7),
      child: MaterialButton(
        minWidth: MediaQuery.of(context).size.width,
        padding: EdgeInsets.fromLTRB(20.0, 15.0, 20.0, 15.0),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => myLoginPage()),
          );
        },
        child: Text("Login",
            textAlign: TextAlign.center,
            style: style.copyWith(
                color: Colors.white, fontWeight: FontWeight.bold)),
      ),
    );
    final dellText = Material(
      elevation: 5.0,
      borderRadius: BorderRadius.circular(30.0),
      color: Color.fromRGBO(255, 255, 255, 0.1),
      child: Padding(
          padding: const EdgeInsets.only(top: 10.0),
          child: Column(
            children: <Widget>[
              Padding(
                  padding: const EdgeInsets.only(top: 20.0),
                  child: Container(
                    child: Image.asset("ICCA.png"),
                  )),
              Text("Powered By",
                  textAlign: TextAlign.center,
                  style: style.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 15)),
              Container(
                child: Image.asset("dell_logo.png"),
                width: 200,
              ),
            ],
          )),
    );
    final registerButton = Material(
      elevation: 5.0,
      borderRadius: BorderRadius.circular(30.0),
      color: Color(0xff01A0C7),
      child: MaterialButton(
        minWidth: MediaQuery.of(context).size.width,
        padding: EdgeInsets.fromLTRB(20.0, 15.0, 20.0, 15.0),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => RegisterPage()),
          );
        },
        child: Text("Register",
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
            padding: const EdgeInsets.only(left: 36.0, top: 66.0, right: 36.0, bottom: 10.0),
            child: ListView(
              children: <Widget>[
                SizedBox(
                  height: 35.0,
                ),
                loginButton,
                SizedBox(
                  height: 35.0,
                ),
                registerButton,
                SizedBox(
                  height: 15.0,
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 100, bottom: 180),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Padding(
                        padding: const EdgeInsets.only(right: 30),
                        child: InkWell(
                          onTap: () async {
                            final service =
                                Provider.of<Services>(context, listen: false);
                            await service.userService.signInWithFacebook();
                          },
                          child: _facebookTest(),
                        ),
                      ),
                      InkWell(
                        onTap: () {
                          final service =
                              Provider.of<Services>(context, listen: false);
                          service.userService.signInWithGoogle();
                        },
                        child: _google(),
                      )
                    ],
                  ),
                ),
                dellText
              ],
            ),
          ),
        ),
      ),
    );
  }
}
