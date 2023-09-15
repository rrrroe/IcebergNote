import 'package:flutter/material.dart';

RichText buildRichText(String text, String searchText, TextStyle ordinaryStyle,
    TextStyle highlightStyle) {
  List<TextSpan> richList = [];
  int start = 0;
  int end;

  //遍历，进行多处高亮
  while ((end = text.indexOf(searchText, start)) != -1) {
    //如果搜索内容在开头位置，直接高亮，此处不执行
    if (end != 0) {
      richList.add(TextSpan(
          text: text.substring(start, end).length > 250
              ? '${text.substring(start, start + 100)}……${text.substring(end - 100, end)}'
              : text.substring(start, end),
          style: ordinaryStyle));
    }
    //高亮内容
    richList.add(TextSpan(text: searchText, style: highlightStyle));
    //赋值索引
    start = end + searchText.length;
  }
  //搜索内容只有在开头或者中间位置，才执行
  if (start != text.length) {
    richList.add(TextSpan(
        text: text.length - start > 250
            ? '${text.substring(start, start + 200)}……'
            : text.substring(start, text.length),
        style: ordinaryStyle));
  }
  return RichText(
    text: TextSpan(children: richList),
  );
}
