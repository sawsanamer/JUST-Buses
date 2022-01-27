import 'dart:async';
import 'dart:collection';
import 'dart:typed_data';
import 'dart:ui';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_database/ui/firebase_animated_list.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:flutter_slider_drawer/flutter_slider_drawer.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:just_busses/components/navdrawer.dart';
import 'package:just_busses/components/rounded_button.dart';
import 'package:just_busses/helpers/authentication_service.dart';
import 'package:just_busses/helpers/database_methods.dart';
import 'package:just_busses/helpers/dialog_boxes.dart';
import 'package:just_busses/theme/app_colors.dart';
import 'package:just_busses/theme/app_typography.dart';
import 'package:just_busses/views/driver/screen1.dart';
import 'package:just_busses/views/student/log_in.dart';
import 'package:location/location.dart';
import 'package:provider/provider.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';

class DriverMap extends StatefulWidget {
  const DriverMap({this.driverType});

  @override
  DriverMapState createState() => DriverMapState(driverType);

  final String driverType;
}

class DriverMapState extends State<DriverMap> {
  final ItemScrollController itemScrollController = ItemScrollController();
  GoogleMapController _controller;
  GoogleMapController googleMapController;
  String driverType;
  StreamSubscription<Event> _currentAvSubscription;
  DatabaseReference _currentAvSeatsRef;
  int avSeats = 0;
  StreamSubscription _locationSubscription;
  Location _locationTracker = Location();
  Marker marker;
  Circle circle;
  DriverMapState(this.driverType);

  Position currentPosition;
  var geoLocator = Geolocator();

  void getCurrentLocation() async {
    try {
      Uint8List imageData = await getMarker();
      var location = await _locationTracker.getLocation();

      updateMarkerAndCircle(location, imageData);

      if (_locationSubscription != null) {
        _locationSubscription.cancel();
      }

      _locationSubscription =
          _locationTracker.onLocationChanged.listen((newLocalData) {
        if (_controller != null) {
          // _controller.animateCamera(CameraUpdate.newCameraPosition(
          //     new CameraPosition(
          //         bearing: 192.8334901395799,
          //         target: LatLng(newLocalData.latitude, newLocalData.longitude),
          //         tilt: 0,
          //         zoom: 14.00)));

          DatabaseMethods.updateDriverLocation(
              newLocalData.latitude,
              newLocalData.longitude,
              newLocalData.heading,
              Provider.of<User>(context, listen: false).email);

          updateMarkerAndCircle(newLocalData, imageData);
        }
      });
    } on PlatformException catch (e) {
      if (e.code == 'PERMISSION_DENIED') {
        debugPrint("Permission Denied");
      }
    }
  }

  Future<Uint8List> getMarker() async {
    ByteData byteData =
        await DefaultAssetBundle.of(context).load("assets/bus.png");
    return byteData.buffer.asUint8List();
  }

  void updateMarkerAndCircle(LocationData newLocalData, Uint8List imageData) {
    LatLng latlng = LatLng(newLocalData.latitude, newLocalData.longitude);
    this.setState(() {
      marker = Marker(
          markerId: MarkerId("home"),
          position: latlng,
          rotation: newLocalData.heading,
          draggable: false,
          zIndex: 2,
          flat: true,
          anchor: Offset(0.5, 0.5),
          icon: BitmapDescriptor.fromBytes(imageData));
      circle = Circle(
          circleId: CircleId("car"),
          radius: newLocalData.accuracy,
          zIndex: 1,
          strokeColor: Colors.blue,
          center: latlng,
          fillColor: Colors.blue.withAlpha(70));
    });
  }

  // Future<void> locateUserPosition() async {
  //   //locate user position and move camera there.
  //   Position position = await Geolocator.getCurrentPosition(
  //       desiredAccuracy: LocationAccuracy.high);
  //   currentPosition = position;
  //
  //   LatLng latLngPosition = LatLng(position.latitude, position.longitude);
  //
  //   CameraPosition cameraPosition = new CameraPosition(
  //       target: latLngPosition,
  //       zoom: 14); //to move the camera to the new poisition
  //
  //   googleMapController
  //       .animateCamera(CameraUpdate.newCameraPosition(cameraPosition));
  // }

  Future<void> locateMarkerPosition(latLng) async {
    CameraPosition cameraPosition = new CameraPosition(
        target: latLng, zoom: 14); //to move the camera to the new poisition

    googleMapController
        .animateCamera(CameraUpdate.newCameraPosition(cameraPosition));
  }

  static Future<Uint8List> getBytesFromAsset(String path, int width) async {
    ByteData data = await rootBundle.load(path);
    Codec codec = await instantiateImageCodec(data.buffer.asUint8List(),
        targetWidth: width);
    FrameInfo fi = await codec.getNextFrame();
    return (await fi.image.toByteData(format: ImageByteFormat.png))
        .buffer
        .asUint8List();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    if (_locationSubscription != null) {
      _locationSubscription.cancel();
    }
    _currentAvSubscription.cancel();
  }

