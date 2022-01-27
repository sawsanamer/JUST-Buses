import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:just_busses/components/scrollable_background_container.dart';
import 'package:just_busses/helpers/authentication_service.dart';
import 'package:just_busses/helpers/database_methods.dart';
import 'package:just_busses/helpers/dialog_boxes.dart';
import 'package:just_busses/theme/app_colors.dart';
import 'package:just_busses/theme/app_typography.dart';
import 'package:just_busses/views/driver/screen2.dart';
import 'package:just_busses/views/student/log_in.dart';
import 'package:provider/provider.dart';

class Screen1 extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ScrollableBackgroundContainer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Align(
            alignment: Alignment.topRight,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: IconButton(
                icon: Icon(
                  Icons.logout,
                  color: Colors.grey[800],
                  size: 30,
                ),
                onPressed: () {
                  Provider.of<AuthenticationService>(context, listen: false)
                      .signOut();
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => LogIn()),
                  );
                },
              ),
            ),
          ),
          Center(
            child: Text(
              'Are you the current or next bus in the terminal?',
              style: AppTypography.buttonText.copyWith(
                color: Colors.white,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          SizedBox(
            height: 60.0,
          ),
          Padding(
            padding: const EdgeInsets.all(15.0),
            child: FlatButton(
              highlightColor: AppColors.lightBlue,
              color: Colors.white,
              height: 40.0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10.0),
              ),
              onPressed: () async {
                String msg = await DatabaseMethods.checkIfThereIsAlreadyADriver(
                    "current");
                if (msg != "")
                  DialogBoxes.showErrorDialogBox(msg, context);
                else {
                  DatabaseMethods.setCurrentDriverEmailInRealtime(
                      Provider.of<User>(context, listen: false).email);
                  DatabaseMethods.setCurrentAvSeatsRealtimeDatabase(
                      Provider.of<User>(context, listen: false).email, 30);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => Screen2(
                              driverType: 'current',
                            )),
                  );
                }
              },
              child: Text(
                'Current Bus',
                style: AppTypography.buttonText,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(15.0),
            child: FlatButton(
              highlightColor: AppColors.lightBlue,
              color: Colors.white,
              height: 40.0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10.0),
              ),
              onPressed: () async {
                String msg =
                    await DatabaseMethods.checkIfThereIsAlreadyADriver("next");
                if (msg != "")
                  DialogBoxes.showErrorDialogBox(msg, context);
                else
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => Screen2(
                              driverType: 'next',
                            )),
                  );
              },
              child: Text(
                'Next Bus',
                style: AppTypography.buttonText,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(15.0),
            child: FlatButton(
              highlightColor: AppColors.lightBlue,
              color: Colors.white,
              height: 40.0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10.0),
              ),
              onPressed: () {
                showDialog<String>(
                    context: context,
                    builder: (BuildContext context) => AlertDialog(
                          title: Text(
                              'Come back when you are the current/next bus in the terminal'),
                          actions: [
                            FlatButton(
                              child: const Text(
                                'OK',
                                style: TextStyle(
                                  color: AppColors.aquaBlue,
                                  fontSize: 16.0,
                                ),
                              ),
                              onPressed: () {
                                Navigator.pop(context, 'OK');
                              },
                            ),
                          ],
                        ));
              },
              child: Text(
                'Neither',
                style: AppTypography.buttonText,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
