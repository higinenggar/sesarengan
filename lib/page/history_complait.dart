// ignore_for_file: prefer_const_constructors, use_key_in_widget_constructors, unnecessary_null_comparison

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart';

import 'complaint_detail.dart';

class HistoryComplaint extends StatefulWidget {
  final String tokenAuth;

  const HistoryComplaint(this.tokenAuth);

  @override
  State<HistoryComplaint> createState() => _HistoryComplaintState();
}

class _HistoryComplaintState extends State<HistoryComplaint> {
  List _listHistory = [];

  Future _fetchHistory() async {
    var response = await get(
      Uri.parse(
        'https://sesarengan.afdlolnur.id/api/history',
      ),
      headers: {
        "Accept": "application/json",
        "Authorization": 'Bearer ' + widget.tokenAuth,
      },
    );

    setState(() {
      final jsonData = jsonDecode(response.body);
      _listHistory = jsonData['data'];
      print(_listHistory);
    });
  }

  @override
  void initState() {
    super.initState();
    _fetchHistory();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Riwayat Aduan',
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
        //centerTitle: true,
      ),
      body: SizedBox(
        width: MediaQuery.of(context).size.width,
        child: ListView.builder(
          shrinkWrap: true,
          padding: const EdgeInsets.only(
            left: 8,
            right: 8,
            bottom: 10,
          ),
          //physics: BouncingScrollPhysics(),
          itemCount: _listHistory.length,
          itemBuilder: (context, index) {
            var status = _listHistory[index]['status'];
            var idUser = _listHistory[index]['user_id'];
            var idComplaint = _listHistory[index]['id'];
            var createdAt = _listHistory[index]['created_at'];
            var picturePath = _listHistory[index]['picture_path'];
            var caption = _listHistory[index]['caption']['caption'];
            var desc = _listHistory[index]['description'];
            var district = _listHistory[index]['district'];
            var _lat = _listHistory[index]['latitude'];
            var _long = _listHistory[index]['longitude'];

            return GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => DetailComplaint(
                      idComplaint.toString(),
                      picturePath.toString(),
                      caption,
                      desc,
                      status,
                      idUser,
                      createdAt,
                      district,
                      _lat,
                      _long,
                    ),
                  ),
                );
              },
              child: Container(
                width: MediaQuery.of(context).size.width,
                constraints: BoxConstraints(
                  minHeight: 100,
                ),
                margin: EdgeInsets.only(top: 8),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(15),
                  //color: Colors.amber,
                  border: Border.all(
                    color: Colors.grey.withOpacity(0.4),
                    width: 2,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    ListTile(
                      leading: SizedBox(
                        height: 40,
                        width: 40,
                        child: SizedBox(
                          height: 40,
                          width: 40,
                          child: Image.asset('assets/icons/ava.png'),
                        ),
                      ),
                      title: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(
                            '#AWSB14${_listHistory[index]['id']}',
                            style: GoogleFonts.poppins(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                          ),
                          SizedBox(
                            height: 2,
                          ),
                          Text(
                            '${_listHistory[index]['created_at']}',
                            style: GoogleFonts.poppins(
                              fontSize: 12,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                      trailing: Container(
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: status == 'PENDING'
                                ? Colors.red
                                : status == 'DIKERJAKAN'
                                    ? Color.fromARGB(255, 255, 153, 0)
                                    : Colors.teal,
                          ),
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: Center(
                          child: Text(
                            '${_listHistory[index]['status']}',
                            style: GoogleFonts.poppins(
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                              color: status == 'PENDING'
                                  ? Colors.red
                                  : status == 'DIKERJAKAN'
                                      ? Color.fromARGB(255, 255, 153, 0)
                                      : Colors.teal,
                            ),
                          ),
                        ),
                        height: 30,
                        width: 70,
                      ),
                    ),
                    Center(
                      child: SizedBox(
                        width: MediaQuery.of(context).size.width * 0.85,
                        height: 100,
                        child: Ink.image(
                          image: NetworkImage(
                            '${_listHistory[index]['picture_path']}',
                          ),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 15.0),
                      child: Text(
                        '${_listHistory[index]['caption']['caption']}',
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 5,
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 15.0, right: 15),
                      child: Text(
                        '${_listHistory[index]['district']}',
                        style: GoogleFonts.poppins(
                          fontSize: 13,
                          color: Colors.black45,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    Padding(
                      padding: const EdgeInsets.only(
                        left: 15.0,
                        right: 50,
                        bottom: 20,
                      ),
                      child: Text(
                        '${_listHistory[index]['description']}',
                        style: GoogleFonts.poppins(
                          fontSize: 13,
                          color: Colors.grey,
                        ),
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                      ),
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
