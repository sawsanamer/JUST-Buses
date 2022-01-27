import 'dart:collection';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';

import 'authentication_service.dart';

class DatabaseMethods {
  static DatabaseReference referenceRealtime =
      FirebaseDatabase.instance.reference();
  static var _firestore = FirebaseFirestore.instance;

  updateCurrentAvSeats() {
    referenceRealtime.child("bookings").once().then((DataSnapshot snapshot) {
      int value = snapshot.value; //retrieve number of bookings made;
      value++;
      referenceRealtime.child('bookings').set(value).asStream();
    });
  }

  static void addUserInfo(
      {String email, String name, String role, String username}) async {
    Map<String, dynamic> userData = {
      'role': role,
      'email': email,
      'wallet': 0.0,
      'username': username
    }; //role: s for student, m for moderator, d for driver
    if (name != null) userData['username'] = name;
    _firestore.collection('users').add(userData);
  }

  static void addDriver(String email, bool busy, String driverType) async {
    Map<String, dynamic> driverData = {
      'busy': busy,
      'email': email,
      'av_seats': 30,
      'bookingsCount': 0,
      'driverType': driverType,
      "latitude": 31.995384266632275,
      "longitude": 35.92004926835121
    }; //role: s for student, m for moderator, d for driver
    DocumentReference driverid =
        await _firestore.collection('drivers').add(driverData);
  }

  getDriverTypeByEmail(String email) async {
    String email;

    await _firestore
        .collection('drivers')
        .where('email', isEqualTo: 'email')
        .get()
        .then((value) => email = value.docs[0]['driverType']);

    return email;
  }

  static Future<QuerySnapshot> getBookingsDocs(String driverType) async {
    return await _firestore
        .collection('bookings')
        .where('driverType', isEqualTo: driverType)
        .get();
  }

//todo:123
  static void updateDriverBookingsTypeFromTo(
      String oldType, String newType) async {
    //done
    QuerySnapshot currentBookings = await getBookingsDocs(oldType);
    for (int i = 0; i < currentBookings.docs.length; i++) {
      await _firestore
          .collection('bookings')
          .doc(currentBookings.docs[i].id)
          .update({'driverType': newType});
    }
  }

  static void updateDriverTypeFromTo(String oldType, String newType) async {
    String driverId = await getDriverId(oldType);
    if (!driverId.contains("Error"))
      await _firestore
          .collection('drivers')
          .doc(driverId)
          .update({'driverType': newType});
  }

  static void updateDriverLocation(
    double latitude,
    double longitude,
    double heading,
    String email,
  ) async {
    String driverId = await getDriverIdByEmail(email);
    if (!driverId.contains("Error"))
      await _firestore.collection('drivers').doc(driverId).update(
          {'latitude': latitude, 'longitude': longitude, 'heading': heading});
  }

//todo
  static void deleteMovedDriverBooking(String param, String email) async {
    _firestore
        .collection('bookings')
        .where(param, isEqualTo: email)
        .get()
        .then((snapshot) {
      for (DocumentSnapshot ds in snapshot.docs) {
        ds.reference.delete();
      }
      ;
    });
  }

  static void updateMovedStudentBookingState(String email) async {
    _firestore
        .collection('bookings')
        .where("userEmail", isEqualTo: email)
        .get()
        .then((snapshot) {
      for (DocumentSnapshot ds in snapshot.docs) {
        ds.reference.update({'state': "picked"});
      }
      ;
    });
  }

  static void updateAllMovedStudentsBookingState() async {
    _firestore.collection('bookings').get().then((snapshot) {
      for (DocumentSnapshot ds in snapshot.docs) {
        ds.reference.update({'state': "picked"});
      }
      ;
    });
  }

  static Future<void> deleteDriver(email) async {
    //done
    await _firestore
        .collection('drivers')
        .where('email', isEqualTo: email)
        .get()
        .then((snapshot) {
      for (DocumentSnapshot ds in snapshot.docs) {
        ds.reference.delete();
      }
      ;
    });
  }

  static Future<String> getDriverId(driverType) async {
    //done
    QuerySnapshot driver = await _firestore
        .collection('drivers')
        .where('driverType', isEqualTo: driverType)
        .get();

    if (driver.docs.length < 1) return "Error: no drivers";
    return driver.docs[0].id;
  }

  static Future<String> getDriverIdByEmail(email) async {
    //done
    QuerySnapshot driver = await _firestore
        .collection('drivers')
        .where('email', isEqualTo: email)
        .get();

    if (driver.docs.isEmpty) return "Error: no drivers";
    return driver.docs[0].id;
  }

  static Future<String> getDriverEmail(String driverType) async {
    var drivers = await _firestore
        .collection('drivers')
        .where('driverType', isEqualTo: driverType)
        .get();
    if (drivers.docs.length > 0) return drivers.docs[0]['email'];
    return "";
  }

