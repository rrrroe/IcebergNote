import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:get/get.dart';
import 'package:icebergnote/class/habit.dart';
import 'package:icebergnote/extensions/icondata_serialization.dart';
import 'package:icebergnote/main.dart';
import 'package:icebergnote/screen/input/habit_input.dart';
import 'package:realm/realm.dart';

class HabitCardWeek extends StatefulWidget {
  final VoidCallback onChanged;
  final int mod;
  final Habit habit;
  final List<HabitRecord?> habitRecords;
  final DateTime today;

  const HabitCardWeek(
      {super.key,
      required this.onChanged,
      required this.mod, //0正常，1不可编辑
      required this.habit,
      required this.habitRecords,
      required this.today});

  @override
  State<HabitCardWeek> createState() => _HabitCardWeekState();
}

class _HabitCardWeekState extends State<HabitCardWeek> {
  Color bgColor = Colors.blue;
  Color ftColor = Colors.white;
  IconData? icon;
  @override
  void initState() {
    bgColor = hexToColor(widget.habit.color);
    ftColor = hexToColor(widget.habit.fontColor);
    if (widget.habit.icon != '') {
      icon = deserializeIcon(jsonDecode(widget.habit.icon));
    }
    super.initState();
  }

  void saveRecord(index) {
    if (widget.mod == 0) {
      DateTime now = DateTime.now();
      realmHabitRecord.write(() {
        if (widget.habitRecords[index] != null) {
          if (widget.habitRecords[index]!.value == 0) {
            widget.habitRecords[index]!.value = 1;
          } else {
            widget.habitRecords[index]!.value = 0;
          }
          widget.habitRecords[index]!.updateDate = now.toUtc();
        } else {
          widget.habitRecords[index] = HabitRecord(
              Uuid.v4(),
              widget.habit.id,
              1,
              widget.today
                  .add(Duration(days: index - widget.today.weekday + 1))
                  .add(Duration(hours: now.timeZoneOffset.inHours)),
              now.toUtc(),
              now.toUtc());
          realmHabitRecord.add(widget.habitRecords[index]!);
        }
      });
    }
    setState(() {});
  }

  bool isFinished(int index) {
    if (widget.habitRecords[index] == null) {
      return false;
    } else {
      if (widget.habitRecords[index]!.value == 1) {
        return true;
      } else {
        return false;
      }
    }
  }

  bool istoday(int index) {
    if (widget.today.weekday == index + 1) {
      return true;
    } else {
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.fromLTRB(15, 0, 15, 10),
      elevation: 0,
      shadowColor: Colors.grey,
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(
          color: bgColor, // 边框颜色
          width: isFinished(widget.today.weekday - 1) ? 5 : 1, // 边框宽度
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                GestureDetector(
                  onTap: () {
                    if (widget.mod == 0) {
                      Get.to(() => HabitInputPage(
                          onPageClosed: () {}, mod: 1, habit: widget.habit));
                    }
                  },
                  child: Container(
                      height: 50,
                      width: 50,
                      decoration: BoxDecoration(
                          border: Border.all(color: Colors.black12, width: 0),
                          borderRadius: BorderRadius.circular(8.0),
                          color: Colors.white),
                      child: Icon(icon, color: bgColor, size: 40)),
                ),
                const SizedBox(width: 10),
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.habit.name,
                      style: TextStyle(color: bgColor, fontSize: 22),
                    ),
                    const SizedBox(width: 15),
                    Row(
                      children: List.generate(
                          7,
                          (index) => GestureDetector(
                                onTap: () {
                                  saveRecord(index);
                                  widget.onChanged();
                                },
                                child: Container(
                                  height: istoday(index) ? 22 : 18,
                                  width: istoday(index) ? 22 : 18,
                                  margin: const EdgeInsets.fromLTRB(2, 0, 1, 0),
                                  decoration: BoxDecoration(
                                      border: Border.all(
                                          color: istoday(index)
                                              ? Colors.black26
                                              : Colors.black12,
                                          width: istoday(index) ? 3 : 1),
                                      borderRadius: BorderRadius.circular(3),
                                      color: isFinished(index)
                                          ? bgColor
                                          : Colors.black12),
                                ),
                              )),
                    )
                  ],
                ),
                Expanded(child: Container()),
                GestureDetector(
                  onTap: () {
                    saveRecord(widget.today.weekday - 1);
                    widget.onChanged();
                  },
                  child: Container(
                    height: 50,
                    width: 50,
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8.0),
                        color: Colors.white),
                    child: Icon(
                      Icons.verified_outlined,
                      size: isFinished(widget.today.weekday - 1) ? 50 : 35,
                      color: isFinished(widget.today.weekday - 1)
                          ? bgColor
                          : Colors.black12,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
