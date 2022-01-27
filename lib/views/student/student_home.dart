import 'dart:async';
import 'dart:collection';
import 'dart:convert' as JSON;
import 'dart:typed_data';
import 'dart:ui';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_config/flutter_config.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:flutter_slider_drawer/flutter_slider_drawer.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:just_busses/components/navdrawer.dart';
import 'package:just_busses/components/rounded_button.dart';
import 'package:just_busses/helpers/database_methods.dart';
import 'package:just_busses/helpers/dialog_boxes.dart';
import 'package:just_busses/theme/app_colors.dart';
import 'package:just_busses/theme/app_typography.dart';
import 'package:location/location.dart';
import 'package:provider/provider.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';

class StudentHome extends StatefulWidget {
  @override
  StudentHomeState createState() => StudentHomeState();
}

class StudentHomeState extends State<StudentHome> {
  final ItemScrollController itemScrollController = ItemScrollController();
  // Completer<GoogleMapController> _controller = Completer();
  GoogleMapController googleMapController;
  GoogleMapController _controller;

  Uint8List imageData;
  Position currentPosition;
  var geoLocator = Geolocator();
  Marker marker;
  Circle circle;
  void getDriverLocation(latitude, longitude, double heading) async {
    try {
      if (mounted)
        updateMarkerAndCircle(latitude, longitude, heading, imageData);

      if (_controller != null) {
        _controller.animateCamera(CameraUpdate.newCameraPosition(
            new CameraPosition(
                bearing: 192.8334901395799,
                target: LatLng(latitude, longitude),
                tilt: 0,
                zoom: 14.00)));
      }
    } on PlatformException catch (e) {
      if (e.code == 'PERMISSION_DENIED') {}
    }
  }

  Future<Uint8List> getMarker() async {
    ByteData byteData =
        await DefaultAssetBundle.of(context).load("assets/bus.png");
    return byteData.buffer.asUint8List();
  }

  void updateMarkerAndCircle(
      latitude, longitude, heading, Uint8List imageData) {
    LatLng latlng = LatLng(latitude, longitude);
    this.setState(() {
      marker = Marker(
          markerId: MarkerId("home"),
          position: latlng,
          rotation: heading,
          draggable: false,
          zIndex: 2,
          flat: true,
          anchor: Offset(0.5, 0.5),
          icon: BitmapDescriptor.fromBytes(imageData));
      circle = Circle(
          circleId: CircleId("car"),
          // radius: newLocalData.accuracy,
          zIndex: 1,
          strokeColor: Colors.blue,
          center: latlng,
          fillColor: Colors.blue.withAlpha(70));
    });
  }

  Future<LatLng> locateUserPosition() async {
    //locate user position and move camera there.
    Position position = await Geolocator.getCurrentPosition();
    currentPosition = position;

    LatLng latLngPosition = LatLng(position.latitude, position.longitude);
    return (latLngPosition);
    // CameraPosition cameraPosition = new CameraPosition(
    //     target: latLngPosition,
    //     zoom: 14); //to move the camera to the new poisition

    // googleMapController
    //     .animateCamera(CameraUpdate.newCameraPosition(cameraPosition));
  }

  Future<void> locateMarkerPosition(latLng) async {
    CameraPosition cameraPosition = new CameraPosition(
        target: latLng, zoom: 14); //to move the camera to the new poisition

    googleMapController
        .animateCamera(CameraUpdate.newCameraPosition(cameraPosition));
  }

  @override
  void initState() {
    // getBytesFromAsset('assets/images/loca.png', 115).then((onValue) {
    //   customIcon = BitmapDescriptor.fromBytes(onValue);
    // });

    assignImageToMarker();
    super.initState();
  }

  assignImageToMarker() async {
    imageData = await getMarker();
  }

  Set<Marker> createMarkersList(
      context, AsyncSnapshot<QuerySnapshot> locationsSnapshot) {
    Set<Marker> markers = new Set<Marker>();
    print("hola");
    for (int i = 0; i < locationsSnapshot.data.docs.length; i++) {
      print("GDFG" + locationsSnapshot.data.docs[i].data().toString());
      markers.add(Marker(
        markerId: MarkerId(locationsSnapshot.data.docs[i].id),
        position: LatLng(locationsSnapshot.data.docs[i].data()['latitude'],
            locationsSnapshot.data.docs[i].data()['longitude']),
        infoWindow: InfoWindow(
            title: locationsSnapshot.data.docs[i].data()['name'],
            onTap: () {
              showBookingDialogBox(i, context, locationsSnapshot);
            }),
        onTap: () {
          itemScrollController.jumpTo(
            index: i,
          );
        },
      ));
    }
    return markers;
  }

