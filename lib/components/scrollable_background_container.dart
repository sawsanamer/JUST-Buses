import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:just_busses/theme/app_colors.dart';

class ScrollableBackgroundContainer extends StatelessWidget {
  ScrollableBackgroundContainer(
      {@required this.child,
      this.padding = const EdgeInsets.only(top: 124.0, bottom: 58.0)});
  final Widget child;
  final EdgeInsets padding;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(children: [
        Stack(
          children: [
            Container(
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  image: DecorationImage(
                      image: AssetImage("assets/background.jpg"),
                      fit: BoxFit.cover,
                      alignment: Alignment.topCenter),
                )),
            Container(
              decoration: BoxDecoration(
                  gradient: LinearGradient(colors: [
                AppColors.aquaBlue.withOpacity(0.8),
                AppColors.orange.withOpacity(0.6),
                Colors.redAccent.withOpacity(0.7)
              ], begin: Alignment.topCenter)),
            )
          ],
        ),
        SingleChildScrollView(
          child: Container(
              height: MediaQuery.of(context).size.height,
              padding: this.padding,
              child: this.child),
        ),
      ]),
    );
  }
}
