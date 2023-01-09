// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables, curly_braces_in_flow_control_structures, prefer_void_to_null
import 'dart:convert';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:netizens/page/registration/confirm_regis.dart';

class CreateAccount extends StatefulWidget {
  const CreateAccount({Key? key}) : super(key: key);

  @override
  State<CreateAccount> createState() => _CreateAccountState();
}

class _CreateAccountState extends State<CreateAccount> {
  bool isLoading = false;

  TextEditingController user = TextEditingController();
  TextEditingController email = TextEditingController();
  TextEditingController pass = TextEditingController();
  TextEditingController conpass = TextEditingController();

  bool _passObscure = true;
  bool _passObscure1 = true;

  final _formKey = GlobalKey<FormState>();

  Future<void> _requestOtp() async {
    var response = await http.post(
        Uri.parse('https://sesarengan.afdlolnur.id/api/register2'),
        body: {
          "name": user.text,
          "email": email.text,
          "password": pass.text,
          "password_confirmation": conpass.text,
        });

    print(response.statusCode);
    if (response.statusCode == 200) {
      final _userCreate = json.decode(response.body);

      //print(_userCreate);

      setState(() {
        var _email = _userCreate['data']['user']['email'];

        Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (context) => ConfirmRegis(_email)));
      });

      //disini

    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Gagal, email anda sudah pernah terdaftar sebelumnya'),
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
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        margin: EdgeInsets.all(25),
        padding: EdgeInsets.only(top: 30),
        alignment: Alignment.center,
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
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
                  "Selamat datang di\nSesarengan.",
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
                  "Sesarengan mbangun wonosobo.",
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey,
                    //fontWeight: FontWeight.w600,
                    // fontFamily: 'OpenSans',
                  ),
                ),
                SizedBox(
                  height: 20,
                ),
                SizedBox(
                  width: 400,
                  height: 140,
                  child: Image.asset(
                    'assets/images/mid.png',
                  ),
                ),
                SizedBox(
                  height: 15,
                ),
                Text(
                  'Nama',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: Colors.black,
                  ),
                ),
                SizedBox(
                  height: 10,
                ),
                TextFormField(
                  controller: user,
                  validator: (val) {
                    if (val!.isEmpty) return 'Nama tidak boleh kosong';
                    return null;
                  },
                  decoration: InputDecoration(
                    hintText: "Masukkan nama kamu",
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
                  'Email',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: Colors.black,
                  ),
                ),
                SizedBox(
                  height: 10,
                ),
                TextFormField(
                  controller: email,
                  validator: (val) {
                    if (val!.isEmpty) return 'Email tidak boleh kosong';
                    return null;
                  },
                  decoration: InputDecoration(
                    hintText: "Masukkan Email",
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
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Password',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: Colors.black,
                          ),
                        ),
                        SizedBox(
                          height: 5,
                        ),
                        SizedBox(
                          width: MediaQuery.of(context).size.width * 0.40,
                          child: TextFormField(
                            controller: pass,
                            obscureText: _passObscure,
                            validator: (val) {
                              if (val!.isEmpty) return 'Tidak boleh kosong';
                              if (val.length < 8)
                                return 'Minimal harus 8 karakter';
                              return null;
                            },
                            decoration: InputDecoration(
                              hintText: 'Password',
                              hintStyle: TextStyle(fontSize: 10),
                              suffixIcon: IconButton(
                                color: Color(0XFF007461).withOpacity(0.6),
                                icon: Icon(
                                  _passObscure
                                      ? Icons.visibility_off_outlined
                                      : Icons.visibility_outlined,
                                  size: 22,
                                ),
                                onPressed: () {
                                  setState(() {
                                    _passObscure = !_passObscure;
                                  });
                                },
                              ),
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
                        ),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Ulangi Password',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: Colors.black,
                          ),
                        ),
                        SizedBox(
                          height: 5,
                        ),
                        SizedBox(
                          width: MediaQuery.of(context).size.width * 0.40,
                          child: TextFormField(
                            controller: conpass,
                            validator: (val) {
                              if (val!.isEmpty) return 'Tidak boleh kosong';
                              if (val != pass.text)
                                return 'Password tidak sama';
                              return null;
                            },
                            obscureText: _passObscure1,
                            decoration: InputDecoration(
                              hintText: 'Ulangi password',
                              hintStyle: TextStyle(fontSize: 10),
                              suffixIcon: IconButton(
                                color: Color(0XFF007461).withOpacity(0.6),
                                icon: Icon(
                                  _passObscure1
                                      ? Icons.visibility_off_outlined
                                      : Icons.visibility_outlined,
                                  size: 22,
                                ),
                                onPressed: () {
                                  setState(() {
                                    _passObscure1 = !_passObscure1;
                                  });
                                },
                              ),
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
                        ),
                      ],
                    ),

                    // ? Padding(
                    //     padding: const EdgeInsets.only(
                    //       top: 10,
                    //     ),
                    //     child: Icon(
                    //       Icons.check_circle_rounded,
                    //       color: Color.fromARGB(255, 13, 107, 98),
                    //     ),
                    //   )
                    // : Padding(
                    //     padding: const EdgeInsets.only(top: 10.0),
                    //     child: Icon(
                    //       Icons.not_interested,
                    //       color: Colors.red,
                    //     ),
                    //   ),
                  ],
                ),
                SizedBox(
                  height: 20,
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
                    setState(() => isLoading = true);
                    await Future.delayed(Duration(seconds: 2));
                    setState(() => isLoading = false);
                    if (_formKey.currentState!.validate()) _requestOtp();
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
                          'DAFTAR',
                          style: TextStyle(fontSize: 18),
                        ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
