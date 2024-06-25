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
              itemCount: habits.length,
              itemBuilder: (context, index) {
                return GestureDetector(
                    onTap: () {},
                    child: HabitCardWeek(
                      onPageClosed: () {},
                      mod: 0,
                      habit: habits[index],
                      habitRecords: habitsRecords[index],
                      today: today,
                    ));
              },
            ),
          ),
        ],
      ),
    );
  }
}
