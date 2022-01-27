import 'package:flutter/material.dart';
import 'package:just_busses/theme/app_colors.dart';

class DialogBoxes {
  static void showErrorDialogBox(String msg, context) {
    showDialog<String>(
        context: context,
        builder: (BuildContext context) => AlertDialog(
              title: Text(msg),
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
                    Navigator.pop(context, "Ok");
                  },
                ),
              ],
            ));
  }
}
