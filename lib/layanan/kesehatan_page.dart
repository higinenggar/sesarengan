// ignore_for_file: prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:netizens/model/layanan_model/kesehatan_model.dart';
import 'package:url_launcher/url_launcher.dart';

class KesehatanPage extends StatefulWidget {
  const KesehatanPage({Key? key}) : super(key: key);

  @override
  State<KesehatanPage> createState() => _KesehatanPageState();
}

class _KesehatanPageState extends State<KesehatanPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Informasi Kesehatan',
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
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              physics: BouncingScrollPhysics(),
              padding: EdgeInsets.only(top: 10, left: 5, right: 5),
              itemCount: detailKes.length,
              itemBuilder: (context, index) {
                return GestureDetector(
                  onTap: () async {
                    final url = Uri.parse(
                      detailKes[index].url.toString(),
                    );

                    if (await canLaunchUrl(url)) {
                      await launchUrl(
                        url,
                        mode: LaunchMode.externalApplication,
                      );
                    }

                    var snackBar = SnackBar(content: Text(url.toString()));
                    ScaffoldMessenger.of(context).showSnackBar(snackBar);
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(15),
                      color: Colors.white,
                    ),
                    padding: EdgeInsets.only(top: 8, bottom: 8),
                    margin: EdgeInsets.only(bottom: 10),
                    child: ListTile(
                      leading: Container(
                        width: 57,
                        height: 80,
                        decoration: BoxDecoration(
                          color: Color.fromARGB(255, 255, 255, 255),
                          //borderRadius: BorderRadius.circular(15),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withOpacity(0.3),
                              spreadRadius: 2,
                              blurRadius: 3,
                              offset:
                                  Offset(0, 2), // changes position of shadow
                            ),
                          ],
                          border: Border.all(color: Colors.teal),
                        ),
                        child: Image.asset(
                          detailKes[index].images.toString(),
                          scale: 1.2,
                        ),
                      ),
                      title: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            detailKes[index].jenis.toString(),
                            style: TextStyle(
                                fontSize: 14, color: Color(0XFF007461)),
                          ),
                          SizedBox(
                            height: 5,
                          ),
                          Text(
                            detailKes[index].title.toString(),
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(
                            height: 5,
                          ),
                          Text(
                            detailKes[index].description.toString(),
                            style: TextStyle(
                              color: Colors.grey,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                      trailing: IconButton(
                        color: Colors.black87,
                        icon: Icon(
                          Icons.info_outline_rounded,
                        ),
                        onPressed: () async {},
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
