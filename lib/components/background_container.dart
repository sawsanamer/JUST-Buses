import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:just_busses/theme/app_colors.dart';

class BackgroundContainer extends StatelessWidget {
  BackgroundContainer(
      {this.assetPath,
      @required this.child,
      this.linearGradient,
      this.imageUrl});
  final String assetPath;
  final Widget child;
  final Widget linearGradient;
  final String imageUrl;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(children: [
        imageUrl != null || assetPath != null
            ? Container(
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: imageUrl != null
                        ? NetworkImage(imageUrl)
                        : AssetImage(this.assetPath),
                    fit: BoxFit.cover,
                  ),
                ))
            : SizedBox(),
        linearGradient == null ? SizedBox() : linearGradient,
        Container(
          decoration: BoxDecoration(
              gradient: LinearGradient(colors: [
            AppColors.aquaBlue.withOpacity(0.8),
            AppColors.orange.withOpacity(0.6),
            Colors.redAccent.withOpacity(0.7)
          ], begin: Alignment.topCenter)),
        ),
        SafeArea(child: this.child),
      ]),
    );
  }
}
