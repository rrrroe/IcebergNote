import 'dart:math';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:icebergnote/class/habit.dart';
import 'package:icebergnote/extensions/color_extensions.dart';
import 'package:icebergnote/extensions/icondata_serialization.dart';
import 'package:icebergnote/main.dart';
import 'package:icebergnote/postgresql/sync.dart';
import 'package:icebergnote/screen/input/habit_input.dart';
import 'package:intl/intl.dart';
import 'package:realm/realm.dart';
import 'package:input_slider/input_slider.dart';

NumberFormat numberFormatMaxf2 = NumberFormat('#.##');

class HabitCardDay extends StatefulWidget {
  final VoidCallback onChanged;
  final int mod;
  final Habit habit;
  final List<HabitRecord?> habitRecord;
  final DateTime today;
  final Color bgColor;
  final Color ftColor;

  const HabitCardDay({
    super.key,
    required this.onChanged,
    required this.mod, //0正常，1实例无法进一步跳转，2拖动模式
    required this.habit,
    required this.habitRecord,
    required this.today,
    required this.bgColor,
    required this.ftColor,
  });

  @override
  State<HabitCardDay> createState() => _HabitCardDayState();
}

class _HabitCardDayState extends State<HabitCardDay> {
  @override
  void initState() {
    super.initState();
  }

  bool isFinished() {
    if (widget.habit.type == 0) {
      if (widget.habitRecord[0] == null) {
        return false;
      } else {
        if (widget.habitRecord[0]!.value == 1) {
          return true;
        } else {
          return false;
        }
      }
    } else if (widget.habit.type == 1) {
      if (widget.habitRecord[0] == null) {
        return false;
      } else {
        if (widget.habitRecord[0]!.data >=
            widget.habit.freqDen / widget.habit.freqNum) {
          return true;
        } else {
          return false;
        }
      }
    } else {
      return false;
    }
  }

  void saveRecord(index) {
    DateTime now = DateTime.now();
    // realmHabitRecord.write(() {
    //   if (widget.habitRecord[0] != null) {
    //     if (widget.habitRecord[0]!.value == 0) {
    //       widget.habitRecord[0]!.value = 1;
    //     } else {
    //       widget.habitRecord[0]!.value = 0;
    //     }
    //     widget.habitRecord[0]!.updateDate = now.toUtc();
    //   } else {
    //     widget.habitRecord[0] = HabitRecord(
    //         Uuid.v4(),
    //         widget.habit.id,
    //         1,
    //         widget.today
    //             .add(Duration(days: index - widget.today.weekday + 1))
    //             .add(Duration(hours: now.timeZoneOffset.inHours)),
    //         now.toUtc(),
    //         now.toUtc());
    //     realmHabitRecord.add(widget.habitRecord[0]!);
    //   }
    // });
    // syncHabitRecordToRemote(widget.habitRecord[0]!);
    // setState(() {});
    saveSingleRecord(
        widget.habitRecord[0],
        widget.habit,
        widget.today
            .add(Duration(days: index - widget.today.weekday + 1))
            .add(Duration(hours: now.timeZoneOffset.inHours)),
        now,
        context,
        widget.onChanged);
  }

  @override
  Widget build(BuildContext context) {
    Widget currentIcon =
        iconDataToWidget(widget.habit.icon, 40, isFinished() ? 1 : 0.5);
    return Column(
      children: [
        Card(
          margin: const EdgeInsets.fromLTRB(15, 5, 15, 2),
          elevation: 0,
          shadowColor: Colors.grey,
          color: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
            side: BorderSide(
              color: widget.bgColor,
              width: isFinished() ? 5 : 0.1,
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(10),
            child: GestureDetector(
              onTap: () {
                saveRecord(widget.today.weekday - 1);
                widget.onChanged();
              },
              child: Container(
                  height: 45,
                  width: 45,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                      border: Border.all(color: Colors.black12, width: 0),
                      borderRadius: BorderRadius.circular(8.0),
                      color:
                          widget.bgColor.withOpacity(isFinished() ? 0.7 : 0.1)),
                  child: currentIcon),
            ),
          ),
        ),
        Text(
          widget.habit.name,
          style: TextStyle(color: widget.bgColor, fontSize: 14),
        ),
        const SizedBox(height: 5)
      ],
    );
  }
}

class HabitCardWeek extends StatefulWidget {
  final VoidCallback onChanged;
  final VoidCallback delete;
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
      required this.ftColor,
      required this.delete});

  @override
  State<HabitCardWeek> createState() => _HabitCardWeekState();
}

