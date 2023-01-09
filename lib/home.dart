// ignore_for_file: prefer_const_literals_to_create_immutables, prefer_const_constructors, prefer_const_declarations, must_call_super, unused_local_variable, unrelated_type_equality_checks, avoid_print, sized_box_for_whitespace, prefer_typing_uninitialized_variables, unnecessary_new
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:bottom_navy_bar/bottom_navy_bar.dart';
import 'package:netizens/layanan/governmet_page.dart';
import 'package:netizens/layanan/kesehatan_page.dart';
import 'package:netizens/page/complaint_detail.dart';
import 'package:netizens/page/complaint_list.dart';
import 'package:netizens/page/history_complait.dart';
import 'package:netizens/page/login.dart';
import 'package:netizens/page/pesan_layanan.dart';
import 'package:netizens/page/report_page.dart';
import 'package:netizens/page/splash.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';
import 'model/carousel_model.dart';
import 'package:syncfusion_flutter_barcodes/barcodes.dart';
import 'package:geocoding/geocoding.dart';
import 'dart:convert';
import 'package:http/http.dart';
import 'package:shimmer/shimmer.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<Tab> tabs = [
    Tab(
      text: "Data Akun",
    ),
    Tab(
      text: "Kode QR",
    )
  ];

  int index = 0;
  bool isLoaded = false;
  var kotamark = "";
  var kota = "";
  String? address;
  var hour = DateTime.now().hour;
  var _greeting = "";
  List _listData = [];

  String? nama;
  int heightToBeReduced = 380;

  late final String tokenAuth;
  String? idUser;
  String? emailUser;

  late YoutubePlayerController controller;

  @override
  void deactivate() {
    controller.pause();

    super.deactivate();
  }

  @override
  void dispose() {
    controller.dispose();

    super.dispose();
  }

  void launchWhatsapp({@required number, @required message}) async {
    final url = Uri.parse('whatsapp://send?phone=$number&text=$message');

    if (await canLaunchUrl(url)) {
      await launchUrl(
        url,
        mode: LaunchMode.externalApplication,
      );
    }
  }

  Future getLogin() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    String? token;
    setState(
      () {
        nama = preferences.getString('nama');
        token = preferences.getString('token');
        print('ini token $token');
        if (token != null) {
          tokenAuth = token!;
        }
      },
    );
  }

  void _logout() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    String? token;
    setState(
      () {
        token = preferences.getString('token');
      },
    );
    var response = await post(
      Uri.parse('https://sesarengan.afdlolnur.id/api/logout'),
      headers: {
        "Accept": "application/json",
        "Authorization": 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      preferences.remove('token');
      Fluttertoast.showToast(
          msg: "Logout Berhasil",
          toastLength: Toast.LENGTH_SHORT,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.red,
          textColor: Colors.white,
          fontSize: 16);
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => SplashScreen(),
        ),
      );
    }
  }

  Future _fetchUser() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    String? token;
    setState(
      () {
        token = preferences.getString('token');
        print('ini token $token');
      },
    );
    var response = await get(
      Uri.parse('https://sesarengan.afdlolnur.id/api/user'),
      headers: {
        "Accept": "application/json",
        "Authorization": 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      setState(() {
        final jsonData = jsonDecode(response.body);
        idUser = jsonData['data']['id'].toString();
        emailUser = jsonData['data']['email'];
        //print(emailUser);
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        new SnackBar(
          content: Text(
            'Sesi anda telah berakhir, silahkan login',
            textAlign: TextAlign.center,
          ),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          backgroundColor: Color.fromARGB(255, 215, 80, 80),
        ),
      );
      controller.pause();
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => LoginPage(),
        ),
      );
    }
  }

  Future _fetchData() async {
    var response = await get(
      Uri.parse('https://sesarengan.afdlolnur.id/api/complaint'),
      headers: {
        "Accept": 'application/json',
        "Content-type": "application/x-www-form-urlencoded",
      },
    );

    //print(_listData);
    if (mounted) {
      setState(() {
        final jsonData = jsonDecode(response.body);
        _listData = jsonData['data']['data'];
        isLoaded = true;
      });
    }
  }

  Future _fetchJadwal() async {
    if (hour <= 12) {
      _greeting = 'Selamat Pagi';
    } else if ((hour > 12) && (hour <= 16)) {
      _greeting = 'Selamat Siang';
    } else if ((hour > 16) && (hour < 20)) {
      _greeting = 'Selamat Sore';
    } else {
      _greeting = 'Selamat Malam';
    }

    LocationPermission permission = await Geolocator.requestPermission();
    Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);

    List<Placemark> placemarks =
        await placemarkFromCoordinates(position.latitude, position.longitude);
    //print(placemarks);
    setState(() {
      kota = placemarks.first.locality!;
      kotamark = placemarks.first.subLocality!;
      address = kota + ', ' + kotamark;
    });
  }

  Future refresh() async {
    await Future.delayed(const Duration(seconds: 1), () {
      setState(() {
        _fetchData();
      });
    });
  }

  @override
  void initState() {
    super.initState();
    getLogin();
    _fetchData();
    _fetchJadwal();
    _fetchUser();
    final url = "https://www.youtube.com/watch?v=avjK8zYutqQ";
    controller = YoutubePlayerController(
      initialVideoId: YoutubePlayer.convertUrlToId(url)!,
      flags: const YoutubePlayerFlags(
        autoPlay: true,
        mute: false,
        loop: false,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      //backgroundColor: Color.fromARGB(255, 223, 29, 29),
      body: buildPages(),
      bottomNavigationBar: buildBottomNavigation(),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          if (controller.value.isPlaying) {
            controller.pause();
          }
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const ReportPage()),
          );
        },
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.camera_enhance_sharp,
            ),
          ],
        ),
        backgroundColor: Color(0XFF007461),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }

  Widget buildPages() {
    switch (index) {
      case 1:
        return Scaffold(
          appBar: AppBar(
            automaticallyImplyLeading: false,
            backgroundColor: Colors.transparent,
            elevation: 0,
            title: Image.asset(
              'assets/images/NET.png',
              fit: BoxFit.cover,
              height: 30,
            ),
            //centerTitle: true,
          ),
          body: Container(
            width: MediaQuery.of(context).size.width,
            margin: EdgeInsets.all(10),
            child: ListView(
              physics: BouncingScrollPhysics(),
              children: [
                Container(
                  height: 200,
                  width: MediaQuery.of(context).size.width,
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(15),
                      color: Colors.white,
                      border:
                          Border.all(color: Color.fromARGB(255, 31, 83, 77))),
                  child: Row(
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(left: 8.0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              margin: EdgeInsets.only(left: 10),
                              height: 110,
                              width: 110,
                              child: Image.asset('assets/icons/ava.png'),
                            ),
                            SizedBox(
                              height: 5,
                            ),
                            TextButton.icon(
                              icon: const Icon(Icons.camera_alt),
                              label: const Text('Ganti Foto'),
                              onPressed: () {
                                Fluttertoast.showToast(
                                    msg: "Fitur masih dalam tahap pengembangan",
                                    toastLength: Toast.LENGTH_SHORT,
                                    timeInSecForIosWeb: 1,
                                    backgroundColor:
                                        Color.fromARGB(255, 229, 77, 77),
                                    textColor: Colors.white,
                                    fontSize: 16);
                              },
                              style: TextButton.styleFrom(
                                fixedSize: Size.fromHeight(20),
                                primary: Color.fromARGB(255, 23, 54, 80),
                                backgroundColor: Colors.grey.withOpacity(0.2),
                                shape: const RoundedRectangleBorder(
                                  borderRadius: BorderRadius.all(
                                    Radius.circular(15),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(
                        width: 10,
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top: 25.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              constraints: BoxConstraints(
                                maxWidth: 230,
                              ),
                              padding: EdgeInsets.only(right: 13.0),
                              child: Text(
                                nama ?? 'kosong',
                                style: GoogleFonts.libreFranklin(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: Color.fromARGB(255, 23, 54, 80),
                                ),
                              ),
                            ),
                            SizedBox(
                              height: 10,
                            ),
                            Container(
                              height: 40,
                              width: 100,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(12),
                                color: Color(0xffe0f2f2),
                              ),
                              child: Center(
                                child: Text(
                                  'NWS-510$idUser',
                                  style: GoogleFonts.libreFranklin(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w500,
                                    color: Color(0XFF007461),
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ),
                            SizedBox(
                              height: 15,
                            ),
                            Text(
                              'Warga [WONOSOBO]',
                              style: GoogleFonts.libreFranklin(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: Color.fromARGB(255, 23, 54, 80),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(
                  height: 35,
                ),
                DefaultTabController(
                  length: tabs.length,
                  child: Column(
                    children: [
                      TabBar(
                        indicatorSize: TabBarIndicatorSize.tab,
                        indicatorWeight: 2,
                        //isScrollable: true,
                        labelColor: Colors.white,
                        unselectedLabelColor: Colors.grey,
                        labelStyle: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            fontFamily: 'OpenSans'),
                        unselectedLabelStyle: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            fontFamily: 'OpenSans'),
                        indicator: BoxDecoration(
                          borderRadius:
                              BorderRadius.circular(20), // Creates border
                          color: Color(0XFF007461),
                        ),
                        tabs: tabs,
                      ),
                      SizedBox(
                        height: 500,
                        child: TabBarView(
                          children: [
                            Column(
                              children: [
                                ListTile(
                                  leading: Icon(
                                    Icons.person_outline_outlined,
                                    size: 25,
                                  ),
                                  title: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Padding(
                                        padding:
                                            const EdgeInsets.only(top: 10.0),
                                        child: Text(
                                          'Username',
                                          style: TextStyle(
                                            fontSize: 14,
                                            color: Colors.grey,
                                          ),
                                        ),
                                      ),
                                      SizedBox(
                                        height: 10,
                                      ),
                                      Text(
                                        '$nama',
                                        style: GoogleFonts.libreFranklin(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w400,
                                          color:
                                              Color.fromARGB(255, 23, 54, 80),
                                        ),
                                      ),
                                    ],
                                  ),
                                  trailing: IconButton(
                                    icon: Icon(Icons.edit),
                                    onPressed: () {},
                                  ),
                                ),
                                ListTile(
                                  leading: Icon(
                                    Icons.email_outlined,
                                    size: 25,
                                  ),
                                  title: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Padding(
                                        padding:
                                            const EdgeInsets.only(top: 10.0),
                                        child: Text(
                                          'Email',
                                          style: TextStyle(
                                            fontSize: 14,
                                            color: Colors.grey,
                                          ),
                                        ),
                                      ),
                                      SizedBox(
                                        height: 10,
                                      ),
                                      Text(
                                        '$emailUser',
                                        style: GoogleFonts.libreFranklin(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w400,
                                          color:
                                              Color.fromARGB(255, 23, 54, 80),
                                        ),
                                      ),
                                    ],
                                  ),
                                  trailing: IconButton(
                                    icon: Icon(Icons.edit),
                                    onPressed: () {},
                                  ),
                                ),
                                ListTile(
                                  leading: Icon(
                                    Icons.location_on,
                                    size: 25,
                                  ),
                                  title: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Padding(
                                        padding:
                                            const EdgeInsets.only(top: 10.0),
                                        child: Text(
                                          'Alamat',
                                          style: TextStyle(
                                            fontSize: 14,
                                            color: Colors.grey,
                                          ),
                                        ),
                                      ),
                                      SizedBox(
                                        height: 10,
                                      ),
                                      Text(
                                        'Kosong',
                                        style: GoogleFonts.libreFranklin(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w400,
                                          color:
                                              Color.fromARGB(255, 23, 54, 80),
                                        ),
                                      ),
                                    ],
                                  ),
                                  trailing: IconButton(
                                    icon: Icon(Icons.edit),
                                    onPressed: () {},
                                  ),
                                ),
                                ListTile(
                                  leading: Icon(
                                    Icons.phone_android_outlined,
                                    size: 25,
                                  ),
                                  title: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Padding(
                                        padding:
                                            const EdgeInsets.only(top: 10.0),
                                        child: Text(
                                          'Nomor HP',
                                          style: TextStyle(
                                            fontSize: 14,
                                            color: Colors.grey,
                                          ),
                                        ),
                                      ),
                                      SizedBox(
                                        height: 10,
                                      ),
                                      Text(
                                        'Belum diisi',
                                        style: GoogleFonts.libreFranklin(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w400,
                                          color:
                                              Color.fromARGB(255, 23, 54, 80),
                                        ),
                                      ),
                                    ],
                                  ),
                                  trailing: IconButton(
                                    icon: Icon(Icons.edit),
                                    onPressed: () {},
                                  ),
                                ),
                                SizedBox(
                                  height: 20,
                                ),
                                TextButton(
                                  style: TextButton.styleFrom(
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    primary: Colors.white,
                                    backgroundColor: Color(0xffe0f2f2),
                                    minimumSize: const Size(320, 52),
                                    //elevation: 20,
                                  ),
                                  onPressed: () {
                                    Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) =>
                                                HistoryComplaint(tokenAuth)));
                                  },
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.post_add_outlined,
                                        color: Color(0XFF007461),
                                      ),
                                      SizedBox(
                                        width: 15,
                                      ),
                                      Text(
                                        'Riwayat Aduan',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: Color(0XFF007461),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            viewQRcode(),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );

      case 0:
      default:
        return Scaffold(
          //backgroundColor: Color.fromARGB(255, 230, 230, 230),
          appBar: AppBar(
            automaticallyImplyLeading: false,
            backgroundColor: Colors.transparent,
            elevation: 0,
            title: Image.asset(
              'assets/images/NET.png',
              fit: BoxFit.cover,
              height: 30,
            ),
            //centerTitle: true,
            actions: [
              IconButton(
                onPressed: () {},
                icon: Icon(Icons.sort),
                color: Color(0XFF007461),
              )
            ],
          ),
          body: RefreshIndicator(
            onRefresh: refresh,
            color: Color(0XFF007461),
            child: Container(
              width: MediaQuery.of(context).size.width,
              //padding: EdgeInsets.all(15),
              child: ListView(
                padding: EdgeInsets.all(15),
                physics: BouncingScrollPhysics(),
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: <Widget>[
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    _greeting,
                                    style: GoogleFonts.libreFranklin(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.grey,
                                    ),
                                  ),
                                  Text(
                                    nama ?? 'kosong',
                                    style: GoogleFonts.libreFranklin(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0XFF007461),
                                    ),
                                  ),
                                  address != null
                                      ? Text(
                                          address ?? 'kosong',
                                          style: GoogleFonts.libreFranklin(
                                            fontSize: 13,
                                            fontWeight: FontWeight.w400,
                                            color: Colors.grey,
                                          ),
                                        )
                                      : Shimmer.fromColors(
                                          baseColor:
                                              Color.fromARGB(255, 14, 14, 14),
                                          highlightColor:
                                              Color.fromARGB(255, 25, 25, 25),
                                          period: Duration(seconds: 3),
                                          child: SizedBox(
                                            height: 10,
                                            width: 120,
                                          ),
                                        ),
                                ],
                              ),
                              Row(
                                children: [
                                  CircleAvatar(
                                    backgroundColor: Colors.grey,
                                    radius: 19.2,
                                    child: CircleAvatar(
                                      backgroundColor: Colors.white,
                                      radius: 18,
                                      child: IconButton(
                                        iconSize: 20,
                                        onPressed: () {
                                          Navigator.of(context).push(
                                            MaterialPageRoute(
                                              builder: (_) => PesanLayanan(),
                                            ),
                                          );
                                        },
                                        icon: Icon(
                                          Icons.message,
                                        ),
                                        color: Color(0XFF007461),
                                      ),
                                    ),
                                  ),
                                  SizedBox(
                                    width: 15,
                                  ),
                                  CircleAvatar(
                                    backgroundColor: Colors.grey,
                                    radius: 19.2,
                                    child: CircleAvatar(
                                      backgroundColor: Colors.white,
                                      radius: 18,
                                      child: IconButton(
                                        iconSize: 20,
                                        onPressed: () {},
                                        icon: Icon(
                                          Icons.help_outline_rounded,
                                        ),
                                        color: Color(0XFF007461),
                                      ),
                                    ),
                                  ),
                                  SizedBox(
                                    width: 15,
                                  ),
                                  CircleAvatar(
                                    backgroundColor: Colors.grey,
                                    radius: 19.2,
                                    child: CircleAvatar(
                                      backgroundColor: Colors.white,
                                      radius: 18,
                                      child: IconButton(
                                        iconSize: 20,
                                        onPressed: () {
                                          if (controller.value.isPlaying) {
                                            controller.pause();
                                          }
                                          _logout();
                                        },
                                        icon: Icon(
                                          Icons.logout_outlined,
                                        ),
                                        color: Color(0XFF007461),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ],
                      ),
                      SizedBox(
                        height: 15,
                      ),
                      SizedBox(
                        // color: Colors.black,
                        height: 160,
                        width: MediaQuery.of(context).size.width,
                        child: CarouselSlider.builder(
                          options: CarouselOptions(
                            autoPlay: true,
                            viewportFraction: 1.0,
                          ),
                          itemCount: carousels.length,
                          itemBuilder: (context, index, realIndex) {
                            return Stack(
                              children: [
                                Container(
                                  width: MediaQuery.of(context).size.width,
                                  height: 180,
                                  margin: EdgeInsets.only(right: 8),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(10),
                                    image: DecorationImage(
                                        image: AssetImage(
                                          carousels[index].image.toString(),
                                        ),
                                        fit: BoxFit.cover),
                                  ),
                                ),
                              ],
                            );
                          },
                        ),
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      Text(
                        'Layanan',
                        style: GoogleFonts.libreFranklin(
                          fontSize: 19,
                          fontWeight: FontWeight.bold,
                          color: Color(0XFF007461),
                        ),
                      ),
                      Text(
                        'Cari informasi seputar Wonosobo',
                        style: GoogleFonts.libreFranklin(
                          fontSize: 13,
                          //fontWeight: FontWeight.bold,
                          color: Colors.grey,
                        ),
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      Container(
                        constraints: BoxConstraints(
                          maxHeight: 200,
                        ),
                        child: GridView(
                          physics: NeverScrollableScrollPhysics(),
                          padding: EdgeInsets.only(top: 3),
                          //shrinkWrap: true,
                          gridDelegate:
                              SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 4,
                            childAspectRatio: 1.8 / 2.3,
                            mainAxisSpacing: 14,
                            crossAxisSpacing: 25,
                          ),
                          children: [
                            GestureDetector(
                                child: CategoryCard(
                                  title: 'Government',
                                  images: 'assets/icons/g.png',
                                ),
                                onTap: () {
                                  if (controller.value.isPlaying) {
                                    controller.pause();
                                  }
                                  Navigator.of(context).push(MaterialPageRoute(
                                      builder: (_) => GoverPage()));
                                }),
                            GestureDetector(
                              child: CategoryCard(
                                title: "Society",
                                images: 'assets/icons/smart.png',
                              ),
                              onTap: () {
                                showDialog(
                                  context: context,
                                  builder: (context) => AlertDialog(
                                    title: Text(
                                      'Smart Society',
                                      style: GoogleFonts.robotoSlab(
                                        fontSize: 19,
                                        fontWeight: FontWeight.bold,
                                        color: Color(0XFF173650),
                                      ),
                                    ),
                                    content: Container(
                                      constraints: BoxConstraints(
                                        maxHeight: 100,
                                      ),
                                      width: MediaQuery.of(context).size.width,
                                      child: GestureDetector(
                                        onTap: () async {
                                          final url = Uri.parse(
                                            'https://www.youtube.com/watch?v=2Lis3l5m3uA',
                                          );

                                          if (await canLaunchUrl(url)) {
                                            await launchUrl(
                                              url,
                                              mode: LaunchMode
                                                  .externalApplication,
                                            );
                                          }
                                        },
                                        child: Column(
                                          children: [
                                            ListTile(
                                              leading: Container(
                                                width: 57,
                                                height: 80,
                                                decoration: BoxDecoration(
                                                  color: Color.fromARGB(
                                                      255, 255, 255, 255),
                                                  borderRadius:
                                                      BorderRadius.circular(15),
                                                  boxShadow: [
                                                    BoxShadow(
                                                      color: Colors.grey
                                                          .withOpacity(0.3),
                                                      spreadRadius: 2,
                                                      blurRadius: 3,
                                                      offset: Offset(0,
                                                          2), // changes position of shadow
                                                    ),
                                                  ],
                                                  border: Border.all(
                                                      color: Colors.teal),
                                                ),
                                                child: Icon(
                                                  Icons.voice_chat,
                                                  color: Color(0XFF57bab1),
                                                ),
                                              ),
                                              title: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    'Smart Society',
                                                    style: TextStyle(
                                                        fontSize: 14,
                                                        color:
                                                            Color(0XFF007461)),
                                                  ),
                                                  SizedBox(
                                                    height: 5,
                                                  ),
                                                  Text(
                                                    'Hoax Crisis Centre',
                                                    style: TextStyle(
                                                      fontWeight:
                                                          FontWeight.bold,
                                                    ),
                                                  ),
                                                  SizedBox(
                                                    height: 5,
                                                  ),
                                                  Text(
                                                    'Lawan hoax',
                                                    style: TextStyle(
                                                      color: Colors.grey,
                                                      fontSize: 13,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),
                            GestureDetector(
                              child: CategoryCard(
                                title: "Branding",
                                images: 'assets/icons/branding.png',
                              ),
                              onTap: () {},
                            ),
                            GestureDetector(
                              child: CategoryCard(
                                title: "Environment",
                                images: 'assets/icons/envi.png',
                              ),
                              onTap: () {
                                showDialog(
                                  context: context,
                                  builder: (context) => AlertDialog(
                                    title: Text(
                                      'Smart Environment',
                                      style: GoogleFonts.robotoSlab(
                                        fontSize: 19,
                                        fontWeight: FontWeight.bold,
                                        color: Color(0XFF173650),
                                      ),
                                    ),
                                    content: Container(
                                      constraints: BoxConstraints(
                                        maxHeight: 100,
                                      ),
                                      width: MediaQuery.of(context).size.width,
                                      child: GestureDetector(
                                        onTap: () async {
                                          final url = Uri.parse(
                                            'https://www.youtube.com/watch?v=1N0q17ghqao',
                                          );

                                          if (await canLaunchUrl(url)) {
                                            await launchUrl(
                                              url,
                                              mode: LaunchMode
                                                  .externalApplication,
                                            );
                                          }
                                        },
                                        child: Column(
                                          children: [
                                            ListTile(
                                              leading: Container(
                                                width: 57,
                                                height: 80,
                                                decoration: BoxDecoration(
                                                  color: Color.fromARGB(
                                                      255, 255, 255, 255),
                                                  borderRadius:
                                                      BorderRadius.circular(15),
                                                  boxShadow: [
                                                    BoxShadow(
                                                      color: Colors.grey
                                                          .withOpacity(0.3),
                                                      spreadRadius: 2,
                                                      blurRadius: 3,
                                                      offset: Offset(0,
                                                          2), // changes position of shadow
                                                    ),
                                                  ],
                                                  border: Border.all(
                                                      color: Colors.teal),
                                                ),
                                                child: Icon(
                                                  Icons.recycling,
                                                  color: Color(0XFF57bab1),
                                                ),
                                              ),
                                              title: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    'Smart Environment',
                                                    style: TextStyle(
                                                        fontSize: 14,
                                                        color:
                                                            Color(0XFF007461)),
                                                  ),
                                                  SizedBox(
                                                    height: 5,
                                                  ),
                                                  Text(
                                                    'Wonosobo Ben Resik',
                                                    style: TextStyle(
                                                      fontWeight:
                                                          FontWeight.bold,
                                                    ),
                                                  ),
                                                  SizedBox(
                                                    height: 5,
                                                  ),
                                                  Text(
                                                    'Lingkungan Bersih dan Sehat',
                                                    style: TextStyle(
                                                      color: Colors.grey,
                                                      fontSize: 13,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),
                            GestureDetector(
                              child: CategoryCard(
                                title: "Economy",
                                images: 'assets/icons/eco.png',
                              ),
                              onTap: () {
                                showDialog(
                                  context: context,
                                  builder: (context) => AlertDialog(
                                    title: Text(
                                      'Smart Environment',
                                      style: GoogleFonts.robotoSlab(
                                        fontSize: 19,
                                        fontWeight: FontWeight.bold,
                                        color: Color(0XFF173650),
                                      ),
                                    ),
                                    content: Container(
                                      constraints: BoxConstraints(
                                        maxHeight: 100,
                                      ),
                                      width: MediaQuery.of(context).size.width,
                                      child: GestureDetector(
                                        onTap: () async {
                                          final url = Uri.parse(
                                            'https://www.youtube.com/watch?v=2Lis3l5m3uA',
                                          );

                                          if (await canLaunchUrl(url)) {
                                            await launchUrl(
                                              url,
                                              mode: LaunchMode
                                                  .externalApplication,
                                            );
                                          }
                                        },
                                        child: Column(
                                          children: [
                                            ListTile(
                                              leading: Container(
                                                width: 57,
                                                height: 80,
                                                decoration: BoxDecoration(
                                                  color: Color.fromARGB(
                                                      255, 255, 255, 255),
                                                  borderRadius:
                                                      BorderRadius.circular(15),
                                                  boxShadow: [
                                                    BoxShadow(
                                                      color: Colors.grey
                                                          .withOpacity(0.3),
                                                      spreadRadius: 2,
                                                      blurRadius: 3,
                                                      offset: Offset(0,
                                                          2), // changes position of shadow
                                                    ),
                                                  ],
                                                  border: Border.all(
                                                      color: Colors.teal),
                                                ),
                                                child: Icon(
                                                  Icons.recycling,
                                                  color: Color(0XFF57bab1),
                                                ),
                                              ),
                                              title: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    'Smart Economy',
                                                    style: TextStyle(
                                                        fontSize: 14,
                                                        color:
                                                            Color(0XFF007461)),
                                                  ),
                                                  SizedBox(
                                                    height: 5,
                                                  ),
                                                  Text(
                                                    'Harga Pokok',
                                                    style: TextStyle(
                                                      fontWeight:
                                                          FontWeight.bold,
                                                    ),
                                                  ),
                                                  SizedBox(
                                                    height: 5,
                                                  ),
                                                  Text(
                                                    'Cek harga kebutuhan pokok',
                                                    style: TextStyle(
                                                      color: Colors.grey,
                                                      fontSize: 13,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),
                            GestureDetector(
                              child: CategoryCard(
                                title: "Smart Living",
                                images: 'assets/icons/living.png',
                              ),
                              onTap: () {
                                showDialog(
                                  context: context,
                                  builder: (context) => AlertDialog(
                                    title: Text(
                                      'Smart Living',
                                      style: GoogleFonts.robotoSlab(
                                        fontSize: 19,
                                        fontWeight: FontWeight.bold,
                                        color: Color(0XFF173650),
                                      ),
                                    ),
                                    content: Container(
                                      constraints: BoxConstraints(
                                        maxHeight: 200,
                                      ),
                                      width: MediaQuery.of(context).size.width,
                                      child: GestureDetector(
                                        onTap: () async {
                                          final url = Uri.parse(
                                            'https://www.youtube.com/watch?v=2Lis3l5m3uA',
                                          );

                                          if (await canLaunchUrl(url)) {
                                            await launchUrl(
                                              url,
                                              mode: LaunchMode
                                                  .externalApplication,
                                            );
                                          }
                                        },
                                        child: Column(
                                          children: [
                                            //satu
                                            ListTile(
                                              leading: Container(
                                                width: 57,
                                                height: 80,
                                                decoration: BoxDecoration(
                                                  color: Color.fromARGB(
                                                      255, 255, 255, 255),
                                                  borderRadius:
                                                      BorderRadius.circular(15),
                                                  boxShadow: [
                                                    BoxShadow(
                                                      color: Colors.grey
                                                          .withOpacity(0.3),
                                                      spreadRadius: 2,
                                                      blurRadius: 3,
                                                      offset: Offset(0,
                                                          2), // changes position of shadow
                                                    ),
                                                  ],
                                                  border: Border.all(
                                                      color: Colors.teal),
                                                ),
                                                child: Icon(
                                                  Icons.connected_tv,
                                                  color: Color(0XFF57bab1),
                                                ),
                                              ),
                                              title: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    'Smart Living',
                                                    style: TextStyle(
                                                        fontSize: 14,
                                                        color:
                                                            Color(0XFF007461)),
                                                  ),
                                                  SizedBox(
                                                    height: 5,
                                                  ),
                                                  Text(
                                                    'CCTV Wonosobo',
                                                    style: TextStyle(
                                                      fontWeight:
                                                          FontWeight.bold,
                                                    ),
                                                  ),
                                                  SizedBox(
                                                    height: 5,
                                                  ),
                                                  Text(
                                                    'Pantau CCTV Wonosobo',
                                                    style: TextStyle(
                                                      color: Colors.grey,
                                                      fontSize: 13,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                            SizedBox(
                                              height: 10,
                                            ),
                                            ListTile(
                                              leading: Container(
                                                width: 57,
                                                height: 80,
                                                decoration: BoxDecoration(
                                                  color: Color.fromARGB(
                                                      255, 255, 255, 255),
                                                  borderRadius:
                                                      BorderRadius.circular(15),
                                                  boxShadow: [
                                                    BoxShadow(
                                                      color: Colors.grey
                                                          .withOpacity(0.3),
                                                      spreadRadius: 2,
                                                      blurRadius: 3,
                                                      offset: Offset(0,
                                                          2), // changes position of shadow
                                                    ),
                                                  ],
                                                  border: Border.all(
                                                      color: Colors.teal),
                                                ),
                                                child: Icon(
                                                  Icons.web,
                                                  color: Color(0XFF57bab1),
                                                ),
                                              ),
                                              title: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    'Smart Living',
                                                    style: TextStyle(
                                                        fontSize: 14,
                                                        color:
                                                            Color(0XFF007461)),
                                                  ),
                                                  SizedBox(
                                                    height: 5,
                                                  ),
                                                  Text(
                                                    'Kebencanaan',
                                                    style: TextStyle(
                                                      fontWeight:
                                                          FontWeight.bold,
                                                    ),
                                                  ),
                                                  SizedBox(
                                                    height: 5,
                                                  ),
                                                  Text(
                                                    'Pantauan Bencana Kabupaten Wonosobo',
                                                    style: TextStyle(
                                                      color: Colors.grey,
                                                      fontSize: 13,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),
                            GestureDetector(
                              child: CategoryCard(
                                title: "Darurat",
                                images: 'assets/icons/warning.png',
                              ),
                              onTap: () {
                                showDialog(
                                  context: context,
                                  builder: (context) => AlertDialog(
                                    title: Text(
                                      'Gawat Darurat',
                                      style: GoogleFonts.robotoSlab(
                                        fontSize: 19,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.red,
                                      ),
                                    ),
                                    content: Container(
                                      constraints: BoxConstraints(
                                        maxHeight: 200,
                                      ),
                                      width: MediaQuery.of(context).size.width,
                                      child: GestureDetector(
                                        onTap: () async {
                                          final url = Uri.parse(
                                            'https://www.youtube.com/watch?v=2Lis3l5m3uA',
                                          );

                                          if (await canLaunchUrl(url)) {
                                            await launchUrl(
                                              url,
                                              mode: LaunchMode
                                                  .externalApplication,
                                            );
                                          }
                                        },
                                        child: Column(
                                          children: [
                                            //satu
                                            GestureDetector(
                                              child: ListTile(
                                                leading: Container(
                                                  width: 57,
                                                  height: 80,
                                                  decoration: BoxDecoration(
                                                    color: Color.fromARGB(
                                                        255, 255, 255, 255),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            15),
                                                    boxShadow: [
                                                      BoxShadow(
                                                        color: Colors.grey
                                                            .withOpacity(0.3),
                                                        spreadRadius: 2,
                                                        blurRadius: 3,
                                                        offset: Offset(0,
                                                            2), // changes position of shadow
                                                      ),
                                                    ],
                                                    border: Border.all(
                                                        color: Colors.red),
                                                  ),
                                                  child: Icon(
                                                    Icons.dangerous,
                                                    color: Colors.red,
                                                  ),
                                                ),
                                                title: Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    Text(
                                                      'Gawat Darurat',
                                                      style: TextStyle(
                                                          fontSize: 14,
                                                          color: Colors.red),
                                                    ),
                                                    SizedBox(
                                                      height: 5,
                                                    ),
                                                    Text(
                                                      'Ambulance SIJAGO',
                                                      style: TextStyle(
                                                        fontWeight:
                                                            FontWeight.bold,
                                                      ),
                                                    ),
                                                    SizedBox(
                                                      height: 5,
                                                    ),
                                                    Text(
                                                      'Ambulance Gratis Siap Jemput',
                                                      style: TextStyle(
                                                        color: Colors.grey,
                                                        fontSize: 13,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              onTap: () {
                                                print('cek');
                                                launchWhatsapp(
                                                    number: "+628112721118",
                                                    message: "Halo SIJAGO");
                                              },
                                            ),
                                            SizedBox(
                                              height: 10,
                                            ),
                                            ListTile(
                                              leading: Container(
                                                width: 57,
                                                height: 80,
                                                decoration: BoxDecoration(
                                                  color: Color.fromARGB(
                                                      255, 255, 255, 255),
                                                  borderRadius:
                                                      BorderRadius.circular(15),
                                                  boxShadow: [
                                                    BoxShadow(
                                                      color: Colors.grey
                                                          .withOpacity(0.3),
                                                      spreadRadius: 2,
                                                      blurRadius: 3,
                                                      offset: Offset(0,
                                                          2), // changes position of shadow
                                                    ),
                                                  ],
                                                  border: Border.all(
                                                      color: Colors.red),
                                                ),
                                                child: Icon(
                                                  Icons.fire_hydrant,
                                                  color: Colors.red,
                                                ),
                                              ),
                                              title: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    'Gawat Darurat',
                                                    style: TextStyle(
                                                        fontSize: 14,
                                                        color: Colors.red),
                                                  ),
                                                  SizedBox(
                                                    height: 5,
                                                  ),
                                                  Text(
                                                    'PSC 119',
                                                    style: TextStyle(
                                                      fontWeight:
                                                          FontWeight.bold,
                                                    ),
                                                  ),
                                                  SizedBox(
                                                    height: 5,
                                                  ),
                                                  Text(
                                                    'Panggilan gawat darurat',
                                                    style: TextStyle(
                                                      color: Colors.grey,
                                                      fontSize: 13,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),
                            GestureDetector(
                              child: CategoryCard(
                                title: "Lainnya",
                                images: 'assets/icons/lain.png',
                              ),
                              onTap: () {
                                showDialog(
                                  context: context,
                                  builder: (context) => AlertDialog(
                                    title: Text(
                                      'Lainnya',
                                      style: GoogleFonts.robotoSlab(
                                        fontSize: 19,
                                        fontWeight: FontWeight.bold,
                                        color: Color(0XFF173650),
                                      ),
                                    ),
                                    content: Container(
                                      constraints: BoxConstraints(
                                        maxHeight: 100,
                                      ),
                                      width: MediaQuery.of(context).size.width,
                                      child: GestureDetector(
                                        onTap: () async {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) =>
                                                  KesehatanPage(),
                                            ),
                                          );
                                        },
                                        child: Column(
                                          children: [
                                            ListTile(
                                              leading: Container(
                                                width: 57,
                                                height: 80,
                                                decoration: BoxDecoration(
                                                  color: Color.fromARGB(
                                                      255, 255, 255, 255),
                                                  borderRadius:
                                                      BorderRadius.circular(15),
                                                  boxShadow: [
                                                    BoxShadow(
                                                      color: Colors.grey
                                                          .withOpacity(0.3),
                                                      spreadRadius: 2,
                                                      blurRadius: 3,
                                                      offset: Offset(0,
                                                          2), // changes position of shadow
                                                    ),
                                                  ],
                                                  border: Border.all(
                                                      color: Colors.teal),
                                                ),
                                                child: Icon(
                                                  Icons.health_and_safety,
                                                  color: Color(0XFF57bab1),
                                                ),
                                              ),
                                              title: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    'Informasi Kesehatan',
                                                    style: TextStyle(
                                                        fontSize: 14,
                                                        color:
                                                            Color(0XFF007461)),
                                                  ),
                                                  SizedBox(
                                                    height: 5,
                                                  ),
                                                  Text(
                                                    'Kesehatan',
                                                    style: TextStyle(
                                                      fontWeight:
                                                          FontWeight.bold,
                                                    ),
                                                  ),
                                                  SizedBox(
                                                    height: 5,
                                                  ),
                                                  Text(
                                                    'Informasi layanan kesehatan',
                                                    style: TextStyle(
                                                      color: Colors.grey,
                                                      fontSize: 13,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                      SizedBox(
                        height: 5,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Wonosobo WEB TV',
                            style: GoogleFonts.libreFranklin(
                              fontSize: 19,
                              fontWeight: FontWeight.bold,
                              color: Color(0XFF007461),
                            ),
                          ),
                          TextButton(
                            child: Text(
                              'Official WEB TV',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            style: TextButton.styleFrom(
                              primary: Color(0XFF007461),
                              side: BorderSide(
                                  color: Color(0XFF007461), width: 1.5),
                              shape: const RoundedRectangleBorder(
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(10))),
                            ),
                            onPressed: () async {
                              final Uri _url = Uri.parse(
                                  'https://www.youtube.com/channel/UC4tNqFlp_od17EE9HfBQQ3A');
                              if (await canLaunchUrl(_url)) {
                                await launchUrl(
                                  _url,
                                  mode: LaunchMode.externalApplication,
                                );
                              }
                            },
                          )
                        ],
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      YoutubePlayerBuilder(
                        player: YoutubePlayer(
                          controller: controller,
                        ),
                        builder: (context, player) {
                          return Stack(
                            alignment: Alignment.center,
                            children: [
                              Container(
                                width: MediaQuery.of(context).size.width,
                                height: 200,
                                child: player,
                              ),
                            ],
                          );
                        },
                      ),
                      SizedBox(
                        height: 18,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Aduan Masyarakat',
                                style: GoogleFonts.libreFranklin(
                                  fontSize: 19,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0XFF007461),
                                ),
                              ),
                              Text(
                                'Pantau aduan masyarakat',
                                style: GoogleFonts.libreFranklin(
                                  fontSize: 13,
                                  //fontWeight: FontWeight.bold,
                                  color: Colors.grey,
                                ),
                              ),
                            ],
                          ),
                          TextButton(
                            child: Text(
                              'Lihat semua',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            style: TextButton.styleFrom(
                              primary: Color(0XFF007461),
                              side: BorderSide(
                                  color: Color(0XFF007461), width: 1.5),
                              shape: const RoundedRectangleBorder(
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(10))),
                            ),
                            onPressed: () {
                              if (controller.value.isPlaying) {
                                controller.pause();
                              }
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => ComplaintList()),
                              );
                            },
                          ),
                        ],
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      Hero(
                        tag: 'aduan',
                        child: viewAduan(),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
    }
  }

  Widget viewAduan() => isLoaded
      ? Container(
          constraints: BoxConstraints(maxHeight: 210),
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            physics: BouncingScrollPhysics(),
            shrinkWrap: true,
            itemCount: _listData.length <= 8 ? _listData.length : 8,
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
                  if (controller.value.isPlaying) {
                    controller.pause();
                  }
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
                  margin: EdgeInsets.only(right: 15),
                  width: 160,
                  child: Stack(
                    alignment: Alignment.topCenter,
                    children: [
                      Ink.image(
                        height: 160,
                        image: NetworkImage(
                          '${_listData[index]['picture_path']}',
                        ),
                        fit: BoxFit.cover,
                      ),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            decoration: BoxDecoration(
                              color: status == 'PENDING'
                                  ? Colors.red
                                  : status == 'DITERIMA'
                                      ? Color.fromARGB(255, 255, 153, 0)
                                      : status == 'DIKERJAKAN'
                                          ? Colors.blueAccent
                                          : Colors.teal,
                              borderRadius: BorderRadius.only(
                                bottomRight: Radius.circular(10),
                              ),
                            ),
                            child: Center(
                              child: Text(
                                '${_listData[index]['status']}',
                                style: GoogleFonts.libreFranklin(
                                  fontSize: 9.8,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                            height: 25,
                            width: 65,
                          ),
                        ],
                      ),
                      Positioned(
                        top: 90,
                        //bottom: 10,
                        left: 5,
                        right: 3,
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Container(
                            height: 50,
                            width: MediaQuery.of(context).size.width,
                            color: Colors.black.withOpacity(0.4),
                            child: Padding(
                              padding: const EdgeInsets.all(5.0),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    '${_listData[index]['caption']['caption']}',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 13.5,
                                      fontWeight: FontWeight.w600,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                    maxLines: 2,
                                    textAlign: TextAlign.start,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                      Positioned(
                        top: 165,
                        left: 5,
                        child: Text(
                          '${_listData[index]['created_at']}',
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 10.5,
                            fontWeight: FontWeight.w600,
                          ),
                          textAlign: TextAlign.start,
                        ),
                      ),
                      Positioned(
                        top: 180,
                        left: 5,
                        child: SizedBox(
                          width: 150,
                          child: Text(
                            '${_listData[index]['description']}',
                            style: TextStyle(
                              color: Colors.grey,
                              fontSize: 10.5,
                              //fontWeight: FontWeight.w600,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            textAlign: TextAlign.start,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        )
      : Shimmer.fromColors(
          baseColor: Color.fromARGB(255, 177, 177, 177),
          highlightColor: Color.fromARGB(255, 192, 192, 192),
          period: Duration(seconds: 3),
          child: Container(
            height: 200,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              physics: BouncingScrollPhysics(),
              shrinkWrap: true,
              itemCount: _listData.length <= 8 ? _listData.length : 8,
              itemBuilder: (BuildContext context, index) {
                return Container(
                  margin: EdgeInsets.only(right: 15),
                  width: 160,
                  child: Stack(
                    alignment: Alignment.topCenter,
                    children: [
                      Container(
                        height: 160,
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        );

  Widget viewQRcode() => Container(
        padding: EdgeInsets.only(top: 20),
        height: MediaQuery.of(context).size.height * 0.40,
        //padding: EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            //SizedBox(height: MediaQuery.of(context).size.height * 0.020),
            Column(
              children: <Widget>[
                SizedBox(
                  height: 260,
                  child: SfBarcodeGenerator(
                    value: 'NWS-510$idUser',
                    symbology: QRCode(),
                    //showValue: true,
                  ),
                ),
                SizedBox(
                  height: 15,
                ),
              ],
            ),
          ],
        ),
      );

  Widget buildBottomNavigation() {
    final inactiveColor = Colors.grey;
    return BottomNavyBar(
      selectedIndex: index,
      onItemSelected: (index) => setState(() => this.index = index),
      items: <BottomNavyBarItem>[
        BottomNavyBarItem(
          icon: Icon(Icons.home),
          title: Text('Home'),
          textAlign: TextAlign.center,
          activeColor: Color(0XFF007461),
          inactiveColor: inactiveColor,
        ),
        BottomNavyBarItem(
          icon: Icon(Icons.person_sharp),
          title: Text('Akun'),
          textAlign: TextAlign.center,
          activeColor: Color(0XFF007461),
          inactiveColor: inactiveColor,
        ),
      ],
    );
  }
}

class CategoryCard extends StatelessWidget {
  final String title;
  final String images;
  const CategoryCard({
    Key? key,
    required this.title,
    required this.images,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          height: 55,
          width: 55,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(15),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.3),
                spreadRadius: 2,
                blurRadius: 3,
                offset: Offset(0, 2), // changes position of shadow
              ),
            ],
          ),
          child: Image.asset(
            images,
            scale: 1.5,
          ),
        ),
        SizedBox(
          height: 10,
        ),
        Text(
          title,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontFamily: 'libreFranklin',
            fontWeight: FontWeight.w500,
            color: Color.fromARGB(255, 6, 77, 65),
            fontSize: 12,
          ),
        ),
      ],
    );
  }
}
