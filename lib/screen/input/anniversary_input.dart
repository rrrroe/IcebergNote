import 'dart:convert';
import 'package:clipboard/clipboard.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_rounded_date_picker/flutter_rounded_date_picker.dart';
import 'package:icebergnote/class/anniversary_class.dart';
import 'package:icebergnote/constants.dart';
import 'package:icebergnote/main.dart';
import 'package:icebergnote/class/notes.dart';
import 'package:icebergnote/postgresql/sync.dart';
import 'package:icebergnote/screen/card/anniversary_card.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:icebergnote/screen/widget/input_alert_dialog.dart';
import 'package:slide_switcher/slide_switcher.dart';

// ignore: must_be_immutable
class AnniversaryInputPage extends StatefulWidget {
  final VoidCallback onPageClosed;
  final Notes note;
  final int mod; //0新建，1修改，2查看
  final Anniversary anniversary;
  List<String> folderList = ['新建', '清空'];
  List<String> projectList = ['新建', '清空'];
  AnniversaryInputPage({
    super.key,
    required this.onPageClosed,
    required this.note,
    required this.mod,
    required this.anniversary,
  });

  @override
  State<AnniversaryInputPage> createState() => _AnniversaryInputPageState();
}

class _AnniversaryInputPageState extends State<AnniversaryInputPage> {
  TextEditingController titleController = TextEditingController();
  TextEditingController contentController = TextEditingController();
  TextEditingController oldprefixController = TextEditingController();
  TextEditingController oldsuffixController = TextEditingController();
  TextEditingController futprefixController = TextEditingController();
  TextEditingController futsuffixController = TextEditingController();
  TextEditingController otherController = TextEditingController();
  TextEditingController specialDayController = TextEditingController();
  final bgColorTextController = TextEditingController(text: '#FF7062DB');
  final ftColorTextController = TextEditingController(text: '#FFFFFFFF');
  int specialDays = 0;
  DateTime specialDate = DateTime(2024);
  bool specialDayErr = false;
  DateTime now = DateTime.now();

  @override
  void initState() {
    super.initState();
    titleController.text = widget.anniversary.title;
    contentController.text = widget.anniversary.content;
    specialDayController.text = widget.anniversary.alarmSpecialDay.toString();
    oldprefixController.text = widget.anniversary.oldPrefix;
    oldsuffixController.text = widget.anniversary.oldSuffix;
    futprefixController.text = widget.anniversary.futurePrefix;
    futsuffixController.text = widget.anniversary.futureSuffix;
    if (int.tryParse(specialDayController.text) == null) {
      specialDayErr = true;
    }
    specialDate = widget.anniversary.date;
    List<Notes> folderDistinctList = realm
        .query<Notes>(
            "noteFolder !='' DISTINCT(noteFolder) SORT(noteCreateDate DESC)")
        .toList();

    for (int i = 0; i < folderDistinctList.length; i++) {
      widget.folderList.add(folderDistinctList[i].noteFolder);
    }
    List<Notes> projectDistinctList = realm
        .query<Notes>(
            "noteProject !='' DISTINCT(noteProject) SORT(noteCreateDate DESC)")
        .toList();

    for (int i = 0; i < projectDistinctList.length; i++) {
      widget.projectList.add(projectDistinctList[i].noteProject);
    }
  }

