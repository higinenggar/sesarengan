// ignore_for_file: prefer_const_constructors, annotate_overrides, unnecessary_null_comparison, use_key_in_widget_constructors

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:netizens/home.dart';
import 'package:netizens/page/login.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  String? token = "";
  Future getLogin() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    setState(() {
      token = preferences.getString('token');
    });
  }

  void initState() {
    getLogin();
    super.initState();
    Timer(Duration(seconds: 3), () {
      if (token != null) {
        Navigator.of(context)
            .pushReplacement(MaterialPageRoute(builder: (_) => HomePage()));
      } else {
        Navigator.of(context)
            .pushReplacement(MaterialPageRoute(builder: (_) => LoginPage()));
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              'assets/images/NET.png',
              fit: BoxFit.cover,
              height: 45,
            ),
            SizedBox(
              height: 25,
            ),
            SizedBox(
              height: 20,
              width: 20,
              child: CircularProgressIndicator(
                color: Color(0XFF007461),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