  Future<String> getEstimatedTimeMsg(String driverType, data) async {
    if (driverType == "moved")
      return "The bus needs: " +
          data['rows'][0]['elements'][0]['duration']["text"];
    else if (driverType == "current") {
      int avSeats = await DatabaseMethods.getNumberOFAvailableSeats("current");
      int n = 0;
      if (avSeats < 10 && avSeats > 5)
        n = 5;
      else if (avSeats < 5)
        n = 2;
      else if (avSeats < 20 && avSeats > 10)
        n = 10;
      else
        n = 15;

      int time = int.parse(data['rows'][0]['elements'][0]['duration']["text"]
              .replaceAll(new RegExp(r'[^0-9]'), '')) +
          n;

      return "The bus needs: " + time.toString() + " mins.";
    } else {
      return "Cannot be Estimated";
    }
  }

  getEstimatedTimeDialogBox(bookingsSnapshot, driverSnapshot) async {
    if (bookingsSnapshot.hasData &&
        driverSnapshot.hasData &&
        driverSnapshot.data != null &&
        driverSnapshot.data.docs.length > 0) {
      double locationLatitude =
          bookingsSnapshot.data.docs[0].data()['latitude'];
      double locationLongitude =
          bookingsSnapshot.data.docs[0].data()['longitude'];

      Dio dio = new Dio();

      double destLatitude = driverSnapshot.data.docs[0].data()['latitude'];
      double destLongitude = driverSnapshot.data.docs[0].data()['longitude'];
      print(destLatitude);
      Response response = await dio.get(
          "https://maps.googleapis.com/maps/api/distancematrix/json?units=metric&origins=" +
              locationLatitude.toString() +
              "," +
              locationLongitude.toString() +
              "&destinations=" +
              destLatitude.toString() +
              "%2C" +
              destLongitude.toString() +
              "%7C40.6905615%2C-73.9976592%7C40.6905615%2C-73.9976592%7C40.6905615%2C-73.9976592%7C40.6905615%2C-73.9976592%7C40.6905615%2C-73.9976592%7C40.659569%2C-73.933783%7C40.729029%2C-73.851524%7C40.6860072%2C-73.6334271%7C40.598566%2C-73.7527626%7C40.659569%2C-73.933783%7C40.729029%2C-73.851524%7C40.6860072%2C-73.6334271%7C40.598566%2C-73.7527626&key=" +
              FlutterConfig.get('GOOGLE_API_KEY'));
      if (response.statusCode == 200) {
        Map<String, dynamic> data = JSON.jsonDecode(response.toString());
        print(int.parse(data['rows'][0]['elements'][0]['duration']["text"]
            .replaceAll(new RegExp(r'[^0-9]'), '')));
        String driverType = bookingsSnapshot.data.docs[0].data()['driverType'];
        String msg = await getEstimatedTimeMsg(driverType, data);
        DialogBoxes.showErrorDialogBox(msg, context);
      }
      //iza enu moved only the time it needs, iza enu current depending on kam feyo nas

    } else {
      DialogBoxes.showErrorDialogBox("error: problem in connection", context);
    }
  }

