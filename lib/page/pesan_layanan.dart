// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart';

class PesanLayanan extends StatefulWidget {
  const PesanLayanan({Key? key}) : super(key: key);

  @override
  State<PesanLayanan> createState() => _PesanLayananState();
}

class _PesanLayananState extends State<PesanLayanan> {
  List _listPesan = [];

  Future _fetchMessage() async {
    var response = await get(
      Uri.parse('https://sesarengan.afdlolnur.id/api/article'),
      headers: {
        "Accept": "application/json",
      },
    );

    setState(() {
      final jsonData = jsonDecode(response.body);
      _listPesan = jsonData['data'];
    });
  }

  @override
  void initState() {
    super.initState();
    _fetchMessage();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Pesan Layanan Sesarengan',
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
      body: SizedBox(
        width: MediaQuery.of(context).size.width,
        child: ListView.builder(
          physics: BouncingScrollPhysics(),
          padding: EdgeInsets.only(
            left: 8,
            right: 8,
            bottom: 10,
          ),
          //physics: BouncingScrollPhysics(),
          shrinkWrap: true,
          itemCount: _listPesan.length,
          itemBuilder: (context, index) {
            return Container(
              constraints: BoxConstraints(
                minHeight: 100,
              ),
              margin: EdgeInsets.only(top: 8),
              decoration: BoxDecoration(
                color: Color(0XFFf1fbf3),
                borderRadius: BorderRadius.circular(15),
                border: Border.all(
                  color: Color.fromARGB(255, 87, 161, 125).withOpacity(0.4),
                  width: 1.5,
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.only(
                  left: 15.0,
                  right: 15,
                  bottom: 20,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    ListTile(
                      leading: Image.asset(
                        'assets/icons/pemkab.png',
                        //fit: BoxFit.cover,
                        height: 45,
                      ),
                      title: Text(
                        'Wonosobo Smart Service',
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Color.fromARGB(255, 23, 54, 80),
                        ),
                      ),
                      subtitle: Text(
                        '${_listPesan[index]['created_at']}',
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          fontWeight: FontWeight.w400,
                          color: Colors.grey,
                        ),
                      ),
                    ),
                    Divider(
                      thickness: 1,
                      //color: Colors.black,
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    Text(
                      '${_listPesan[index]['description']}',
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        fontWeight: FontWeight.w400,
                        color: Colors.black,
                      ),
                      textAlign: TextAlign.justify,
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
