import 'package:firebase_auth/firebase_auth.dart';
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
import 'package:just_busses/views/driver/screen1.dart';
import 'package:just_busses/views/moderator/moderator_home.dart';
import 'package:provider/provider.dart';
import 'student_home.dart';
import 'log_in.dart';

class SignUp extends StatelessWidget {
  final _accountInfoFormKey = GlobalKey<FormState>();
  final UserAccount _userAccount = UserAccount();
  final _passwordTextController = TextEditingController();
  String role = 's';

  @override
  Widget build(BuildContext context) {
    return ScrollableBackgroundContainer(
      child: ListView(
        // mainAxisSize: MainAxisSize.min,
        // mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Align(
              alignment: Alignment.bottomCenter,
              child: Text(
                "Sign up",
                style: AppTypography.header3.copyWith(color: Colors.white),
              )),
          Form(
              key: this._accountInfoFormKey,
              child: Padding(
                padding:
                    const EdgeInsets.only(left: 24.0, right: 24.0, top: 50.0),
                child: Column(children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: AppTextField(
                      label: "name",
                      prefixIcon: Icon(Icons.supervised_user_circle),
                      validator: FormValidators.presenceValidator,
                      onSaved: (val) => this._userAccount.username = val,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: AppTextField(
                      label: "email",
                      prefixIcon: Icon(Icons.email),
                      validator: FormValidators.emailValidator,
                      onSaved: (val) => this._userAccount.email = val,
                      isEmail: true,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: AppTextField(
                      label: "password",
                      prefixIcon: Icon(Icons.ad_units_outlined),
                      validator: (val) =>
                          FormValidators.lengthValidator(val, 6, 32),
                      onSaved: (val) => this._userAccount.password = val,
                      isPassword: true,
                      controller: _passwordTextController,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: AppTextField(
                      label: "Confirm Password",
                      prefixIcon: Icon(Icons.local_play_outlined),
                      validator: (val) => FormValidators.confirmationValidator(
                          this._passwordTextController.text,
                          val,
                          "Confirmation Password Error"),
                      isPassword: true,
                    ),
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  Text(
                      "Please enter your code if you are a driver or moderator"),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: AppTextField(
                      label: "Code",
                      isPassword: true,
                      prefixIcon: Icon(Icons.supervised_user_circle),
                      onSaved: (val) async {
                        role = await DatabaseMethods.getRoleFromCode(val);
                      },
                    ),
                  ),
                ]),
              )),
          Flexible(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  RoundedButton(
                    text: "Create Account",
                    onPressed: () async {
                      if (_accountInfoFormKey.currentState.validate()) {
                        EasyLoading.show(status: "Loading..");
                        _accountInfoFormKey.currentState.save();

                        String message = await context
                            .read<AuthenticationService>()
                            .signUp(
                                email: _userAccount.email,
                                password: _userAccount.password,
                                name: _userAccount.username);

                        if (message == "") {
                          DatabaseMethods.addUserInfo(
                              role: role,
                              email: _userAccount.email,
                              username: _userAccount.username);
                          EasyLoading.dismiss();

                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(builder: (context) {
                              if (role == "s")
                                return StudentHome();
                              else if (role == "m")
                                return ModeratorHome();
                              else
                                return Screen1();
                            }),
                          );
                          //  Navigator.pushNamed(context, "/signUp/userInfo");
                        } else {
                          EasyLoading.showError(message);
                          //todo: show error message
                        }
                      }
                    },
                    variant: RoundedButtonVariant.outline,
                    color: AppColors.neutrals[200],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text("Have an account?"),
                      TextButton(
                        onPressed: () {
                          //todo: push named
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(builder: (context) => LogIn()),
                          );
                          // Navigator.pushReplacementNamed(
                          //     context, signInRoute);
                        },
                        child: Text("Login"),
                      )
                    ],
                  ),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }
}
