// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables

import 'dart:async';
import 'dart:convert';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:timeline_tile/timeline_tile.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart';

class DetailComplaint extends StatefulWidget {
  final String idUser;
  final String idComplaint;
  final String picturePath;
  final String caption;
  final String desc;
  final String status;
  final String createdAt;
  final String district;
  final String _lat;
  final String _long;

  const DetailComplaint(
      this.idComplaint,
      this.picturePath,
      this.caption,
      this.desc,
      this.status,
      this.idUser,
      this.createdAt,
      this.district,
      this._lat,
      this._long,
      {Key? key})
      : super(key: key);

  @override
  State<DetailComplaint> createState() => _DetailComplaintState();
}

class _DetailComplaintState extends State<DetailComplaint> {
  List _listDetail = [];

  final List<Marker> markers = <Marker>[];
  final Completer<GoogleMapController> googleMapController = Completer();

  Future _fetchData() async {
    var response = await get(
      Uri.parse('https://sesarengan.afdlolnur.id/api/complaintdetail/' +
          widget.idComplaint),
      headers: {
        "Accept": 'application/json',
        "Content-type": "application/x-www-form-urlencoded",
      },
    );

    if (response.statusCode == 200) {
      setState(() {
        final jsonData = jsonDecode(response.body);
        _listDetail = jsonData['data'];
        print(_listDetail);
      });
    }
  }

  Future<Position> getCurrentLocation() async {
    await Geolocator.requestPermission()
        .then((value) {})
        .onError((error, stackTrace) {
      //print('error' + error.toString());
    });
    return await Geolocator.getCurrentPosition();
  }

  Future _fetchLoc() async {
    markers.add(
      Marker(
        markerId: MarkerId('2'),
        position: LatLng(
          double.parse(widget._lat),
          double.parse(widget._long),
        ),
        infoWindow: InfoWindow(
          title: 'My Current Location',
        ),
      ),
    );
    final GoogleMapController controller = await googleMapController.future;
    CameraPosition cameraPosition = CameraPosition(
        zoom: 14,
        target: LatLng(double.parse(widget._lat), double.parse(widget._long)));

    setState(() {
      controller.animateCamera(CameraUpdate.newCameraPosition(cameraPosition));
    });
  }

  static final CameraPosition initialCameraPosition =
      CameraPosition(target: LatLng(-7.3633, 109.8985), zoom: 14);

