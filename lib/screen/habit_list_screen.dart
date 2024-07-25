import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:flutter_rounded_date_picker/flutter_rounded_date_picker.dart';
import 'package:icebergnote/class/habit.dart';
import 'package:icebergnote/extensions/date_extensions.dart';
import 'package:icebergnote/extensions/screenshot_extensions.dart';
import 'package:icebergnote/main.dart';
import 'package:icebergnote/postgresql/sync.dart';
import 'package:icebergnote/screen/card/habit_card.dart';
import 'package:icebergnote/screen/input/habit_input.dart';
import 'package:realm/realm.dart';
import 'package:primer_progress_bar/primer_progress_bar.dart';

class HabitListScreen extends StatefulWidget {
  const HabitListScreen({super.key});

  @override
  State<HabitListScreen> createState() => _HabitListScreenState();
}

class _HabitListScreenState extends State<HabitListScreen> {
  final ScrollController scrollController = ScrollController();
  List<Habit> habits = [];
  List<List<HabitRecord?>> habitsRecords = [];
  int durationLenth = 371;
  late DateTime today, now, firstDay, lastDay;
  int firstDayWeek = 0,
      lastDayWeek = 0,
      firstDay7Week = 0,
      lastDay7Week = 0,
      firstDayMonth = 0,
      lastDayMonth = 0,
      firstDayYear = 3,
      lastDayYear = 368,
      todayIndex = 0,
      todayOffsetWeekYear = 0;
  List scoresWeek = [0, 0, []];
  List scoresToday = [0, 0, []];
  List scores7Week = [0, 0, []];
  List scoresYear = [0, 0, []];
  List<String> tips = ['未来可期', '初露锋芒', '渐入佳境', '势如破竹', '一骑绝尘', '登峰造极'];
  GlobalKey repaintWidgetKey = GlobalKey();

  @override
  void initState() {
    now = DateTime.now();
    today = DateTime(now.year, now.month, now.day);
    firstDay = DateTime(today.year, 1, 1).add(const Duration(days: -3));
    lastDay = DateTime(today.year, 12, 31).add(const Duration(days: 3));
    habits =
        realmHabit.query<Habit>('delete != true SORT(position ASC)').toList();
    dateInit();
    dataInit();
    super.initState();
  }

  void dateInit() {
    todayOffsetWeekYear = offsetWeekYear(today);

    firstDay = DateTime(today.year + todayOffsetWeekYear, 1, 1)
        .add(const Duration(days: -3));
    lastDay = DateTime(today.year + todayOffsetWeekYear, 12, 31)
        .add(const Duration(days: 3));
    todayIndex = today.difference(firstDay).inDays;
    if (DateTime(today.year + 1 + todayOffsetWeekYear, 1, 1)
            .difference(DateTime(today.year + todayOffsetWeekYear, 1, 1))
            .inDays ==
        365) {
      durationLenth = 372;
      lastDayYear = 369;
    }
    // if (todayOffsetWeekYear == 0) {
    // } else if (todayOffsetWeekYear == -1) {
    // } else if (todayOffsetWeekYear == 1) {}
    firstDayWeek = todayIndex - today.weekday + 1;
    lastDayWeek = firstDayWeek + 7;

    firstDay7Week = firstDayWeek;

    for (; (firstDay7Week % 49) >= 7;) {
      firstDay7Week = firstDay7Week - 7;
    }
    // while ((firstDay7week % 49) >= 7) {
    //   firstDay7week = firstDay7week - 7;
    //   print(firstDay7week);
    // }
    lastDay7Week = firstDay7Week + 49;
    if (lastDay7Week > durationLenth) {
      lastDay7Week = durationLenth;
    }
    // firstDayMonth =
    //     int.parse(DateFormat("D").format(DateTime(today.year, today.month))) -
    //         1 +
    //         3;
    // lastDayMonth = int.parse(DateFormat("D").format(
    //         DateTime(today.year, today.month + 1)
    //             .add(const Duration(days: -1)))) +
    //     3;
  }