  double zoomVal = 5.0;
  GlobalKey<SliderMenuContainerState> _key =
      new GlobalKey<SliderMenuContainerState>();
  @override
  Widget build(BuildContext context) {
    // _createMarkerImageFromAsset(context);
    return StreamBuilder(
      stream: DatabaseMethods.findBookingByEmail(
          Provider.of<User>(context, listen: false).email),
      builder: (context, AsyncSnapshot<QuerySnapshot> bookingsSnapshot) {
        return StreamBuilder(
          builder: (context, AsyncSnapshot<QuerySnapshot> locationsSnapshot) {
            return StreamBuilder(
              builder: (context, driverSnapshot) {
                return Scaffold(
                  drawer: NavDrawer(),
                  appBar: AppBar(
                    title: Text(bookingsSnapshot.hasData &&
                            bookingsSnapshot.data.docs.length > 0
                        ? "Thank you for booking!"
                        : "Choose Pick Up Location"),
                  ),
                  body: Container(
                    height: double.infinity,
                    child: Stack(
                      children: [
                        _buildGoogleMap(context, bookingsSnapshot,
                            locationsSnapshot, driverSnapshot),
                        bookingsSnapshot.hasData &&
                                bookingsSnapshot.data.docs.length == 0
                            ? buildBottomContainer(locationsSnapshot)
                            : bookingsSnapshot.hasData &&
                                    bookingsSnapshot.data.docs[0]
                                            .data()['state'] ==
                                        'not_picked'
                                ? Align(
                                    alignment: Alignment.bottomCenter,
                                    child: Padding(
                                      padding: EdgeInsets.all(16),
                                      child: RoundedButton(
                                        onPressed: () async {
                                          EasyLoading.show(status: "Loading..");
                                          await getEstimatedTimeDialogBox(
                                              bookingsSnapshot, driverSnapshot);
                                          EasyLoading.dismiss();
                                        },
                                        color: Colors.red[700],
                                        text: "See Estimated Time",
                                      ),
                                    ),
                                  )
                                : SizedBox()
                      ],
                    ),
                    // child: Stack(
                    //   children: <Widget>[
                    //     _buildGoogleMap(context),
                    //     StreamBuilder(
                    //       builder: (context, snapshot) {
                    //         return snapshot.hasData && snapshot.data.docs.length > 0
                    //             ? Align(
                    //                 alignment: Alignment.bottomCenter,
                    //                 child: RoundedButton(
                    //                   text: "gdfg",
                    //                 ),
                    //               )
                    //             : buildBottomContainer();
                    //       },
                    //       stream: DatabaseMethods.findBookingByEmail(
                    //           Provider.of<User>(context, listen: false).email),
                    //     )
                    //   ],
                    // ),
                  ),
                );
              },
              stream: DatabaseMethods.getDriver(bookingsSnapshot.hasData &&
                      bookingsSnapshot.data.docs.length > 0
                  ? bookingsSnapshot.data.docs[0].data()['driverEmail']
                  : ""),
            );
          },
          stream: DatabaseMethods.getLocationsStream(),
        );
      },
    );
  }

  // Future<void> changeZoomValue(double zoomVal) async {
  //   final GoogleMapController controller = await _controller.future;
  //   controller.animateCamera(CameraUpdate.newCameraPosition(CameraPosition(
  //       target: LatLng(-24.975122649942392, 133.76997152163685),
  //       zoom: zoomVal)));
  // }