  @override
  void initState() {
    super.initState();
    _fetchData();
    _fetchLoc();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Detail Aduan',
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
      body: Container(
        constraints: BoxConstraints(
          maxHeight: 900,
        ),
        child: ListView(
          shrinkWrap: true,
          children: [
            Container(
              margin: EdgeInsets.all(8),
              width: MediaQuery.of(context).size.width,
              constraints: BoxConstraints(
                minHeight: 100,
              ),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(15),
                border: Border.all(
                  color: Colors.grey.withOpacity(0.2),
                  width: 2,
                ),
              ),
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.only(left: 5.0, top: 10),
                    child: ListTile(
                      leading: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Nomor Aduan',
                            style: GoogleFonts.poppins(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              color: Colors.grey,
                            ),
                          ),
                          Text(
                            '#AWSB14' + widget.idComplaint,
                            style: GoogleFonts.poppins(
                              fontSize: 17,
                              fontWeight: FontWeight.bold,
                              color: Color.fromARGB(255, 23, 54, 80),
                            ),
                          ),
                        ],
                      ),
                      trailing: Container(
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: widget.status == 'PENDING'
                                ? Colors.red
                                : widget.status == 'DITERIMA'
                                    ? Color.fromARGB(255, 255, 153, 0)
                                    : widget.status == 'DIKERJAKAN'
                                        ? Colors.blueAccent
                                        : Colors.teal,
                          ),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Center(
                          child: Text(
                            widget.status,
                            style: GoogleFonts.poppins(
                              fontSize: 9.3,
                              fontWeight: FontWeight.bold,
                              color: widget.status == 'PENDING'
                                  ? Colors.red
                                  : widget.status == 'DITERIMA'
                                      ? Color.fromARGB(255, 255, 153, 0)
                                      : widget.status == 'DIKERJAKAN'
                                          ? Colors.blueAccent
                                          : Colors.teal,
                            ),
                          ),
                        ),
                        height: 28,
                        width: 65,
                      ),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.only(
                      left: 20,
                      right: 20,
                    ),
                    child: Divider(
                      thickness: 2,
                      //color: Colors.black,
                    ),
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 20),
                    child: Row(
                      children: [
                        Icon(
                          Icons.person_rounded,
                          size: 25,
                          color: Colors.grey,
                        ),
                        SizedBox(
                          width: 10,
                        ),
                        Text(
                          'NWS-510' + widget.idUser,
                          style: GoogleFonts.poppins(
                            fontSize: 15,
                            fontWeight: FontWeight.w400,
                            color: Colors.black,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 20, top: 10),
                    child: Row(
                      children: [
                        Icon(
                          Icons.calendar_month,
                          size: 25,
                          color: Colors.grey,
                        ),
                        SizedBox(
                          width: 10,
                        ),
                        Text(
                          widget.createdAt,
                          style: GoogleFonts.poppins(
                            fontSize: 15,
                            fontWeight: FontWeight.w400,
                            color: Colors.black,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(
                      left: 20,
                      top: 10,
                      bottom: 20,
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.location_on,
                          size: 25,
                          color: Colors.grey,
                        ),
                        SizedBox(
                          width: 10,
                        ),
                        Flexible(
                          child: Container(
                            margin: EdgeInsets.only(
                              right: 10,
                            ),
                            width: MediaQuery.of(context).size.width,
                            child: Text(
                              widget.district,
                              style: GoogleFonts.poppins(
                                fontSize: 15,
                                fontWeight: FontWeight.w400,
                                color: Colors.black,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Container(
              margin: EdgeInsets.all(8),
              width: MediaQuery.of(context).size.width,
              constraints: BoxConstraints(
                minHeight: 100,
              ),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(15),
                border: Border.all(
                  color: Colors.grey.withOpacity(0.2),
                  width: 2,
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.all(15.0),
                child: Column(
                  children: [
                    Text(
                      'Detail Aduan',
                      style: GoogleFonts.poppins(
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                        color: Color.fromARGB(255, 23, 54, 80),
                      ),
                    ),
                    SizedBox(
                      height: 5,
                    ),
                    Ink.image(
                      height: 180,
                      image: NetworkImage(
                        widget.picturePath,
                      ),
                      fit: BoxFit.fitHeight,
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    SizedBox(
                      width: MediaQuery.of(context).size.width,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.caption,
                            style: GoogleFonts.poppins(
                              fontSize: 17,
                              fontWeight: FontWeight.bold,
                              color: Color.fromARGB(255, 23, 54, 80),
                            ),
                          ),
                          SizedBox(
                            height: 5,
                          ),
                          Text(
                            widget.desc,
                            style: GoogleFonts.poppins(
                              fontSize: 14,
                              //fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(
              height: 10,
            ),
            Container(
              margin: EdgeInsets.all(8),
              height: 200,
              width: MediaQuery.of(context).size.width,
              child: GoogleMap(
                //myLocationEnabled: true,
                initialCameraPosition: initialCameraPosition,
                markers: Set<Marker>.of(markers),
                zoomControlsEnabled: false,
                mapType: MapType.normal,
                onMapCreated: (GoogleMapController controller) {
                  googleMapController.complete(controller);
                },
              ),
            ),
            SizedBox(
              height: 10,
            ),
            Container(
              margin: EdgeInsets.all(8),
              width: MediaQuery.of(context).size.width,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(15),
                border: Border.all(
                  color: Colors.grey.withOpacity(0.2),
                  width: 2,
                ),
              ),
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(15.0),
                    child: Column(
                      children: [
                        Text(
                          'Timeline Aduan',
                          style: GoogleFonts.poppins(
                            fontSize: 17,
                            fontWeight: FontWeight.bold,
                            color: Color.fromARGB(255, 23, 54, 80),
                          ),
                        ),
                        SizedBox(
                          height: 5,
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'Status : ',
                              style: GoogleFonts.poppins(
                                fontSize: 14,
                                color: Colors.grey,
                              ),
                            ),
                            _listDetail.length == 4
                                ? Text(
                                    'Selesai',
                                    style: GoogleFonts.poppins(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0XFF007461),
                                    ),
                                  )
                                : _listDetail.length == 3
                                    ? Text(
                                        'Dikerjakan',
                                        style: GoogleFonts.poppins(
                                          fontSize: 14,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.blueAccent,
                                        ),
                                      )
                                    : _listDetail.length == 2
                                        ? Text(
                                            'Diterima',
                                            style: GoogleFonts.poppins(
                                              fontSize: 14,
                                              fontWeight: FontWeight.bold,
                                              color: Color.fromARGB(
                                                  255, 255, 153, 0),
                                            ),
                                          )
                                        : Text(
                                            'Pending',
                                            style: GoogleFonts.poppins(
                                              fontSize: 14,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.red,
                                            ),
                                          ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  ListView.builder(
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    scrollDirection: Axis.vertical,
                    itemCount: _listDetail.length,
                    itemBuilder: (context, index) {
                      var status = _listDetail[index]['status'];
                      bool _isFirst = false;

                      if (status == 'SELESAI' && widget.status == 'SELESAI') {
                        _isFirst = true;
                      } else if (status == 'DIKERJAKAN' &&
                          widget.status == 'DIKERJAKAN') {
                        _isFirst = true;
                      } else if (status == 'DITERIMA' &&
                          widget.status == 'DITERIMA') {
                        _isFirst = true;
                      } else if (status == 'PENDING' &&
                          widget.status == 'PENDING') {
                        _isFirst = true;
                      }

                      return Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          TimelineTile(
                            isFirst: _isFirst,
                            isLast: false,
                            indicatorStyle: IndicatorStyle(
                              //indicatorXY: 0.7,
                              width: 15,
                              color: status == 'SELESAI' &&
                                      widget.status == 'SELESAI'
                                  ? Color(0XFF007461)
                                  : status == 'DIKERJAKAN' &&
                                          widget.status == 'DIKERJAKAN'
                                      ? Color(0XFF007461)
                                      : status == 'DITERIMA' &&
                                              widget.status == 'DITERIMA'
                                          ? Color(0XFF007461)
                                          : status == 'PENDING' &&
                                                  widget.status == 'PENDING'
                                              ? Colors.red
                                              : Colors.grey,
                            ),
                            afterLineStyle: LineStyle(
                              color: status == 'SELESAI' &&
                                      widget.status == 'SELESAI'
                                  ? Color(0XFF007461)
                                  : status == 'DIKERJAKAN' &&
                                          widget.status == 'DIKERJAKAN'
                                      ? Color(0XFF007461)
                                      : status == 'DITERIMA' &&
                                              widget.status == 'DITERIMA'
                                          ? Color(0XFF007461)
                                          : status == 'PENDING'
                                              ? Colors.transparent
                                              : Colors.grey,
                              thickness: 3,
                            ),
                            beforeLineStyle: LineStyle(
                              color: Colors.grey,
                              thickness: 3,
                            ),
                            alignment: TimelineAlign.manual,
                            lineXY: 0.12,
                            endChild: Container(
                              //color: Colors.amber,
                              constraints: BoxConstraints(
                                minHeight: 120,
                              ),
                              child: Padding(
                                padding: const EdgeInsets.only(
                                  left: 8.0,
                                  top: 20,
                                ),
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      '${_listDetail[index]['time']}',
                                      style: GoogleFonts.poppins(
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold,
                                        color: Color(0XFF007461),
                                      ),
                                    ),
                                    SizedBox(
                                      height: 10,
                                    ),
                                    Text(
                                      status == 'SELESAI'
                                          ? 'Petugas telah menyelesaikan aduan'
                                          : status == 'DIKERJAKAN'
                                              ? 'Petugas sedang mengerjakan aduan'
                                              : status == 'DITERIMA'
                                                  ? 'Petugas telah menerima aduan'
                                                  : 'Masyarakat melaporkan aduan',
                                      style: GoogleFonts.poppins(
                                        fontSize: 13,
                                        color: status == 'SELESAI' &&
                                                widget.status == 'SELESAI'
                                            ? Color(0XFF007461)
                                            : status == 'DIKERJAKAN' &&
                                                    widget.status ==
                                                        'DIKERJAKAN'
                                                ? Color(0XFF007461)
                                                : status == 'DITERIMA' &&
                                                        widget.status ==
                                                            'DITERIMA'
                                                    ? Color(0XFF007461)
                                                    : Colors.black,
                                      ),
                                    ),
                                    SizedBox(
                                      height: 10,
                                    ),
                                    Row(
                                      children: [
                                        Icon(
                                          Icons.person_outline_rounded,
                                          size: 15,
                                          color: status == 'SELESAI' &&
                                                  widget.status == 'SELESAI'
                                              ? Color(0XFF007461)
                                              : status == 'DIKERJAKAN' &&
                                                      widget.status ==
                                                          'DIKERJAKAN'
                                                  ? Color(0XFF007461)
                                                  : status == 'DITERIMA' &&
                                                          widget.status ==
                                                              'DITERIMA'
                                                      ? Color(0XFF007461)
                                                      : Colors.black,
                                        ),
                                        SizedBox(
                                          width: 5,
                                        ),
                                        Text(
                                          status == 'PENDING'
                                              ? 'NWS-510' + widget.idUser
                                              : '${_listDetail[index]['pic']}',
                                          style: GoogleFonts.poppins(
                                            fontSize: 13,
                                            //fontWeight: FontWeight.bold,
                                            color: status == 'SELESAI' &&
                                                    widget.status == 'SELESAI'
                                                ? Color(0XFF007461)
                                                : status == 'DIKERJAKAN' &&
                                                        widget.status ==
                                                            'DIKERJAKAN'
                                                    ? Color(0XFF007461)
                                                    : status == 'DITERIMA' &&
                                                            widget.status ==
                                                                'DITERIMA'
                                                        ? Color(0XFF007461)
                                                        : Colors.black,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