  void dataInit() {
    habitsRecords = [];

    for (int i = 0; i < habits.length; i++) {
      List<HabitRecord> tmp = realmHabitRecord.query<HabitRecord>(
          'currentDate >= \$0 && currentDate <= \$1 && habit == \$2 SORT(currentDate ASC)',
          [firstDay, lastDay, habits[i].id]).toList();
      habitsRecords.add(List.generate(durationLenth, (index) => null));
      for (int j = 0; j < tmp.length; j++) {
        habitsRecords[i][
            tmp[j].currentDate.difference(DateTime(today.year, 1, 1)).inDays +
                3] = tmp[j];
      }
    }
    if (lastDay7Week > durationLenth) {
      lastDay7Week = durationLenth;
    }
    scoresToday = countScores(todayIndex, todayIndex + 1);
    scoresWeek = countScores(firstDayWeek, lastDayWeek);
    scores7Week = countScores(firstDay7Week, lastDay7Week);
    scoresYear = countScores(firstDayYear, lastDayYear);
    // print('--------------------------------------');
    // print('today        : $today');
    // print('firstDay     : $firstDay');
    // print('lastDay      : $lastDay');
    // // if (habitsRecords[0][firstDayWeek] != null) {
    // //   print('indexfirst   : ${habitsRecords[0][firstDayWeek]!.currentDate}');
    // // } else {
    // //   print('indexfirst   : ${habitsRecords[0][firstDayWeek]}');
    // // }
    // // if (habitsRecords[0][lastDayWeek - 1] != null) {
    // //   print('indexlast    : ${habitsRecords[0][lastDayWeek - 1]!.currentDate}');
    // // } else {
    // //   print('indexlast    : ${habitsRecords[0][lastDayWeek - 1]}');
    // // }

    // print('todayIndex   : $todayIndex');

    // print('firstDayWeek : $firstDayWeek');
    // print('lastDayWeek  : $lastDayWeek');
    // print('firstDayMonth: $firstDayMonth');
    // print('lastDayMonth : $lastDayMonth');
    // print('firstDay7week: $firstDay7week');
    // print('lastDay7week : $lastDay7week');
    // print('firstDayYear : $firstDayYear');
    // print('lastDayYear  : $lastDayYear');
  }

  void updateScore() {
    dateInit();
    dataInit();
    setState(() {});
  }

  List countScores(int first, int last) {
    num scores = 0;
    num weights = 0;
    List<Segment> segments = [];
    for (int i = 0; i < habits.length; i++) {
      num score = 0;
      int start = 0;
      int stop = durationLenth - 1;
      if (habits[i].startDate.isAfter(firstDay)) {
        start = habits[i].startDate.difference(firstDay).inDays;
      }
      if (habits[i].stopDate.isAfter(habits[i].startDate)) {
        if (habits[i].stopDate.isBefore(lastDay)) {
          stop = habits[i].stopDate.difference(firstDay).inDays;
        }
      }
      // print('$i: start $start   stop $stop');
      for (int j = max(first, start); j < min(stop, last); j++) {
        if (habitsRecords[i][j] != null) {
          score = score + habitsRecords[i][j]!.value;
        } else {}
      }
      scores = scores + score * habits[i].weight;
      weights = weights +
          habits[i].weight *
              habits[i].freqNum /
              habits[i].freqDen *
              (last - first);
      segments.add(Segment(
          value: (score * habits[i].weight).toInt(),
          color: hexToColor(habits[i].color)));
    }
    List tmp = [scores, weights, segments];
    return tmp;
  }

  // List<num> countWeekScore() {
  //   num scores = 0;
  //   num weights = 0;
  //   segmentsWeek = [];
  //   for (int i = 0; i < habits.length; i++) {
  //     num score = 0;
  //     for (int j = 0; j < habitsRecords[i].length; j++) {
  //       if (habitsRecords[i][j] != null) {
  //         score = score + habitsRecords[i][j]!.value;
  //       } else {}
  //     }
  //     scores = scores + score * habits[i].weight;
  //     weights = weights +
  //         habits[i].weight * habits[i].freqNum / habits[i].freqDen * 7;
  //     segmentsWeek.add(Segment(
  //         value: (score * habits[i].weight).toInt(),
  //         color: hexToColor(habits[i].color)));
  //   }
  //   return [scores, weights];
  // }

  // List<num> countTodayScore() {
  //   num scores = 0;
  //   num weights = 0;
  //   segmentsToday = [];
  //   for (int i = 0; i < habits.length; i++) {
  //     num score = 0;
  //     if (habitsRecords[i][today.weekday - 1] != null) {
  //       score = score + habitsRecords[i][today.weekday - 1]!.value;
  //     } else {}

