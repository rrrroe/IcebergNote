// Copyright 2021 The Flutter team. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

// ignore_for_file: constant_identifier_names

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
// import 'package:permission_handler/permission_handler.dart';

// NavigationRail shows if the screen width is greater or equal to
// narrowScreenWidthThreshold; otherwise, NavigationBar is used for navigation.
const double narrowScreenWidthThreshold = 450;

const double mediumWidthBreakpoint = 1000;
const double largeWidthBreakpoint = 1500;

const double transitionLength = 500;

class APPConstants {
  static const String appName = '冰山记';
  static const String logoTag = 'icebergnotelogo';
  static const String titleTag = 'icebergnotetitle';
}

List<String> defaultAddTypeList = ['.待办', '.清单', '.记录', '.日子'];

enum ColorSeed {
  baseColor('M3 Baseline', Color(0xff6750a4)),
  indigo('Indigo', Colors.indigo),
  blue('Blue', Colors.blue),
  teal('Teal', Colors.teal),
  green('Green', Colors.green),
  yellow('Yellow', Colors.yellow),
  orange('Orange', Colors.orange),
  deepOrange('Deep Orange', Colors.deepOrange),
  pink('Pink', Colors.pink);

  const ColorSeed(this.label, this.color);
  final String label;
  final Color color;
}

enum ScreenSelected {
  star(0),
  component(1),
  todo(2),
  color(3),
  elevation(4),
  habit(5);

  const ScreenSelected(this.value);
  final int value;
}

ButtonStyle selectButtonStyle = ElevatedButton.styleFrom(
  foregroundColor: const Color.fromARGB(15, 233, 239, 247),
  backgroundColor: const Color.fromARGB(200, 233, 239, 247),
  shape: RoundedRectangleBorder(
    borderRadius: BorderRadius.circular(10),
  ),
  padding: const EdgeInsets.all(0),
);
ButtonStyle selectedContextButtonStyle = ElevatedButton.styleFrom(
  foregroundColor: const Color.fromARGB(255, 0, 0, 0),
  backgroundColor: const Color.fromARGB(255, 255, 255, 255),
  shape: RoundedRectangleBorder(
    borderRadius: BorderRadius.circular(5),
  ),
  padding: const EdgeInsets.all(0),
);
ButtonStyle transparentContextButtonStyle = ElevatedButton.styleFrom(
  foregroundColor: const Color.fromARGB(0, 0, 0, 0),
  backgroundColor: const Color.fromARGB(0, 255, 255, 255),
  shape: RoundedRectangleBorder(
    borderRadius: BorderRadius.circular(5),
  ),
  padding: const EdgeInsets.all(0),
);
ButtonStyle menuChildrenButtonStyle = ElevatedButton.styleFrom(
  alignment: Alignment.center,
  padding: const EdgeInsets.fromLTRB(8, 0, 0, 0),
  minimumSize: const Size(64, 36),
);
MenuStyle menuAnchorStyle = MenuStyle(
  maximumSize: WidgetStateProperty.all(const Size(250, 250)),
  padding: WidgetStateProperty.all(const EdgeInsets.all(0)),
  visualDensity: VisualDensity.compact,
);

enum Toast {
  /// Show Short toast for 1 sec
  LENGTH_SHORT,

  /// Show Long toast for 5 sec
  LENGTH_LONG
}

enum ToastGravity {
  TOP,
  BOTTOM,
  CENTER,
  TOP_LEFT,
  TOP_RIGHT,
  BOTTOM_LEFT,
  BOTTOM_RIGHT,
  CENTER_LEFT,
  CENTER_RIGHT,
  SNACKBAR,
  NONE
}

/// Plugin to show a toast message on screen
/// Only for android, ios and Web platforms
class Fluttertoast {
  /// [MethodChannel] used to communicate with the platform side.
  static const MethodChannel _channel =
      MethodChannel('PonnamKarthik/fluttertoast');

  /// Let say you have an active show
  /// Use this method to hide the toast immediately
  static Future<bool?> cancel() async {
    bool? res = await _channel.invokeMethod("cancel");
    return res;
  }

  /// Summons the platform's showToast which will display the message
  ///
  /// Wraps the platform's native Toast for android.
  /// Wraps the Plugin https://github.com/scalessec/Toast for iOS
  /// Wraps the https://github.com/apvarun/toastify-js for Web
  ///
  /// Parameter [msg] is required and all remaining are optional
  static Future<bool?> showToast({
    required String msg,
    Toast? toastLength,
    int timeInSecForIosWeb = 1,
    double? fontSize,
    ToastGravity? gravity,
    Color? backgroundColor,
    Color? textColor,
    bool webShowClose = false,
    webBgColor = "linear-gradient(to right, #00b09b, #96c93d)",
    webPosition = "right",
  }) async {
    String toast = "short";
    if (toastLength == Toast.LENGTH_LONG) {
      toast = "long";
    }

    String gravityToast = "bottom";
    if (gravity == ToastGravity.TOP) {
      gravityToast = "top";
    } else if (gravity == ToastGravity.CENTER) {
      gravityToast = "center";
    } else {
      gravityToast = "bottom";
    }

//lines from 78 to 97 have been changed in order to solve issue #328
    backgroundColor ??= Colors.black;
    textColor ??= Colors.white;
    final Map<String, dynamic> params = <String, dynamic>{
      'msg': msg,
      'length': toast,
      'time': timeInSecForIosWeb,
      'gravity': gravityToast,
      'bgcolor': backgroundColor.value,
      'iosBgcolor': backgroundColor.value,
      'textcolor': textColor.value,
      'iosTextcolor': textColor.value,
      'fontSize': fontSize,
      'webShowClose': webShowClose,
      'webBgColor': webBgColor,
      'webPosition': webPosition
    };

    bool? res = await _channel.invokeMethod('showToast', params);
    return res;
  }
}

// class PermissionUtil {
//   /// 安卓权限
//   static List<Permission> androidPermissions = <Permission>[
//     // 在这里添加需要的权限
//     Permission.storage
//   ];

//   /// ios权限
//   static List<Permission> iosPermissions = <Permission>[
//     // 在这里添加需要的权限
//     Permission.storage
//   ];

//   static Future<Map<Permission, PermissionStatus>> requestAll() async {
//     if (Platform.isIOS) {
//       return await iosPermissions.request();
//     }
//     return await androidPermissions.request();
//   }
// }
