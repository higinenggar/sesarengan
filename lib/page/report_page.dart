// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables, unused_field, avoid_print, unnecessary_const, empty_catches, unnecessary_new, unnecessary_null_comparison, avoid_function_literals_in_foreach_calls, unnecessary_brace_in_string_interps
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart';
import 'package:image_picker/image_picker.dart';
import 'package:netizens/home.dart';
import 'package:netizens/model/caption_model.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shimmer/shimmer.dart';
import 'dart:io';
import 'dart:async';
import 'package:http/http.dart' as http;
import 'package:sliding_up_panel/sliding_up_panel.dart';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter_native_image/flutter_native_image.dart';

class ReportPage extends StatefulWidget {
  const ReportPage({Key? key}) : super(key: key);

  @override
  State<ReportPage> createState() => _ReportPageState();
}

class _ReportPageState extends State<ReportPage> {
  final Completer<GoogleMapController> googleMapController = Completer();

  static const double fabHeightClosed = 130.0;
  double fabHeight = fabHeightClosed;
  final List<Marker> markers = <Marker>[];

  File? fileimage;
  String? imageName;
  String? imageData;

  bool isLoading = false;

  final _captionText = TextEditingController();
  final _descText = TextEditingController();
  String? selectedRadio;
  String? choice;
  bool isChecked = false;

  var _check = "";

  var kotamark = "";
  var kec = "";
  var kab = "";

  String? address;

  String? _idCaption;
  String? _latitude;
  String? _longitude;

  var id = "";
  String? token;

  final _formKey = GlobalKey<FormState>();

