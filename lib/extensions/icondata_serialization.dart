// ignore_for_file: curly_braces_in_flow_control_structures, library_prefixes

import 'package:flutter/material.dart';

String _getIconKey(Map<String, IconData> icons, IconData icon) =>
    icons.entries.firstWhere((iconEntry) => iconEntry.value == icon).key;

Widget iconDataToWidget(String s, double size, double opacity) {
  List<String> tmp = s.split('||');
  if (tmp.length == 3) {
    if (tmp[0] != '' && tmp[1] != '' && tmp[2] != '') {
      if (tmp[0] == 'Image') {
        return Opacity(
          opacity: opacity, // 设置透明度
          child: Image.asset(
            'lib/assets/icon/${tmp[1]}/${tmp[2]}',
          ),
        );
      }
      if (tmp[0] == 'Emoji') {
        return Opacity(
          opacity: opacity, // 设置透明度
          child: Container(
            alignment: Alignment.center, // 确保容器中的子组件居中
            padding: EdgeInsets.all(0),
            child: FittedBox(
              fit: BoxFit.scaleDown, // 防止文字溢出
              child: Text(
                tmp[2], // 显示的文字
                textAlign: TextAlign.center, // 确保文字居中对齐
                style: TextStyle(
                  fontSize: size, // 字体大小
                  height: 1.0, // 调整行高（防止字体内部的偏移）
                ),
              ),
            ),
          ),
        );
      }
    }
  }
  return Opacity(
    opacity: opacity, // 设置透明度
    child: Image.asset(
      'lib/assets/icon/LifeIcon/image19.png',
    ),
  );
}
