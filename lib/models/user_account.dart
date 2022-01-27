import 'package:firebase_auth/firebase_auth.dart';

class UserAccount {
  String email;
  String password;
  String username;
  User loggedInUser;

  UserAccount({this.email, this.password, this.username});
}
