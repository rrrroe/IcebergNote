import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:icebergnote/chart/heatmap.dart';
import 'package:icebergnote/screen/noteslist_screen.dart';
import 'package:icebergnote/screen/record_graph_benifit.dart';
import 'package:realm/realm.dart';
import 'package:yaml/yaml.dart';
import '../constants.dart';
import '../main.dart';
import '../notes.dart';
import '../card.dart';
import 'record_graph_bar.dart';
import 'record_graph_line.dart';
import 'input/record_input.dart';
import 'package:intl/intl.dart';

bool isLeap(int year) {
  if (year % 4 == 0) {
    if (year % 100 == 0) {
      if (year % 400 == 0) {
        return true;
      } else {
        return false;
      }
    } else {
      return true;
    }
  } else {
    return false;
  }
}

class ReportScreen extends StatefulWidget {
  const ReportScreen({super.key, required this.duration});
  final String duration;
  @override
  State<ReportScreen> createState() => _ReportScreenState();
}

class _ReportScreenState extends State<ReportScreen>
    with SingleTickerProviderStateMixin {
  final tabs = <Tab>[
    const Tab(
      text: "报表",
    ),
    const Tab(
      text: "总览",
    ),
  ];
  List<num> randomdata = [];
  late TabController tabController;
  String currentProject = '';
  String currentReport = '';
  String currentReportDurationType = '';
  int dateFlag = 0;
  String selectDuration = '';
  late RealmResults<Notes> notesList;
  List<Notes> filterNoteList = [];
  List<Map> recordList = [];
  List<Map> filterRecordList = [];
  late Map noteMap, noteMapOther;
  late Color backgroundColor = Colors.white;
  late Color fontColor = Colors.black;
  late List propertySettings1;
  List<List> graphSettings = [];
  DateFormat ymd = DateFormat('yyyy-MM-dd');
  DateTime now = DateTime.now().toUtc();
  late int weekday;
  late DateTime firstDay;
  late DateTime lastDay;
  int quarter = 1;
  List<String> durationTypeList = ['周报', '月报', '季报', '年报', '自定义'];
  List<String> recordProjectList = [];
  List<num?> graphDataList = [];
  List<String> reportTypeList = [];
  @override
  void initState() {
    super.initState();
    tabController = TabController(length: tabs.length, vsync: this);
    DateTime now = DateTime.now().toUtc();
    weekday = now.weekday;
    firstDay = now.subtract(Duration(days: weekday - 1));
    firstDay = DateTime(firstDay.year, firstDay.month, firstDay.day);
    lastDay = now.add(Duration(days: DateTime.daysPerWeek - weekday));
    lastDay = DateTime(lastDay.year, lastDay.month, lastDay.day);
    recordProjectList = recordTemplates.keys.toList();
    if (recordProjectList != []) {
      currentProject = recordProjectList[0];
    }
    reportInit();
    for (int i = 0; i < 365; i++) {
      randomdata.add(Random().nextInt(10));
    }
  }

  void reportInit() {
    if (recordProjectList.isNotEmpty && currentProject == '') {
      currentProject = recordProjectList[0];
    }
    if (recordTemplatesSettings[currentProject] != null) {
      reportTypeList = recordTemplatesSettings[currentProject]!.keys.toList();
      reportTypeList.remove('settings');
      reportTypeList.remove('color');
      reportTypeList.remove('卡片');
    }
    if (currentReport == '') {
      currentReport = reportTypeList.isEmpty ? '' : reportTypeList[0];
    }
    selectDuration = widget.duration;
    notesList = realm.query<Notes>(
        "( noteProject == \$0 OR noteProject == \$1 ) AND noteType == '.记录' AND noteIsDeleted != true SORT(noteCreateDate ASC)",
        [currentProject, '$currentProject/']);

    backgroundColor = Color.fromARGB(
      40,
      recordTemplatesSettings[currentProject]!['color']![0],
      recordTemplatesSettings[currentProject]!['color']![1],
      recordTemplatesSettings[currentProject]!['color']![2],
    );
    fontColor = Color.fromARGB(
      255,
      max(0,
          min(recordTemplatesSettings[currentProject]!['color']![0] - 50, 255)),
      max(0,
          min(recordTemplatesSettings[currentProject]!['color']![1] - 50, 255)),
      max(0,
          min(recordTemplatesSettings[currentProject]!['color']![2] - 50, 255)),
    );
    propertySettings1 = recordTemplates[currentProject]!.values.elementAt(0);

    List tmpstr =
        recordTemplatesSettings[currentProject]![currentReport] ?? ['', '', ''];
    for (int index = 0; index < tmpstr.length; index++) {
      if (tmpstr[index][1] == '日期') {
        dateFlag = tmpstr[index][0];
        if (tmpstr[index].length > 2) {
          currentReportDurationType = tmpstr[index][2];
        } else {
          currentReportDurationType = '';
        }
      }
    }
    recordList = [];
    for (int i = 0; i < notesList.length; i++) {
      if (checkNoteFormat(notesList[i])) {
        recordList.add(loadYaml(notesList[i].noteContext) as YamlMap);
      }
    }
    filterNoteList = [];
    graphSettings = [];

    List<dynamic> filterSelect = [0];

    for (int index = 0; index < tmpstr.length; index++) {
      if (tmpstr[index][1] == '过滤' &&
          recordTemplates[currentProject]![tmpstr[index][0]]![1] == '单选') {
        filterSelect[0] = tmpstr[index][0];

        filterSelect.addAll(tmpstr[index][2].toString().split('||'));
      } else {
        graphSettings.add(tmpstr[index]);
      }
    }
    if (currentReportDurationType != '') {
      for (int i = 0; i < recordList.length; i++) {
        DateTime? date;
        if (dateFlag == 0) {
          date = DateTime.parse("1234-05-06 07:08:09");
        } else {
          if (recordList[i][dateFlag] != null) {
            date = ymd.parse(recordList[i][dateFlag].toString());
          }
        }
        bool arrayCrossFlag = false;

        if (date != null) {
          if (date.isBefore(
                  lastDay.add(const Duration(days: 1, seconds: -1))) &&
              date.isAfter(firstDay.add(const Duration(seconds: -1)))) {
            if (filterSelect[0] != 0) {
              List recordSelectProperty =
                  recordList[i][filterSelect[0]].toString().split(', ');
              for (int j = 0; j < recordSelectProperty.length; j++) {
                if (filterSelect.contains(recordSelectProperty[j])) {
                  arrayCrossFlag = true;
                }
              }
              if (arrayCrossFlag) {
                filterNoteList.add(notesList[i]);
              }
            } else {
              filterNoteList.add(notesList[i]);
            }
          }
        }
      }
    } else if (filterSelect[0] != 0) {
      for (int i = 0; i < recordList.length; i++) {
        bool arrayCrossFlag = false;
        if (filterSelect[0] != 0) {
          List recordSelectProperty =
              recordList[i][filterSelect[0]].toString().split(', ');
          for (int j = 0; j < recordSelectProperty.length; j++) {
            if (filterSelect.contains(recordSelectProperty[j])) {
              arrayCrossFlag = true;
            }
          }
          if (arrayCrossFlag) {
            filterNoteList.add(notesList[i]);
          }
        } else {
          filterNoteList.add(notesList[i]);
        }
      }
    } else {
      filterNoteList = notesList.toList();
    }

    filterRecordList = [];
    for (int i = 0; i < filterNoteList.length; i++) {
      filterRecordList.add(loadYaml(filterNoteList[i].noteContext) as YamlMap);
    }
    graphDataList = [];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: SizedBox(
          height: 50,
          child: TabBar(
            controller: tabController,
            tabs: tabs,
            indicatorSize: TabBarIndicatorSize.tab,
            indicatorColor: const Color.fromARGB(255, 0, 140, 198),
            isScrollable: false,
            labelStyle: const TextStyle(fontSize: 16, fontFamily: 'LXGWWenKai'),
            unselectedLabelStyle:
                const TextStyle(fontSize: 14, fontFamily: 'LXGWWenKai'),
          ),
        ),
      ),
      body: TabBarView(
        controller: tabController,
        children: [
          SingleChildScrollView(
            scrollDirection: Axis.vertical,
            child: RepaintBoundary(
                key: repaintWidgetKey,
                child: Container(
                  color: Colors.white,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: buildTitleList() +
                        buildMenuList() +
                        buildgraphList() +
                        buildCardList(),
                  ),
                )),
          ),
          DaysInYearHeatmap(
            data: randomdata,
            color: Colors.green,
            level: const [2, 4, 6, 8],
            firstWeekday: 3,
            today: 355,
          ),
        ],
      ),
    );
  }

  List<Widget> buildTitleList() {
    List<Widget> titleList = [];
    titleList.add(
      Row(
        children: [
          const SizedBox(width: 15),
          MenuAnchor(
            builder: (context, controller, child) {
              return FilledButton.tonal(
                style: transparentContextButtonStyle,
                onPressed: () {
                  if (controller.isOpen) {
                    controller.close();
                  } else {
                    controller.open();
                  }
                },
                child: Text(
                  currentProject,
                  style: TextStyle(
                    color: fontColor,
                    fontSize: 30,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              );
            },
            menuChildren: recordProjectList.map((type) {
              return MenuItemButton(
                style: menuChildrenButtonStyle,
                child: Text(type),
                onPressed: () {
                  setState(() {
                    currentProject = type;
                    reportInit();
                  });
                },
              );
            }).toList(),
          ),
          Expanded(child: Container()),
          GestureDetector(
            child: const Icon(Icons.fit_screen_outlined),
            onTap: () async {
              // PermissionUtil.requestAll();
              Uint8List pngBytes = await onScreenshot(20);
              // ignore: use_build_context_synchronously
              showDialog(
                builder: (_) => ImagePopup(pngBytes: pngBytes),
                context: context,
              );
            },
          ),
          const SizedBox(width: 15),
        ],
      ),
    );
    return titleList;
  }

  List<Widget> buildMenuList() {
    List<Widget> titleList = [];
    titleList.add(
      Row(
        children: [
          const SizedBox(width: 15),
          SizedBox(
            height: 30,
            width: 70,
            child: MenuAnchor(
              builder: (context, controller, child) {
                return FilledButton.tonal(
                  style: transparentContextButtonStyle,
                  onPressed: () {
                    if (controller.isOpen) {
                      controller.close();
                    } else {
                      controller.open();
                    }
                  },
                  child: Text(
                    currentReport,
                    style: const TextStyle(
                      color: Colors.black,
                      fontSize: 16,
                    ),
                  ),
                );
              },
              menuChildren: reportTypeList.map((type) {
                return MenuItemButton(
                  style: menuChildrenButtonStyle,
                  child: Text(type),
                  onPressed: () {
                    setState(() {
                      currentReport = type;
                      List tmpstr = recordTemplatesSettings[currentProject]![
                          currentReport]!;
                      for (int index = 0; index < tmpstr.length; index++) {
                        if (tmpstr[index][1] == '日期') {
                          dateFlag = tmpstr[index][0];
                          if (tmpstr[index].length > 2) {
                            currentReportDurationType = tmpstr[index][2];
                          } else {
                            currentReportDurationType = '';
                          }
                        }
                      }
                      quarter = ((now.month - 1) ~/ 3) + 1;
                      switch (currentReportDurationType) {
                        case '自定义':
                        case '周报':
                          firstDay = now.subtract(Duration(days: weekday - 1));
                          firstDay = DateTime(
                              firstDay.year, firstDay.month, firstDay.day);
                          lastDay = now.add(
                              Duration(days: DateTime.daysPerWeek - weekday));
                          lastDay = DateTime(
                              lastDay.year, lastDay.month, lastDay.day);
                          break;
                        case '月报':
                          firstDay = DateTime(now.year, now.month, 1);
                          lastDay = DateTime(now.year, now.month + 1, 1)
                              .subtract(const Duration(days: 1));
                          break;
                        case '季报':
                          if (quarter == 1) {
                            firstDay = DateTime(now.year, 1, 1);
                            lastDay = DateTime(now.year, 3, 31);
                          } else if (quarter == 2) {
                            firstDay = DateTime(now.year, 4, 1);
                            lastDay = DateTime(now.year, 6, 30);
                          } else if (quarter == 3) {
                            firstDay = DateTime(now.year, 7, 1);
                            lastDay = DateTime(now.year, 9, 30);
                          } else {
                            firstDay = DateTime(now.year, 10, 1);
                            lastDay = DateTime(now.year, 12, 31);
                          }
                          break;
                        case '年报':
                          firstDay = DateTime(now.year, 1, 1);
                          lastDay = DateTime(now.year, 12, 31);
                      }
                      reportInit();
                    });
                  },
                );
              }).toList(),
            ),
          ),
          Expanded(
              child: Container(
            height: 40,
          )),
          Visibility(
            visible: currentReportDurationType != '',
            child: Row(
              children: [
                IconButton.filledTonal(
                  onPressed: () {
                    quarter = ((firstDay.month - 1) ~/ 3) + 1;
                    setState(() {
                      switch (currentReportDurationType) {
                        case '自定义':
                        case '周报':
                          firstDay = firstDay.add(const Duration(days: -7));
                          lastDay = lastDay.add(const Duration(days: -7));
                          break;
                        case '月报':
                          lastDay = firstDay.add(const Duration(days: -1));
                          firstDay = DateTime(lastDay.year, lastDay.month, 1);
                          break;
                        case '季报':
                          lastDay = firstDay.add(const Duration(days: -1));
                          quarter = ((lastDay.month - 1) ~/ 3) + 1;
                          if (quarter == 1) {
                            firstDay = DateTime(lastDay.year, 1, 1);
                          } else if (quarter == 2) {
                            firstDay = DateTime(lastDay.year, 4, 1);
                          } else if (quarter == 3) {
                            firstDay = DateTime(lastDay.year, 7, 1);
                          } else {
                            firstDay = DateTime(lastDay.year, 10, 1);
                          }
                          break;
                        case '年报':
                          lastDay = firstDay.add(const Duration(days: -1));
                          firstDay = DateTime(lastDay.year, 1, 1);
                      }
                      reportInit();
                    });
                  },
                  style: ButtonStyle(
                      foregroundColor: MaterialStateProperty.all(Colors.white),
                      backgroundColor: MaterialStateProperty.all(
                          const Color.fromARGB(0, 255, 255, 255))),
                  icon: const Icon(
                    Icons.arrow_circle_left_outlined,
                    color: Colors.grey,
                  ),
                ),
                Text(
                  '${ymd.format(firstDay)} ~ ${ymd.format(lastDay)}',
                  style: const TextStyle(
                      fontSize: 14, fontWeight: FontWeight.w600),
                ),
                IconButton.filledTonal(
                  onPressed: () {
                    setState(() {
                      switch (currentReportDurationType) {
                        case '自定义':
                        case '周报':
                          firstDay = firstDay.add(const Duration(days: 7));
                          lastDay = lastDay.add(const Duration(days: 7));
                          break;
                        case '月报':
                          firstDay = lastDay.add(const Duration(days: 1));
                          lastDay =
                              DateTime(firstDay.year, firstDay.month + 1, 1)
                                  .subtract(const Duration(days: 1));
                          break;
                        case '季报':
                          firstDay = lastDay.add(const Duration(days: 1));
                          quarter = ((firstDay.month - 1) ~/ 3) + 1;
                          if (quarter == 1) {
                            lastDay = DateTime(firstDay.year, 3, 31);
                          } else if (quarter == 2) {
                            lastDay = DateTime(firstDay.year, 6, 30);
                          } else if (quarter == 3) {
                            lastDay = DateTime(firstDay.year, 9, 30);
                          } else {
                            lastDay = DateTime(firstDay.year, 12, 31);
                          }
                          break;
                        case '年报':
                          firstDay = lastDay.add(const Duration(days: 1));
                          lastDay = DateTime(firstDay.year, 12, 31);
                      }
                      reportInit();
                    });
                  },
                  style: ButtonStyle(
                      foregroundColor: MaterialStateProperty.all(Colors.white),
                      backgroundColor: MaterialStateProperty.all(
                          const Color.fromARGB(0, 255, 255, 255))),
                  icon: const Icon(
                    Icons.arrow_circle_right_outlined,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
        ],
      ),
    );
    return titleList;
  }

  List<Widget> buildgraphList() {
    List<Widget> graphList = [];

    return graphList;
  }

  List<Widget> buildCardList() {
    List<Widget> cardList = [];
    for (List graphSetting in graphSettings) {
      List propertySettings =
          (!recordTemplates[currentProject]!.containsKey(graphSetting[0])
              ? []
              : recordTemplates[currentProject]![graphSetting[0]]!);
      if (graphSetting[0] == 0) {
        List data = [];
        for (int i = 0; i < filterRecordList.length; i++) {
          data.add(1);
        }
        cardList.add(
            statisticsGenerate('', '条目', graphSetting, data, fontColor, ''));
      }
      if (recordTemplates[currentProject]!.containsKey(graphSetting[0])) {
        int durationDayLength = lastDay.difference(firstDay).inDays + 1;
        if (graphSetting[1] == '折线图' || graphSetting[1] == '柱状图') {
          List<num> data = [];
          if (recordTemplates[currentProject]![graphSetting[0]]![1] == '数字') {
            switch (currentReportDurationType) {
              case '周报':
                for (int i = 0; i < durationDayLength; i++) {
                  data.add(0);
                }
                for (int i = 0; i < filterRecordList.length; i++) {
                  if (filterRecordList[i][graphSetting[0]].runtimeType == int ||
                      filterRecordList[i][graphSetting[0]].runtimeType ==
                          double) {
                    data[DateTime.parse(filterRecordList[i][dateFlag]).weekday -
                        1] += filterRecordList[i][graphSetting[0]];
                  }
                }
                break;
              case '月报':
                for (int i = 0; i < durationDayLength; i++) {
                  data.add(0);
                }
                for (int i = 0; i < filterRecordList.length; i++) {
                  if (filterRecordList[i][graphSetting[0]].runtimeType == int ||
                      filterRecordList[i][graphSetting[0]].runtimeType ==
                          double) {
                    data[DateTime.parse(filterRecordList[i][dateFlag]).day -
                        1] += filterRecordList[i][graphSetting[0]];
                  }
                }
                break;
              case '年报':
                for (int i = 0; i < 12; i++) {
                  data.add(0);
                }
                for (int i = 0; i < filterRecordList.length; i++) {
                  if (filterRecordList[i][graphSetting[0]].runtimeType == int ||
                      filterRecordList[i][graphSetting[0]].runtimeType ==
                          double) {
                    data[DateTime.parse(filterRecordList[i][dateFlag]).month -
                        1] += filterRecordList[i][graphSetting[0]];
                  }
                }
                break;
            }
            if (graphSetting[1] == '折线图') {
              cardList.add(
                LineChartSample(
                  fontColor: fontColor,
                  dataList: data,
                  currentReportDurationType: currentReportDurationType,
                  title: recordTemplates[currentProject]![graphSetting[0]]![0],
                  unit: propertySettings[3],
                  length: data.length,
                ),
              );
            }
            if (graphSetting[1] == '柱状图') {
              cardList.add(
                BarChartSample3(
                  fontColor: fontColor,
                  dataList: data,
                  currentReportDurationType: currentReportDurationType,
                  title: '',
                  unit: propertySettings[3],
                  length: data.length,
                ),
              );
            }
          }
        } else if (graphSetting[1] == '收益曲线图') {
          if (recordTemplates[currentProject]!.containsKey(graphSetting[0])) {
            if (recordTemplates[currentProject]![graphSetting[0]]![1] == '数字' &&
                recordTemplates[currentProject]![
                        int.tryParse(graphSetting[2])]![1] ==
                    '数字') {
              switch (graphSetting[3]) {
                case '本年':
                  List<Map<String, int>> data = []; //｛天数：[资产总额，出入金，投入额，收益率]｝
                  DateTime startDay = DateTime(firstDay.year, 1, 1);
                  DateTime endDay = lastDay;

                  var notesListX = realm.query<Notes>(
                      "( noteProject == \$0 ) AND noteType == '.记录' AND noteIsDeleted != true SORT(noteCreateDate ASC)",
                      [currentProject]);
                  List<Map> recordListX = [];
                  for (int i = 0; i < notesListX.length; i++) {
                    if (checkNoteFormat(notesListX[i])) {
                      recordListX
                          .add(loadYaml(notesListX[i].noteContext) as YamlMap);
                    }
                  }
                  Map<String, int> tmp0 = {};
                  DateTime leastDay = DateTime(1, 1, 1);
                  for (int i = 0; i < recordListX.length; i++) {
                    DateTime? date =
                        DateTime.tryParse(recordListX[i][dateFlag].toString());
                    if (date != null) {
                      if (date.isBefore(startDay)) {
                        if (date.isAfter(leastDay)) {
                          if (recordListX[i][graphSetting[0]].runtimeType ==
                                  int ||
                              recordListX[i][graphSetting[0]].runtimeType ==
                                  double) {
                            tmp0['day'] = 0;
                            tmp0['asset'] = recordListX[i][graphSetting[0]];

                            if (recordListX[i][graphSetting[2]].runtimeType ==
                                    int ||
                                recordListX[i][graphSetting[2]].runtimeType ==
                                    double) {
                              tmp0['change'] = recordListX[i][graphSetting[2]];
                            } else {
                              tmp0['change'] = 0;
                            }
                            leastDay = date;
                          }
                        }
                      }
                      if (date.isBefore(endDay
                              .add(const Duration(days: 1, seconds: -1))) &&
                          date.isAfter(
                              startDay.add(const Duration(seconds: -1)))) {
                        if (recordListX[i][graphSetting[0]].runtimeType ==
                                int ||
                            recordListX[i][graphSetting[0]].runtimeType ==
                                double) {
                          Map<String, int> tmp = {};
                          tmp['day'] = date.difference(startDay).inDays + 1;
                          tmp['asset'] = recordListX[i][graphSetting[0]];
                          if (recordListX[i][int.tryParse(graphSetting[2])]
                                      .runtimeType ==
                                  int ||
                              recordListX[i][int.tryParse(graphSetting[2])]
                                      .runtimeType ==
                                  double) {
                            tmp['change'] =
                                recordListX[i][int.tryParse(graphSetting[2])];
                          } else {
                            tmp['change'] = 0;
                          }
                          data.add(tmp);
                        }
                      }
                    }
                  }
                  if (leastDay == DateTime(1, 1, 1)) {
                    tmp0['day'] = 0;
                    tmp0['asset'] = -1;
                    tmp0['change'] = 0;
                  }
                  data.add(tmp0);
                  cardList.add(
                    BenifutLineChart(
                      fontColor: fontColor,
                      dataList: data,
                      currentReportDurationType: currentReportDurationType,
                      title: '',
                      unit: propertySettings[3],
                      length: data.length,
                      startDay: startDay,
                    ),
                  );
              }
            }
          }
        } else if (graphSetting[1] == '日年热力图') {
          if (recordTemplates[currentProject]!.containsKey(graphSetting[0])) {
            if (recordTemplates[currentProject]![graphSetting[0]]![1] == '数字') {
              List<num> level = [];
              List<num> data = [];
              for (int i = 2; i < graphSetting.length; i++) {
                level.add(
                    num.tryParse(graphSetting[i].toString()) ?? level.last);
              }
              for (int i = 0; i < (isLeap(firstDay.year) ? 366 : 365); i++) {
                data.add(0);
              }
              for (int i = 0; i < filterRecordList.length; i++) {
                DateTime tmp = DateTime.parse(filterRecordList[i][dateFlag]);
                int dayNO = tmp.difference(DateTime(tmp.year)).inDays;
                data[dayNO] =
                    data[dayNO] + filterRecordList[i][graphSetting[0]];
              }
              cardList.add(DaysInYearHeatmap(
                  data: data,
                  color: fontColor,
                  level: level,
                  firstWeekday: firstDay.weekday,
                  today: -20));
            } else {
              List<num> level = [];
              List<num> data = [];
              if (graphSetting.length <= 2) {
                level.add(1);
              } else {
                for (int i = 2; i < graphSetting.length; i++) {
                  level.add(num.tryParse(graphSetting[i]) ?? level.last);
                }
              }

              for (int i = 0; i < (isLeap(firstDay.year) ? 366 : 365); i++) {
                data.add(0);
              }
              for (int i = 0; i < filterRecordList.length; i++) {
                DateTime tmp = DateTime.parse(filterRecordList[i][dateFlag]);
                int dayNO = tmp.difference(DateTime(tmp.year)).inDays;
                data[dayNO] = data[dayNO] + 1;
              }
              cardList.add(DaysInYearHeatmap(
                  data: data,
                  color: fontColor,
                  level: level,
                  firstWeekday: firstDay.weekday,
                  today: -20));
            }
          }
        } else {
          List data = [];
          for (int i = 0; i < filterRecordList.length; i++) {
            data.add(filterRecordList[i][graphSetting[0]]);
          }

          cardList.add(statisticsGenerate(
              propertySettings[0],
              propertySettings[1],
              graphSetting,
              data,
              fontColor,
              propertySettings[3]));
        }
      }
      if (graphSetting[0] == 1111) {
        cardList.add(const SizedBox(height: 5));
        if (graphSetting[1] == '卡片') {
          for (int i = 0; i < filterRecordList.length; i++) {
            Map noteMap = filterRecordList[i];
            Map noteMapOther = {...noteMap};
            noteMapOther.remove(noteMapOther.keys.first);
            noteMapOther.removeWhere((key, value) => value == null);
            if (graphSetting.length > 2) {
              List<int> properties = [];
              List<String> propertiesName =
                  graphSetting[2].toString().split('||');
              for (int i = 0; i < propertiesName.length; i++) {
                int? tmp = int.tryParse(propertiesName[i]);
                if (tmp != null) {
                  properties.add(tmp);
                }
              }
              cardList.add(buildRecordCardOfList(
                  filterNoteList[i], 3, context, reportInit, properties));
            } else {
              if (recordTemplatesSettings[currentProject]!['卡片'] != null) {
                List<int> properties = [];
                for (int i = 0;
                    i < recordTemplatesSettings[currentProject]!['卡片']!.length;
                    i++) {
                  int? tmp = int.tryParse(
                      recordTemplatesSettings[currentProject]!['卡片']![i]);
                  if (tmp != null) {
                    properties.add(tmp);
                  }
                }
                cardList.add(buildRecordCardOfList(
                    filterNoteList[i], 3, context, reportInit, properties));
              } else {
                cardList.add(buildRecordCardOfList(
                    filterNoteList[i],
                    3,
                    context,
                    reportInit,
                    recordTemplates[currentProject]!.keys.toList()));
              }
            }
          }
        } else if (graphSetting[1] == '表格') {
          List<int> properties = [];
          List<String> propertiesName = graphSetting[2].toString().split('||');
          List<double?> propertiesLength = [];
          if (graphSetting.length > 3) {
            List<String> tmp = graphSetting[3].toString().split('||');
            for (int i = 0; i < tmp.length; i++) {
              propertiesLength.add(double.tryParse(tmp[i]));
            }
          }
          for (int i = 0; i < propertiesName.length; i++) {
            int? tmp = int.tryParse(propertiesName[i]);
            if (tmp != null) {
              properties.add(tmp);
            }
          }
          if (properties == []) {
            properties = recordTemplates[currentProject]!.keys.toList();
          }
          cardList.add(
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Container(
                    margin: const EdgeInsets.fromLTRB(20, 10, 20, 20),
                    child: Table(
                      textBaseline: TextBaseline.alphabetic,
                      defaultVerticalAlignment:
                          TableCellVerticalAlignment.middle,
                      defaultColumnWidth: const IntrinsicColumnWidth(),
                      children: [
                            TableRow(
                                decoration: BoxDecoration(color: fontColor),
                                children: List.generate(
                                    properties.length,
                                    (index) => Container(
                                          alignment: Alignment.center,
                                          child: Text(
                                            recordTemplates[currentProject]![
                                                properties[index]]![0],
                                            style: const TextStyle(
                                              fontSize: 16,
                                              color: Colors.white,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ))),
                          ] +
                          List.generate(filterRecordList.length, (index) {
                            return TableRow(
                                children: List.generate(
                              properties.length,
                              (index2) => recordTableCellGenerate(
                                  filterRecordList[index][properties[index2]],
                                  recordTemplates[currentProject]![
                                      properties[index2]]!,
                                  index,
                                  properties[index2],
                                  propertiesLength[index2]),
                            ));
                          }),
                      border: TableBorder.all(color: fontColor, width: 2),
                    ),
                  )),
            ),
          );
        }
      }
    }
    return cardList;
  }

  Widget recordTableCellGenerate(dynamic content, List propertySetting, int i,
      int property, double? length) {
    List<String> selectList = propertySetting.last.toString().split("||");
    List<String> currentList =
        filterRecordList[i][property].toString().split(", ");
    switch (propertySetting[1]) {
      case '单选':
        return GestureDetector(
            onTap: () {
              showDialog(
                context: context,
                builder: (ctx) {
                  return InputSelectAlertDialog(
                    onSubmitted: (text) {
                      Map recordTmp = Map.from(filterRecordList[i]);
                      recordTmp[property] = text;
                      realm.write(() {
                        filterNoteList[i].noteContext = mapToyaml(recordTmp);
                        filterNoteList[i].noteUpdateDate =
                            DateTime.now().toUtc();
                      });
                      reportInit();
                      setState(() {});
                      // List testList = (text.split(', '));
                      // List newList =
                      //     (propertySetting.last.toString().split('||'));
                      // for (int i = 0; i < testList.length; i++) {
                      //   if (!newList.contains(testList[i])) {
                      //     Notes templateNote = realm.query<Notes>(
                      //         "noteType == \$0 AND noteProject == \$1 AND noteIsDeleted != true SORT(noteCreateDate DESC) LIMIT(1)",
                      //         [
                      //           '.表单',
                      //           currentProject,
                      //         ])[0];
                      //     realm.write(() {
                      //       templateNote.noteContext = templateNote.noteContext
                      //           .replaceAll(propertySetting.join(','),
                      //               '${propertySetting.join(',')}||${testList[i]}');
                      //       templateNote.noteUpdateDate = DateTime.now().toUtc();
                      //     });
                      //   }
                      // }
                    },
                    currentList: currentList,
                    selectList: selectList,
                    fontColor: fontColor,
                    isMultiSelect: false,
                    backgroundColor: backgroundColor,
                  );
                },
              );
            },
            child: Container(
              width: length,
              padding: const EdgeInsets.all(3),
              child: Container(
                height: 25,
                margin: const EdgeInsets.fromLTRB(5, 0, 5, 0),
                padding: const EdgeInsets.fromLTRB(5, 0, 5, 0),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  color: fontColor,
                ),
                child: Text(
                  content.toString(),
                  style: const TextStyle(
                    fontFamily: 'LXGWWenKai',
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ),
            ));
      case '多选':
        List selectedlist = content.toString().split(', ');
        return GestureDetector(
          onTap: () {},
          child: Wrap(
            alignment: WrapAlignment.center,
            runAlignment: WrapAlignment.center,
            crossAxisAlignment: WrapCrossAlignment.center,
            runSpacing: 5,
            children: List.generate(
              selectedlist.length,
              (index) {
                return Container(
                  margin: const EdgeInsets.fromLTRB(0, 0, 5, 0),
                  padding: const EdgeInsets.fromLTRB(5, 0, 5, 0),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    color: fontColor,
                  ),
                  child: Text(
                    selectedlist[index],
                    style: const TextStyle(
                      fontFamily: 'LXGWWenKai',
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                );
              },
            ),
          ),
        );
      case '数字':
        return GestureDetector(
          onTap: () {},
          child: Container(
            padding: const EdgeInsets.all(0),
            alignment: Alignment.center,
            width: length,
            height: 25,
            child: Text(
              content.toString(),
              maxLines: null,
              style: TextStyle(
                color: fontColor,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        );
      default:
        return GestureDetector(
          onTap: () {},
          child: Container(
            padding: const EdgeInsets.all(0),
            alignment: Alignment.centerLeft,
            width: length,
            height: 25,
            child: Text(
              content.toString(),
              maxLines: null,
              style: TextStyle(
                color: fontColor,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        );
    }
  }
}

Widget statisticsGenerate(String dataName, String dataType, List graphSetting,
    List data, Color color, String dataUnit) {
  switch (dataType) {
    case '条目':
      switch (graphSetting[1]) {
        case '次数':
          return Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(width: 20),
              const Text(
                '共 ',
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                data.length.toString(),
                style: TextStyle(
                  color: color,
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const Text(
                " 条记录",
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          );
      }
      return const SizedBox();
    case '数字':
      //和、平均数
      switch (graphSetting[1]) {
        case '和':
          //x-和
          double sum = 0;
          int num = 0;
          for (int i = 0; i < data.length; i++) {
            if (data[i] is double || data[i] is int) {
              sum = sum + data[i];
              num++;
            }
          }
          return Row(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              const SizedBox(width: 20),
              const Text(
                '总',
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                '$dataName ',
                style: const TextStyle(
                  color: Colors.black,
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                sum.toStringAsFixed(2),
                style: TextStyle(
                  color: color,
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                ' $dataUnit',
                style: const TextStyle(
                  color: Colors.black,
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Visibility(
                visible: num < data.length,
                child: Text(
                  ' (统计缺少${data.length - num}个数据)',
                  style: const TextStyle(
                    color: Colors.black,
                    fontSize: 12,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ),
            ],
          );

        case '平均数':
          //x-平均数
          double sum = 0;
          int num = 0;
          for (int i = 0; i < data.length; i++) {
            if (data[i] is double || data[i] is int) {
              sum = sum + data[i];
              num++;
            }
          }
          return Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(width: 20),
              const Text(
                '平均',
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                '$dataName ',
                style: const TextStyle(
                  color: Colors.black,
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                num != 0 ? (sum / num).toStringAsFixed(2) : '0.00',
                style: TextStyle(
                  color: color,
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                ' $dataUnit',
                style: const TextStyle(
                  color: Colors.black,
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Visibility(
                visible: num < data.length,
                child: Text(
                  ' (统计缺少${data.length - num}个数据)',
                  style: const TextStyle(
                    color: Colors.black,
                    fontSize: 12,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ),
            ],
          );
      }
      return const SizedBox();
    case '时长':
      //和、平均数
      switch (graphSetting[1]) {
        case '和':
          //x-和
          Duration sum = const Duration();
          int num = 0;
          for (int i = 0; i < data.length; i++) {
            Duration? duration = stringToDuration(data[i].toString());
            if (duration != null) {
              sum = sum + duration;
              num++;
            }
          }
          return Row(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              const SizedBox(width: 20),
              const Text(
                '总',
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                '$dataName ',
                style: const TextStyle(
                  color: Colors.black,
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                '${sum.inHours}时${sum.inMinutes % 60}分${sum.inSeconds % 60}秒',
                style: TextStyle(
                  color: color,
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                ' $dataUnit',
                style: const TextStyle(
                  color: Colors.black,
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Visibility(
                visible: num < data.length,
                child: Text(
                  ' (统计缺少${data.length - num}个数据)',
                  style: const TextStyle(
                    color: Colors.black,
                    fontSize: 12,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ),
            ],
          );

        case '平均数':
          //x-平均数
          int sum = 0;
          int num = 0;
          for (int i = 0; i < data.length; i++) {
            Duration? duration = stringToDuration(data[i].toString());
            if (duration != null) {
              sum = sum + duration.inSeconds;
              num++;
            }
          }
          int avg = sum ~/ num;
          Duration sumDuration = Duration(seconds: avg);
          return Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(width: 20),
              const Text(
                '平均',
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                '$dataName ',
                style: const TextStyle(
                  color: Colors.black,
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                ' : ${sumDuration.inDays == 0 ? '' : '${sumDuration.inDays}天'}${sumDuration.inHours == 0 ? '' : '${sumDuration.inHours % 24}时'}${sumDuration.inMinutes == 0 ? '' : '${sumDuration.inMinutes % 60}分'}${sumDuration.inSeconds == 0 ? '' : '${sumDuration.inSeconds % 60}秒'}',
                style: TextStyle(
                  color: color,
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                ' $dataUnit',
                style: const TextStyle(
                  color: Colors.black,
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Visibility(
                visible: num < data.length,
                child: Text(
                  ' (统计缺少${data.length - num}个数据)',
                  style: const TextStyle(
                    color: Colors.black,
                    fontSize: 12,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ),
            ],
          );
      }
      return const SizedBox();
  }
  return const SizedBox();
}

///条目: 0-次数,
///数字: x-和,x-平均数,
///时长: x-和,x-平均数,

