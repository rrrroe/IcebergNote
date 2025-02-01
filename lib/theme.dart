import 'package:flutter/material.dart';

// class AppColor {
//   Color colorBackgroundLight = const Color.fromARGB(255, 26, 148, 188);
//   Color colorBackgroundMid = const Color.fromARGB(255, 23, 129, 181);
//   Color colorBackgroundDark = const Color.fromARGB(255, 20, 74, 116);

//   Color colorfontLight = const Color.fromARGB(255, 208, 223, 230);
//   Color colorfontMid = const Color.fromARGB(255, 23, 129, 181);
//   Color colorfontDark = const Color.fromARGB(255, 15, 20, 35);

//   Color colorErr = const Color.fromARGB(255, 15, 20, 35);
// }
class AppColor {
  Color colorBackgroundLight = const Color.fromARGB(255, 229, 240, 251);
  Color colorBackgroundMid = const Color.fromARGB(255, 23, 129, 181);
  Color colorBackgroundDark = const Color.fromARGB(255, 20, 74, 116);

  Color colorfontLight = const Color.fromARGB(255, 0, 140, 198);
  Color colorfontMid = const Color.fromARGB(255, 23, 129, 181);
  Color colorfontDark = const Color.fromARGB(255, 15, 20, 35);

  Color colorErr = const Color.fromARGB(255, 240, 75, 75);
}

class TodoColor {
  Color todoFont = const Color(0xFF7D7D7D);
  Color todoBackground = const Color(0xFFD1D1D1);
  Color inprogressFont = const Color(0xFF8D6748);
  Color inprogressground = const Color(0xFFF4E1A1);
  Color doneFont = const Color(0xFF4B8A4E);
  Color doneBackground = const Color(0xFFA8D5BA);
  Color giveupFont = const Color(0xFFB2625E);
  Color giveupBackground = const Color(0xFFF1C6D6);
}

TodoColor todoColor = TodoColor();

enum MacaronColors {
  pink,
  blue,
  green,
  purple,
  yellow,
  peach,
}

extension MacaronColorExtension on MacaronColors {
  // 使用扩展方法为每个枚举值关联一个柔和的背景颜色
  Color get color {
    switch (this) {
      case MacaronColors.pink:
        return const Color(0xFFF8D0D8); // 轻柔马卡龙粉
      case MacaronColors.blue:
        return const Color(0xFFB6D8F7); // 轻柔马卡龙蓝
      case MacaronColors.green:
        return const Color(0xFFC3E1D9); // 轻柔马卡龙绿
      case MacaronColors.purple:
        return const Color(0xFFD6A8D1); // 轻柔马卡龙紫
      case MacaronColors.yellow:
        return const Color(0xFFF9E6A6); // 轻柔马卡龙黄
      case MacaronColors.peach:
        return const Color(0xFFF2D2C7); // 轻柔马卡龙桃
      default:
        return Colors.transparent; // 默认颜色
    }
  }
}
