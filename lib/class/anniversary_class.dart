import 'package:flutter/material.dart';

class Anniversary {
  String title;
  String content;
  DateTime date; // "2024-06-12"
  Color bgColor;
  Color fontColor;
  bool isjune;
  int alarmType; // 0-已过时间或还剩时间，1-周期提示，2-特殊日提示
  String oldPrefix;
  String oldSuffix;
  String futurePrefix;
  String futureSuffix;
  int alarmDuration; // 0年、1季、2月
  int alarmSpecialDay;
  DateTime alarmSpecialDate;
  bool needAlarm;
  String fontFamilyNum;
  String fontFamilyCha;
  String fontFamilyEng;
  Anniversary({
    this.title = '',
    this.content = '',
    required this.date,
    this.bgColor = const Color.fromARGB(255, 0, 140, 198),
    this.fontColor = Colors.white,
    this.isjune = false,
    this.alarmType = 0,
    this.oldPrefix = '已过',
    this.oldSuffix = '天',
    this.futurePrefix = '还有',
    this.futureSuffix = '日',
    this.alarmDuration = 0,
    this.alarmSpecialDay = 0,
    required this.alarmSpecialDate,
    this.needAlarm = false,
    this.fontFamilyNum = 'LXGWWenKai',
    this.fontFamilyCha = 'LXGWWenKai',
    this.fontFamilyEng = 'LXGWWenKai',
  });
  // 将对象转换为 JSON
  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'content': content,
      'date': date.toIso8601String(),
      'bgColor': bgColor.value.toRadixString(16),
      'fontColor': fontColor.value.toRadixString(16),
      'isjune': isjune,
      'alarmType': alarmType,
      'oldPrefix': oldPrefix,
      'oldSuffix': oldSuffix,
      'futurePrefix': futurePrefix,
      'futureSuffix': futureSuffix,
      'alarmDuration': alarmDuration,
      'alarmSpecialDay': alarmSpecialDay,
      'needAlarm': needAlarm,
      'fontFamilyNum': fontFamilyNum,
      'fontFamilyCha': fontFamilyCha,
      'fontFamilyEng': fontFamilyEng,
    };
  }

  // 从 JSON 创建对象
  factory Anniversary.fromJson(Map<String, dynamic> json) {
    return Anniversary(
      title: json['title'] as String,
      content: json['content'] as String,
      date:
          json['date'] != null ? DateTime.parse(json['date']) : DateTime(2024),
      bgColor: Color(int.parse(json['bgColor'], radix: 16)),
      fontColor: Color(int.parse(json['fontColor'], radix: 16)),
      isjune: json['isjune'] as bool,
      alarmType: json['alarmType'] as int,
      oldPrefix: json['oldPrefix'] as String,
      oldSuffix: json['oldSuffix'] as String,
      futurePrefix: json['futurePrefix'] as String,
      futureSuffix: json['futureSuffix'] as String,
      alarmDuration: json['alarmDuration'] as int,
      alarmSpecialDay: json['alarmSpecialDay'] as int,
      alarmSpecialDate:
          json['date'] != null ? DateTime.parse(json['date']) : DateTime(2024),
      needAlarm: json['needAlarm'] as bool,
      fontFamilyNum: json['fontFamilyNum'] as String,
      fontFamilyCha: json['fontFamilyCha'] as String,
      fontFamilyEng: json['fontFamilyEng'] as String,
    );
  }

  int? getDays() {
    return DateTime.now().difference(date).inDays; //以过去的日子为正，还剩的日子为负
  }

  int? getDurationDays() {
    DateTime? nextDate = date;
    DateTime now = DateTime.now().add(const Duration(days: -1));
    switch (alarmDuration) {
      case 0:
        nextDate = DateTime(now.year, date.month, date.day);
        if (nextDate.isBefore(now)) {
          nextDate = DateTime(now.year + 1, date.month, date.day);
        }
        break;

      case 1:
        int monthsToAdd = 3 * ((now.month - date.month + 3) ~/ 3);
        nextDate = DateTime(now.year, date.month + monthsToAdd, date.day);
        if (nextDate.isBefore(now)) {
          nextDate = DateTime(now.year, date.month + monthsToAdd + 3, date.day);
        }
        break;

      case 2:
        nextDate = DateTime(now.year, now.month, date.day);
        if (nextDate.isBefore(now)) {
          nextDate = DateTime(now.year, now.month + 1, date.day);
        }
        break;

      default:
        nextDate = null;
    }
    if (nextDate != null) {
      return nextDate.difference(now).inDays;
    } else {
      return null;
    }
  }

  int getSpecialDaysNum() {
    DateTime now = DateTime.now();
    DateTime nowTmp = DateTime(now.year, now.month, now.day);
    return nowTmp
        .difference(date.add(Duration(days: alarmSpecialDay)))
        .inDays; //以过去的日子为正，还剩的日子为负
  }

  int getSpecialDays() {
    return alarmSpecialDate.difference(date).inDays; //以过去的日子为正，还剩的日子为负
  }

  DateTime getSpecialDate() {
    return date.add(Duration(days: alarmSpecialDay)); //以过去的日子为正，还剩的日子为负
  }

  List<int> getYearsMonthsDays() {
    DateTime now = DateTime.now();
    // 如果startDate在endDate之后，交换它们并标记结果为负
    if (date.isAfter(now)) {
      DateTime temp = date;
      date = now;
      now = temp;
    }
    int years = now.year - date.year;
    int months = now.month - date.month;
    int days = now.day - date.day;
    return [years, months, days]; //以过去的日子为正，还剩的日子为负
  }
}
