import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:just_busses/components/scrollable_background_container.dart';
import 'package:just_busses/helpers/authentication_service.dart';
import 'package:just_busses/helpers/database_methods.dart';
import 'package:just_busses/helpers/dialog_boxes.dart';
import 'package:just_busses/theme/app_colors.dart';
import 'package:just_busses/theme/app_typography.dart';
import 'package:just_busses/views/driver/driver_map.dart';
import 'package:just_busses/views/student/log_in.dart';
import 'package:just_busses/views/student/student_home.dart';
import 'package:provider/provider.dart';

class Screen2 extends StatelessWidget {
  final String driverType;

  const Screen2({@required this.driverType});
  @override
  Widget build(BuildContext context) {
    return ScrollableBackgroundContainer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisAlignment: MainAxisAlignment.center,
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
              'Is the main terminal busy?',
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
              onPressed: () {
                DatabaseMethods.addDriver(
                    Provider.of<User>(context, listen: false).email,
                    true,
                    driverType);
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => DriverMap(
                      driverType: driverType,
                    ),
                  ),
                );
              },
              child: Text(
                'Yes',
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
                DatabaseMethods.addDriver(
                    Provider.of<User>(context, listen: false).email,
                    false,
                    driverType);
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => DriverMap(
                      driverType: driverType,
                    ),
                  ),
                );
              },
              child: Text(
                'No',
                style: AppTypography.buttonText,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
