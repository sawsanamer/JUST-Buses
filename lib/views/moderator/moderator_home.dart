import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:just_busses/components/app_text_field.dart';
import 'package:just_busses/components/background_container.dart';
import 'package:just_busses/components/rounded_button.dart';
import 'package:just_busses/components/scrollable_background_container.dart';
import 'package:just_busses/helpers/authentication_service.dart';
import 'package:just_busses/helpers/database_methods.dart';
import 'package:just_busses/helpers/dialog_boxes.dart';
import 'package:just_busses/helpers/form_validators.dart';
import 'package:just_busses/theme/app_colors.dart';
import 'package:just_busses/theme/app_typography.dart';
import 'package:just_busses/views/student/log_in.dart';
import 'package:provider/provider.dart';

class ModeratorHome extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    TextEditingController studentEmailController = TextEditingController();
    TextEditingController moneyController = TextEditingController();
    ;
    TextEditingController moderatorCodeController = TextEditingController();
    ;
    TextEditingController driverCodeController = TextEditingController();

    TextEditingController locationNameController = TextEditingController();
    TextEditingController latitudeController = TextEditingController();
    TextEditingController longitudeController = TextEditingController();

    updateWallet(context) async {
      String msg = await DatabaseMethods.updateWallet(
          double.parse(moneyController.text), studentEmailController.text);
      if (msg != "")
        DialogBoxes.showErrorDialogBox(msg, context);
      else
        Navigator.pop(context);
    }

    return ScrollableBackgroundContainer(
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            IconButton(
                icon: Icon(
                  Icons.logout,
                ),
                onPressed: () {
                  Provider.of<AuthenticationService>(context, listen: false)
                      .signOut();
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => LogIn()),
                  );
                }),
            Padding(
              padding: const EdgeInsets.only(left: 16.0, right: 16, top: 100),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  RoundedButton(
                    text: 'Add to student wallet',
                    color: Colors.white,
                    style: AppTypography.buttonText,
                    height: 55.0,
                    onPressed: () {
                      showDialog<String>(
                        context: context,
                        builder: (BuildContext context) => AlertDialog(
                          title: Column(
                            children: [
                              Text('Enter student Email and amount to add:'),
                              TextField(
                                decoration: InputDecoration(
                                  labelText: 'Student Email',
                                  prefixIcon: Icon(Icons.email),
                                ),
                                controller: studentEmailController,
                                keyboardType: TextInputType.emailAddress,
                              ),
                              TextField(
                                decoration: InputDecoration(
                                  labelText: 'Amount to add',
                                  prefixIcon: Icon(Icons.money),
                                ),
                                controller: moneyController,
                                keyboardType: TextInputType.number,
                              ),
                            ],
                          ),
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
                                updateWallet(context);
                              },
                              child: const Text(
                                'Confirm',
                                style: TextStyle(color: AppColors.aquaBlue),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                  SizedBox(
                    height: 20.0,
                  ),
                  RoundedButton(
                    text: 'Change driver code',
                    color: Colors.white,
                    style: AppTypography.buttonText,
                    height: 55.0,
                    onPressed: () {
                      showDialog<String>(
                        context: context,
                        builder: (BuildContext context) => AlertDialog(
                          title: Column(
                            children: [
                              Text("Type the new driver code:"),
                              SizedBox(
                                height: 10,
                              ),
                              TextField(
                                obscureText: true,
                                decoration: InputDecoration(
                                  prefixIcon: Icon(Icons.security),
                                ),
                                controller: driverCodeController,
                              ),
                            ],
                          ),
                          actions: <Widget>[
                            FlatButton(
                              onPressed: () => Navigator.pop(context, 'Cancel'),
                              child: const Text(
                                'Cancel',
                                style: TextStyle(color: AppColors.aquaBlue),
                              ),
                            ),
                            FlatButton(
                              onPressed: () {
                                DatabaseMethods.updateCode(
                                    "driver", driverCodeController.text);

                                Navigator.pop(context);
                              },
                              child: const Text(
                                'Confirm',
                                style: TextStyle(color: AppColors.aquaBlue),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                  SizedBox(
                    height: 20.0,
                  ),
                  RoundedButton(
                    text: 'Change moderator code',
                    color: Colors.white,
                    style: AppTypography.buttonText,
                    height: 55.0,
                    onPressed: () {
                      showDialog<String>(
                        context: context,
                        builder: (BuildContext context) => AlertDialog(
                          title: Column(
                            children: [
                              Text("Type the new moderator code:"),
                              SizedBox(
                                height: 10,
                              ),
                              TextField(
                                obscureText: true,
                                decoration: InputDecoration(
                                  prefixIcon: Icon(Icons.security),
                                ),
                                controller: moderatorCodeController,
                              ),
                            ],
                          ),
                          actions: <Widget>[
                            FlatButton(
                              onPressed: () => Navigator.pop(context, 'Cancel'),
                              child: const Text(
                                'Cancel',
                                style: TextStyle(color: AppColors.aquaBlue),
                              ),
                            ),
                            FlatButton(
                              onPressed: () {
                                DatabaseMethods.updateCode(
                                    "moderator", moderatorCodeController.text);
                                Navigator.pop(context);
                              },
                              child: const Text(
                                'Confirm',
                                style: TextStyle(color: AppColors.aquaBlue),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                  SizedBox(
                    height: 20.0,
                  ),
                  RoundedButton(
                    text: 'Add a location',
                    color: Colors.white,
                    style: AppTypography.buttonText,
                    height: 55.0,
                    onPressed: () {
                      showDialog<String>(
                        context: context,
                        builder: (BuildContext context) => AlertDialog(
                          title: Column(
                            children: [
                              Text('Enter location information'),
                              TextField(
                                decoration: InputDecoration(
                                  labelText: 'Location name',
                                  prefixIcon: Icon(Icons.location_city),
                                ),
                                controller: locationNameController,
                                keyboardType: TextInputType.emailAddress,
                              ),
                              TextField(
                                decoration: InputDecoration(
                                  labelText: 'Latitude',
                                  prefixIcon: Icon(Icons.location_on),
                                ),
                                controller: latitudeController,
                                keyboardType: TextInputType.number,
                              ),
                              TextField(
                                decoration: InputDecoration(
                                  labelText: 'Longitude',
                                  prefixIcon: Icon(Icons.location_on),
                                ),
                                controller: longitudeController,
                                keyboardType: TextInputType.number,
                              ),
                            ],
                          ),
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
                                DatabaseMethods.addLocation(
                                    locationNameController.text,
                                    double.parse(latitudeController.text),
                                    double.parse(longitudeController.text));
                                Navigator.pop(context);
                              },
                              child: const Text(
                                'Confirm',
                                style: TextStyle(color: AppColors.aquaBlue),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                  SizedBox(
                    height: 20.0,
                  ),
                  RoundedButton(
                    text: 'Delete a location',
                    color: Colors.white,
                    style: AppTypography.buttonText,
                    height: 55.0,
                    onPressed: () {
                      showDialog<String>(
                        context: context,
                        builder: (BuildContext context) => AlertDialog(
                          title: Column(
                            children: [
                              Text('Enter location name'),
                              TextField(
                                decoration: InputDecoration(
                                  labelText: 'Location name',
                                  prefixIcon: Icon(Icons.location_city),
                                ),
                                controller: locationNameController,
                                keyboardType: TextInputType.emailAddress,
                              ),
                            ],
                          ),
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
                                DatabaseMethods.deleteLocation(
                                  locationNameController.text,
                                );
                                Navigator.pop(context);
                              },
                              child: const Text(
                                'Confirm',
                                style: TextStyle(color: AppColors.aquaBlue),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
            SizedBox(
              height: 260,
            )
          ],
        ),
      ),
    );
  }
}
