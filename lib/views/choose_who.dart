import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:just_busses/theme/app_typography.dart';
import 'package:just_busses/views/student/sign_up.dart';

class ChooseWho extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF3F6274),
      body: Container(
        padding: EdgeInsets.all(30.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AnimatedTextKit(
              animatedTexts: [
                TyperAnimatedText(
                  "Choose who you are?",
                  textStyle: AppTypography.title,
                ),
              ],
            ),
            SizedBox(
              height: 20.0,
            ),
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: FlatButton.icon(
                height: 50.0,
                color: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.0),
                ),
                label: Text(
                  'Moderator',
                  style: AppTypography.header3,
                ),
                icon: Icon(
                  FontAwesomeIcons.userTie,
                  color: Color(0xFF3F6274),
                ),
                onPressed: () {},
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: FlatButton.icon(
                height: 50.0,
                color: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.0),
                ),
                label: Text(
                  'Student',
                  style: AppTypography.header3,
                ),
                icon: Icon(FontAwesomeIcons.chalkboardTeacher),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => SignUp(),
                    ),
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: FlatButton.icon(
                height: 50.0,
                color: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.0),
                ),
                label: Text(
                  'Driver',
                  style: AppTypography.header3,
                ),
                icon: Icon(
                  Icons.directions_bus,
                ),
                onPressed: () {},
              ),
            ),
          ],
        ),
      ),
    );
  }
}