  @override
  void dispose() {
    titleController.dispose();
    contentController.dispose();
    oldprefixController.dispose();
    oldsuffixController.dispose();
    futprefixController.dispose();
    futsuffixController.dispose();
    otherController.dispose();
    bgColorTextController.dispose();
    ftColorTextController.dispose();
    specialDayController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
                AnniversaryCard(
                  note: widget.note,
                  mod: 5,
                  context: context,
                  refreshList: () {},
                  searchText: '',
                  anniversary: widget.anniversary,
                ),
                Expanded(
                  child: SingleChildScrollView(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 25, vertical: 0),
                      child: Column(
                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              const Text(
                                '日子',
                                style: TextStyle(
                                    fontSize: 18, fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(width: 10, height: 28),
                              Expanded(
                                child: TextField(
                                  textAlign: TextAlign.right,
                                  controller: titleController,
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
                                    widget.anniversary.title = value;
                                  },
                                ),
                              ),
                            ],
                          ),
                          const Divider(),
                          Row(
                            children: [
                              const Text(
                                '日期',
                                style: TextStyle(
                                    fontSize: 18, fontWeight: FontWeight.bold),
                              ),
                              Expanded(child: Container(height: 28)),
                              Container(
                                  alignment: Alignment.centerLeft,
                                  color: Colors.white,
                                  height: 28,
                                  child: FilledButton.tonal(
                                    style: selectedContextButtonStyle,
                                    onPressed: () async {
                                      DateTime? newDateTime =
                                          await showRoundedDatePicker(
                                        initialDate: widget.anniversary.date,
                                        firstDate: DateTime(1900, 1, 1),
                                        lastDate: DateTime(2100, 1, 1),
                                        height: 300,
                                        context: context,
                                        locale: const Locale("zh", "CN"),
                                        theme: ThemeData(),
                                      );
                                      if (newDateTime != null) {
                                        setState(() {
                                          widget.anniversary.date = newDateTime;
                                        });
                                      }
                                    },
                                    child: Text(
                                      widget.anniversary.date
                                          .toString()
                                          .substring(0, 10),
                                      style: const TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold),
                                    ),
                                  )),
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
                                              pickerColor:
                                                  widget.anniversary.bgColor,
                                              onColorChanged:
                                                  (Color color) async {
                                                setState(() {
                                                  widget.anniversary.bgColor =
                                                      color;
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
                                    color: widget.anniversary.bgColor,
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
                                              pickerColor:
                                                  widget.anniversary.fontColor,

                                              onColorChanged:
                                                  (Color color) async {
                                                setState(() {
                                                  widget.anniversary.fontColor =
                                                      color;
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
                                    color: widget.anniversary.bgColor,
                                    borderRadius:
                                        BorderRadius.circular(2), // 设置圆角
                                  ),
                                  child: Text(
                                    '字体',
                                    style: TextStyle(
                                        color: widget.anniversary.fontColor,
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
                                '模式',
                                style: TextStyle(
                                    fontSize: 18, fontWeight: FontWeight.bold),
                              ),
                              Expanded(child: Container(height: 28)),
                              SlideSwitcher(
                                initialIndex: widget.anniversary.alarmType,
                                direction: Axis.horizontal,
                                containerColor: widget.anniversary.bgColor,
                                slidersColors: const [Colors.transparent],
                                slidersBorder:
                                    Border.all(color: Colors.white, width: 2),
                                containerBorder:
                                    Border.all(color: Colors.white, width: 0),
                                containerHeight: 28,
                                containerWight: 150,
                                indents: 2,
                                onSelect: (int index) => setState(() {
                                  widget.anniversary.alarmType = index;
                                }),
                                children: [
                                  Text(
                                    '距今',
                                    style: TextStyle(
                                        color: widget.anniversary.fontColor,
                                        fontWeight: FontWeight.bold),
                                  ),
                                  Text(
                                    '周期',
                                    style: TextStyle(
                                        color: widget.anniversary.fontColor,
                                        fontWeight: FontWeight.bold),
                                  ),
                                  Text(
                                    '特殊日',
                                    style: TextStyle(
                                        color: widget.anniversary.fontColor,
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
                                '农历',
                                style: TextStyle(
                                    fontSize: 18, fontWeight: FontWeight.bold),
                              ),
                              Expanded(child: Container(height: 28)),
                              SizedBox(
                                height: 20,
                                child: Switch(
                                    value: widget.anniversary.isjune,
                                    activeColor: widget.anniversary.bgColor,
                                    onChanged: (value) {
                                      setState(() {
                                        widget.anniversary.isjune = value;
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
                                '周期',
                                style: TextStyle(
                                    fontSize: 18, fontWeight: FontWeight.bold),
                              ),
                              Expanded(child: Container(height: 28)),
                              SlideSwitcher(
                                initialIndex: widget.anniversary.alarmDuration,
                                direction: Axis.horizontal,
                                containerColor: widget.anniversary.bgColor,
                                slidersColors: const [Colors.transparent],
                                slidersBorder:
                                    Border.all(color: Colors.white, width: 2),
                                containerBorder:
                                    Border.all(color: Colors.white, width: 0),
                                containerHeight: 28,
                                containerWight: 100,
                                indents: 2,
                                onSelect: (int index) => setState(() {
                                  widget.anniversary.alarmDuration = index;
                                }),
                                children: [
                                  Text(
                                    '年',
                                    style: TextStyle(
                                        color: widget.anniversary.fontColor,
                                        fontWeight: FontWeight.bold),
                                  ),
                                  Text(
                                    '季',
                                    style: TextStyle(
                                        color: widget.anniversary.fontColor,
                                        fontWeight: FontWeight.bold),
                                  ),
                                  Text(
                                    '月',
                                    style: TextStyle(
                                        color: widget.anniversary.fontColor,
                                        fontWeight: FontWeight.bold),
                                  ),
                                ],
                              )
                            ],
                          ),
                          const Divider(),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              const Text(
                                '特殊天数',
                                style: TextStyle(
                                    fontSize: 18, fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(width: 10, height: 28),
                              Expanded(
                                child: TextField(
                                  keyboardType: TextInputType.number,
                                  textAlign: TextAlign.right,
                                  controller: specialDayController,
                                  style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: specialDayErr
                                          ? Colors.red
                                          : Colors.black),
                                  minLines: 1,
                                  maxLines: 5,
                                  decoration: const InputDecoration(
                                    border: InputBorder.none,
                                    contentPadding:
                                        EdgeInsets.symmetric(vertical: 0),
                                    isDense: true,
                                  ),
                                  onChanged: (value) async {
                                    if (int.tryParse(value) != null) {
                                      widget.anniversary.alarmSpecialDay =
                                          int.parse(value);
                                      widget.anniversary.alarmSpecialDate =
                                          widget.anniversary.getSpecialDate();
                                      widget.anniversary.getSpecialDaysNum();
                                      specialDayErr = false;
                                      setState(() {});
                                    } else {
                                      specialDayErr = true;
                                      setState(() {});
                                    }
                                  },
                                ),
                              ),
                            ],
                          ),
                          const Divider(),
                          Row(
                            children: [
                              const Text(
                                '特殊日期',
                                style: TextStyle(
                                    fontSize: 18, fontWeight: FontWeight.bold),
                              ),
                              Expanded(child: Container(height: 28)),
                              Container(
                                  alignment: Alignment.centerLeft,
                                  color: Colors.white,
                                  height: 28,
                                  child: FilledButton.tonal(
                                    style: selectedContextButtonStyle,
                                    onPressed: () async {
                                      DateTime? newDateTime =
                                          await showRoundedDatePicker(
                                        initialDate:
                                            widget.anniversary.alarmSpecialDate,
                                        firstDate: DateTime(1900, 1, 1),
                                        lastDate: DateTime(2100, 1, 1),
                                        height: 300,
                                        context: context,
                                        locale: const Locale("zh", "CN"),
                                        theme: ThemeData(
                                            primarySwatch: Colors.lightBlue),
                                      );
                                      if (newDateTime != null) {
                                        setState(() {
                                          widget.anniversary.alarmSpecialDate =
                                              newDateTime;
                                          widget.anniversary.alarmSpecialDay =
                                              widget.anniversary
                                                  .getSpecialDays();
                                          specialDayController.text = widget
                                              .anniversary.alarmSpecialDay
                                              .toString();
                                        });
                                      }
                                    },
                                    child: Text(
                                      widget.anniversary.alarmSpecialDate
                                          .toString()
                                          .substring(0, 10),
                                      style: const TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold),
                                    ),
                                  )),
                            ],
                          ),
                          const Divider(),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              const Text(
                                '前缀(过去)',
                                style: TextStyle(
                                    fontSize: 18, fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(width: 10, height: 28),
                              Expanded(
                                child: TextField(
                                  textAlign: TextAlign.right,
                                  controller: oldprefixController,
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
                                    widget.anniversary.oldPrefix = value;
                                  },
                                ),
                              ),
                            ],
                          ),
                          const Divider(),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              const Text(
                                '后缀(过去)',
                                style: TextStyle(
                                    fontSize: 18, fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(width: 10, height: 28),
                              Expanded(
                                child: TextField(
                                  textAlign: TextAlign.right,
                                  controller: oldsuffixController,
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
                                    widget.anniversary.oldSuffix = value;
                                  },
                                ),
                              ),
                            ],
                          ),
                          const Divider(),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              const Text(
                                '前缀(未来)',
                                style: TextStyle(
                                    fontSize: 18, fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(width: 10, height: 28),
                              Expanded(
                                child: TextField(
                                  textAlign: TextAlign.right,
                                  controller: futprefixController,
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
                                    widget.anniversary.futurePrefix = value;
                                  },
                                ),
                              ),
                            ],
                          ),
                          const Divider(),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              const Text(
                                '后缀(未来)',
                                style: TextStyle(
                                    fontSize: 18, fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(width: 10, height: 28),
                              Expanded(
                                child: TextField(
                                  textAlign: TextAlign.right,
                                  controller: futsuffixController,
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
                                    widget.anniversary.futureSuffix = value;
                                  },
                                ),
                              ),
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
                                  controller: contentController,
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
                                    widget.anniversary.content = value;
                                  },
                                ),
                              ),
                            ],
                          ),
                          const Divider(),
                          Wrap(
                            direction: Axis.horizontal,
                            alignment: WrapAlignment.start, // Left align
                            spacing: 8.0,
                            runSpacing: 4.0,
                            children: [
                              MenuAnchor(
                                builder: (context, controller, child) {
                                  return FilledButton.tonal(
                                    style: selectButtonStyle,
                                    onPressed: () {
                                      if (controller.isOpen) {
                                        controller.close();
                                      } else {
                                        controller.open();
                                      }
                                    },
                                    child: Text(
                                      widget.note.noteProject == ''
                                          ? '项目'
                                          : widget.note.noteProject,
                                      style: widget.note.noteProject == ''
                                          ? const TextStyle(color: Colors.grey)
                                          : const TextStyle(
                                              color: Color.fromARGB(
                                                  255, 215, 55, 55)),
                                    ),
                                  );
                                },
                                menuChildren: widget.projectList.map((project) {
                                  return MenuItemButton(
                                    style: menuChildrenButtonStyle,
                                    child: Text(project),
                                    onPressed: () {
                                      switch (project) {
                                        case '清空':
                                          setState(() {
                                            realm.write(() {
                                              widget.note.noteProject = '';
                                              widget.note.noteUpdateDate =
                                                  DateTime.now().toUtc();
                                            });
                                          });
                                          break;
                                        case '新建':
                                          showDialog(
                                            context: context,
                                            builder: (ctx) {
                                              return InputAlertDialog(
                                                onSubmitted: (text) {
                                                  setState(() {
                                                    if (!text.startsWith('~')) {
                                                      text = '~$text';
                                                    }
                                                    widget.projectList
                                                        .add(text);
                                                    realm.write(() {
                                                      widget.note.noteProject =
                                                          text;
                                                      widget.note
                                                              .noteUpdateDate =
                                                          DateTime.now()
                                                              .toUtc();
                                                    });
                                                  });
                                                },
                                              );
                                            },
                                          );
                                          break;
                                        default:
                                          setState(() {
                                            realm.write(() {
                                              widget.note.noteProject = project;
                                              widget.note.noteUpdateDate =
                                                  DateTime.now().toUtc();
                                            });
                                          });
                                      }
                                    },
                                  );
                                }).toList(),
                              ),
                              MenuAnchor(
                                builder: (context, controller, child) {
                                  return FilledButton.tonal(
                                    style: selectButtonStyle,
                                    onPressed: () {
                                      if (controller.isOpen) {
                                        controller.close();
                                      } else {
                                        controller.open();
                                      }
                                    },
                                    child: Text(
                                      widget.note.noteFolder == ''
                                          ? '路径'
                                          : widget.note.noteFolder,
                                      style: widget.note.noteFolder == ''
                                          ? const TextStyle(color: Colors.grey)
                                          : const TextStyle(
                                              color: Color.fromARGB(
                                                  255, 4, 123, 60)),
                                    ),
                                  );
                                },
                                menuChildren: widget.folderList.map((folder) {
                                  return MenuItemButton(
                                    style: menuChildrenButtonStyle,
                                    child: Text(folder),
                                    onPressed: () {
                                      switch (folder) {
                                        case '清空':
                                          setState(() {
                                            realm.write(() {
                                              widget.note.noteFolder = '';
                                              widget.note.noteUpdateDate =
                                                  DateTime.now().toUtc();
                                            });
                                          });
                                          break;
                                        case '新建':
                                          showDialog(
                                            context: context,
                                            builder: (ctx) {
                                              return InputAlertDialog(
                                                onSubmitted: (text) {
                                                  setState(() {
                                                    if (!text.startsWith('/')) {
                                                      text = '/$text';
                                                    }
                                                    widget.folderList.add(text);
                                                    realm.write(() {
                                                      widget.note.noteFolder =
                                                          text;
                                                      widget.note
                                                              .noteUpdateDate =
                                                          DateTime.now()
                                                              .toUtc();
                                                    });
                                                  });
                                                },
                                              );
                                            },
                                          );
                                          break;
                                        default:
                                          setState(() {
                                            realm.write(() {
                                              widget.note.noteFolder = folder;
                                              widget.note.noteUpdateDate =
                                                  DateTime.now().toUtc();
                                            });
                                          });
                                      }
                                    },
                                  );
                                }).toList(),
                              ),
                            ],
                          ),
                          Text(widget.note.noteContext),
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
                      onPressed: () async {
                        save();
                        syncNoteToRemote(widget.note);
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
    realm.write(() {
      widget.note.noteContext = jsonEncode(widget.anniversary.toJson());
      widget.note.noteTitle = widget.anniversary.title;
      widget.note.noteUpdateDate = DateTime.now().toUtc();
    });
  }
}
