import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:flutter/widgets.dart';

enum RoundedButtonVariant {
  filled,
  outline,
}

class RoundedButton extends StatelessWidget {
  const RoundedButton(
      {@required this.text,
      @required this.onPressed,
      this.color = Colors.black,
      this.variant = RoundedButtonVariant.filled,
      this.margin = EdgeInsets.zero,
      this.height = 48,
      this.style,
      this.elevation,
      this.width});

  final RoundedButtonVariant variant;
  final Color color;
  final EdgeInsets margin;
  final String text;
  final Function onPressed;
  final double borderRadius = 16.0;
  final double height;
  final double elevation;
  final TextStyle style;
  final width;
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: margin,
      child: SizedBox(
        width: width ?? double.infinity,
        height: height,
        child: buildButton(),
      ),
    );
  }

  Widget buildButton() {
    if (this.variant == RoundedButtonVariant.filled)
      return buildFilledButton();
    else
      return buildOutlineButton();
  }

  Widget buildOutlineButton() {
    return OutlineButton(
      highlightedBorderColor: this.color.withOpacity(0.5),
      onPressed: this.onPressed,
      child: new Text(this.text,
          style: style == null
              ? TextStyle(
                  color: this.color,
                  fontSize: 16,
                )
              : style.copyWith(
                  color: this.color,
                )),
      color: this.color,
      borderSide:
          new BorderSide(width: 3, color: this.color, style: BorderStyle.solid),
      shape: new RoundedRectangleBorder(
        borderRadius: new BorderRadius.circular(this.borderRadius),
      ),
    );
  }

  Widget buildFilledButton() {
    Color textColor =
        (this.color.computeLuminance() > 0.5 ? Colors.black : Colors.white);
    return ElevatedButton(
      onPressed: this.onPressed,
      child: new Text(
        this.text,
        style: style == null
            ? TextStyle(
                color: textColor,
                fontSize: 16,
              )
            : style.copyWith(color: textColor),
      ),
      style: ButtonStyle(
          backgroundColor: MaterialStateProperty.all<Color>(this.color),
          elevation: MaterialStateProperty.all(elevation),
          shape: MaterialStateProperty.all(new RoundedRectangleBorder(
              borderRadius: new BorderRadius.circular(this.borderRadius)))),
    );
  }
}
