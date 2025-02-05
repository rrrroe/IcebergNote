import 'dart:math';
import 'package:flutter/material.dart';

extension ColorExtension on Color {
  /// Convert the color to a darken color based on the [percent]
  Color darken([int percent = 40]) {
    assert(1 <= percent && percent <= 100);
    final value = 1 - percent / 100;
    return Color.fromARGB(
      alpha,
      (red * value).round(),
      (green * value).round(),
      (blue * value).round(),
    );
  }

  Color lighten([int percent = 40]) {
    assert(1 <= percent && percent <= 100);
    final value = percent / 100;
    return Color.fromARGB(
      alpha,
      (red + ((255 - red) * value)).round(),
      (green + ((255 - green) * value)).round(),
      (blue + ((255 - blue) * value)).round(),
    );
  }

  Color avg(Color other) {
    final red = (this.red + other.red) ~/ 2;
    final green = (this.green + other.green) ~/ 2;
    final blue = (this.blue + other.blue) ~/ 2;
    final alpha = (this.alpha + other.alpha) ~/ 2;
    return Color.fromARGB(alpha, red, green, blue);
  }
}

Color list2color(List l) {
  if (l.length == 3) {
    return Color.fromARGB(255, max(0, min(255, l[0])), max(0, min(255, l[1])),
        max(0, min(255, l[2])));
  }
  return Colors.black;
}

Color hexToColor(String hex) {
  // 确保字符串是 8 位长的十六进制颜色代码
  if (hex.length != 8) {
    throw ArgumentError('Hex color must be 8 characters long, e.g., FF93C8D6');
  }

  // 解析颜色代码
  return Color(int.parse(hex, radix: 16));
}