  @override
  void initState() {
    _currentAvSeatsRef =
        DatabaseMethods.referenceRealtime.child('current_av_seats');
    _currentAvSubscription = _currentAvSeatsRef.onValue.listen((Event event) {
      setState(() {
        avSeats = event.snapshot.value ?? 0;
      });
    });
    super.initState();
  }

  void addValueToMap<K, V>(Map<K, List<String>> map, K key, String value) =>
      map.update(key, (list) => list..add(value), ifAbsent: () => [value]);

  HashMap<String, List<String>> mapBetweenLocationNameAndStudents(snapshots) {
    HashMap<String, List<String>> map = new HashMap();
    for (int i = 0; i < snapshots.length; i++) {
      addValueToMap(map, snapshots[i].data()['locationName'],
          snapshots[i].data()['userEmail']);
    }

    return map;
  }

  List<Widget> buildEmailTiles(map, snapshots, i) {
    List<String> emails = map[snapshots[i].data()['locationName']];
    List<Widget> emailTiles = [
      ListTile(
        onTap: () {},
        title: Text(
          "Students who booked from this location:",
          style: TextStyle(fontSize: 20),
        ),
      )
    ];

    for (int j = 0; j < emails.length; j++) {
      emailTiles.add(ListTile(
        onTap: () {
          DatabaseMethods.updateMovedStudentBookingState(emails[j]);
        },
        title: Text(
          emails[j],
        ),
      ));
      emailTiles.add(Divider(
        thickness: 1,
      ));
    }
    return emailTiles;
  }

  showDialogBoxOnMarkerInfoClick(map, snapshots, i, context) {
    List<Widget> emailTiles = buildEmailTiles(map, snapshots, i);
    showDialog<String>(
        context: context,
        builder: (BuildContext context) => AlertDialog(
              title: SingleChildScrollView(
                child: Container(
                  child: Column(
                    children: emailTiles,
                  ),
                ),
              ),
              // title:  Text(map[snapshots[i].data()['locationName']].),
              actions: [
                FlatButton(
                  child: const Text(
                    'Ok',
                    style: TextStyle(
                      color: AppColors.aquaBlue,
                      fontSize: 16.0,
                    ),
                  ),
                  onPressed: () {
                    Navigator.pop(context, 'Ok');
                  },
                ),
              ],
            ));
  }

  Set<Marker> createMarkersList(context, snapshots) {
    Set<Marker> markers = new Set<Marker>();
    HashMap<String, List<String>> map =
        mapBetweenLocationNameAndStudents(snapshots);
    for (int i = 0; i < snapshots.length; i++) {
      markers.add(Marker(
        markerId: MarkerId(i.toString()),
        position: LatLng(
            snapshots[i].data()['latitude'], snapshots[i].data()['longitude']),
        infoWindow: InfoWindow(
            title: snapshots[i].data()['locationName'],
            onTap: () {
              showDialogBoxOnMarkerInfoClick(map, snapshots, i, context);
            }),
      ));
    }
    if (marker != null) markers.add(marker);
    return markers;
  }

