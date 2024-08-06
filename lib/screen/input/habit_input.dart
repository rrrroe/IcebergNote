import 'package:clipboard/clipboard.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:flutter_pickers/pickers.dart';
import 'package:flutter_pickers/time_picker/model/date_mode.dart';
import 'package:flutter_pickers/time_picker/model/pduration.dart';
import 'package:flutter_pickers/time_picker/model/suffix.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:flutter_rounded_date_picker/flutter_rounded_date_picker.dart';
import 'package:icebergnote/class/habit.dart';
import 'package:icebergnote/extensions/icondata_serialization.dart';
import 'package:icebergnote/main.dart';
import 'package:icebergnote/postgresql/sync.dart';
import 'package:icebergnote/screen/card/habit_card.dart';
import 'package:icebergnote/screen/input/icon_picker_input.dart';
import 'package:realm/realm.dart';
import 'package:slide_switcher/slide_switcher.dart';

Habit deepCopyHabit(Habit h) {
  return Habit(
    Uuid.v4(),
    h.createDate,
    h.updateDate,
    h.startDate,
    h.stopDate,
    color: h.color,
    fontColor: h.fontColor,
    description: h.description,
    freqDen: h.freqDen,
    freqNum: h.freqNum,
    highlight: h.highlight,
    reminder: h.reminder,
    reminderDay: h.reminderDay,
    reminderHour: h.reminderHour,
    reminderMin: h.reminderMin,
    weight: h.weight,
    archived: h.archived,
    delete: h.delete,
    question: h.question,
    unit: h.unit,
    icon: h.icon,
    isButtonAdd: h.isButtonAdd,
    buttonAddNum: h.buttonAddNum,
    needlog: h.needlog,
    canExpire: h.canExpire,
    expireDays: h.expireDays,
    reward: h.reward,
    todayAfterHour: h.todayAfterHour,
    todayAfterMin: h.todayAfterMin,
    todayBeforeHour: h.todayBeforeHour,
    todayBeforeMin: h.todayBeforeMin,
    targetFreq: h.targetFreq,
    targetType: h.targetType,
    targetValue: h.targetValue,
    type: h.type,
    // group: h.group,
    position: h.position,
    name: h.name,
    string1: h.string1,
    string2: h.string2,
    string3: h.string3,
    int1: h.int1,
    int2: h.int2,
    int3: h.int3,
    int4: h.int4,
    int5: h.int5,
    double1: h.double1,
    double2: h.double2,
    double3: h.double3,
    bool1: h.bool1,
    bool2: h.bool2,
    bool3: h.bool3,
  );
}

// ignore: must_be_immutable
class HabitInputPage extends StatefulWidget {
  HabitInputPage(
      {super.key,
      required this.onPageClosed,
      required this.mod,
      required this.habit});
  final VoidCallback onPageClosed;
  Habit habit;
  final int mod; //0正常，1不可点击

  @override
  State<HabitInputPage> createState() => _HabitInputPageState();
}

class _HabitInputPageState extends State<HabitInputPage> {
  TextEditingController nameController = TextEditingController();
  TextEditingController descriptionController = TextEditingController();
  TextEditingController questionController = TextEditingController();
  TextEditingController unitController = TextEditingController();
  TextEditingController freqDenController = TextEditingController();
  TextEditingController freqNumController = TextEditingController();
  TextEditingController positionController = TextEditingController();
  TextEditingController targetValueController = TextEditingController();
  TextEditingController weightController = TextEditingController();

