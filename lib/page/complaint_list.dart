// ignore_for_file: prefer_const_constructors, sized_box_for_whitespace, prefer_const_literals_to_create_immutables

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart';

import 'complaint_detail.dart';

class ComplaintList extends StatefulWidget {
  const ComplaintList({Key? key}) : super(key: key);

  @override
  State<ComplaintList> createState() => _ComplaintListState();
}

class _ComplaintListState extends State<ComplaintList> {
  List _listData = [];

  Future _fetchData() async {
    var response = await get(
      Uri.parse('https://sesarengan.afdlolnur.id/api/complaint'),
      headers: {
        "Accept": 'application/json',
        "Content-type": "application/x-www-form-urlencoded",
      },
    );

    setState(() {
      final jsonData = jsonDecode(response.body);
      _listData = jsonData['data']['data'];
    });
  }

  @override
  void initState() {
    _fetchData();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(
            Icons.navigate_before,
            size: 30,
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          'Pengaduan',
          style: GoogleFonts.poppins(
            fontSize: 20,
            fontWeight: FontWeight.w500,
            color: Colors.white,
          ),
        ),
        backgroundColor: Color(0XFF007461),
        //centerTitle: true,
      ),
      body: Container(
        width: MediaQuery.of(context).size.width,
        // padding: EdgeInsets.all(10),
        child: ListView.builder(
          padding: EdgeInsets.only(
            left: 8,
            right: 8,
            bottom: 10,
          ),
          //physics: BouncingScrollPhysics(),
          shrinkWrap: true,
          itemCount: _listData.length,
          itemBuilder: (context, index) {
            var idUser = _listData[index]['user_id'];
            var status = _listData[index]['status'];
            var idComplaint = _listData[index]['id'];
            var createdAt = _listData[index]['created_at'];
            var picturePath = _listData[index]['picture_path'];
            var caption = _listData[index]['caption']['caption'];
            var desc = _listData[index]['description'];
            var district = _listData[index]['district'];
            var _lat = _listData[index]['latitude'];
            var _long = _listData[index]['longitude'];
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
                constraints: BoxConstraints(
                  minHeight: 100,
                ),
                margin: EdgeInsets.only(top: 8),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(15),
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
                      leading: Container(
                        height: 40,
                        width: 40,
                        child: Container(
                          height: 40,
                          width: 40,
                          child: Image.asset('assets/icons/ava.png'),
                        ),
                      ),
                      title: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(
                            '#AWSB14${_listData[index]['id']}',
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
                            '${_listData[index]['created_at']}',
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
                            '${_listData[index]['status']}',
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
                      child: Container(
                        width: MediaQuery.of(context).size.width * 0.85,
                        height: 100,
                        child: Ink.image(
                          image: NetworkImage(
                            '${_listData[index]['picture_path']}',
                          ),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 18.0),
                      child: Text(
                        '${_listData[index]['caption']['caption']}',
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
                      padding: const EdgeInsets.only(left: 18.0),
                      child: Text(
                        '${_listData[index]['district']}',
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
                        left: 18.0,
                        right: 50,
                        bottom: 20,
                      ),
                      child: Text(
                        '${_listData[index]['description']}',
                        style: GoogleFonts.poppins(
                          fontSize: 13,
                          color: Colors.grey,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
          // separatorBuilder: (BuildContext context, int index) {
          //   return Divider(
          //     color: Color(0xffa38dbc),
          //   );
          // },
        ),
      ),
    );
  }
}