class _HabitCardWeekState extends State<HabitCardWeek> {
  @override
  void initState() {
    super.initState();
  }

  void saveRecord(index) {
    // print(widget.habitRecords[index] == null
    //     ? 'null'
    //     : widget.habitRecords[index]!.currentDate);
    if (widget.mod == 0) {
      DateTime now = DateTime.now();
      // realmHabitRecord.write(() {
      //   if (widget.habitRecords[index] != null) {
      //     if (widget.habitRecords[index]!.value == 0) {
      //       widget.habitRecords[index]!.value = 1;
      //     } else {
      //       widget.habitRecords[index]!.value = 0;
      //     }
      //     widget.habitRecords[index]!.updateDate = now.toUtc();
      //   } else {
      //     widget.habitRecords[index] = HabitRecord(
      //         Uuid.v4(),
      //         widget.habit.id,
      //         1,
      //         widget.today
      //             .add(Duration(days: index - widget.today.weekday + 1))
      //             .add(Duration(hours: now.timeZoneOffset.inHours)),
      //         now.toUtc(),
      //         now.toUtc());
      //     realmHabitRecord.add(widget.habitRecords[index]!);
      //   }
      // });
      // syncHabitRecordToRemote(widget.habitRecords[index]!);
      saveSingleRecord(
          widget.habitRecords[index],
          widget.habit,
          widget.today
              .add(Duration(days: index - widget.today.weekday + 1))
              .add(Duration(hours: now.timeZoneOffset.inHours)),
          now,
          context,
          widget.onChanged);
    }
  }