  final bgColorTextController = TextEditingController(text: '#FF7062DB');
  final ftColorTextController = TextEditingController(text: '#FFFFFFFF');
  Color bgColor = const Color.fromARGB(255, 71, 172, 255);
  Color ftColor = const Color.fromARGB(255, 0, 0, 0);
  IconData? icon;
  String iconString = '';
  late Habit habit;
  int? freqDenErr;
  int? freqNumErr;
  int? positionErr;
  double? targetValueErr;
  double? weightErr;
  Set<int> selection = <int>{};
  HabitRecord? tmpHabitRecord;
  @override
  void initState() {
    habit = deepCopyHabit(widget.habit);
    nameController.text = habit.name;
    descriptionController.text = habit.description;
    questionController.text = habit.question;
    unitController.text = habit.unit;
    bgColor = hexToColor(habit.color);
    ftColor = hexToColor(habit.fontColor);
    freqDenController.text = habit.freqDen.toString();
    freqNumController.text = habit.freqNum.toString();
    positionController.text = habit.position.toString();
    targetValueController.text = habit.targetValue.toString();
    weightController.text = habit.weight.toString();
    freqDenErr = habit.freqDen;
    freqNumErr = habit.freqNum;
    positionErr = habit.position;
    targetValueErr = habit.targetValue;
    weightErr = habit.weight;
    selection = <int>{};
    int sum = habit.reminderDay;
    if (sum >= 64) {
      selection.add(64);
      sum = sum - 64;
    }
    if (sum >= 32) {
      selection.add(32);
      sum = sum - 32;
    }
    if (sum >= 16) {
      selection.add(16);
      sum = sum - 16;
    }
    if (sum >= 8) {
      selection.add(8);
      sum = sum - 8;
    }
    if (sum >= 4) {
      selection.add(4);
      sum = sum - 4;
    }
    if (sum >= 2) {
      selection.add(2);
      sum = sum - 2;
    }
    if (sum >= 1) {
      selection.add(1);
      sum = sum - 1;
    }
    tmpHabitRecord = HabitRecord(habit.id, habit.id, 1, habit.startDate,
        habit.startDate, habit.startDate);
    super.initState();
  }

  @override
  void dispose() {
    nameController.dispose();
    descriptionController.dispose();
    questionController.dispose();
    unitController.dispose();
    bgColorTextController.dispose();
    ftColorTextController.dispose();
    freqDenController.dispose();
    freqNumController.dispose();
    positionController.dispose();
    targetValueController.dispose();
    weightController.dispose();

    super.dispose();
  }

  // Future<void> _pickIcon() async {
  //   icon = await showIconPicker(
  //     context,
  //     adaptiveDialog: false,
  //     showTooltips: true,
  //     showSearchBar: true,
  //     iconPickerShape:
  //         RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
  //     iconPackModes: [IconPack.roundedMaterial],
  //     searchComparator: (String search, IconPickerIcon icon) =>
  //         search
  //             .toLowerCase()
  //             .contains(icon.name.replaceAll('_', ' ').toLowerCase()) ||
  //         icon.name.toLowerCase().contains(search.toLowerCase()),
  //   );
  // }

