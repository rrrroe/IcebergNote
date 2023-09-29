import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:icebergnote/screen/noteslist_screen.dart';
import 'package:realm/realm.dart';
import 'package:yaml/yaml.dart';
import '../constants.dart';
import '../main.dart';
import '../notes.dart';
import 'record_screen.dart';
import 'package:intl/intl.dart';

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
  late TabController tabController;
  String currentProject = '';
  String currentReportType = '周报';
  int dateFlag = 0;
  String selectDuration = '';
  late RealmResults<Notes> notesList;
  List<Notes> filterNoteList = [];
  List<Map> recordList = [];
  List<Map> filterRecordList = [];
  late Notes templateNote;
  late Map noteMap, noteMapOther, templateProperty, template;
  late Color backgroundColor = Colors.white;
  late Color fontColor = Colors.black;
  late List propertySettings1;
  List graphSettings = [];
  DateFormat ymd = DateFormat('yyyy-MM-dd');
  DateTime now = DateTime.now();
  late int weekday;
  late DateTime firstDay;
  late DateTime lastDay;
  int quarter = 1;
  List typeList = ['周报', '月报', '季报', '年报', '自定义'];
  List<String> recordProjectList = [];
  late List<Notes> recordProjectDistinctList;
  @override
  void initState() {
    super.initState();
    tabController = TabController(length: tabs.length, vsync: this);
    List<Notes> recordProjectDistinctList = realm
        .query<Notes>(
            "noteType == '.表头' AND noteProject !='' DISTINCT(noteProject)")
        .toList();
    for (int i = 0; i < recordProjectDistinctList.length; i++) {
      recordProjectList.add(recordProjectDistinctList[i].noteProject);
    }
    if (recordProjectList.isNotEmpty && currentProject == '') {
      currentProject = recordProjectList[0];
    }
    selectDuration = widget.duration;
    notesList = realm.query<Notes>(
        "( noteProject == \$0 OR noteProject == \$1 ) AND noteType == '.记录' AND noteIsDeleted != true SORT(id ASC)",
        [currentProject, '$currentProject/']);
    templateNote = realm.query<Notes>(
        "noteType == \$0 AND noteProject == \$1 AND noteIsDeleted != true SORT(id DESC) LIMIT(1)",
        [
          '.表头',
          currentProject,
        ])[0];
    template = loadYaml(templateNote.noteContext
        .substring(0, templateNote.noteContext.indexOf('settings'))) as YamlMap;
    templateProperty = loadYaml(templateNote.noteContext
        .substring(templateNote.noteContext.indexOf('settings'))) as YamlMap;
    backgroundColor = Color.fromARGB(
      40,
      templateProperty['color'][0],
      templateProperty['color'][1],
      templateProperty['color'][2],
    );
    fontColor = Color.fromARGB(
      255,
      max(0, min(templateProperty['color'][0] - 50, 255)),
      max(0, min(templateProperty['color'][1] - 50, 255)),
      max(0, min(templateProperty['color'][2] - 50, 255)),
    );

    propertySettings1 = template.values.elementAt(0).split(",");
    DateTime now = DateTime.now();
    weekday = now.weekday;
    firstDay = now.subtract(Duration(days: weekday - 1));
    firstDay = DateTime(firstDay.year, firstDay.month, firstDay.day);
    lastDay = now.add(Duration(days: DateTime.daysPerWeek - weekday));
    lastDay = DateTime(lastDay.year, lastDay.month, lastDay.day);
    template.forEach((key, value) {
      if (value.toString().split(',')[1] == '日期') {
        dateFlag = key;
      }
    });
    recordList = [];
    for (int i = 0; i < notesList.length; i++) {
      if (checkNoteFormat(notesList[i])) {
        recordList.add(loadYaml(notesList[i].noteContext) as YamlMap);
      }
      if (dateFlag == 0) {
        dateFlag = 999;
        recordList[i][dateFlag] =
            notesList[i].noteCreatTime.toString().substring(0, 10);
      }
    }
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
          Container(),
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
                child: Text(type),
                onPressed: () {
                  setState(() {
                    currentProject = type;
                  });
                },
              );
            }).toList(),
          ),
          Expanded(child: Container()),
          IconButton(
            icon: const Icon(Icons.fit_screen_outlined),
            onPressed: () async {
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
                    currentReportType,
                    style: const TextStyle(
                      color: Colors.black,
                      fontSize: 16,
                    ),
                  ),
                );
              },
              menuChildren: typeList.map((type) {
                return MenuItemButton(
                  child: Text(type),
                  onPressed: () {
                    setState(() {
                      currentReportType = type;
                      quarter = ((now.month - 1) ~/ 3) + 1;
                      switch (currentReportType) {
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
                    });
                  },
                );
              }).toList(),
            ),
          ),
          Expanded(child: Container()),
          IconButton.filledTonal(
            onPressed: () {
              quarter = ((firstDay.month - 1) ~/ 3) + 1;
              setState(() {
                switch (currentReportType) {
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
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
          ),
          IconButton.filledTonal(
            onPressed: () {
              setState(() {
                switch (currentReportType) {
                  case '自定义':
                  case '周报':
                    firstDay = firstDay.add(const Duration(days: 7));
                    lastDay = lastDay.add(const Duration(days: 7));
                    break;
                  case '月报':
                    firstDay = lastDay.add(const Duration(days: 1));
                    lastDay = DateTime(firstDay.year, firstDay.month + 1, 1)
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
    filterNoteList = [];
    graphSettings = [];
    List<dynamic> filterSelect = [0];
    if (templateProperty.keys.contains(currentReportType)) {
      List tmpstr = templateProperty[currentReportType].split(',');
      for (int index = 0; index < tmpstr.length; index++) {
        List tmp = tmpstr[index].toString().split('-');
        List tmp1 = [];
        tmp1.add(int.tryParse(tmp[0]));
        for (int i = 1; i < tmp.length; i++) {
          tmp1.add(tmp[i]);
        }
        if (tmp1[1] == '过滤' &&
            template[tmp1[0]].toString().split(',')[1] == '单选') {
          filterSelect[0] = tmp1[0];
          filterSelect.addAll(tmp1[2].toString().split('||'));
        } else {
          graphSettings.add(tmp1);
        }
      }
      // print(filterSelect);
    }

    for (int i = 0; i < recordList.length; i++) {
      DateTime? date;
      date = ymd.parse(recordList[i][dateFlag].toString());
      bool arrayCrossFlag = false;

      if (date.isBefore(lastDay.add(const Duration(days: 1, seconds: -1))) &&
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
    filterRecordList = [];
    for (int i = 0; i < filterNoteList.length; i++) {
      filterRecordList.add(loadYaml(filterNoteList[i].noteContext) as YamlMap);
    }
    for (var graphSetting in graphSettings) {
      List propertySettings = template[graphSetting[0]].toString().split(',');

      if (graphSetting[0] == 0) {
        List data = [];
        for (int i = 0; i < filterRecordList.length; i++) {
          data.add(1);
        }
        cardList
            .add(graphGenerate('', '条目', graphSetting, data, fontColor, ''));
      }
      if (template.containsKey(graphSetting[0])) {
        List data = [];
        for (int i = 0; i < filterRecordList.length; i++) {
          data.add(filterRecordList[i][graphSetting[0]]);
        }
        cardList.add(graphGenerate(propertySettings[0], propertySettings[1],
            graphSetting, data, fontColor, propertySettings[3]));
      }
      if (graphSetting[0] == 1111) {
        cardList.add(const SizedBox(height: 5));
        for (int i = 0; i < filterRecordList.length; i++) {
          Map noteMap = filterRecordList[i];
          Map noteMapOther = {...noteMap};
          noteMapOther.remove(noteMapOther.keys.first);
          noteMapOther.removeWhere((key, value) => value == null);

          cardList.add(
            Card(
              margin: const EdgeInsets.fromLTRB(15, 0, 15, 10),
              elevation: 0,
              shadowColor: const Color.fromARGB(255, 255, 132, 132),
              color: backgroundColor,
              child: ListTile(
                title: SizedBox(
                  height: 40,
                  child: Text(
                    '${propertySettings1[2] ?? ''}${noteMap[noteMap.keys.first] ?? ''}${propertySettings1[3] ?? ''}',
                    maxLines: 1,
                    overflow: TextOverflow.fade,
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      color: fontColor,
                    ),
                  ),
                ),
                subtitle: Wrap(
                  spacing: 5,
                  runSpacing: 5,
                  children: List.generate(
                    noteMapOther.length,
                    (index) {
                      List propertySettings = ['', '', '', ''];
                      if (template
                          .containsKey(noteMapOther.keys.elementAt(index))) {
                        propertySettings =
                            template[noteMapOther.keys.elementAt(index)]
                                .split(",");
                      }
                      if (noteMapOther.values.elementAt(index) != null) {
                        switch (propertySettings[1]) {
                          case '长文':
                            return Row(
                              crossAxisAlignment: CrossAxisAlignment.baseline,
                              textBaseline: TextBaseline.ideographic,
                              children: [
                                Container(
                                  margin: const EdgeInsets.all(0),
                                  padding:
                                      const EdgeInsets.fromLTRB(5, 0, 5, 0),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(4),
                                    color: fontColor,
                                  ),
                                  child: Text(
                                    "${propertySettings[0] ?? ''}",
                                    style: const TextStyle(
                                      fontFamily: 'LXGWWenKai',
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                                Text(
                                  " : ",
                                  style: TextStyle(
                                    fontFamily: 'LXGWWenKai',
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: fontColor,
                                  ),
                                ),
                                Expanded(
                                  child: Text(
                                    '${propertySettings[2] ?? ''}${noteMapOther.values.elementAt(index).toString().replaceAll('    ', '\n')}${propertySettings[3] ?? ''}',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                      color: fontColor,
                                    ),
                                  ),
                                ),
                              ],
                            );
                          case '单选':
                          case '多选':
                            List selectedlist = noteMapOther.values
                                .elementAt(index)
                                .toString()
                                .split(', ');
                            return Row(
                              mainAxisSize: MainAxisSize.max,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  margin: const EdgeInsets.all(0),
                                  padding:
                                      const EdgeInsets.fromLTRB(5, 0, 5, 0),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(4),
                                    color: fontColor,
                                  ),
                                  child: Text(
                                    "${propertySettings[0] ?? ''}",
                                    style: const TextStyle(
                                      fontFamily: 'LXGWWenKai',
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                                Text(
                                  " : ",
                                  style: TextStyle(
                                    fontFamily: 'LXGWWenKai',
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: fontColor,
                                  ),
                                ),
                                Expanded(
                                  child: Wrap(
                                    runSpacing: 5,
                                    children: List.generate(
                                      selectedlist.length,
                                      (index) {
                                        return Container(
                                          margin: const EdgeInsets.fromLTRB(
                                              0, 0, 5, 0),
                                          padding: const EdgeInsets.fromLTRB(
                                              5, 0, 5, 0),
                                          decoration: BoxDecoration(
                                            borderRadius:
                                                BorderRadius.circular(20),
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
                                ),
                              ],
                            );
                          case '时间':
                            return Row(
                              mainAxisSize: MainAxisSize.max,
                              children: [
                                Container(
                                  margin: const EdgeInsets.all(0),
                                  padding:
                                      const EdgeInsets.fromLTRB(5, 0, 5, 0),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(4),
                                    color: fontColor,
                                  ),
                                  child: Text(
                                    "${propertySettings[0] ?? ''}",
                                    style: const TextStyle(
                                      fontFamily: 'LXGWWenKai',
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                                Text(
                                  noteMapOther.values
                                              .elementAt(index)
                                              .toString()[0] !=
                                          '0'
                                      ? ' : ${propertySettings[2] ?? ''}${noteMapOther.values.elementAt(index).toString()}${propertySettings[3] ?? ''}'
                                      : ' : ${propertySettings[2] ?? ''}${noteMapOther.values.elementAt(index).toString().substring(2).replaceAll(':', '′')}″${propertySettings[3] ?? ''}',
                                  style: TextStyle(
                                    fontFamily: 'LXGWWenKai',
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: fontColor,
                                  ),
                                ),
                              ],
                            );
                          case '时长':
                            return Row(
                              mainAxisSize: MainAxisSize.max,
                              children: [
                                Container(
                                  margin: const EdgeInsets.all(0),
                                  padding:
                                      const EdgeInsets.fromLTRB(5, 0, 5, 0),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(4),
                                    color: fontColor,
                                  ),
                                  child: Text(
                                    "${propertySettings[0] ?? ''}",
                                    style: const TextStyle(
                                      fontFamily: 'LXGWWenKai',
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                                Text(
                                  ' : ${noteMapOther.values.elementAt(index).toString().replaceAll('d', '天').replaceAll('h', '时').replaceAll('m', '分').replaceAll('s', '秒').replaceAll('0时', '').replaceAll('0秒', '')}',
                                  style: TextStyle(
                                    fontFamily: 'LXGWWenKai',
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: fontColor,
                                  ),
                                ),
                              ],
                            );
                          default:
                            return Row(
                              mainAxisSize: MainAxisSize.max,
                              children: [
                                Container(
                                  margin: const EdgeInsets.all(0),
                                  padding:
                                      const EdgeInsets.fromLTRB(5, 0, 5, 0),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(4),
                                    color: fontColor,
                                  ),
                                  child: Text(
                                    "${propertySettings[0] ?? ''}",
                                    style: const TextStyle(
                                      fontFamily: 'LXGWWenKai',
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                                Text(
                                  ' : ${propertySettings[2] ?? ''}${noteMapOther.values.elementAt(index).toString().replaceAll('    ', '\n${' ' * (propertySettings[0].runes.length * 2 + 2)}')}${propertySettings[3] ?? ''}',
                                  style: TextStyle(
                                    fontFamily: 'LXGWWenKai',
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: fontColor,
                                  ),
                                ),
                              ],
                            );
                        }
                      } else {
                        return const SizedBox(height: 0, width: 0);
                      }
                    },
                  ),
                ),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => RecordChangePage(
                        onPageClosed: () {},
                        note: filterNoteList[i],
                        mod: 1,
                      ),
                    ),
                  );
                },
                onLongPress: () {
                  showModalBottomSheet(
                    context: context,
                    builder: (context) {
                      return BottomPopSheet(
                        note: filterNoteList[i],
                        onDialogClosed: () {},
                      );
                    },
                  );
                },
              ),
            ),
          );
        }
      }
    }
    return cardList;
  }
}

Widget graphGenerate(String dataName, String dataType, List graphSetting,
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
      return const SizedBox(height: 0, width: 0);
    case '数字':
      //和、平均数
      switch (graphSetting[1]) {
        case '和':
          //x-和
          double sum = 0;

          for (int i = 0; i < data.length; i++) {
            if (data[i] != null) {
              sum = sum + data[i];
            }
          }
          return Row(
            mainAxisSize: MainAxisSize.min,
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
            ],
          );

        case '平均数':
          //x-平均数
          double sum = 0;
          int num = 0;
          for (int i = 0; i < data.length; i++) {
            if (data[i] != null) {
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
            ],
          );
      }
  }
  return const SizedBox(height: 0, width: 0);
}
///条目: 0-次数,
///数字: x-和,x-平均数,
