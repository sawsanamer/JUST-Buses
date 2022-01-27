import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:just_busses/helpers/authentication_service.dart';
import 'package:just_busses/helpers/database_methods.dart';
import 'package:just_busses/theme/app_colors.dart';
import 'package:just_busses/theme/app_typography.dart';
import 'package:just_busses/views/student/student_home.dart';
import 'package:just_busses/views/student/log_in.dart';
import 'package:provider/provider.dart';
import 'package:rflutter_alert/rflutter_alert.dart';

class NavDrawer extends StatefulWidget {
  @override
  _NavDrawerState createState() => _NavDrawerState();
}

class _NavDrawerState extends State<NavDrawer> {
  String username = "";
  @override
  void initState() {
    DatabaseMethods.getUsername(Provider.of<User>(context, listen: false))
        .then((value) {
      setState(() {
        username = value;
      });
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final drawerHeader = Center(
        child: UserAccountsDrawerHeader(
            decoration: BoxDecoration(
              color: Colors.cyan[800],
            ),
            accountName: Text(
              username,
              style: AppTypography.bodyMedium,
            ),
            accountEmail: Text(
              context.read<AuthenticationService>().email,
              style: AppTypography.bodyMedium,
            ),
            // onDetailsPressed: () {
            //   showDialog<String>(
            //     context: context,
            //     builder: (BuildContext context) => SimpleDialog(
            //       title: const Text('Dialog Title'),
            //       children: <Widget>[
            //         ListTile(
            //           leading: const Icon(Icons.account_circle),
            //           title: const Text('user@example.com'),
            //           onTap: () => Navigator.pop(context, 'user@example.com'),
            //         ),
            //         ListTile(
            //           leading: const Icon(Icons.account_circle),
            //           title: const Text('user2@gmail.com'),
            //           onTap: () => Navigator.pop(context, 'user2@gmail.com'),
            //         ),
            //         ListTile(
            //           leading: const Icon(Icons.add_circle),
            //           title: const Text('Add account'),
            //           onTap: () => Navigator.pop(context, 'Add account'),
            //         ),
            //       ],
            //     ),
            //   ).then((returnVal) {
            //     if (returnVal != null) {
            //       Scaffold.of(context).showSnackBar(
            //         SnackBar(
            //           content: Text('You clicked: $returnVal'),
            //           action: SnackBarAction(label: 'OK', onPressed: () {}),
            //         ),
            //       );
            //     }
            //   });
            // },
            currentAccountPicture: InkWell(
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, '/profile');
              },
              child: CircleAvatar(
                backgroundColor: Colors.white,
                child: Text('M'),
              ),
            )));
    final drawerItems = ListView(
      children: [
        drawerHeader,
        ListTile(
          title: Text(
            "Wallet",
            style: AppTypography.bodyMedium
                .copyWith(color: AppColors.neutrals[800]),
          ),
          leading: const Icon(Icons.account_balance_wallet_outlined),
          onTap: () async {
            double wallet = await DatabaseMethods.getWallet(
                Provider.of<User>(context, listen: false));

            Alert(
                    context: context,
                    title: "Wallet",
                    desc: "Available Balance: " + wallet.toString() + " JD")
                .show();
          },
        ),
        ListTile(
          title: Text(
            "Log Out",
            style: AppTypography.bodyMedium
                .copyWith(color: AppColors.neutrals[800]),
          ),
          leading: const Icon(Icons.logout),
          onTap: () {
            context.read<AuthenticationService>().signOut();
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => LogIn()),
            );
          },
        ),
        Divider()
      ],
    );
    return Drawer(
      child: drawerItems,
    );
  }
}
