import 'dart:ui';

import 'package:ink/core/models/theme/ink_theme.dart';

class InkLightTheme extends InkTheme {
  @override
  Color get backC => const Color(0xFFFCFCFC);

  @override
  Color get borderC => const Color(0xFFDDDEE1);

  @override
  Color get boxesBackC => const Color(0xFFF3F3F5);

  @override
  Color get mainC => const Color(0xFF2580FF);

  @override
  Color get secTextC => const Color(0xFF626269);

  @override
  Color get textC => const Color(0xFF111114);

  @override
  Color get errorC => const Color(0xFFFF007A);
}
