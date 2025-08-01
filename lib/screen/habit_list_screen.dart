import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_rounded_date_picker/flutter_rounded_date_picker.dart';
import 'package:icebergnote/class/habit.dart';
import 'package:icebergnote/extensions/color_extensions.dart';
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
  List<Color> habitsbgColors = [];
  List<Color> habitsftColors = [];
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
  List<GlobalKey> cardsKeys = [];
  bool reordering = false;
  int durationType = 0;

  @override
  void initState() {
    now = DateTime.now();
    today = DateTime(now.year, now.month, now.day);
    firstDay = DateTime(today.year, 1, 1).add(const Duration(days: -3));
    lastDay = DateTime(today.year, 12, 31).add(const Duration(days: 3));
    habits =
        realmHabit.query<Habit>('delete != true SORT(position ASC)').toList();
    for (int i = 0; i < habits.length; i++) {
      habitsbgColors.add(hexToColor(habits[i].color));
      habitsftColors.add(hexToColor(habits[i].fontColor));
    }
    dateInit();
    dataInit();
    cardsKeys = List.generate(habits.length, (int index) => GlobalKey());
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
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
        habitsRecords[i][tmp[j].currentDate.difference(firstDay).inDays] =
            tmp[j];
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
    // print('时间范围：$first~$last');
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
      for (int j = max(first, start); j < min(stop, last); j++) {
        if (habitsRecords[i][j] != null) {
          // if (habits[i].type == 1) {
          //   score = score + habitsRecords[i][j]!.data;
          // } else {
          //   score = score + habitsRecords[i][j]!.value;
          // }
          score = score + habitsRecords[i][j]!.score;
        } else {}
      }
      scores = scores + score;
      weights = weights +
          habits[i].weight *
              habits[i].freqNum /
              habits[i].freqDen *
              (last - first);
      segments.add(
          Segment(value: (score).toInt(), color: hexToColor(habits[i].color)));
      // print('${habits[i].name}:$start~$stop');
      // print('${habits[i].name}:$start+$stop');
    }
    List tmp = [scores, weights, segments];
    // print('-------------------------------');
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
  //         score = score + habitsRecords[i][j]!.finish;
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
  //       score = score + habitsRecords[i][today.weekday - 1]!.data;
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

  Widget buildScoreCard(
      String title,
      int scores,
      int target,
      Color bgColor,
      double leftPadding,
      double rightPadding,
      List<Segment> segments,
      VoidCallback tap) {
    if (target < 0) target = 0;
    return Expanded(
      child: GestureDetector(
        onTap: tap,
        child: Container(
          margin: EdgeInsets.fromLTRB(leftPadding, 5, rightPadding, 5),
          padding: const EdgeInsets.fromLTRB(6, 2, 6, 2),
          decoration: BoxDecoration(
            // boxShadow: [
            //   BoxShadow(
            //     color: Colors.black.withOpacity(0.2), // 阴影颜色
            //     spreadRadius: 5, // 阴影扩散半径
            //     blurRadius: 5, // 阴影模糊半径
            //     offset: const Offset(0, 5), // 阴影偏移
            //   ),
            // ],
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
                maxTotalValue: max(scores, max(1, target)),
                style: const SegmentedBarStyle(
                  size: 6,
                  gap: 0.1,
                  padding: EdgeInsets.fromLTRB(2, 8, 2, 4),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildLongScoreCard(String title, int scores, int target, Color bgColor,
      List<Segment> segments, VoidCallback tap) {
    if (target < 0) target = 0;
    return Expanded(
      child: GestureDetector(
        onTap: tap,
        child: Container(
          margin: const EdgeInsets.fromLTRB(15, 5, 15, 5),
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
                maxTotalValue: max(scores, max(1, target)),
                style: const SegmentedBarStyle(
                  size: 6,
                  gap: 0.1,
                  padding: EdgeInsets.fromLTRB(2, 8, 2, 4),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildBody() {
    if (reordering) {
      return RepaintBoundary(
        key: repaintWidgetKey,
        child: Container(
          color: Colors.white,
          child: Column(children: buildTitle() + buildList()),
        ),
      );
    } else {
      return Dismissible(
        key: Key(today.toString()),
        onDismissed: (direction) {
          // 判断是左滑还是右滑
          if (direction == DismissDirection.startToEnd) {
            // 右滑,切换到前一天
            setState(() {
              if (durationType == 0) {
                today = today.add(const Duration(days: -1));
              } else if (durationType == 1) {
                today = today.add(const Duration(days: -7));
              } else if (durationType == 2) {
                today = firstDay.add(Duration(days: firstDay7Week - 1));
              } else if (durationType == 3) {
                today = DateTime(today.year - 1, today.month, today.day);
              }
              dateInit();
              dataInit();
            });
          } else {
            // 左滑,切换到后一天
            setState(() {
              if (durationType == 0) {
                today = today.add(const Duration(days: 1));
              } else if (durationType == 1) {
                today = today.add(const Duration(days: 7));
              } else if (durationType == 2) {
                today = firstDay.add(Duration(days: lastDay7Week));
              } else if (durationType == 3) {
                today = DateTime(today.year + 1, today.month, today.day);
              }
              dateInit();
              dataInit();
            });
          }
        },
        child: SingleChildScrollView(
          scrollDirection: Axis.vertical,
          child: RepaintBoundary(
            key: repaintWidgetKey,
            child: Container(
              color: Colors.white,
              child: Column(children: buildTitle() + buildList()),
            ),
          ),
        ),
      );
    }
  }

  List<Widget> buildTitle() {
    return [
      Container(
        margin: const EdgeInsets.fromLTRB(20, 10, 16, 5),
        padding: const EdgeInsets.fromLTRB(0, 0, 0, 0),
        child: Row(
          children: [
            GestureDetector(
              onTap: () async {
                DateTime? newDateTime = await showRoundedDatePicker(
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
                '${today.year}年${today.month}月${today.day}日 第${weekNumber(today)}周 第${week7Number(today)}季',
                style:
                    const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
            Expanded(child: Container()),
            GestureDetector(
              child: Icon(reordering
                  ? Icons.check_outlined
                  : Icons.fit_screen_outlined),
              onTap: () async {
                if (reordering) {
                  reordering = false;
                  setState(() {});
                } else {
                  Uint8List pngBytes = await onScreenshot(repaintWidgetKey);
                  if (userLocalInfo != null) {
                    userName = userLocalInfo!.getString('userName');
                    userID = userLocalInfo!.getString('userID');
                    userCreatDate = userLocalInfo!.getString('userCreatDate');
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
                }
              },
            ),
            const SizedBox(width: 5),
            GestureDetector(
              child: const Icon(Icons.add),
              onTap: () async {
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
            ),
          ],
        ),
      ),
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
            scoresToday[2],
            () {
              durationType = 0;
              setState(() {});
            },
          ),
          buildScoreCard(
            '本周',
            scoresWeek[0].toInt(),
            scoresWeek[1].toInt(),
            const Color.fromARGB(255, 137, 190, 244),
            9,
            9,
            scoresWeek[2],
            () {
              durationType = 1;
              setState(() {});
            },
          ),
          buildScoreCard(
            '七周',
            scores7Week[0].toInt(),
            scores7Week[1].toInt(),
            const Color.fromARGB(255, 137, 198, 131),
            4,
            15,
            scores7Week[2],
            () {
              durationType = 2;
              setState(() {});
            },
          ),
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
            scoresYear[2],
            () {
              durationType = 3;
              setState(() {});
            },
          ),
        ],
      ),
    ];
  }

  List<Widget> buildList() {
    if (durationType == 0) {
      return [
        Wrap(
          alignment: WrapAlignment.start,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: List.generate(habits.length, (index) {
            return HabitCardDay(
              onChanged: () {
                updateScore();
                setState(() {});
              },
              mod: 2,
              habit: habits[index],
              habitRecord:
                  habitsRecords[index].sublist(todayIndex, todayIndex + 1),
              today: today,
              bgColor: habitsbgColors[index],
              ftColor: habitsftColors[index],
            );
          }),
        )
      ];
    }
    if (reordering) {
      return [
        Expanded(
          child: ReorderableListView(
            onReorder: onReorder,
            buildDefaultDragHandles: false,
            children: List.generate(habits.length, (index) {
              return GestureDetector(
                  key: cardsKeys[index],
                  onTap: () {},
                  onLongPress: () {
                    reordering = false;
                    setState(() {});
                  },
                  child: HabitCardWeek(
                    onChanged: () {
                      updateScore();
                      setState(() {});
                    },
                    mod: 2,
                    habit: habits[index],
                    habitRecords:
                        habitsRecords[index].sublist(firstDayWeek, lastDayWeek),
                    today: today,
                    index: index,
                    bgColor: habitsbgColors[index],
                    ftColor: habitsftColors[index],
                    delete: () {
                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return AlertDialog(
                            title: const Text('删除'),
                            content: const Text('确定要删除习惯吗？'),
                            actions: <Widget>[
                              TextButton(
                                child: const Text('取消'),
                                onPressed: () {
                                  Navigator.of(context).pop(); // 关闭弹窗
                                },
                              ),
                              TextButton(
                                child: const Text(
                                  '删除',
                                  style: TextStyle(color: Colors.red),
                                ),
                                onPressed: () {
                                  Navigator.of(context).pop(); // 关闭弹窗
                                  realmHabit.write(() {
                                    habits[index].delete = true;
                                    habits[index].updateDate =
                                        DateTime.now().toUtc();
                                  });
                                  setState(() {});
                                  syncHabitToRemote(habits[index]);
                                },
                              ),
                            ],
                          );
                        },
                      );
                    },
                  ));
            }),
          ),
        ),
      ];
    } else {
      return List.generate(habits.length, (index) {
        return GestureDetector(
            onTap: () {},
            onLongPress: () {
              reordering = true;
              setState(() {});
            },
            child: buildCard(
              durationType,
              () {
                updateScore();
                setState(() {});
              },
              () {
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      title: const Text('删除'),
                      content: const Text('确定要删除习惯吗？'),
                      actions: <Widget>[
                        TextButton(
                          child: const Text('取消'),
                          onPressed: () {
                            Navigator.of(context).pop(); // 关闭弹窗
                          },
                        ),
                        TextButton(
                          child: const Text(
                            '删除',
                            style: TextStyle(color: Colors.red),
                          ),
                          onPressed: () {
                            Navigator.of(context).pop(); // 关闭弹窗
                            realmHabit.write(() {
                              habits[index].delete = true;
                              habits[index].updateDate = DateTime.now().toUtc();
                            });
                            setState(() {});
                            syncHabitToRemote(habits[index]);
                          },
                        ),
                      ],
                    );
                  },
                );
              },
              0,
              habits[index],
              habitsRecords[index],
              today,
              index,
              habitsbgColors[index],
              habitsftColors[index],
            ));
      });
    }
  }

  List<Widget> buildTail() {
    return [];
  }

  Widget buildCard(
    int durationType,
    VoidCallback onChanged,
    VoidCallback delete,
    int mod,
    Habit habit,
    List<HabitRecord?> habitRecords,
    DateTime today,
    int index,
    Color bgColor,
    Color ftColor,
  ) {
    switch (durationType) {
      case 0:
        return GestureDetector(
            onTap: () {},
            onLongPress: () {
              reordering = true;
              setState(() {});
            },
            child: HabitCardDay(
              onChanged: onChanged,
              mod: mod,
              habit: habit,
              habitRecord: habitRecords.sublist(todayIndex, todayIndex + 1),
              today: today,
              bgColor: bgColor,
              ftColor: ftColor,
            ));
      case 1:
        return GestureDetector(
            onTap: () {},
            onLongPress: () {
              reordering = true;
              setState(() {});
            },
            child: HabitCardWeek(
              onChanged: onChanged,
              mod: mod,
              habit: habit,
              habitRecords: habitRecords.sublist(firstDayWeek, lastDayWeek),
              today: today,
              index: index,
              bgColor: bgColor,
              ftColor: ftColor,
              delete: delete,
            ));
      case 2:
        return GestureDetector(
            onTap: () {},
            onLongPress: () {
              reordering = true;
              setState(() {});
            },
            child: HabitCardSeason(
              onChanged: onChanged,
              mod: mod,
              habit: habit,
              habitRecords: habitRecords.sublist(firstDay7Week, lastDay7Week),
              today: today,
              todayIndex: today.difference(firstDay).inDays - firstDay7Week,
              index: index,
              bgColor: bgColor,
              ftColor: ftColor,
            ));
      case 3:
      default:
        return GestureDetector(
            onTap: () {},
            onLongPress: () {
              reordering = true;
              setState(() {});
            },
            child: HabitCardWeek(
              onChanged: onChanged,
              mod: mod,
              habit: habit,
              habitRecords: habitRecords,
              today: today,
              index: index,
              bgColor: bgColor,
              ftColor: ftColor,
              delete: delete,
            ));
    }
  }

  void onReorder(int oldIndex, int newIndex) {
    if (oldIndex < newIndex) {
      newIndex -= 1;
    }
    DateTime now = DateTime.now();
    var temp1 = habits.removeAt(oldIndex);
    var temp2 = habitsRecords.removeAt(oldIndex);
    var temp3 = habitsbgColors.removeAt(oldIndex);
    var temp4 = habitsftColors.removeAt(oldIndex);
    habits.insert(newIndex, temp1);
    habitsRecords.insert(newIndex, temp2);
    habitsbgColors.insert(newIndex, temp3);
    habitsftColors.insert(newIndex, temp4);
    setState(() {});
    realmHabit.write(() {
      for (int i = 0; i < habits.length; i++) {
        habits[i].position = i;
        habits[i].updateDate = now.toUtc();
        syncHabitToRemote(habits[i]);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: buildBody(),
    );
  }
}