  void showBookingDialogBox(index, context, locationsSnapshot) {
    String msg = locationsSnapshot.hasData
        ? 'Book a Ticket From ' +
            locationsSnapshot.data.docs[index].data()['name']
        : "";
    showDialog<String>(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        title: Text(msg),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Do you want to buy a ticket?",
              style: AppTypography.headerMedium,
            ),
          ],
        ),
        actions: <Widget>[
          FlatButton(
            onPressed: () => Navigator.pop(context, 'No'),
            child: const Text(
              'No',
              style: TextStyle(color: Colors.red),
            ),
          ),
          FlatButton(
            onPressed: () => Navigator.pop(context, 'Yes'),
            child: const Text(
              'Yes',
              style: TextStyle(color: AppColors.aquaBlue),
            ),
          ),
        ],
      ),
    ).then((returnVal) {
      if (returnVal == "Yes") {
        showDialog<String>(
          context: context,
          builder: (BuildContext context) => AlertDialog(
            title: const Text("Are you sure you want to buy a ticket?"),
            actions: <Widget>[
              FlatButton(
                onPressed: () => Navigator.pop(context, 'Cancel'),
                child: const Text(
                  'Cancel',
                  style: TextStyle(color: AppColors.aquaBlue),
                ),
              ),
              FlatButton(
                onPressed: () async {
                  EasyLoading.show(status: 'loading..');

                  await updateWalletAndAddBooking(
                      index, context, locationsSnapshot);
                  EasyLoading.dismiss();
                },
                child: const Text(
                  'Confirm',
                  style: TextStyle(color: AppColors.aquaBlue),
                ),
              ),
            ],
          ),
        ).then((returnVal) {
          if (returnVal == "Confirm") {
            Scaffold.of(context).showSnackBar(
              SnackBar(
                content: Text('Booking confirmed'),
                // action: SnackBarAction(
                //     label: 'OK', onPressed: () {}),
              ),
            );
          }
        });
      }
    });
  }

  Widget buildBottomContainer(AsyncSnapshot<QuerySnapshot> locationsSnapshot) {
    return locationsSnapshot.hasData
        ? Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              margin: EdgeInsets.symmetric(vertical: 20.0),
              height: 250.0,
              color: Colors.white,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Container(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Text(
                        "Available Bus stops",
                        style: AppTypography.headerMedium,
                      ),
                    ),
                  ),
                  Flexible(
                    child: ScrollablePositionedList.separated(
                      itemCount: locationsSnapshot.data.docs.length,
                      itemBuilder: (context, index) {
                        return ListTile(
                            onTap: () {
                              locateMarkerPosition(LatLng(
                                  locationsSnapshot.data.docs[index]
                                      .data()['latitude'],
                                  locationsSnapshot.data.docs[index]
                                      .data()['longitude']));
                              showBookingDialogBox(
                                  index, context, locationsSnapshot);
                              print("F");
                            },
                            leading: Icon(Icons.directions_bus_outlined),
                            title: Text(
                              locationsSnapshot.data.docs[index].data()['name'],
                              style: AppTypography.bodyMedium,
                            ));
                      },
                      scrollDirection: Axis.vertical,
                      itemScrollController: itemScrollController,
                      separatorBuilder: (BuildContext context, int index) {
                        return Container(
                          height: 0.5,
                          color: Colors.black,
                        );
                      },
                    ),
                  ),
                ],
              ),
              // child: ListView(
              //   scrollDirection: Axis.horizontal,
              //   children: <Widget>[
              //     AboutAustraliaCard(
              //       imageUrl:
              //           "https://ak-d.tripcdn.com/images/10060n000000e4c6nEB47.jpg?proc=source%2Ftrip",
              //       title: "دار أوبرا سيدني",
              //     ),
              //     // Padding(
              //     //   padding: const EdgeInsets.all(8.0),
              //     //   child: TopPlaceBox(
              //     //     image:
              //     //         "https://ak-d.tripcdn.com/images/10060n000000e4c6nEB47.jpg?proc=source%2Ftrip",
              //     //     lat: -33.85657946005523,
              //     //     long: 151.21523232445094,
              //     //     locationName: "دار أوبرا سيدني",
              //     //     gotoLocation: _gotoLocation,
              //     //   ),
              //     // ),
              //
              //   ],
              // ),
            ),
          )
        : Container();
  }

  Future<void> updateWalletAndAddBooking(
      index, context, locationsSnapshot) async {
    double wallet = await DatabaseMethods.getWallet(
        Provider.of<User>(context, listen: false));
    if (wallet < 1.15)
      DialogBoxes.showErrorDialogBox(
          "You Do not have enough money in your wallet", context);
    else {
      String error = await DatabaseMethods.addBooking(
          Provider.of<User>(context, listen: false).email,
          await DatabaseMethods.getUsername(
              Provider.of<User>(context, listen: false)),
          locationsSnapshot.data.docs[index].data()['longitude'],
          locationsSnapshot.data.docs[index].data()['latitude'],
          locationsSnapshot.data.docs[index].data()['name']);
      if (error != "") {
        DialogBoxes.showErrorDialogBox(error, context);
      } else {
        await DatabaseMethods.updateWallet(
            -1.15, Provider.of<User>(context, listen: false).email);
        Navigator.pop(context);
      }
    }
  }

  Widget _buildGoogleMap(
      BuildContext context,
      AsyncSnapshot<QuerySnapshot> bookedSnapshot,
      AsyncSnapshot<QuerySnapshot> locationsSnapshot,
      AsyncSnapshot<QuerySnapshot> driverSnapshot) {
    if (driverSnapshot.hasData &&
        driverSnapshot.data != null &&
        driverSnapshot.data.docs.length > 0)
      getDriverLocation(
          driverSnapshot.data.docs[0].data()['latitude'],
          driverSnapshot.data.docs[0].data()['longitude'],
          driverSnapshot.data.docs[0].data()['heading']);
    return Container(
      height: MediaQuery.of(context).size.height,
      width: MediaQuery.of(context).size.width,
      child: GoogleMap(
        padding: EdgeInsets.only(bottom: 300),
        myLocationEnabled: true,
        zoomGesturesEnabled: true,
        myLocationButtonEnabled: true,
        zoomControlsEnabled: true,
        initialCameraPosition: CameraPosition(
            target: LatLng(31.995384266632275, 35.92004926835121), zoom: 10),
        onMapCreated: (GoogleMapController controller) {
          // _controller.complete(controller);
          googleMapController = controller;
          _controller = controller;
          // locateUserPosition();
        },
        markers: !bookedSnapshot.hasData ||
                bookedSnapshot.data.docs.length > 0 ||
                !locationsSnapshot.hasData
            ? Set.of((marker != null) ? [marker] : [])
            : createMarkersList(context, locationsSnapshot),
        circles: Set.of((circle != null) ? [circle] : []),
      ),
    );
  }
}