  bool isFinished(int index) {
    if (widget.habit.type == 0) {
      if (widget.habitRecords[index] == null) {
        return false;
      } else {
        if (widget.habitRecords[index]!.value == 1) {
          return true;
        } else {
          return false;
        }
      }
    } else if (widget.habit.type == 1) {
      if (widget.habitRecords[index] == null) {
        return false;
      } else {
        if (widget.habitRecords[index]!.data >=
            widget.habit.freqDen / widget.habit.freqNum) {
          return true;
        } else {
          return false;
        }
      }
    } else {
      return false;
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
    Widget currentIcon = iconDataToWidget(widget.habit.icon, 40, 1);
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
                          onPageClosed: () {
                            widget.onChanged();
                          },
                          mod: 1,
                          habit: widget.habit));
                    }
                    setState(() {});
                  },
                  child: Container(
                      height: 60,
                      width: 60,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                          border: Border.all(color: Colors.black12, width: 0),
                          borderRadius: BorderRadius.circular(8.0),
                          color: widget.bgColor.withOpacity(0.5)),
                      child: currentIcon),
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
                Expanded(child: Container()),
                Visibility(
                  visible: widget.mod == 2,
                  child: GestureDetector(
                    onTap: widget.delete,
                    child: const Icon(
                      Icons.delete_forever_rounded,
                      size: 30,
                      color: Colors.red,
                    ),
                  ),
                ),
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
  int daySum = 0;
  double numSum = 0;
  double scoreSum = 0;
  int maxSeq = 0;
  double percent = 0;
  double target = 0;
  int startIndex = 0;
  int stopIndex = 49;
  @override
  void initState() {
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
        if (widget.habitRecords[i]!.value == 1) {
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
    if (target != 0) {
      percent = scoreSum / target * 100;
    } else {
      percent = -1;
    }
  }

  void saveRecord(index) {
    if (widget.mod == 0) {
      DateTime now = DateTime.now();
      // realmHabitRecord.write(() {
      //   if (widget.habitRecords[index] != null) {
      //     if (widget.habitRecords[index]!.value == 0) {
      //       widget.habitRecords[index]!.value = 1;
      //     } else {
      //       widget.habitRecords[index]!.value = 0;
      //     }
      //     widget.habitRecords[index]!.updateDate = now.toUtc();
      //   } else {
      //     widget.habitRecords[index] = HabitRecord(
      //         Uuid.v4(),
      //         widget.habit.id,
      //         1,
      //         widget.today
      //             .add(Duration(days: index - widget.todayIndex))
      //             .add(Duration(hours: now.timeZoneOffset.inHours)),
      //         now.toUtc(),
      //         now.toUtc());
      //     realmHabitRecord.add(widget.habitRecords[index]!);
      //   }
      // });
      // syncHabitRecordToRemote(widget.habitRecords[index]!);
      saveSingleRecord(
          widget.habitRecords[index],
          widget.habit,
          widget.today
              .add(Duration(days: index - widget.todayIndex))
              .add(Duration(hours: now.timeZoneOffset.inHours)),
          now,
          context,
          widget.onChanged);
    }
    setState(() {
      countScores();
    });
  }

  bool isFinished(int index) {
    if (widget.habit.type == 0) {
      if (widget.habitRecords[index] == null) {
        return false;
      } else {
        if (widget.habitRecords[index]!.value == 1) {
          return true;
        } else {
          return false;
        }
      }
    } else if (widget.habit.type == 1) {
      if (widget.habitRecords[index] == null) {
        return false;
      } else {
        if (widget.habitRecords[index]!.data >=
            widget.habit.freqDen / widget.habit.freqNum) {
          return true;
        } else {
          return false;
        }
      }
    } else {
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    countScores();
    Widget currentIcon = iconDataToWidget(widget.habit.icon, 40, 1);
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
                              onPageClosed: () {
                                widget.onChanged();
                              },
                              mod: 1,
                              habit: widget.habit));
                        }
                      },
                      child: Container(
                          height: 60,
                          width: 60,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                              border:
                                  Border.all(color: Colors.black12, width: 0),
                              borderRadius: BorderRadius.circular(8.0),
                              color: Colors.white),
                          child: currentIcon),
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
                          Text(percent >= 0 ? '完成率' : '',
                              style: TextStyle(
                                  color: widget.bgColor, fontSize: 14)),
                        ],
                      ),
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: List.generate(
                          5,
                          (int i) => Text(
                              ((percent >= 0 && i == 4) || i < 4) ? ': ' : '',
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
                          Text(
                              percent >= 0
                                  ? '${percent.toStringAsFixed(0)}%'
                                  : '',
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

void saveSingleRecord(HabitRecord? record, Habit habit, DateTime currentDay,
    DateTime now, BuildContext context, VoidCallback onChanged) {
  if (habit.type == 0) {
    realmHabitRecord.write(() {
      if (record != null) {
        if (record!.value == 0) {
          record!.value = 1;
        } else {
          record!.value = 0;
        }
        record!.updateDate = now.toUtc();
      } else {
        record = HabitRecord(
            Uuid.v4(), habit.id, 1, currentDay, now.toUtc(), now.toUtc());
        realmHabitRecord.add(record!);
      }
    });
    onChanged();
    syncHabitRecordToRemote(record!);
  } else if (habit.type == 1) {
    double tmpdata = record != null ? record.data : 0;
    Color color = hexToColor(habit.color);
    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          titlePadding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
          contentPadding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
          insetPadding: const EdgeInsets.all(20),
          actionsPadding: const EdgeInsets.all(10),
          title: Container(
            width: 50,
            height: 10,
            padding: const EdgeInsets.all(0),
            // color: Colors.white,
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              InputSlider(
                onChange: (value) {
                  tmpdata = double.parse(value.toStringAsFixed(habit.int1));
                },
                min: 0.0,
                max: 10.0,
                decimalPlaces: habit.int1,
                fillColor: color,
                borderColor: color,
                focusBorderColor: color,
                activeSliderColor: color,
                inactiveSliderColor: color,
                leading: Text(
                  habit.name,
                  style: TextStyle(
                      color: color, fontSize: 16, fontWeight: FontWeight.bold),
                ),
                defaultValue: record == null ? 0 : record!.data,
              )
            ],
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('取消', style: TextStyle(color: Colors.grey)),
              onPressed: () => Navigator.of(context).pop(),
            ),
            TextButton(
              onPressed: () {
                realmHabitRecord.write(() {
                  if (record != null) {
                    record!.data = tmpdata;
                    record!.updateDate = now.toUtc();
                  } else {
                    record = HabitRecord(
                        Uuid.v4(),
                        habit.id,
                        tmpdata > 0 ? 1 : 0,
                        currentDay,
                        now.toUtc(),
                        now.toUtc(),
                        data: tmpdata);
                    realmHabitRecord.add(record!);
                  }
                });
                onChanged();
                syncHabitRecordToRemote(record!);
                Navigator.of(context).pop();
              },
              child: Text('确定', style: TextStyle(color: color)),
            ),
          ],
          actionsAlignment: MainAxisAlignment.spaceAround,
        );
      },
    );
  }
}