  double zoomVal = 5.0;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        height: double.infinity,
        child: SafeArea(
          child: StreamBuilder(
            stream: DatabaseMethods.getAllBookingsStream(
                Provider.of<User>(context, listen: false).email),
            builder: (context, snapshot) {
              print(snapshot.data);
              return Stack(
                children: <Widget>[
                  snapshot.hasData
                      ? _buildGoogleMap(context, snapshot)
                      : SizedBox(),
                  Align(
                    alignment: Alignment.topLeft,
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: IconButton(
                        icon: Icon(
                          Icons.logout,
                          color: Colors.red,
                          size: 30,
                        ),
                        onPressed: () {
                          Provider.of<AuthenticationService>(context,
                                  listen: false)
                              .signOut();
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(builder: (context) => LogIn()),
                          );
                        },
                      ),
                    ),
                  ),
                  _buildBottomMovedOrCurrentDriverWidget(context)
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildBottomMovedOrCurrentDriverWidget(BuildContext context) {
    return StreamBuilder(
      stream: DatabaseMethods.getDriver(
          Provider.of<User>(context, listen: false).email),
      builder: (context, snapshot) {
        if (snapshot.hasData && snapshot.data.docs.length > 0) if (snapshot
                .data.docs[0]
                .data()['driverType']
                .toString() ==
            "moved") return _buildMovedWidget();

        return snapshot.hasData && snapshot.data.docs.length > 0
            ? Align(
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(vertical: 60, horizontal: 16),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        decoration: BoxDecoration(
                            border: Border.all(width: 0.5),
                            color: Colors.white,
                            borderRadius: BorderRadius.all(Radius.circular(8))),
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: snapshot.data.docs[0].data()["driverType"] ==
                                  "current"
                              ? Text(
                                  "Number of available seats: " +
                                      avSeats.toString(),
                                  style: TextStyle(
                                    fontSize: 16,
                                  ),
                                )
                              // ? FirebaseAnimatedList(
                              //     query: DatabaseMethods.query(),
                              //     itemBuilder:
                              //         (context, snapshot, animation, index) {
                              //       return Text(snapshot.value);
                              //     },
                              //   )
                              : Text(
                                  "Number of available seats: " +
                                      snapshot.data.docs[0]
                                          .data()["av_seats"]
                                          .toString(),
                                  style: TextStyle(
                                    fontSize: 16,
                                  ),
                                ),
                          // child: Text(
                          //   "Number of available seats: " +
                          //       snapshot.data.docs[0]
                          //           .data()["av_seats"]
                          //           .toString(),
                          //   style: TextStyle(
                          //     fontSize: 16,
                          //   ),
                          // ),
                        ),
                        width: MediaQuery.of(context).size.width - 80,
                      ),
                      SizedBox(
                        height: 8,
                      ),
                      Container(
                        decoration: BoxDecoration(
                            border: Border.all(width: 0.5),
                            color: Colors.white,
                            borderRadius: BorderRadius.all(Radius.circular(8))),
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(
                            "Number of bookings: " +
                                snapshot.data.docs[0]
                                    .data()["bookingsCount"]
                                    .toString(),
                            style: TextStyle(
                              fontSize: 16,
                            ),
                          ),
                        ),
                        width: MediaQuery.of(context).size.width - 80,
                      ),
                      SizedBox(
                        height: 8,
                      ),
                      snapshot.hasData
                          ? snapshot.data.docs[0].data()["driverType"] ==
                                  "current"
                              ? RoundedButton(
                                  text: 'Move Bus',
                                  width: MediaQuery.of(context).size.width - 80,
                                  onPressed: () async {
                                    EasyLoading.show(status: "Loading...");
                                    // DatabaseMethods
                                    //     .updateAllMovedStudentsBookingState();

                                    int nextAvSeats = await DatabaseMethods
                                        .getNumberOFAvailableSeats("next");
                                    if (nextAvSeats != -1) {
                                      //1- n3raf whos the next driver email
                                      //2- set the current email
                                      //2- set email_av_seats
                                      String nextEmail =
                                          await DatabaseMethods.getDriverEmail(
                                              'next');

                                      await DatabaseMethods
                                          .setCurrentDriverEmailInRealtime(
                                              nextEmail);

                                      await DatabaseMethods
                                          .setCurrentAvSeatsRealtimeDatabase(
                                              nextEmail, nextAvSeats);
                                      // DatabaseMethods
                                      //     .resetCurrentRealtimeDatabase();
                                    }
                                    await DatabaseMethods
                                        .updateDriverBookingsTypeFromTo(
                                            "current", "moved");
                                    await DatabaseMethods
                                        .updateDriverBookingsTypeFromTo(
                                            "next", "current");
                                    await DatabaseMethods
                                        .updateDriverTypeFromTo(
                                            "current", "moved");

                                    await DatabaseMethods
                                        .updateDriverTypeFromTo(
                                            "next", "current");

                                    EasyLoading.dismiss();
                                    setState(() {});
                                  },
                                  color: Colors.red[700],
                                )
                              : SizedBox()
                          : SizedBox(),
                    ],
                  ),
                ),
                alignment: Alignment.bottomLeft,
              )
            : Container();
      },
    );
  }

  Widget _buildMovedWidget() {
    return Align(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
        child: RoundedButton(
          text: 'Arrived',
          width: MediaQuery.of(context).size.width - 80,
          onPressed: () async {
            showDialog<String>(
                context: context,
                builder: (BuildContext context) => AlertDialog(
                      title: const Text("Are you sure you have arrived?"),
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
                            EasyLoading.show(status: "Loading..");
                            await DatabaseMethods.deleteMovedDriverBooking(
                                "driverEmail",
                                Provider.of<User>(context, listen: false)
                                    .email);
                            await DatabaseMethods.deleteDriver(
                                Provider.of<User>(context, listen: false)
                                    .email);
                            EasyLoading.dismiss();
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => Screen1()),
                            );
                          },
                          child: const Text(
                            'Confirm',
                            style: TextStyle(color: AppColors.aquaBlue),
                          ),
                        ),
                      ],
                    ));
          },
          color: Colors.red[700],
        ),
      ),
      alignment: Alignment.bottomLeft,
    );
  }

  Widget _buildGoogleMap(BuildContext context, snapshot) {
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
            _controller = controller;
            googleMapController = controller;
            getCurrentLocation();
            // locateUserPosition();
          },
          markers: createMarkersList(context, snapshot.data.docs),
          circles: Set.of((circle != null) ? [circle] : []),
        ));
  }
}
