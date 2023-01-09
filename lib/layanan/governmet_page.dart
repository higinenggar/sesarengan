// ignore_for_file: prefer_const_constructors, non_constant_identifier_names

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:netizens/model/layanan_model/g_model.dart';
import 'package:url_launcher/url_launcher.dart';

class GoverPage extends StatefulWidget {
  const GoverPage({Key? key}) : super(key: key);

  @override
  State<GoverPage> createState() => _GoverPageState();
}

class _GoverPageState extends State<GoverPage> {
  static List<GovernModel> detail = detailMenu;

  @override
  Widget build(BuildContext context) => Scaffold(
        backgroundColor: Color.fromARGB(255, 243, 243, 243),
        appBar: AppBar(
          title: Text(
            'Smart Government',
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
            buildSearch(),
            Expanded(
              child: ListView.builder(
                physics: BouncingScrollPhysics(),
                padding: EdgeInsets.only(top: 10, left: 5, right: 5),
                itemCount: detail.length,
                itemBuilder: (context, index) {
                  return GestureDetector(
                    onTap: () async {
                      final url = Uri.parse(
                        detail[index].url.toString(),
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
                            borderRadius: BorderRadius.circular(15),
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
                            detail[index].image.toString(),
                            scale: 1.2,
                          ),
                        ),
                        title: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              detail[index].jenis.toString(),
                              style: TextStyle(
                                  fontSize: 14, color: Color(0XFF007461)),
                            ),
                            SizedBox(
                              height: 5,
                            ),
                            Text(
                              detail[index].title.toString(),
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(
                              height: 5,
                            ),
                            Text(
                              detail[index].description.toString(),
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
  Widget buildSearch() => Padding(
        padding: const EdgeInsets.only(top: 10, left: 10, right: 10),
        child: TextField(
          onChanged: searchMenu,
          decoration: InputDecoration(
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide.none,
              ),
              prefixIcon: Icon(
                Icons.search,
              ),
              hintText: 'Cari layanan...'),
        ),
      );

  void searchMenu(String query) {
    final suggestions = detailMenu.where((detail) {
      final menuTitle = detail.title.toLowerCase();
      final input = query.toLowerCase();

      return menuTitle.contains(input);
    }).toList();

    setState(() => detail = suggestions);
  }
}
