// ignore_for_file: prefer_const_constructors, unnecessary_new, prefer_void_to_null, unused_field, prefer_final_fields, prefer_const_literals_to_create_immutables

import 'dart:async';
import 'dart:io';
import 'dart:convert';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:netizens/home.dart';
import 'package:netizens/page/registration/create_account.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  TextEditingController user = new TextEditingController();
  TextEditingController pass = new TextEditingController();

  bool _passObscure = true;
  bool isLoading = false;

  Future<Null> _login() async {
    try {
      if (user.text.isNotEmpty && pass.text.isNotEmpty) {
        var response = await http.post(
            Uri.parse('https://sesarengan.afdlolnur.id/api/login'),
            body: {
              //"status": '200',
              "email": user.text,
              "password": pass.text,
            }).timeout(const Duration(seconds: 2), onTimeout: () {
          throw TimeoutException(
              'The connection has timed out, Please try again!');
        });

        //print(response.statusCode);
        if (response.statusCode == 200) {
          final datauser = json.decode(response.body);
          var nama = datauser['data']['user']['name'];
          var id = datauser['data']['user']['id'];
          var token = datauser['data']['access_token'];
          SharedPreferences preferences = await SharedPreferences.getInstance();
          preferences.setString('nama', nama);
          preferences.setInt('id', id);
          preferences.setString('token', token);
          Fluttertoast.showToast(
              msg: "Login Sukses",
              toastLength: Toast.LENGTH_SHORT,
              timeInSecForIosWeb: 1,
              backgroundColor: Color.fromARGB(255, 229, 77, 77),
              textColor: Colors.white,
              fontSize: 16);
          Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(builder: (context) => HomePage()),
              (Route<dynamic> route) => false);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(new SnackBar(
            content: Text('Gagal login, anda belum terdaftar'),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(24),
            ),
            backgroundColor: Color.fromARGB(255, 231, 82, 72),
            margin: EdgeInsets.only(
                bottom: MediaQuery.of(context).size.height - 100,
                right: 10,
                left: 10),
          ));
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(new SnackBar(
          content: Text('Gagal login, data masih kosong'),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          backgroundColor: Color.fromARGB(255, 231, 82, 72),
          margin: EdgeInsets.only(
              bottom: MediaQuery.of(context).size.height - 100,
              right: 10,
              left: 10),
        ));
      }
    } on TimeoutException catch (_) {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error Gagal Terhubung ke Server')));
    } on SocketException catch (_) {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error, Periksa Koneksi Internet Anda')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      //backgroundColor: Color.fromARGB(255, 255, 255, 255),
      body: Container(
        margin: EdgeInsets.all(20),
        alignment: Alignment.center,
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              SizedBox(
                height: 10,
              ),
              Image.asset(
                'assets/images/logo.png',
                fit: BoxFit.cover,
                height: 45,
              ),
              SizedBox(
                height: 10,
              ),
              Text(
                "Be The Agent \nOf Change.",
                style: GoogleFonts.poppins(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              SizedBox(
                height: 5,
              ),
              Text(
                "Smart people, smart governance",
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey,
                  //fontWeight: FontWeight.w600,
                  // fontFamily: 'OpenSans',
                ),
              ),
              SizedBox(
                height: 10,
              ),
              SizedBox(
                width: 400,
                height: 150,
                child: Image.asset(
                  'assets/images/login.png',
                ),
              ),
              SizedBox(
                height: 10,
              ),
              Text(
                'Email',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Colors.black,
                ),
              ),
              SizedBox(
                height: 15,
              ),
              TextField(
                controller: user,
                decoration: InputDecoration(
                  prefixIcon: Icon(
                    Icons.email,
                    size: 20,
                    color: Color(0XFF007461).withOpacity(0.6),
                  ),
                  hintText: "Masukkan email",
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(color: Colors.grey),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(
                      color: Color(0XFF007461),
                    ),
                  ),
                ),
              ),
              SizedBox(
                height: 15,
              ),
              Text(
                'Password',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Colors.black,
                ),
              ),
              SizedBox(
                height: 15,
              ),
              TextField(
                controller: pass,
                obscureText: _passObscure,
                decoration: InputDecoration(
                  prefixIcon: Icon(
                    Icons.key,
                    size: 20,
                    color: Color(0XFF007461).withOpacity(0.6),
                  ),
                  suffixIcon: IconButton(
                    color: Color(0XFF007461).withOpacity(0.6),
                    icon: Icon(
                      _passObscure
                          ? Icons.visibility_off_outlined
                          : Icons.visibility_outlined,
                    ),
                    onPressed: () {
                      setState(() {
                        _passObscure = !_passObscure;
                      });
                    },
                  ),
                  hintText: "Masukkan password",
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(
                      color: Colors.grey,
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(
                      color: Color(0XFF007461),
                    ),
                  ),
                ),
              ),
              SizedBox(
                height: 10,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: <Widget>[
                  Text('Belum punya akun ?'),
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => CreateAccount(),
                        ),
                      );
                    },
                    child: Text(
                      'Daftar sekarang',
                      style: TextStyle(
                        decoration: TextDecoration.underline,
                        decorationThickness: 1.5,
                        fontSize: 15,
                      ),
                    ),
                  )
                ],
              ),
              SizedBox(
                height: 15,
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  primary: Color(0XFF007461),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  minimumSize: Size(450, 50),
                ),
                onPressed: () async {
                  if (isLoading) return;

                  setState(() => isLoading = true);
                  await Future.delayed(Duration(seconds: 2));
                  setState(() => isLoading = false);
                  _login();
                },
                child: isLoading
                    ? SizedBox(
                        height: 25,
                        width: 25,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                        ),
                      )
                    : Text(
                        'LOGIN',
                        style: TextStyle(fontSize: 18),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