  static Future<String> addBooking(String email, String username,
      double longitude, double latitude, String locationName) async {
    //dd
    //done
    Map<String, dynamic> bookingData = {
      'userEmail': email,
      'username': username,
      'longitude': longitude,
      'latitude': latitude,
      'heading': 0,
      'locationName': locationName,
      'driverType': 'current',
      'state': 'not_picked'
    };

    String driverId = await getDriverId("current");
    if (!driverId.contains('Error')) {
      bool busy = await _getDriverBusyState("current");
      String driverEmail = await getDriverEmail('current');
      bookingData['driverEmail'] = driverEmail;
      int avSeats =
          await getNumberOFAvailableSeats("current", currentEmail: driverEmail);
      if (!busy && avSeats > 2) {
        try {
          print(driverId);

          _firestore.collection('bookings').add(bookingData);
          updateBookingsCountAndNumOfAvailableSeats('current',
              currentEmail: driverEmail);
        } on FirebaseException catch (e) {
          print(e.message);
          return "Error: There are no busses currently available";
        }
        return "";
      } else {
        print("bla");
        String driverId = await getDriverId("next");
        if (!driverId.contains("Error")) {
          print("Afffffff");
          int bc = await _getBookingsCount('next');
          if (bc != -1 && bc < 8) {
            try {
              String driverEmail = await getDriverEmail('next');
              bookingData['driverEmail'] = driverEmail;
              bookingData['driverType'] = 'next';
              _firestore.collection('bookings').add(bookingData);
              updateBookingsCountAndNumOfAvailableSeats('next');
            } on FirebaseException catch (e) {
              print(e.message);
              return "Error: There are no busses currently available";
            }
          } else
            return "Error: There are no busses currently available";

          return "";
        } else {
          print("QADSFASDFWSDFASDF");
          return "Error: There are no busses currently available";
        }
      }
    }

    return "Error: There are no busses currently available";
  }

  static Stream<QuerySnapshot> getAllBookingsStream(String email) {
    //dd
    print("SDF");
    var bookings = _firestore
        .collection('bookings')
        .where('driverEmail', isEqualTo: email)
        .snapshots();
    bookings.forEach((element) {
      print("ASD");
    });
    return bookings;
  }

  static Future<String> checkIfThereIsAlreadyADriver(String driverType) async {
    var driver = await _firestore
        .collection('drivers')
        .where('driverType', isEqualTo: driverType)
        .get();
    if (driver.docs.length > 0) {
      return "Error: There is already a driver";
    }
    return "";
  }

  static Future<String> checkIfTheLoggedInUserIsACurrentOrNextDriver(
      String email) async {
    var driver = await _firestore
        .collection('drivers')
        .where('email', isEqualTo: email)
        .get();
    if (driver.docs.length > 0) {
      return driver.docs[0].data()['driverType'];
    }
    return "";
  }

  //todo:
  static Stream<QuerySnapshot> getDriver(String email) {
    var drivers = _firestore
        .collection('drivers')
        .where('email', isEqualTo: email)
        .snapshots();

    return drivers;
  }

  static Future<int> _getBookingsCount(String driverType) async {
    //done
    int bookingsCount = -1;
    try {
      String driverId = await getDriverId(driverType);
      await _firestore.collection('drivers').doc(driverId).get().then((value) {
        if (value.exists) bookingsCount = value['bookingsCount'];
      });
    } on FirebaseException catch (e) {
      print(e.message);
      return -1;
    }
    return bookingsCount;
  }

  static Future<int> getNumberOFAvailableSeats(String driverType,
      {String currentEmail}) async {
    //done
    int AvSeats = -1;
    try {
      String driverId = await getDriverId(driverType);
      if (driverType == "current")
        await referenceRealtime
            .child("current_av_seats")
            .once()
            .then((DataSnapshot snapshot) {
          AvSeats = snapshot.value; //retrieve number of bookings made;
        });
      else {
        await _firestore
            .collection('drivers')
            .doc(driverId)
            .get()
            .then((value) {
          if (value.exists) AvSeats = value['av_seats'];
        });
      }
    } on FirebaseException catch (e) {
      print(e.message);
      return -1;
    }
    return AvSeats;
  }

  static Future<int> updateBookingsCountAndNumOfAvailableSeats(
      String driverType,
      {String currentEmail}) async {
    //done
    int bookingsCount = await _getBookingsCount(driverType);
    String driverId = await getDriverId(driverType);
    _firestore
        .collection('drivers')
        .doc(driverId)
        .update({'bookingsCount': bookingsCount + 1});

    if (driverType == "current")
      referenceRealtime
          .child("current_av_seats")
          .once()
          .then((DataSnapshot snapshot) {
        int value = snapshot.value; //retrieve number of bookings made;
        value--;
        referenceRealtime.child('current_av_seats').set(value).asStream();
      });
    else {
      int avSeats = await getNumberOFAvailableSeats(driverType,
          currentEmail: currentEmail);
      _firestore
          .collection('drivers')
          .doc(driverId)
          .update({'av_seats': avSeats - 1});
    }
  }

