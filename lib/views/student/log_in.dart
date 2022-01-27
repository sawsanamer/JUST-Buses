import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:just_busses/components/app_text_field.dart';
import 'package:just_busses/components/rounded_button.dart';
import 'package:just_busses/components/scrollable_background_container.dart';
import 'package:just_busses/helpers/authentication_service.dart';
import 'package:just_busses/helpers/database_methods.dart';
import 'package:just_busses/helpers/form_validators.dart';
import 'package:just_busses/models/user_account.dart';
import 'package:just_busses/theme/app_colors.dart';
import 'package:just_busses/theme/app_typography.dart';
import 'package:just_busses/views/driver/driver_map.dart';
import 'package:just_busses/views/driver/screen1.dart';
import 'package:just_busses/views/moderator/moderator_home.dart';
import 'package:provider/provider.dart';
import 'student_home.dart';
import 'sign_up.dart';

class LogIn extends StatelessWidget {
  final _accountInfoFormKey = GlobalKey<FormState>();
  final UserAccount _userAccount = UserAccount();

  @override
  Widget build(BuildContext context) {
    return ScrollableBackgroundContainer(
      child: Container(
        height: MediaQuery.of(context).size.height,
        padding: EdgeInsets.only(bottom: 40.0),
        child: ListView(
          // mainAxisSize: MainAxisSize.min,
          // mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Align(
              alignment: Alignment.bottomCenter,
              child: Column(
                children: [
                  Text(
                    'Welcome Back!',
                    style: AppTypography.headerMedium,
                  ),
                  Text(
                    'Please Login to your account.',
                  ),
                ],
              ),
            ),
            Form(
                key: _accountInfoFormKey,
                child: Padding(
                  padding:
                      const EdgeInsets.only(left: 24.0, right: 24.0, top: 50.0),
                  child: Column(children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      child: AppTextField(
                        label: 'email',
                        prefixIcon: Icon(Icons.email),
                        validator: FormValidators.emailValidator,
                        onSaved: (val) => _userAccount.email = val,
                        isEmail: true,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      child: AppTextField(
                        label: 'password',
                        prefixIcon: Icon(Icons.lock),
                        isPassword: true,
                        validator: FormValidators.presenceValidator,
                        onSaved: (val) => _userAccount.password = val,
                      ),
                    ),
                  ]),
                )),
            Padding(
              padding: const EdgeInsets.only(left: 24.0, right: 24, top: 190),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  RoundedButton(
                    text: 'Login',
                    onPressed: () async {
                      if (_accountInfoFormKey.currentState.validate()) {
                        EasyLoading.show(status: 'loading..');
                        _accountInfoFormKey.currentState.save();
                        String message = await context
                            .read<AuthenticationService>()
                            .signIn(
                                password: _userAccount.password,
                                email: _userAccount.email);
                        String role;
                        if (message == "") {
                          role = await DatabaseMethods.getUserRole(
                            Provider.of<User>(context, listen: false).email,
                          );
                          String driverType = "";
                          if (role == "d")
                            driverType = await DatabaseMethods
                                .checkIfTheLoggedInUserIsACurrentOrNextDriver(
                                    Provider.of<User>(context, listen: false)
                                        .email);
                          EasyLoading.dismiss();

                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(builder: (context) {
                              if (role == "s")
                                return StudentHome();
                              else if (role == 'm')
                                return ModeratorHome();
                              else if (driverType != "")
                                return DriverMap(
                                  driverType: driverType,
                                );
                              else
                                return Screen1();
                            }),
                          );
                          // Navigator.pushNamed(context, tabsViewRoute);
                        } else {
                          EasyLoading.showError(message);
                        }
                      }
                    },
                    variant: RoundedButtonVariant.outline,
                    color: AppColors.neutrals[200],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('No account?'),
                      TextButton(
                        onPressed: () {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(builder: (context) => SignUp()),
                          );
                        },
                        child: Text(
                          'Sign Up',
                          style: TextStyle(color: Colors.blue),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
