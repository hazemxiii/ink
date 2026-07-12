import 'dart:ui';

enum InkThemeType { dark, light, system }

abstract class InkTheme {
  Color get backC;
  Color get mainC;
  Color get textC;
  Color get secTextC;
  Color get boxesBackC;
  Color get borderC;
  Color get errorC;
}