  //     scores = scores + score * habits[i].weight;
  //     weights = weights +
  //         habits[i].weight * habits[i].freqNum / habits[i].freqDen * 7;
  //     segmentsToday.add(Segment(
  //         value: (score * habits[i].weight).toInt(),
  //         color: hexToColor(habits[i].color)));
  //   }
  //   return [scores, weights / 7];
  // }

  int congratulationLevel(num scores, num weights) {
    if (scores >= weights) return 5;
    if (scores >= weights * 0.9) return 4;
    if (scores >= weights * 0.8) return 3;
    if (scores >= weights * 0.7) return 2;
    if (scores >= weights * 0.6) return 1;
    return 0;
  }

  Widget buildScoreCard(String title, int scores, int target, Color bgColor,
      double leftPadding, double rightPadding, List<Segment> segments) {
    return Expanded(
      child: Container(
        margin: EdgeInsets.fromLTRB(leftPadding, 10, rightPadding, 10),
        padding: const EdgeInsets.fromLTRB(6, 2, 6, 2),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(20.0),
            topRight: Radius.circular(2.0),
            bottomRight: Radius.circular(20.0),
            bottomLeft: Radius.circular(2.0),
          ),
          border: Border.all(
            color: Colors.white24,
            width: 5.0,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Row(
              children: [
                Text(
                  title,
                  overflow: TextOverflow.visible,
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.bold),
                ),
                Expanded(child: Container()),
                Text(
                  scores.toInt().toString(),
                  textAlign: TextAlign.right,
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold),
                ),
              ],
            ),
            Row(
              children: [
                const Text(
                  '目标',
                  overflow: TextOverflow.visible,
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.bold),
                ),
                Expanded(child: Container()),
                Text(
                  target.toString(),
                  textAlign: TextAlign.right,
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold),
                ),
              ],
            ),
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(congratulationLevel(scores, target) + 1,
                  (index) {
                return const Icon(
                  Icons.star,
                  size: 13,
                  color: Colors.white,
                );
              }),
            ),
            // Text(
            //   tips[congratulationLevel(scores, target)],
            //   textAlign: TextAlign.right,
            //   style: const TextStyle(
            //       color: Colors.white,
            //       fontSize: 12,
            //       fontWeight: FontWeight.bold),
            // ),
            SegmentedBar(
              segments: segments,
              maxTotalValue: max(scores, target),
              style: const SegmentedBarStyle(
                size: 6,
                gap: 0.1,
                padding: EdgeInsets.fromLTRB(2, 8, 2, 4),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildLongScoreCard(String title, int scores, int target, Color bgColor,
      List<Segment> segments) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.fromLTRB(15, 0, 15, 15),
        padding: const EdgeInsets.fromLTRB(6, 2, 6, 2),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(20.0),
            topRight: Radius.circular(2.0),
            bottomRight: Radius.circular(20.0),
            bottomLeft: Radius.circular(2.0),
          ),
          border: Border.all(
            color: Colors.white24,
            width: 5.0,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Row(
              children: [
                Text(
                  title,
                  overflow: TextOverflow.visible,
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.bold),
                ),
                const SizedBox(width: 10),
                Text(
                  scores.toInt().toString(),
                  textAlign: TextAlign.right,
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold),
                ),
                Expanded(child: Container()),
                Column(
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(
                          congratulationLevel(scores, target) + 1, (index) {
                        return const Icon(
                          Icons.star,
                          size: 13,
                          color: Colors.white,
                        );
                      }),
                    ),
                    // Text(
                    //   tips[congratulationLevel(scores, target)],
                    //   textAlign: TextAlign.right,
                    //   style: const TextStyle(
                    //       color: Colors.white,
                    //       fontSize: 12,
                    //       fontWeight: FontWeight.bold),
                    // ),
                  ],
                ),
                Expanded(child: Container()),
                const Text(
                  '目标',
                  overflow: TextOverflow.visible,
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.bold),
                ),
                const SizedBox(width: 10),
                Text(
                  target.toString(),
                  textAlign: TextAlign.right,
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold),
                ),
              ],
            ),
            SegmentedBar(
              segments: segments,
              maxTotalValue: max(scores, target),
              style: const SegmentedBarStyle(
                size: 6,
                gap: 0.1,
                padding: EdgeInsets.fromLTRB(2, 8, 2, 4),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: GestureDetector(
        onLongPress: () {},
        child: FloatingActionButton(
          onPressed: () {
            DateTime now = DateTime.now();
            Habit habit = Habit(
                Uuid.v4(),
                now.toUtc(),
                DateTime(now.year, now.month, now.day),
                now.toUtc(),
                DateTime(now.year, now.month, now.day));
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => HabitInputPage(
                  onPageClosed: () {},
                  mod: 0,
                  habit: habit,
                ),
              ),
            );
          },
          child: const Icon(Icons.add),
        ),
      ),
      body: SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: RepaintBoundary(
          key: repaintWidgetKey,
          child: Container(
            color: Colors.white,
            child: Column(
              children: <Widget>[
                    Container(
                      margin: const EdgeInsets.fromLTRB(20, 10, 16, 0),
                      padding: const EdgeInsets.fromLTRB(0, 0, 0, 0),
                      child: Row(
                        children: [
                          GestureDetector(
                            onTap: () async {
                              DateTime? newDateTime =
                                  await showRoundedDatePicker(
                                initialDate: today,
                                firstDate: DateTime(1900, 1, 1),
                                lastDate: DateTime(2100, 1, 1),
                                height: 300,
                                context: context,
                                locale: const Locale("zh", "CN"),
                                theme: ThemeData(),
                              );
                              if (newDateTime != null) {
                                setState(() {
                                  today = newDateTime;
                                  dateInit();
                                  dataInit();
                                });
                              }
                            },
                            child: Text(
                              '${today.year}年${today.month}月${today.day}日  第${weekNumber(today)}周  第${week7Number(today)}季',
                              style: const TextStyle(
                                  fontSize: 18, fontWeight: FontWeight.bold),
                            ),
                          ),
                          Expanded(child: Container()),
                          GestureDetector(
                            child: const Icon(Icons.fit_screen_outlined),
                            onTap: () async {
                              // PermissionUtil.requestAll();

                              Uint8List pngBytes =
                                  await onScreenshot(repaintWidgetKey);
                              if (userLocalInfo != null) {
                                userName = userLocalInfo!.getString('userName');
                                userID = userLocalInfo!.getString('userID');
                                userCreatDate =
                                    userLocalInfo!.getString('userCreatDate');
                              }
                              // ignore: use_build_context_synchronously
                              //     .executeThread();
                              showDialog(
                                builder: (_) => ImagePopup(
                                  pngBytes: pngBytes,
                                  mainColor: Colors.black,
                                ),
                                // ignore: use_build_context_synchronously
                                context: context,
                              );
                            },
                          ),
                        ],
                      ),
                    )
                  ] +
                  List.generate(habits.length + 1, (index) {
                    if (index == 0) {
                      return Column(
                        children: [
                          Row(
                            mainAxisSize: MainAxisSize.max,
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              buildScoreCard(
                                  '今日',
                                  scoresToday[0].toInt(),
                                  scoresToday[1].toInt(),
                                  const Color.fromARGB(255, 249, 172, 146),
                                  15,
                                  4,
                                  scoresToday[2]),
                              buildScoreCard(
                                  '本周',
                                  scoresWeek[0].toInt(),
                                  scoresWeek[1].toInt(),
                                  const Color.fromARGB(255, 137, 190, 244),
                                  9,
                                  9,
                                  scoresWeek[2]),
                              buildScoreCard(
                                  '七周',
                                  scores7Week[0].toInt(),
                                  scores7Week[1].toInt(),
                                  const Color.fromARGB(255, 137, 198, 131),
                                  4,
                                  15,
                                  scores7Week[2]),
                            ],
                          ),
                          Row(
                            mainAxisSize: MainAxisSize.max,
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              buildLongScoreCard(
                                  '年度',
                                  scoresYear[0].toInt(),
                                  scoresYear[1].toInt(),
                                  const Color.fromARGB(255, 147, 117, 205),
                                  scoresYear[2]),
                            ],
                          ),
                        ],
                      );
                    } else {
                      return GestureDetector(
                          onTap: () {},
                          child: HabitCardWeek(
                            onChanged: () {
                              updateScore();
                            },
                            mod: 0,
                            habit: habits[index - 1],
                            habitRecords: habitsRecords[index - 1]
                                .sublist(firstDayWeek, lastDayWeek),
                            today: today,
                          ));
                    }
                  }),
            ),
          ),
        ),
      ),
    );
  }
}
