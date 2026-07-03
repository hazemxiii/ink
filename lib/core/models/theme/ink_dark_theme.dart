import 'dart:ui';

import 'package:ink/core/models/theme/ink_theme.dart';

class InkDarkTheme extends InkTheme {
  @override
  Color get backC => const Color(0xFF0A0A0C);

  @override
  Color get borderC => const Color(0xFF262629);

  @override
  Color get boxesBackC => const Color(0xFF151517);

  @override
  Color get mainC => const Color(0xFF2580FF);

  @override
  Color get secTextC => const Color(0xFF717174);

  @override
  Color get textC => const Color(0xFFF4F4F6);
}
