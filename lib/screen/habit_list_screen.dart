import 'package:flutter/material.dart';
import 'package:flutter_rounded_date_picker/flutter_rounded_date_picker.dart';
import 'package:icebergnote/class/habit.dart';
import 'package:icebergnote/main.dart';
import 'package:icebergnote/screen/card/habit_card.dart';
import 'package:icebergnote/screen/input/habit_input.dart';
import 'package:realm/realm.dart';

class HabitListScreen extends StatefulWidget {
  const HabitListScreen({super.key});

  @override
  State<HabitListScreen> createState() => _HabitListScreenState();
}

class _HabitListScreenState extends State<HabitListScreen> {
  final ScrollController scrollController = ScrollController();
  List<Habit> habits = [];
  List<List<HabitRecord?>> habitsRecords = [];
  late int durationLenth = 7;
  late DateTime firstDay, lastDay, today, now;
  List<num> scoresWeek = [0, 0];
  List<num> scoresToday = [0, 0];
  List<String> tips = ['未来可期', '初露锋芒', '渐入佳境', '势如破竹', '一骑绝尘', '登峰造极'];
  @override
  void initState() {
    habits =
        realmHabit.query<Habit>('delete != true SORT(position ASC)').toList();
    now = DateTime.now();
    today = DateTime(now.year, now.month, now.day);
    dataInit();
    super.initState();
  }

  void dataInit() {
    habitsRecords = [];
    if (durationLenth == 7) {
      firstDay = today.add(Duration(days: -today.weekday + 1));
      lastDay = firstDay.add(const Duration(days: 7));
    }
    for (int i = 0; i < habits.length; i++) {
      List<HabitRecord> tmp = realmHabitRecord.query<HabitRecord>(
          'currentDate >= \$0 && currentDate <= \$1 && habit == \$2 SORT(currentDate ASC)',
          [firstDay, lastDay, habits[i].id]).toList();
      habitsRecords.add(List.generate(durationLenth, (index) => null));
      for (int j = 0; j < tmp.length; j++) {
        habitsRecords[i][tmp[j].currentDate.weekday - 1] = tmp[j];
      }
    }
    scoresWeek = countWeekScore();
    scoresToday = countTodayScore();
  }

  void updateScore() {
    habitsRecords = [];
    if (durationLenth == 7) {
      firstDay = today.add(Duration(days: -today.weekday + 1));
      lastDay = firstDay.add(const Duration(days: 7));
    }
    for (int i = 0; i < habits.length; i++) {
      List<HabitRecord> tmp = realmHabitRecord.query<HabitRecord>(
          'currentDate >= \$0 && currentDate <= \$1 && habit == \$2 SORT(currentDate ASC)',
          [firstDay, lastDay, habits[i].id]).toList();
      habitsRecords.add(List.generate(durationLenth, (index) => null));
      for (int j = 0; j < tmp.length; j++) {
        habitsRecords[i][tmp[j].currentDate.weekday - 1] = tmp[j];
      }
    }
    scoresWeek = countWeekScore();
    scoresToday = countTodayScore();
    setState(() {});
  }

  List<num> countWeekScore() {
    num scores = 0;
    num weights = 0;

    for (int i = 0; i < habits.length; i++) {
      num score = 0;
      for (int j = 0; j < habitsRecords[i].length; j++) {
        if (habitsRecords[i][j] != null) {
          score = score + habitsRecords[i][j]!.value;
        } else {}
      }
      scores = scores +
          score / 7 / habits[i].freqNum * habits[i].freqDen * habits[i].weight;
      weights = weights + habits[i].weight;
    }
    return [scores, weights];
  }

  List<num> countTodayScore() {
    num scores = 0;
    num weights = 0;

    for (int i = 0; i < habits.length; i++) {
      num score = 0;

      if (habitsRecords[i][today.weekday - 1] != null) {
        score = score + habitsRecords[i][today.weekday - 1]!.value;
      } else {}

      scores = scores +
          score / 7 / habits[i].freqNum * habits[i].freqDen * habits[i].weight;
      weights = weights + habits[i].weight;
    }
    return [scores, weights / 7];
  }

  int congratulationLevel(num scores, num weights) {
    if (scores >= weights) return 5;
    if (scores >= weights * 0.9) return 4;
    if (scores >= weights * 0.8) return 3;
    if (scores >= weights * 0.7) return 2;
    if (scores >= weights * 0.6) return 1;
    return 0;
  }

  Widget congratulationWidget(int l) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
            Text(
              tips[l],
              style: const TextStyle(
                color: Colors.white,
              ),
            ),
            Expanded(child: Container())
          ] +
          List.generate(l, (index) {
            return const Icon(
              Icons.star,
              size: 15,
              color: Colors.white,
            );
          }),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: GestureDetector(
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
                dataInit();
              });
            }
          },
          child: Text(
            today.toString().substring(0, 10),
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ),
      ),
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
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              controller: scrollController,
              itemCount: habits.length + 1,
              itemBuilder: (context, index) {
                if (index == 0) {
                  return Row(
                    mainAxisSize: MainAxisSize.max,
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      Expanded(
                        child: Container(
                          margin: const EdgeInsets.fromLTRB(15, 0, 8, 10),
                          padding: const EdgeInsets.fromLTRB(15, 0, 15, 0),
                          decoration: BoxDecoration(
                            color: const Color.fromARGB(255, 249, 172, 146),
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
                            // alignment: WrapAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  const Text(
                                    '今日',
                                    overflow: TextOverflow.visible,
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 22,
                                        fontWeight: FontWeight.bold),
                                  ),
                                  Expanded(child: Container()),
                                  Text(
                                    scoresToday[0].toInt().toString(),
                                    textAlign: TextAlign.right,
                                    style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 32,
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
                                        fontSize: 22,
                                        fontWeight: FontWeight.bold),
                                  ),
                                  Expanded(child: Container()),
                                  Text(
                                    scoresToday[1].toInt().toString(),
                                    textAlign: TextAlign.right,
                                    style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 32,
                                        fontWeight: FontWeight.bold),
                                  ),
                                ],
                              ),
                              congratulationWidget(congratulationLevel(
                                  scoresToday[0], scoresToday[1])),
                            ],
                          ),
                        ),
                      ),
                      Expanded(
                        child: Container(
                          margin: const EdgeInsets.fromLTRB(8, 0, 15, 10),
                          padding: const EdgeInsets.fromLTRB(15, 0, 15, 0),
                          decoration: BoxDecoration(
                            color: const Color.fromARGB(255, 137, 190, 244),
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
                            // alignment: WrapAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  const Text(
                                    '本周',
                                    overflow: TextOverflow.visible,
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 22,
                                        fontWeight: FontWeight.bold),
                                  ),
                                  Expanded(child: Container()),
                                  Text(
                                    scoresWeek[0].toInt().toString(),
                                    textAlign: TextAlign.right,
                                    style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 32,
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
                                        fontSize: 22,
                                        fontWeight: FontWeight.bold),
                                  ),
                                  Expanded(child: Container()),
                                  Text(
                                    scoresWeek[1].toInt().toString(),
                                    textAlign: TextAlign.right,
                                    style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 32,
                                        fontWeight: FontWeight.bold),
                                  ),
                                ],
                              ),
                              congratulationWidget(congratulationLevel(
                                  scoresWeek[0], scoresWeek[1])),
                            ],
                          ),
                        ),
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
                        habitRecords: habitsRecords[index - 1],
                        today: today,
                      ));
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}