  static setCurrentAvSeatsRealtimeDatabase(String email, int num) {
    referenceRealtime.child('current_av_seats').set(num).asStream();
  }

  static setCurrentDriverEmailInRealtime(String email) {
    referenceRealtime.child('current_email').set(email).asStream();
  }

  static Future<bool> _getDriverBusyState(String driverType) async {
    //done
    bool busy;

    await _firestore
        .collection('drivers')
        .where('driverType', isEqualTo: driverType)
        .get()
        .then((value) => busy = value.docs[0]['busy']);
    return busy;
  }

  static Future<String> getUserRole(String email) async {
    String role = "";
    var users = await _firestore
        .collection('users')
        .where('email', isEqualTo: email)
        .get();
    role = users.docs[0]['role'];

    return role;
  }

  static Future<String> getUsername(User user) async {
    String username = "";
    if (user != null) {
      var users = await _firestore
          .collection('users')
          .where('email', isEqualTo: user.email)
          .get();

      username = await users.docs[0].data()['username'];

      // await referenceDatabase
      //     .child('users')
      //     .child(user.uid)
      //     .child('username')
      //     .once()
      //     .then((DataSnapshot snapshot) {
      //   val = snapshot.value;
      // });
    }

    return username;
  }

  static Future<double> getWallet(User user) async {
    double wallet = 0;
    if (user != null) {
      var users = await _firestore
          .collection('users')
          .where('email', isEqualTo: user.email)
          .get();

      wallet = await users.docs[0].data()['wallet'];
    }

    return wallet;
  }

  static Future<String> _getUserIdFromEmail(email) async {
    String id = "";
    try {
      var users = await _firestore
          .collection('users')
          .where('email', isEqualTo: email)
          .get();
      if (users.docs.length > 0)
        id = users.docs[0].id;
      else
        return "Error: The email does not exist";
    } on FirebaseException catch (e) {
      return "Error: " + e.message;
    }

    return id;
  }

  static Future<double> _getWalletFromId(id) async {
    double wallet = 12342;
    Future<DocumentSnapshot> user =
        _firestore.collection('users').doc(id).get();
    await user.then((value) {
      print(value['wallet']);
      wallet = value['wallet'];
    });
    return wallet;
  }

  static Future<String> updateWallet(double amount, String email) async {
    String id =
        await _getUserIdFromEmail(email); //to know which user we need to update

    if (id.startsWith("Error")) return id;

    double wallet = await _getWalletFromId(id); //get current wallet amount

    _firestore.collection('users').doc(id).update({'wallet': amount + wallet});

    return "";
  }

  static Future<void> updateCode(String type, String codeValue) {
    _firestore
        .collection('codes')
        .doc("w37slNt3EwkqteVc4XOm")
        .update({type: codeValue});
  }

  static Future<String> getRoleFromCode(String code) async {
    String modCode = "";
    String driverCode = "";

    await _firestore
        .collection('codes')
        .doc("w37slNt3EwkqteVc4XOm")
        .get()
        .then((value) {
      modCode = value.data()["moderator"];
      print(value.data()["moderator"]);
      driverCode = value.data()["driver"];
    });
    if (code == driverCode)
      return "d";
    else if (code == modCode)
      return "m";
    else
      return "s";
  }

  static Stream<QuerySnapshot> findBookingByEmail(String email) {
    var v = _firestore
        .collection('bookings')
        .where('userEmail', isEqualTo: email)
        .snapshots();
    return v;
  }

  changeState(id) {
    _firestore.collection('bookings').doc(id).update({'state': "picked"});
  }

  static Stream<QuerySnapshot> getLocationsStream() {
    var v = _firestore.collection('locations').snapshots();
    v.forEach((element) {
      print(element.docs[0]['name']);
    });
    return v;
  }

  static Future<int> getLocationsLength() async {
    int l = -1;
    var v = await _firestore
        .collection('locations')
        .get()
        .then((value) => l = value.docs.length);
    return l;
  }

  static Future<void> addLocation(
      String name, double latitude, double longitude) async {
    int length = await getLocationsLength();
    var data = {
      'name': name,
      'latitude': latitude,
      'longitude': longitude,
      'index': length
    };
    _firestore.collection('locations').add(data);
  }

  static Future<void> deleteLocation(String name) async {
    print(name);
    _firestore
        .collection('locations')
        .where("name", isEqualTo: name)
        .get()
        .then((snapshot) {
      for (DocumentSnapshot ds in snapshot.docs) {
        ds.reference.delete();
      }
    });
  }
}