  Future getLogin() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    setState(() {
      id = preferences.getInt('id').toString();
      token = preferences.getString('token');
    });
  }

  Future _fetchLoc() async {
    getCurrentLocation().then((value) async {
      markers.add(
        Marker(
          markerId: MarkerId('2'),
          position: LatLng(value.latitude, value.longitude),
          infoWindow: InfoWindow(
            title: 'My Current Location',
          ),
        ),
      );
      CameraPosition cameraPosition = CameraPosition(
          zoom: 14, target: LatLng(value.latitude, value.longitude));

      final GoogleMapController controller = await googleMapController.future;
      List<Placemark> placemarks =
          await placemarkFromCoordinates(value.latitude, value.longitude);
      //print(placemarks);
      setState(() {
        kotamark = placemarks.first.subLocality!;
        kec = placemarks.first.locality!;
        kab = placemarks.first.subAdministrativeArea!;
        address = kotamark + ', ' + kec + ', ' + kab;
        controller
            .animateCamera(CameraUpdate.newCameraPosition(cameraPosition));
        _latitude = value.latitude.toString();
        _longitude = value.longitude.toString();
      });
    });
  }

  static final CameraPosition initialCameraPosition =
      CameraPosition(target: LatLng(-7.3633, 109.8985), zoom: 14);

  Future<Position> getCurrentLocation() async {
    await Geolocator.requestPermission()
        .then((value) {})
        .onError((error, stackTrace) {
      print('error' + error.toString());
    });
    return await Geolocator.getCurrentPosition();
  }

  setSelectedRadio(String? value) {
    setState(() {
      selectedRadio = value;
      switch (value) {
        case '1':
          choice = value;
          break;
        case '2':
          choice = value;
          break;
        default:
          choice = null;
      }
      print(choice);
    });
  }

  final ImagePicker _picker = ImagePicker();

  Future<File> customCompressed({
    required File imagePathToCompress,
    quality = 100,
    percentage = 30,
  }) async {
    var path = FlutterNativeImage.compressImage(
      imagePathToCompress.absolute.path,
      quality: 100,
      percentage: 30,
    );
    return path;
  }

  Future<void> getImage() async {
    final XFile? imagePicked = await _picker.pickImage(
        source: ImageSource.camera, maxHeight: 1500, maxWidth: 1500);
    File image = File(imagePicked!.path);
    final sizebefore = image.lengthSync() / 1024;
    print("sebelum ${sizebefore}Kb");
    File compressedImage = await customCompressed(imagePathToCompress: image);
    final after = compressedImage.lengthSync() / 1024;
    print("setelah ${after}Kb");
    setState(() {
      fileimage = compressedImage;
    });
  }

  Future<void> postComplaint() async {
    var headers = {
      'Accept': 'application/json',
      //'Authorization': 'Bearer $token',
      'Content-Type': 'application/x-www-form-urlencoded'
    };

    final uri = Uri.parse("https://sesarengan.afdlolnur.id/api/complaint");
    var request = http.MultipartRequest('POST', uri);
    var pic =
        await http.MultipartFile.fromPath("picture_path", fileimage!.path);
    request.fields["user_id"] = id;
    request.fields["description"] = _descText.text;
    request.files.add(pic);
    request.fields["latitude"] = _latitude!;
    request.fields["longitude"] = _longitude!;
    request.fields["district"] = address!;
    request.fields["is_public"] = choice!;
    request.fields["is_anon"] = _check;
    request.fields["caption_id"] = _idCaption!;

    request.headers.addAll(headers);
    var response = await request.send();

    print(response.statusCode);

    if (response.statusCode == 200) {
      ScaffoldMessenger.of(context).showSnackBar(
        new SnackBar(
          content: Text(
            'Aduan berhasil dikirim',
            textAlign: TextAlign.center,
          ),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          backgroundColor: Color.fromARGB(255, 215, 80, 80),
        ),
      );
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => HomePage(),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        new SnackBar(
          content: Text(
            "Gagal kirim aduan",
            textAlign: TextAlign.center,
          ),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          backgroundColor: Color.fromARGB(255, 1, 110, 100),
        ),
      );
    }
  }

  @override
  void initState() {
    super.initState();
    _fetchLoc();
    getLogin();
  }

  @override
  Widget build(BuildContext context) {
    final panelHeightOpen = MediaQuery.of(context).size.height * 0.75;
    final panelHeightClosed = MediaQuery.of(context).size.height * 0.13;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(
            Icons.navigate_before,
            color: Colors.white,
            size: 35,
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          'Google Maps Location',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
          ),
        ),
        backgroundColor: Color(0XFF007461),
        elevation: 2,
      ),
      body: Stack(
        alignment: Alignment.topCenter,
        children: <Widget>[
          SlidingUpPanel(
            maxHeight: panelHeightOpen,
            minHeight: panelHeightClosed,
            parallaxEnabled: true,
            parallaxOffset: .5,
            body: GoogleMap(
              //myLocationEnabled: true,
              initialCameraPosition: initialCameraPosition,
              markers: Set<Marker>.of(markers),
              zoomControlsEnabled: false,
              mapType: MapType.normal,
              onMapCreated: (GoogleMapController controller) {
                googleMapController.complete(controller);
              },
            ),
            panelBuilder: (sc) => _panel(sc),
            borderRadius: BorderRadius.vertical(
              top: Radius.circular(18),
            ),
            onPanelSlide: (position) => setState(() {
              final panelMaxScroll = panelHeightOpen - panelHeightClosed;

              fabHeight = position * panelMaxScroll + fabHeightClosed;
            }),
          ),
          Positioned(
            right: 20,
            bottom: fabHeight,
            child: buildFloatingButton(context),
          ),
        ],
      ),
    );
  }

  Widget _panel(ScrollController sc) {
    return MediaQuery.removeViewPadding(
      context: context,
      removeTop: true,
      child: ListView(
        keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
        controller: sc,
        children: <Widget>[
          SizedBox(
            height: 12,
          ),
          buildHandle(),
          buildForm(),
        ],
      ),
    );
  }

  Widget buildHandle() => Center(
        child: Container(
          width: 30,
          height: 5,
          decoration: BoxDecoration(
            color: Colors.grey[300],
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );

  Widget buildForm() => Container(
        padding: EdgeInsets.all(15),
        child: Column(
          children: [
            Center(
              child: Text(
                'Your Location',
                style: GoogleFonts.sourceSansPro(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color(0XFF007461),
                ),
              ),
            ),
            SizedBox(
              height: 8,
            ),
            Center(
              child: kab != ''
                  ? Text(
                      kotamark + ", " + kec + ", " + kab,
                      style: GoogleFonts.sourceSansPro(
                        fontSize: 13,
                        //fontWeight: FontWeigh,
                        color: Color.fromARGB(252, 34, 71, 64),
                      ),
                      textAlign: TextAlign.center,
                    )
                  : Shimmer.fromColors(
                      baseColor: Color.fromARGB(255, 14, 14, 14),
                      highlightColor: Color.fromARGB(255, 25, 25, 25),
                      period: Duration(seconds: 3),
                      child: SizedBox(
                        height: 10,
                        width: 120,
                      ),
                    ),
            ),
            SizedBox(
              height: 45,
            ),
            Center(
              child: Text(
                'Pilih caption aduan',
                style: GoogleFonts.sourceSansPro(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: Color(0XFF007461),
                ),
              ),
            ),
            SizedBox(
              height: 5,
            ),
            DropdownSearch<Caption>(
              mode: Mode.BOTTOM_SHEET,
              showSearchBox: true,
              dropdownSearchDecoration: InputDecoration(
                border: OutlineInputBorder(
                  borderSide: const BorderSide(color: Colors.grey, width: 2.0),
                  borderRadius: BorderRadius.circular(8.0),
                ),
                //enabledBorder: InputBorder.none,
                focusedBorder: OutlineInputBorder(
                  borderSide:
                      const BorderSide(color: Colors.blueAccent, width: 2.0),
                  borderRadius: BorderRadius.circular(8.0),
                ),
                hintText: 'Pilih Caption',
              ),
              onChanged: (value) => print(_idCaption = value?.id.toString()),
              dropdownBuilder: (context, selectedItem) =>
                  Text(selectedItem?.caption ?? "Silahkan Pilih Caption Aduan"),
              popupItemBuilder: (context, item, isSelected) => ListTile(
                title: Text(item.caption),
              ),
              onFind: (text) async {
                var response = await get(
                  Uri.parse('https://sesarengan.afdlolnur.id/api/caption'),
                  headers: {
                    "Accept": 'application/json',
                    "Content-type": "application/x-www-form-urlencoded",
                  },
                );

                if (response.statusCode != 200) {
                  return [];
                }
                List allCaption = (json.decode(response.body)
                    as Map<String, dynamic>)["data"]["data"];
                List<Caption> allModelCaption = [];

                allCaption.forEach((element) {
                  allModelCaption.add(Caption(
                    id: element["id"],
                    caption: element["caption"],
                  ));
                });
                // print(_idCaption);
                return allModelCaption;
              },
            ),
            SizedBox(
              height: 20,
            ),
            Text(
              'Gambar',
              style: GoogleFonts.sourceSansPro(
                fontSize: 15,
                fontWeight: FontWeight.bold,
                color: Color(0XFF007461),
              ),
            ),
            SizedBox(
              height: 10,
            ),
            Text(
              'Sertakan gambar yang berguna untuk membantu pengecekan petugas',
              style: GoogleFonts.sourceSansPro(
                fontSize: 13,
                //fontWeight: FontWeigh,
                color: Color.fromARGB(252, 34, 71, 64),
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(
              height: 35,
            ),
            fileimage != null
                ? SizedBox(
                    height: 150,
                    width: 270,
                    child: Image.file(
                      fileimage!,
                      fit: BoxFit.cover,
                    ))
                : OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(
                          color: Color.fromARGB(255, 17, 125, 107), width: 1),
                      minimumSize: Size(20, 80),
                    ),
                    label: Text(
                      'Upload',
                      style: GoogleFonts.sourceSansPro(
                        fontSize: 13,
                        //fontWeight: FontWeigh,
                        color: Color(0XFF007461),
                      ),
                    ),
                    icon: Icon(
                      Icons.upload,
                      color: Colors.teal,
                    ),
                    onPressed: () {
                      getImage();
                    },
                  ),
            SizedBox(
              height: 35,
            ),
            Center(
              child: Text(
                'Tambahhkan deskripsi aduan',
                style: GoogleFonts.sourceSansPro(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: Color(0XFF007461),
                ),
              ),
            ),
            SizedBox(
              height: 10,
            ),
            Form(
              key: _formKey,
              child: TextFormField(
                validator: (val) {
                  if (val!.isEmpty) return 'Deskripsi tidak boleh kosong';
                  return null;
                },
                controller: _descText,
                decoration: const InputDecoration(
                  labelText: 'Deskripsi aduan',
                  border: OutlineInputBorder(),
                  contentPadding: const EdgeInsets.symmetric(
                      vertical: 50.0, horizontal: 10.0),
                  errorBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.red, width: 5)),
                ),
                keyboardType: TextInputType.multiline,
                //keyboardType: TextInputType.number,
                //maxLength: 500,
              ),
            ),
            SizedBox(
              height: 20,
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Posting Laporan untuk :',
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 15,
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: <Widget>[
                    Radio(
                      value: '1',
                      groupValue: selectedRadio,
                      activeColor: Color(0XFF007461),
                      onChanged: setSelectedRadio,
                    ),
                    Text(
                      'Publik',
                      style: TextStyle(fontSize: 17.0),
                    ),
                    Radio(
                      value: '2',
                      groupValue: selectedRadio,
                      activeColor: Colors.red,
                      onChanged: setSelectedRadio,
                    ),
                    Text(
                      'Privasi',
                      style: TextStyle(
                        fontSize: 17.0,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            // Container(
            //   height: 50,
            //   width: MediaQuery.of(context).size.width,
            //   decoration: BoxDecoration(
            //     borderRadius: BorderRadius.circular(10),
            //     color: Color(0xffe0f2f2),
            //   ),
            //   // child: CheckboxListTile(
            //   //   title: Text(
            //   //     'Sembunyikan identitas saya',
            //   //     style: GoogleFonts.sourceSansPro(
            //   //       fontSize: 13.3,
            //   //       fontWeight: FontWeight.w700,
            //   //       color: Color(0XFF007461),
            //   //     ),
            //   //   ),
            //   //   value: isChecked,
            //   //   activeColor: Colors.red,
            //   //   checkColor: Colors.white,
            //   //   onChanged: (newValue) {
            //   //     setState(() {
            //   //       isChecked = newValue!;
            //   //       if (isChecked == true) {
            //   //         _check = '1';
            //   //       } else {
            //   //         _check = '0';
            //   //       }
            //   //       print(_check);
            //   //     });
            //   //   },
            //   //   controlAffinity:
            //   //       ListTileControlAffinity.trailing, //  <-- leading Checkbox
            //   // ),
            // ),
            SizedBox(
              height: 15,
            ),
            Align(
              alignment: Alignment.bottomCenter,
              child: TextButton(
                style: TextButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  primary: Colors.white,
                  backgroundColor: Colors.redAccent,
                  minimumSize: const Size(200, 52),
                  //elevation: 20,
                ),
                child: isLoading
                    ? Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          CircularProgressIndicator(
                            color: Colors.white,
                          ),
                          SizedBox(
                            width: 24,
                          ),
                          Text('Mohon Tunggu...'),
                        ],
                      )
                    : Text(
                        'Lapor Sekarang',
                        style: TextStyle(
                          fontSize: 15,
                          //fontWeight: FontWeight.bold,
                        ),
                      ),
                onPressed: () async {
                  setState(() => isLoading = true);
                  await Future.delayed(Duration(seconds: 4));
                  setState(() => isLoading = false);
                  if (_formKey.currentState!.validate()) postComplaint();
                },
              ),
            ),
          ],
        ),
      );

  Widget buildFloatingButton(BuildContext context) => FloatingActionButton(
        backgroundColor: Colors.white,
        onPressed: () async {
          getCurrentLocation().then((value) async {
            markers.add(
              Marker(
                markerId: MarkerId('2'),
                position: LatLng(value.latitude, value.longitude),
                infoWindow: InfoWindow(
                  title: 'My Current Location',
                ),
              ),
            );
            CameraPosition cameraPosition = CameraPosition(
                zoom: 14, target: LatLng(value.latitude, value.longitude));

            final GoogleMapController controller =
                await googleMapController.future;
            controller
                .animateCamera(CameraUpdate.newCameraPosition(cameraPosition));
            List<Placemark> placemarks =
                await placemarkFromCoordinates(value.latitude, value.longitude);
            //print(placemarks);
            setState(() {
              kotamark = placemarks.first.subLocality!;
              kec = placemarks.first.locality!;
              //sublocal = placemarks.first.subLocality!;
              kab = placemarks.first.subAdministrativeArea!;
            });
          });
        },
        child: Icon(
          Icons.gps_fixed,
          color: Colors.blue,
        ),
      );
}
