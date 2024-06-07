import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_firebase/screens/email_auth/login_screen.dart';
import 'package:flutter_firebase/screens/phone_auth/sign_in_with_phone.dart';

class Sign_Option extends StatefulWidget {
  const Sign_Option({Key? key}) : super(key: key);

  @override
  State<Sign_Option> createState() => _Sign_OptionState();
}

class _Sign_OptionState extends State<Sign_Option> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Sign In With",
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.cyan,
        centerTitle: true,
      ),
      body: Padding(
        padding: EdgeInsets.all(15),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            CupertinoButton(
              color: Colors.cyan,
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => LoginScreen()),
                );
              },
              child: Text('Email'),
            ),
            SizedBox(height: 20),
            CupertinoButton(
              color: Colors.cyan,
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => MyPhone()),
                );
              },
              child: Text('Phone Number'),
            ),
          ],
        ),
      ),
    );
  }
}