  @override
  Widget build(BuildContext context) {
    Widget currentIcon = iconDataToWidget(habit.icon, 18);

    return PopScope(
      onPopInvoked: (a) {
        widget.onPageClosed;
      },
      child: Scaffold(
        resizeToAvoidBottomInset: true,
        body: Stack(
          children: [
            Column(
              mainAxisSize: MainAxisSize.max,
              children: [
                const SizedBox(height: 20),
                Expanded(
                  child: SingleChildScrollView(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 25, vertical: 0),
                      child: Column(
                        children: [
                          Container(
                            height: 30,
                          ),
                          HabitCardWeek(
                            onChanged: () {},
                            delete: () {},
                            mod: 1,
                            habit: habit,
                            habitRecords: [
                              tmpHabitRecord,
                              null,
                              tmpHabitRecord,
                              tmpHabitRecord,
                              null,
                              null,
                              tmpHabitRecord,
                            ],
                            today: DateTime.now(),
                            index: 0,
                            bgColor: bgColor,
                            ftColor: ftColor,
                          ),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              const Text(
                                '名称',
                                style: TextStyle(
                                    fontSize: 18, fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(width: 10, height: 28),
                              Expanded(
                                child: TextField(
                                  textAlign: TextAlign.right,
                                  controller: nameController,
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  minLines: 1,
                                  maxLines: 1,
                                  decoration: const InputDecoration(
                                    border: InputBorder.none,
                                    contentPadding:
                                        EdgeInsets.symmetric(vertical: 0),
                                    isDense: true,
                                  ),
                                  onChanged: (value) async {
                                    habit.name = value;
                                  },
                                ),
                              ),
                            ],
                          ),
                          const Divider(),
                          Row(
                            children: [
                              const Text(
                                '图标',
                                style: TextStyle(
                                    fontSize: 18, fontWeight: FontWeight.bold),
                              ),
                              Expanded(child: Container(height: 28)),
                              GestureDetector(
                                onTap: () {
                                  showDialog(
                                    context: context,
                                    builder: (ctx) {
                                      return IconPickerAlertDialog(
                                        onSubmitted: (text) {
                                          setState(() {
                                            habit.icon = text;
                                          });
                                        },
                                        oldIcon: habit.icon,
                                      );
                                    },
                                  );
                                },
                                child: Container(
                                    height: 25,
                                    width: 40,
                                    alignment: Alignment.center,
                                    decoration: BoxDecoration(
                                      borderRadius:
                                          BorderRadius.circular(2), // 设置圆角
                                    ),
                                    child: currentIcon),
                              ),
                              const SizedBox(width: 2),
                            ],
                          ),
                          const Divider(),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              const Text(
                                '频率',
                                style: TextStyle(
                                    fontSize: 18, fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(width: 10, height: 28),
                              Expanded(child: Container()),
                              const Text(
                                '每',
                                style: TextStyle(
                                    fontSize: 18, fontWeight: FontWeight.bold),
                              ),
                              Container(
                                width: 30,
                                color: bgColor.withOpacity(0.1),
                                child: TextField(
                                  keyboardType: TextInputType.number,
                                  textAlign: TextAlign.center,
                                  controller: freqDenController,
                                  style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: freqDenErr == null
                                          ? Colors.red
                                          : Colors.black),
                                  minLines: 1,
                                  maxLines: 1,
                                  decoration: const InputDecoration(
                                    border: InputBorder.none,
                                    contentPadding:
                                        EdgeInsets.symmetric(vertical: 0),
                                    isDense: true,
                                  ),
                                  onChanged: (value) async {
                                    freqDenErr = int.tryParse(value);
                                    setState(() {});
                                    if (freqDenErr != null) {
                                      habit.freqDen = freqDenErr!;
                                    }
                                  },
                                ),
                              ),
                              const Text(
                                '天',
                                style: TextStyle(
                                    fontSize: 18, fontWeight: FontWeight.bold),
                              ),
                              Container(
                                width: 30,
                                color: bgColor.withOpacity(0.1),
                                child: TextField(
                                  keyboardType: TextInputType.number,
                                  textAlign: TextAlign.center,
                                  controller: freqNumController,
                                  style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: freqNumErr == null
                                          ? Colors.red
                                          : Colors.black),
                                  minLines: 1,
                                  maxLines: 1,
                                  decoration: const InputDecoration(
                                    border: InputBorder.none,
                                    contentPadding:
                                        EdgeInsets.symmetric(vertical: 0),
                                    isDense: true,
                                  ),
                                  onChanged: (value) async {
                                    freqNumErr = int.tryParse(value);
                                    setState(() {});
                                    if (freqNumErr != null) {
                                      habit.freqNum = freqNumErr!;
                                    }
                                  },
                                ),
                              ),
                              Container(
                                width: 5,
                              ),
                              Container(
                                width: 50,
                                color: bgColor.withOpacity(0.1),
                                child: TextField(
                                  keyboardType: TextInputType.number,
                                  textAlign: TextAlign.center,
                                  controller: unitController,
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  minLines: 1,
                                  maxLines: 1,
                                  decoration: const InputDecoration(
                                    border: InputBorder.none,
                                    contentPadding:
                                        EdgeInsets.symmetric(vertical: 0),
                                    isDense: true,
                                  ),
                                  onChanged: (value) async {
                                    habit.unit = value;
                                  },
                                ),
                              ),
                              const Text(
                                '(单位)',
                                style: TextStyle(
                                    fontSize: 18, fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                          const Divider(),
                          // Row(
                          //   crossAxisAlignment: CrossAxisAlignment.center,
                          //   children: [
                          //     const Text(
                          //       '排序',
                          //       style: TextStyle(
                          //           fontSize: 18, fontWeight: FontWeight.bold),
                          //     ),
                          //     const SizedBox(width: 10, height: 28),
                          //     Expanded(
                          //       child: TextField(
                          //         keyboardType: TextInputType.number,
                          //         textAlign: TextAlign.right,
                          //         controller: positionController,
                          //         style: TextStyle(
                          //             fontSize: 18,
                          //             fontWeight: FontWeight.bold,
                          //             color: freqDenErr == null
                          //                 ? Colors.red
                          //                 : Colors.black),
                          //         minLines: 1,
                          //         maxLines: 1,
                          //         decoration: const InputDecoration(
                          //           border: InputBorder.none,
                          //           contentPadding:
                          //               EdgeInsets.symmetric(vertical: 0),
                          //           isDense: true,
                          //         ),
                          //         onChanged: (value) async {
                          //           positionErr = int.tryParse(value);
                          //           setState(() {});
                          //           if (positionErr != null) {
                          //             habit.position = positionErr!;
                          //           }
                          //         },
                          //       ),
                          //     ),
                          //   ],
                          // ),
                          // const Divider(),
                          Row(
                            children: [
                              const Text(
                                '起始',
                                style: TextStyle(
                                    fontSize: 18, fontWeight: FontWeight.bold),
                              ),
                              Expanded(child: Container(height: 28)),
                              Container(
                                alignment: Alignment.centerLeft,
                                height: 28,
                                child: GestureDetector(
                                  onTap: () async {
                                    DateTime? newDateTime =
                                        await showRoundedDatePicker(
                                      initialDate: habit.startDate,
                                      firstDate: DateTime(1900, 1, 1),
                                      lastDate: DateTime(2100, 1, 1),
                                      height: 300,
                                      context: context,
                                      locale: const Locale("zh", "CN"),
                                      theme: ThemeData(),
                                    );
                                    if (newDateTime != null) {
                                      setState(() {
                                        bool v = !habit.stopDate
                                            .isAfter(habit.startDate);
                                        habit.startDate = DateTime.utc(
                                            newDateTime.year,
                                            newDateTime.month,
                                            newDateTime.day);
                                        if (v) {
                                          habit.stopDate = habit.startDate;
                                        }
                                      });
                                    }
                                  },
                                  child: Text(
                                    habit.startDate.toString().substring(0, 10),
                                    style: const TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const Divider(),
                          Row(
                            children: [
                              const Text(
                                '结束',
                                style: TextStyle(
                                    fontSize: 18, fontWeight: FontWeight.bold),
                              ),
                              Expanded(child: Container(height: 28)),
                              Container(
                                alignment: Alignment.centerLeft,
                                height: 28,
                                child: GestureDetector(
                                  onTap: () async {
                                    DateTime? newDateTime =
                                        await showRoundedDatePicker(
                                      initialDate: habit.stopDate,
                                      firstDate: DateTime(1900, 1, 1),
                                      lastDate: DateTime(2100, 1, 1),
                                      height: 300,
                                      context: context,
                                      locale: const Locale("zh", "CN"),
                                      theme: ThemeData(),
                                    );
                                    if (newDateTime != null) {
                                      setState(() {
                                        habit.stopDate = DateTime.utc(
                                            newDateTime.year,
                                            newDateTime.month,
                                            newDateTime.day);
                                      });
                                    }
                                  },
                                  child: Text(
                                    habit.stopDate.isAfter(habit.startDate)
                                        ? habit.stopDate
                                            .toString()
                                            .substring(0, 10)
                                        : '未设置',
                                    style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color: habit.stopDate
                                                .isAfter(habit.startDate)
                                            ? Colors.black
                                            : Colors.grey),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const Divider(),
                          Row(
                            children: [
                              const Text(
                                '背景',
                                style: TextStyle(
                                    fontSize: 18, fontWeight: FontWeight.bold),
                              ),
                              Expanded(child: Container(height: 28)),
                              GestureDetector(
                                onTap: () {
                                  showDialog(
                                    context: context,
                                    builder: (BuildContext context) {
                                      return AlertDialog(
                                        scrollable: true,
                                        titlePadding: const EdgeInsets.all(0),
                                        contentPadding: const EdgeInsets.all(0),
                                        content: Column(
                                          children: [
                                            ColorPicker(
                                              pickerColor: bgColor,
                                              onColorChanged:
                                                  (Color color) async {
                                                setState(() {
                                                  bgColor = color;
                                                  habit.color =
                                                      color.toHexString(
                                                          includeHashSign:
                                                              true);
                                                });
                                              },
                                              colorPickerWidth: 300,
                                              pickerAreaHeightPercent: 0.7,
                                              enableAlpha:
                                                  true, // hexInputController will respect it too.
                                              displayThumbColor: true,
                                              paletteType: PaletteType.hsv,
                                              labelTypes: const [],
                                              pickerAreaBorderRadius:
                                                  const BorderRadius.only(
                                                topLeft: Radius.circular(2),
                                                topRight: Radius.circular(2),
                                              ),
                                              hexInputController:
                                                  bgColorTextController, // <- here
                                              portraitOnly: true,
                                            ),
                                            Padding(
                                              padding:
                                                  const EdgeInsets.fromLTRB(
                                                      16, 0, 16, 16),
                                              child: CupertinoTextField(
                                                controller:
                                                    bgColorTextController,
                                                // Everything below is purely optional.
                                                prefix: const Padding(
                                                    padding: EdgeInsets.only(
                                                        left: 8),
                                                    child: Icon(Icons.tag)),
                                                suffix: IconButton(
                                                  icon: const Icon(Icons
                                                      .content_paste_rounded),
                                                  onPressed: () =>
                                                      FlutterClipboard.copy(
                                                          bgColorTextController
                                                              .text),
                                                ),
                                                autofocus: false,
                                                maxLength: 9,
                                                inputFormatters: [
                                                  // Any custom input formatter can be passed
                                                  // here or use any Form validator you want.
                                                  UpperCaseTextFormatter(),
                                                  FilteringTextInputFormatter
                                                      .allow(RegExp(
                                                          kValidHexPattern)),
                                                ],
                                              ),
                                            )
                                          ],
                                        ),
                                      );
                                    },
                                  );
                                },
                                child: Container(
                                  height: 25,
                                  width: 40,
                                  decoration: BoxDecoration(
                                    color: bgColor,
                                    borderRadius:
                                        BorderRadius.circular(2), // 设置圆角
                                  ),
                                ),
                              ),
                              const SizedBox(width: 2),
                            ],
                          ),
                          const Divider(),
                          Row(
                            children: [
                              const Text(
                                '字体',
                                style: TextStyle(
                                    fontSize: 18, fontWeight: FontWeight.bold),
                              ),
                              Expanded(child: Container(height: 28)),
                              GestureDetector(
                                onTap: () {
                                  showDialog(
                                    context: context,
                                    builder: (BuildContext context) {
                                      return AlertDialog(
                                        scrollable: true,
                                        titlePadding: const EdgeInsets.all(0),
                                        contentPadding: const EdgeInsets.all(0),
                                        content: Column(
                                          children: [
                                            ColorPicker(
                                              pickerColor: ftColor,

                                              onColorChanged:
                                                  (Color color) async {
                                                setState(() {
                                                  ftColor = color;
                                                  habit.fontColor =
                                                      color.toHexString();
                                                });
                                              },
                                              colorPickerWidth: 300,
                                              pickerAreaHeightPercent: 0.7,
                                              enableAlpha:
                                                  true, // hexInputController will respect it too.
                                              displayThumbColor: true,
                                              paletteType: PaletteType.hsv,
                                              labelTypes: const [],
                                              pickerAreaBorderRadius:
                                                  const BorderRadius.only(
                                                topLeft: Radius.circular(2),
                                                topRight: Radius.circular(2),
                                              ),
                                              hexInputController:
                                                  ftColorTextController, // <- here
                                              portraitOnly: true,
                                            ),
                                            Padding(
                                              padding:
                                                  const EdgeInsets.fromLTRB(
                                                      16, 0, 16, 16),
                                              child: CupertinoTextField(
                                                controller:
                                                    ftColorTextController,
                                                // Everything below is purely optional.
                                                prefix: const Padding(
                                                    padding: EdgeInsets.only(
                                                        left: 8),
                                                    child: Icon(Icons.tag)),
                                                suffix: IconButton(
                                                  icon: const Icon(Icons
                                                      .content_paste_rounded),
                                                  onPressed: () =>
                                                      FlutterClipboard.copy(
                                                          ftColorTextController
                                                              .text),
                                                ),
                                                autofocus: false,
                                                maxLength: 9,
                                                inputFormatters: [
                                                  // Any custom input formatter can be passed
                                                  // here or use any Form validator you want.
                                                  UpperCaseTextFormatter(),
                                                  FilteringTextInputFormatter
                                                      .allow(RegExp(
                                                          kValidHexPattern)),
                                                ],
                                              ),
                                            )
                                          ],
                                        ),
                                      );
                                    },
                                  );
                                },
                                child: Container(
                                  height: 25,
                                  width: 40,
                                  alignment: Alignment.center,
                                  decoration: BoxDecoration(
                                    color: bgColor,
                                    borderRadius:
                                        BorderRadius.circular(2), // 设置圆角
                                  ),
                                  child: Text(
                                    '字体',
                                    style: TextStyle(
                                        color: ftColor,
                                        fontWeight: FontWeight.bold),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 2),
                            ],
                          ),
                          const Divider(),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                '类型',
                                style: TextStyle(
                                    fontSize: 18, fontWeight: FontWeight.bold),
                              ),
                              Expanded(child: Container(height: 28)),
                              SlideSwitcher(
                                direction: Axis.horizontal,
                                initialIndex: widget.habit.type,
                                containerColor: bgColor,
                                slidersColors: const [Colors.transparent],
                                slidersBorder:
                                    Border.all(color: Colors.white, width: 2),
                                containerBorder:
                                    Border.all(color: Colors.white, width: 0),
                                containerHeight: 28,
                                containerWight: 150,
                                indents: 2,
                                onSelect: (int index) {
                                  habit.type = index;
                                  setState(() {});
                                },
                                children: [
                                  Text(
                                    '仅完成的',
                                    style: TextStyle(
                                        color: ftColor,
                                        fontWeight: FontWeight.bold),
                                  ),
                                  Text(
                                    '可计量的',
                                    style: TextStyle(
                                        color: ftColor,
                                        fontWeight: FontWeight.bold),
                                  ),
                                ],
                              )
                            ],
                          ),
                          const Divider(),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                '目标',
                                style: TextStyle(
                                    fontSize: 18, fontWeight: FontWeight.bold),
                              ),
                              Expanded(child: Container(height: 28)),
                              SlideSwitcher(
                                direction: Axis.horizontal,
                                initialIndex: widget.habit.type,
                                containerColor: bgColor,
                                slidersColors: const [Colors.transparent],
                                slidersBorder:
                                    Border.all(color: Colors.white, width: 2),
                                containerBorder:
                                    Border.all(color: Colors.white, width: 0),
                                containerHeight: 28,
                                containerWight: 100,
                                indents: 2,
                                onSelect: (int index) {
                                  habit.type = index;
                                  setState(() {});
                                },
                                children: [
                                  Text(
                                    '至少',
                                    style: TextStyle(
                                        color: ftColor,
                                        fontWeight: FontWeight.bold),
                                  ),
                                  Text(
                                    '至多',
                                    style: TextStyle(
                                        color: ftColor,
                                        fontWeight: FontWeight.bold),
                                  ),
                                ],
                              ),
                              SizedBox(
                                width: 50,
                                child: TextField(
                                  keyboardType: TextInputType.number,
                                  textAlign: TextAlign.right,
                                  controller: targetValueController,
                                  style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: targetValueErr == null
                                          ? Colors.red
                                          : Colors.black),
                                  minLines: 1,
                                  maxLines: 1,
                                  decoration: const InputDecoration(
                                    border: InputBorder.none,
                                    contentPadding:
                                        EdgeInsets.symmetric(vertical: 0),
                                    isDense: true,
                                  ),
                                  onChanged: (value) async {
                                    targetValueErr = double.tryParse(value);
                                    setState(() {});
                                    if (targetValueErr != null) {
                                      habit.targetValue = targetValueErr!;
                                    }
                                  },
                                ),
                              ),
                            ],
                          ),
                          const Divider(),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                '每次得分',
                                style: TextStyle(
                                    fontSize: 18, fontWeight: FontWeight.bold),
                              ),
                              Expanded(
                                child: TextField(
                                  keyboardType: TextInputType.number,
                                  textAlign: TextAlign.right,
                                  controller: weightController,
                                  style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: weightErr == null
                                          ? Colors.red
                                          : Colors.black),
                                  minLines: 1,
                                  maxLines: 1,
                                  decoration: const InputDecoration(
                                    border: InputBorder.none,
                                    contentPadding:
                                        EdgeInsets.symmetric(vertical: 0),
                                    isDense: true,
                                  ),
                                  onChanged: (value) async {
                                    weightErr = double.tryParse(value);
                                    setState(() {});
                                    if (weightErr != null) {
                                      habit.weight = weightErr!;
                                    }
                                  },
                                ),
                              ),
                            ],
                          ),
                          const Divider(),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                '是否提醒',
                                style: TextStyle(
                                    fontSize: 18, fontWeight: FontWeight.bold),
                              ),
                              Expanded(child: Container(height: 28)),
                              SizedBox(
                                height: 20,
                                child: Switch(
                                    value: habit.reminder,
                                    activeColor: bgColor,
                                    onChanged: (value) {
                                      setState(() {
                                        habit.reminder = value;
                                      });
                                    }),
                              )
                            ],
                          ),
                          const Divider(),
                          Visibility(
                            visible: habit.reminder,
                            child: Column(
                              children: [
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    const Text(
                                      '提醒问句',
                                      style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold),
                                    ),
                                    const SizedBox(width: 10, height: 28),
                                    Expanded(
                                      child: TextField(
                                        textAlign: TextAlign.right,
                                        controller: questionController,
                                        style: const TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                        ),
                                        minLines: 1,
                                        maxLines: 5,
                                        decoration: const InputDecoration(
                                          border: InputBorder.none,
                                          contentPadding:
                                              EdgeInsets.symmetric(vertical: 0),
                                          isDense: true,
                                        ),
                                        onChanged: (value) async {
                                          habit.question = value;
                                        },
                                      ),
                                    ),
                                  ],
                                ),
                                const Divider(),
                                Row(
                                  children: [
                                    const Text(
                                      '提醒时刻',
                                      style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold),
                                    ),
                                    Expanded(child: Container(height: 28)),
                                    Container(
                                      alignment: Alignment.centerLeft,
                                      height: 28,
                                      child: GestureDetector(
                                        onTap: () async {
                                          Pickers.showDatePicker(
                                            context,
                                            mode: DateMode.HM,
                                            suffix: Suffix.normal(),
                                            selectDate: PDuration(
                                              hour: habit.reminderHour,
                                              minute: habit.reminderMin,
                                            ),
                                            onConfirm: (p) {
                                              setState(() {
                                                if (p.hour != null) {
                                                  habit.reminderHour = p.hour!;
                                                }
                                                if (p.minute != null) {
                                                  habit.reminderMin = p.minute!;
                                                }
                                              });
                                            },
                                          );
                                        },
                                        child: Text(
                                          '${habit.reminderHour}:${habit.reminderMin}',
                                          style: const TextStyle(
                                              fontSize: 18,
                                              fontWeight: FontWeight.bold),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const Divider(),
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    const Text(
                                      '提醒日',
                                      style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold),
                                    ),
                                    SegmentedButton<int>(
                                      emptySelectionAllowed: true,
                                      segments: const [
                                        ButtonSegment(
                                            value: 1, label: Text('一')),
                                        ButtonSegment(
                                            value: 2, label: Text('二')),
                                        ButtonSegment(
                                            value: 4, label: Text('三')),
                                        ButtonSegment(
                                            value: 8, label: Text('四')),
                                        ButtonSegment(
                                            value: 16, label: Text('五')),
                                        ButtonSegment(
                                            value: 32, label: Text('六')),
                                        ButtonSegment(
                                            value: 64, label: Text('日')),
                                      ],
                                      style: const ButtonStyle(
                                          visualDensity:
                                              VisualDensity.standard),
                                      onSelectionChanged: (newSelection) {
                                        setState(() {
                                          selection = newSelection;
                                        });
                                        habit.reminderDay = 0;
                                        for (var value in newSelection) {
                                          habit.reminderDay =
                                              habit.reminderDay + value;
                                        }
                                      },
                                      selected: selection,
                                      multiSelectionEnabled: true,
                                      showSelectedIcon: false,
                                    ),
                                    const SizedBox(width: 10, height: 28),
                                  ],
                                ),
                                const Divider(),
                              ],
                            ),
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                '是否删除',
                                style: TextStyle(
                                    fontSize: 18, fontWeight: FontWeight.bold),
                              ),
                              Expanded(child: Container(height: 28)),
                              SizedBox(
                                height: 20,
                                child: Switch(
                                    value: habit.delete,
                                    activeColor: bgColor,
                                    onChanged: (value) {
                                      setState(() {
                                        habit.delete = value;
                                      });
                                    }),
                              )
                            ],
                          ),
                          const Divider(),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                '是否归档',
                                style: TextStyle(
                                    fontSize: 18, fontWeight: FontWeight.bold),
                              ),
                              Expanded(child: Container(height: 28)),
                              SizedBox(
                                height: 20,
                                child: Switch(
                                    value: habit.archived,
                                    activeColor: bgColor,
                                    onChanged: (value) {
                                      setState(() {
                                        habit.archived = value;
                                      });
                                    }),
                              )
                            ],
                          ),
                          const Divider(),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              const Text(
                                '备注',
                                style: TextStyle(
                                    fontSize: 18, fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(width: 10, height: 28),
                              Expanded(
                                child: TextField(
                                  textAlign: TextAlign.right,
                                  controller: descriptionController,
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  minLines: 1,
                                  maxLines: 5,
                                  decoration: const InputDecoration(
                                    border: InputBorder.none,
                                    contentPadding:
                                        EdgeInsets.symmetric(vertical: 0),
                                    isDense: true,
                                  ),
                                  onChanged: (value) async {
                                    habit.description = value;
                                  },
                                ),
                              ),
                            ],
                          ),
                          const Divider(),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(
                  height: 40,
                )
              ],
            ),
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                height: 40,
                decoration: BoxDecoration(
                    color: Theme.of(context).secondaryHeaderColor),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.end,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    TextButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      child: const Text('取消'),
                    ),
                    TextButton(
                      onPressed: () {
                        save();

                        Navigator.pop(context);
                        widget.onPageClosed();
                      },
                      child: const Text('保存'),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  save() {
    if (widget.mod == 0) {
      realmHabit.write(() {
        realmHabit.add(habit);
      });
      syncHabitToRemote(habit);
    } else {
      realmHabit.write(() {
        widget.habit.name = habit.name;
        widget.habit.color = habit.color;
        widget.habit.fontColor = habit.fontColor;
        widget.habit.description = habit.description;
        widget.habit.freqDen = habit.freqDen;
        widget.habit.freqNum = habit.freqNum;
        widget.habit.highlight = habit.highlight;
        widget.habit.position = habit.position;
        widget.habit.reminderHour = habit.reminderHour;
        widget.habit.reminderMin = habit.reminderMin;
        widget.habit.reminderDay = habit.reminderDay;
        widget.habit.type = habit.type;
        widget.habit.targetType = habit.targetType;
        widget.habit.targetValue = habit.targetValue;
        widget.habit.targetFreq = habit.targetFreq;
        widget.habit.weight = habit.weight;
        widget.habit.archived = habit.archived;
        widget.habit.delete = habit.delete;
        widget.habit.reminder = habit.reminder;
        widget.habit.question = habit.question;
        widget.habit.unit = habit.unit;
        widget.habit.createDate = habit.createDate;
        widget.habit.updateDate = DateTime.now().toUtc();
        widget.habit.startDate = habit.startDate;
        widget.habit.stopDate = habit.stopDate;
        widget.habit.icon = habit.icon;
        widget.habit.isButtonAdd = habit.isButtonAdd;
        widget.habit.buttonAddNum = habit.buttonAddNum;
        widget.habit.needlog = habit.needlog;
        widget.habit.canExpire = habit.canExpire;
        widget.habit.expireDays = habit.expireDays;
        widget.habit.reward = habit.reward;
        widget.habit.todayAfterHour = habit.todayAfterHour;
        widget.habit.todayAfterMin = habit.todayAfterMin;
        widget.habit.todayBeforeHour = habit.todayBeforeHour;
        widget.habit.todayBeforeMin = habit.todayBeforeMin;
        widget.habit.group = habit.group;
        widget.habit.string1 = habit.string1;
        widget.habit.string2 = habit.string2;
        widget.habit.string3 = habit.string3;
        widget.habit.int1 = habit.int1;
        widget.habit.int2 = habit.int2;
        widget.habit.int3 = habit.int3;
        widget.habit.int4 = habit.int4;
        widget.habit.int5 = habit.int5;
        widget.habit.double1 = habit.double1;
        widget.habit.double2 = habit.double2;
        widget.habit.double3 = habit.double3;
        widget.habit.bool1 = habit.bool1;
        widget.habit.bool2 = habit.bool2;
        widget.habit.bool3 = habit.bool3;
      });
      syncHabitToRemote(widget.habit);
    }
  }
}
