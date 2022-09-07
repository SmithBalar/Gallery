import 'package:flutter/material.dart';

class AppText extends StatelessWidget {
  final String text, fontFamily;
  final double fontSize;
  final Color color;
  final FontWeight fontWeight;
  final double? letterSpacing;
  final TextDecoration textDecoration;
  final TextAlign textAlign;
  final int maxLines;
  AppText({
    required this.text,
    this.fontSize = 14,
    this.color = Colors.white,
    this.fontWeight = FontWeight.normal,
    this.fontFamily = 'Poppins',
    this.letterSpacing,
    this.textDecoration = TextDecoration.none,
    this.textAlign = TextAlign.start,
    this.maxLines = 1,
  });

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      textAlign: textAlign,
      overflow: TextOverflow.ellipsis,
      maxLines: maxLines,
      style: TextStyle(
        shadows: [
          Shadow(
            offset: Offset(0.0, 0.0),
            blurRadius: 4.0,
            color: Colors.black,
          )
        ],
        color: color,
        fontFamily: fontFamily,
        fontSize: fontSize,
        fontWeight: fontWeight,
        letterSpacing: letterSpacing,
        decoration: textDecoration,
      ),
    );
  }
}
