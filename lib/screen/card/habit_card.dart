import 'dart:convert';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:icebergnote/class/habit.dart';
import 'package:icebergnote/extensions/icondata_serialization.dart';
import 'package:icebergnote/main.dart';
import 'package:icebergnote/screen/input/habit_input.dart';
import 'package:intl/intl.dart';
import 'package:realm/realm.dart';

NumberFormat numberFormatMaxf2 = NumberFormat('#.##');

class HabitCardWeek extends StatefulWidget {
  final VoidCallback onChanged;
  final int mod;
  final Habit habit;
  final List<HabitRecord?> habitRecords;
  final DateTime today;
  final int index;
  final Color bgColor;
  final Color ftColor;

  const HabitCardWeek(
      {super.key,
      required this.onChanged,
      required this.mod, //0正常，1实例无法进一步跳转，2拖动模式
      required this.habit,
      required this.habitRecords,
      required this.today,
      required this.index,
      required this.bgColor,
      required this.ftColor});

  @override
  State<HabitCardWeek> createState() => _HabitCardWeekState();
}

class _HabitCardWeekState extends State<HabitCardWeek> {
  IconData? icon;

  @override
  void initState() {
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
      margin: const EdgeInsets.fromLTRB(15, 5, 15, 5),
      elevation: 0,
      shadowColor: Colors.grey,
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(
          color: widget.bgColor,
          width: widget.mod == 2
              ? 5
              : isFinished(widget.today.weekday - 1)
                  ? 5
                  : 1,
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
                    if (widget.mod == 0 || widget.mod == 2) {
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
                      child: Icon(icon, color: widget.bgColor, size: 40)),
                ),
                const SizedBox(width: 10),
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.habit.name,
                      style: TextStyle(color: widget.bgColor, fontSize: 22),
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
                                          ? widget.bgColor
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
                    child: widget.mod == 2
                        ? ReorderableDragStartListener(
                            index: widget.index,
                            child: const Icon(
                              Icons.drag_handle_rounded,
                              size: 30,
                              color: Colors.grey,
                            ),
                          )
                        : Icon(
                            Icons.verified_outlined,
                            size:
                                isFinished(widget.today.weekday - 1) ? 50 : 35,
                            color: isFinished(widget.today.weekday - 1)
                                ? widget.bgColor
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

class HabitCardSeason extends StatefulWidget {
  final VoidCallback onChanged;
  final int mod;
  final Habit habit;
  final List<HabitRecord?> habitRecords;
  final DateTime today;
  final int todayIndex;
  final int index;
  final Color bgColor;
  final Color ftColor;

  const HabitCardSeason(
      {super.key,
      required this.onChanged,
      required this.mod, //0正常，1实例无法进一步跳转，2拖动模式
      required this.habit,
      required this.habitRecords,
      required this.today,
      required this.todayIndex,
      required this.index,
      required this.bgColor,
      required this.ftColor});

  @override
  State<HabitCardSeason> createState() => _HabitCardSeasonState();
}

class _HabitCardSeasonState extends State<HabitCardSeason> {
  IconData? icon;
  int daySum = 0;
  int numSum = 0;
  double scoreSum = 0;
  int maxSeq = 0;
  double percent = 0;
  double target = 0;
  int startIndex = 0;
  int stopIndex = 49;
  @override
  void initState() {
    if (widget.habit.icon != '') {
      icon = deserializeIcon(jsonDecode(widget.habit.icon));
    }
    startIndex = widget.habit.startDate.difference(widget.today).inDays -
        widget.todayIndex;
    if (widget.habit.stopDate.isAfter(widget.habit.startDate)) {
      stopIndex = widget.habit.stopDate.difference(widget.today).inDays -
          widget.todayIndex;
    }
    target = widget.habit.weight *
        widget.habit.freqNum /
        widget.habit.freqDen *
        (min(stopIndex, 49) - max(0, startIndex));

    super.initState();
  }

  void countScores() {
    daySum = 0;
    numSum = 0;
    scoreSum = 0;
    maxSeq = 0;
    percent = 0;
    int currentSeq = 0;
    for (int i = 0; i < widget.habitRecords.length; i++) {
      if (widget.habitRecords[i] != null) {
        if (widget.habitRecords[i]!.value > 0) {
          daySum++;
          numSum = numSum + widget.habitRecords[i]!.value;
          scoreSum =
              scoreSum + widget.habitRecords[i]!.value * widget.habit.weight;
          currentSeq++;
          if (currentSeq > maxSeq) {
            maxSeq = currentSeq;
          }
        } else {
          currentSeq = 0;
        }
      } else {
        currentSeq = 0;
      }
    }
    percent = scoreSum / target * 100;
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
                  .add(Duration(days: index - widget.todayIndex))
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

  @override
  Widget build(BuildContext context) {
    countScores();
    return Card(
      margin: const EdgeInsets.fromLTRB(15, 5, 15, 5),
      elevation: 0,
      shadowColor: Colors.grey,
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(
          color: widget.bgColor,
          width: 5,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(5, 10, 0, 10),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(child: Container()),
                Column(
                  children: [
                    GestureDetector(
                      onTap: () {
                        if (widget.mod == 0 || widget.mod == 2) {
                          Get.to(() => HabitInputPage(
                              onPageClosed: () {},
                              mod: 1,
                              habit: widget.habit));
                        }
                      },
                      child: Container(
                          height: 50,
                          width: 50,
                          decoration: BoxDecoration(
                              border:
                                  Border.all(color: Colors.black12, width: 0),
                              borderRadius: BorderRadius.circular(8.0),
                              color: Colors.white),
                          child: Icon(icon, color: widget.bgColor, size: 40)),
                    ),
                    const SizedBox(width: 10),
                    Text(
                      widget.habit.name,
                      style: TextStyle(color: widget.bgColor, fontSize: 18),
                    ),
                  ],
                ),
                Expanded(child: Container()),
                Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: List.generate(
                        7,
                        (int i) => Row(
                              children: List.generate(
                                  7,
                                  (int j) => GestureDetector(
                                        onTap: () {
                                          saveRecord(i * 7 + j);
                                          widget.onChanged();
                                        },
                                        child: Container(
                                          height: 16,
                                          width: 16,
                                          margin: const EdgeInsets.fromLTRB(
                                              0, 0, 0, 0),
                                          decoration: BoxDecoration(
                                              border: Border.all(
                                                  color: Colors.white,
                                                  width: widget.todayIndex ==
                                                          i * 7 + j
                                                      ? 2
                                                      : 0),
                                              // borderRadius:
                                              //     BorderRadius.circular(0),
                                              color: isFinished(i * 7 + j)
                                                  ? widget.bgColor
                                                  : Colors.black12),
                                        ),
                                      )),
                            ))),
                Expanded(child: Container()),
                SizedBox(
                  width: 115,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text('完成天数',
                              style: TextStyle(
                                  color: widget.bgColor, fontSize: 14)),
                          Text('完成次数',
                              style: TextStyle(
                                  color: widget.bgColor, fontSize: 14)),
                          Text('累计分数',
                              style: TextStyle(
                                  color: widget.bgColor, fontSize: 14)),
                          Text('最长连续',
                              style: TextStyle(
                                  color: widget.bgColor, fontSize: 14)),
                          Text('完成率',
                              style: TextStyle(
                                  color: widget.bgColor, fontSize: 14)),
                        ],
                      ),
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: List.generate(
                          5,
                          (int i) => Text(': ',
                              style: TextStyle(
                                  color: widget.bgColor, fontSize: 14)),
                        ),
                      ),
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text('$daySum',
                              style: TextStyle(
                                  color: widget.bgColor, fontSize: 14)),
                          Text('$numSum',
                              style: TextStyle(
                                  color: widget.bgColor, fontSize: 14)),
                          Text(numberFormatMaxf2.format(scoreSum),
                              style: TextStyle(
                                  color: widget.bgColor, fontSize: 14)),
                          Text('$maxSeq',
                              style: TextStyle(
                                  color: widget.bgColor, fontSize: 14)),
                          Text('${percent.toStringAsFixed(0)}%',
                              style: TextStyle(
                                  color: widget.bgColor, fontSize: 14)),
                        ],
                      ),
                    ],
                  ),
                ),
                Expanded(child: Container()),
                // GestureDetector(
                //   onTap: () {
                //     saveRecord(widget.today.weekday - 1);
                //     widget.onChanged();
                //   },
                //   child: Container(
                //     height: 50,
                //     width: 50,
                //     decoration: BoxDecoration(
                //         borderRadius: BorderRadius.circular(8.0),
                //         color: Colors.white),
                //     child: widget.mod == 2
                //         ? ReorderableDragStartListener(
                //             index: widget.index,
                //             child: const Icon(
                //               Icons.drag_handle_rounded,
                //               size: 30,
                //               color: Colors.grey,
                //             ),
                //           )
                //         : Icon(
                //             Icons.verified_outlined,
                //             size:
                //                 isFinished(widget.today.weekday - 1) ? 50 : 35,
                //             color: isFinished(widget.today.weekday - 1)
                //                 ? widget.bgColor
                //                 : Colors.black12,
                //           ),
                //   ),
                // ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
