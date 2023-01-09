// ignore_for_file: prefer_const_constructors, avoid_unnecessary_containers, prefer_const_literals_to_create_immutables, must_be_immutable
import 'dart:async';
import 'dart:io';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:netizens/page/login.dart';

class ConfirmRegis extends StatefulWidget {
  final String _email;

  const ConfirmRegis(this._email, {Key? key}) : super(key: key);

  @override
  State<ConfirmRegis> createState() => _ConfirmRegisState();
}

class _ConfirmRegisState extends State<ConfirmRegis> {
  bool isLoading = false;

  TextEditingController otp1 = TextEditingController();
  TextEditingController otp2 = TextEditingController();
  TextEditingController otp3 = TextEditingController();
  TextEditingController otp4 = TextEditingController();
  TextEditingController otp5 = TextEditingController();
  TextEditingController otp6 = TextEditingController();

  Future<void> _submitOtp() async {
    try {
      var response = await http.post(
          Uri.parse('https://sesarengan.afdlolnur.id/api/submitotp'),
          body: {
            "email": widget._email,
            "otp": otp1.text +
                otp2.text +
                otp3.text +
                otp4.text +
                otp5.text +
                otp6.text,
          }).timeout(const Duration(seconds: 2), onTimeout: () {
        throw TimeoutException(
            'The connection has timed out, Please try again!');
      });

      // print(response.statusCode);
      if (response.statusCode == 200) {
        setState(() {
          Fluttertoast.showToast(
              msg: "Akun berhasil dibuat, silahkan login :)",
              toastLength: Toast.LENGTH_SHORT,
              timeInSecForIosWeb: 1,
              backgroundColor: Color.fromARGB(255, 229, 77, 77),
              textColor: Colors.white,
              fontSize: 16);
          Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(builder: (context) => LoginPage()),
              (Route<dynamic> route) => false);
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Kode OTP yang anda masukkan tidak sesuai'),
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

  Future<void> _requestOTP() async {
    var response = await http.post(
        Uri.parse('https://sesarengan.afdlolnur.id/api/otprequestulang'),
        body: {
          "email": widget._email,
        });

    if (response.statusCode == 200) {
      setState(() {
        Fluttertoast.showToast(
            msg: "OTP berhasil dikirim, silahkan cek email anda.",
            toastLength: Toast.LENGTH_SHORT,
            timeInSecForIosWeb: 1,
            backgroundColor: Color.fromARGB(255, 229, 77, 77),
            textColor: Colors.white,
            fontSize: 14);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Verifikasi Email',
          style: GoogleFonts.poppins(
            fontSize: 20,
            fontWeight: FontWeight.w500,
            color: Colors.white,
          ),
        ),
        leading: IconButton(
          icon: Icon(
            Icons.navigate_before,
            color: Colors.white,
            size: 35,
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
        backgroundColor: Color(0XFF007461),
      ),
      body: Container(
        margin: EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              'Kode Verifikasi',
              style: GoogleFonts.catamaran(
                fontSize: 25,
                fontWeight: FontWeight.bold,
                color: Color.fromARGB(255, 23, 54, 80),
              ),
            ),
            Text(
              'Kami telah mengirimkan kode verifikasi ke ',
              style: GoogleFonts.poppins(
                fontSize: 12,
                //fontWeight: FontWeight.w500,
                color: Colors.grey,
              ),
            ),
            SizedBox(
              height: 5,
            ),
            Text(
              widget._email
                  .replaceAll(RegExp('(?<=.)[^@](?=[^@]*?[^@]@)'), '*'),
              style: GoogleFonts.poppins(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Color.fromARGB(255, 23, 54, 80),
              ),
            ),
            SizedBox(
              height: 5,
            ),
            Text(
              'Jika anda tidak menerima email, cek folder spam',
              style: GoogleFonts.poppins(
                fontSize: 12,
                //fontWeight: FontWeight.w500,
                color: Colors.grey,
              ),
            ),
            SizedBox(
              height: 20,
            ),
            Form(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  SizedBox(
                    height: 58,
                    width: 54,
                    child: TextField(
                      controller: otp1,
                      onChanged: ((value) {
                        if (value.length == 1) {
                          FocusScope.of(context).nextFocus();
                        }
                      }),
                      decoration: InputDecoration(
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
                      style: Theme.of(context).textTheme.headline6,
                      keyboardType: TextInputType.number,
                      textAlign: TextAlign.center,
                      inputFormatters: [
                        LengthLimitingTextInputFormatter(1),
                        FilteringTextInputFormatter.digitsOnly,
                      ],
                    ),
                  ),
                  SizedBox(
                    height: 58,
                    width: 54,
                    child: TextField(
                      controller: otp2,
                      onChanged: ((value) {
                        if (value.length == 1) {
                          FocusScope.of(context).nextFocus();
                        }
                      }),
                      decoration: InputDecoration(
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
                      style: Theme.of(context).textTheme.headline6,
                      keyboardType: TextInputType.number,
                      textAlign: TextAlign.center,
                      inputFormatters: [
                        LengthLimitingTextInputFormatter(1),
                        FilteringTextInputFormatter.digitsOnly,
                      ],
                    ),
                  ),
                  SizedBox(
                    height: 58,
                    width: 54,
                    child: TextField(
                      controller: otp3,
                      onChanged: ((value) {
                        if (value.length == 1) {
                          FocusScope.of(context).nextFocus();
                        }
                      }),
                      decoration: InputDecoration(
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
                      style: Theme.of(context).textTheme.headline6,
                      keyboardType: TextInputType.number,
                      textAlign: TextAlign.center,
                      inputFormatters: [
                        LengthLimitingTextInputFormatter(1),
                        FilteringTextInputFormatter.digitsOnly,
                      ],
                    ),
                  ),
                  SizedBox(
                    height: 58,
                    width: 54,
                    child: TextField(
                      controller: otp4,
                      onChanged: ((value) {
                        if (value.length == 1) {
                          FocusScope.of(context).nextFocus();
                        }
                      }),
                      decoration: InputDecoration(
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
                      style: Theme.of(context).textTheme.headline6,
                      keyboardType: TextInputType.number,
                      textAlign: TextAlign.center,
                      inputFormatters: [
                        LengthLimitingTextInputFormatter(1),
                        FilteringTextInputFormatter.digitsOnly,
                      ],
                    ),
                  ),
                  SizedBox(
                    height: 58,
                    width: 54,
                    child: TextField(
                      controller: otp5,
                      onChanged: ((value) {
                        if (value.length == 1) {
                          FocusScope.of(context).nextFocus();
                        }
                      }),
                      decoration: InputDecoration(
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
                      style: Theme.of(context).textTheme.headline6,
                      keyboardType: TextInputType.number,
                      textAlign: TextAlign.center,
                      inputFormatters: [
                        LengthLimitingTextInputFormatter(1),
                        FilteringTextInputFormatter.digitsOnly,
                      ],
                    ),
                  ),
                  SizedBox(
                    height: 58,
                    width: 54,
                    child: TextField(
                      controller: otp6,
                      onChanged: ((value) {
                        if (value.length == 1) {
                          FocusScope.of(context).nextFocus();
                        }
                      }),
                      decoration: InputDecoration(
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
                      style: Theme.of(context).textTheme.headline6,
                      keyboardType: TextInputType.number,
                      textAlign: TextAlign.center,
                      inputFormatters: [
                        LengthLimitingTextInputFormatter(1),
                        FilteringTextInputFormatter.digitsOnly,
                      ],
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(
              height: 20,
            ),
            Row(
              children: [
                Text(
                  'Belum menerima OTP ?',
                  style: GoogleFonts.poppins(
                    fontSize: 13,
                    color: Colors.grey,
                  ),
                ),
                TextButton(
                  onPressed: () {
                    _requestOTP();
                  },
                  child: Text(
                    'Request Ulang',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Color.fromARGB(255, 23, 54, 80),
                      decoration: TextDecoration.underline,
                      decorationThickness: 1.5,
                      fontSize: 15,
                    ),
                  ),
                ),
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
                setState(() => isLoading = true);
                await Future.delayed(Duration(seconds: 2));
                setState(() => isLoading = false);
                _submitOtp();
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
                      'KIRIM',
                      style: TextStyle(fontSize: 18),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
