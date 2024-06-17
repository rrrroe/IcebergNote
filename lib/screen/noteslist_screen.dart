// Copyright 2021 The Flutter team. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:clipboard/clipboard.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:icebergnote/class/anniversary_class.dart';
import 'package:icebergnote/postgresql/sync.dart';
import 'package:icebergnote/screen/card/anniversary_card.dart';
import 'package:icebergnote/screen/card/check_list_card.dart';
import 'package:icebergnote/screen/card/todo_card.dart';
import 'package:icebergnote/screen/card/normal_card.dart';
import 'package:icebergnote/screen/input/anniversary_input.dart';
import 'package:icebergnote/screen/input/input_screen.dart';
import 'package:icebergnote/notes.dart';
import 'package:realm/realm.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:image/image.dart' as img;

import '../main.dart';
import '../constants.dart';
import '../card.dart';
import 'input/check_list_input.dart';
import 'input/record_input.dart';

const rowDividerincrease = SizedBox(width: 20);
const colDivider = SizedBox(height: 10);
const tinySpacing = 3.0;
const smallSpacing = 10.0;
const double cardWidth = 115;
const double widthConstraint = 450;
GlobalKey repaintWidgetKey = GlobalKey();
var searchnotesList = NotesList();
bool checkNoteFormat(Notes note) {
  switch (note.noteType) {
    case '.记录':
      var templateNoteList = realm.query<Notes>(
          "noteType == \$0 AND noteProject == \$1 AND noteIsDeleted != true SORT(noteCreateDate DESC) LIMIT(1)",
          [
            '.表单',
            note.noteProject,
          ]);
      if (realm.query<Notes>(
          "noteType == \$0 AND noteProject == \$1 AND noteIsDeleted != true SORT(noteCreateDate DESC) LIMIT(1)",
          [
            '.表单',
            note.noteProject,
          ]).isEmpty) {
        return false;
      } else {
        List templateList = templateNoteList[0]
            .noteContext
            .replaceAll(RegExp(r'\n{2,}'), '\n')
            .split('\n');
        RegExp pattern = RegExp(": ");
        for (String str in templateList) {
          if (pattern.allMatches(str).length != 1 && str != '') {
            return false;
          }
        }
        return true;
      }
    default:
      return true;
  }
}

class Utils {
  static void toast(String msg) {
    Fluttertoast.showToast(
      msg: msg,
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.CENTER,
      timeInSecForIosWeb: 1,
      textColor: Colors.white,
      fontSize: 16.0,
      backgroundColor: Colors.black,
    );
  }
}

Future<Uint8List> onScreenshot(int index) async {
  RenderRepaintBoundary boundary = repaintWidgetKey.currentContext!
      .findRenderObject() as RenderRepaintBoundary;
  ui.Image image = await boundary.toImage(pixelRatio: 2);
  ByteData? byteData = await (image.toByteData(format: ui.ImageByteFormat.png));
  Uint8List pngBytes = byteData!.buffer.asUint8List();
  return pngBytes;
}

class ImagePopup extends StatefulWidget {
  final Uint8List pngBytes;

  const ImagePopup({super.key, required this.pngBytes});

  @override
  State<ImagePopup> createState() => _ImagePopupState();
}

class _ImagePopupState extends State<ImagePopup> {
  @override
  Widget build(BuildContext context) {
    return _buildPopup();
  }

  Widget _buildPopup() {
    return Center(
      child: Material(
        child: Stack(
          children: [
            Image.memory(widget.pngBytes),
            Positioned(
              right: 0,
              bottom: 0,
              child: Row(
                children: [
                  IconButton.filledTonal(
                    onPressed: () async {
                      // final dir = Directory('export');
                      // dir.create();
                      String tmp =
                          DateTime.now().toString().replaceAll(':', '');
                      await (img.Command()
                            // Decode the PNG image file
                            ..decodePng(widget.pngBytes)
                            // Save the resized image to a PNG image file
                            ..writeToFile('export/export_$tmp.png'))
                          // executeThread will run the commands in an Isolate thread
                          .executeThread();
                      Get.snackbar(
                        '恭喜',
                        '导出已完成',
                        duration: const Duration(seconds: 1),
                        backgroundColor: const Color.fromARGB(60, 0, 140, 198),
                      );
                    },
                    style: ButtonStyle(
                        foregroundColor: WidgetStateProperty.all(Colors.white),
                        backgroundColor: WidgetStateProperty.all(
                            const Color.fromARGB(0, 255, 255, 255))),
                    icon: const Icon(
                      Icons.download,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class BottomPopSheet extends StatelessWidget {
  const BottomPopSheet(
      {super.key, required this.note, required this.onDialogClosed});
  final Notes note;
  final VoidCallback onDialogClosed;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // ListTile(
          //   leading: const Icon(Icons.share),
          //   title: const Text('分享'),
          //   onTap: () {
          //     onDialogClosed();
          //     Navigator.pop(context);
          //   },
          // ),
          ListTile(
            leading: const Icon(Icons.copy),
            title: const Text('复制'),
            onTap: () {
              FlutterClipboard.copy('${note.noteTitle}\n${note.noteContext}');
              poplog(1, '复制', context);
              onDialogClosed();
              Navigator.pop(context);
            },
          ),
          ListTile(
            leading: const Icon(Icons.settings),
            title: const Text('编辑'),
            onTap: () {
              onDialogClosed();

              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ChangePage(
                    onPageClosed: () {
                      onDialogClosed();
                    },
                    note: note,
                    mod: 1,
                  ),
                ),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.delete),
            title: const Text('删除', style: TextStyle(color: Colors.red)),
            onTap: () {
              realm.write(() {
                note.noteIsDeleted = true;
                note.noteUpdateDate = DateTime.now().toUtc();
                note.noteDeleteDate = DateTime.now().toUtc();
              });
              onDialogClosed();
              Navigator.pop(context);
            },
          ),
          ListTile(
            leading: const Icon(Icons.star),
            title: Text(note.noteIsStarred == true ? '取消星标' : '星标'),
            onTap: () {
              realm.write(() {
                note.noteIsStarred = !note.noteIsStarred;
                note.noteUpdateDate = DateTime.now().toUtc();
              });
              onDialogClosed();
              Navigator.pop(context);
            },
          ),
        ],
      ),
    );
  }
}

class BottomNoteTypeSheet extends StatelessWidget {
  const BottomNoteTypeSheet(
      {super.key, required this.noteTypeList, required this.onDialogClosed});
  final List<String> noteTypeList;
  final VoidCallback onDialogClosed;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: noteTypeList.length,
              itemBuilder: (context, index) {
                return ListTile(
                  leading: const Icon(Icons.data_thresholding),
                  title: Text(noteTypeList[index]),
                  onTap: () {
                    if (noteTypeList[index] == '.记录') {
                      Navigator.pop(context);
                      List<String> recordProjectList = [];
                      List<Notes> recordProjectDistinctList = realm
                          .query<Notes>(
                              "noteType == '.表单' AND noteProject !='' DISTINCT(noteProject)")
                          .toList();
                      for (int i = 0;
                          i < recordProjectDistinctList.length;
                          i++) {
                        recordProjectList
                            .add(recordProjectDistinctList[i].noteProject);
                      }
                      showModalBottomSheet(
                        context: context,
                        builder: (context) {
                          return BottomRecordTypeSheet(
                            onDialogClosed: () {},
                            recordProjectList: recordProjectList,
                          );
                        },
                      );
                    } else if (noteTypeList[index] == '.清单') {
                      Navigator.pop(context);
                      Notes note = Notes(
                          Uuid.v4(),
                          '',
                          '',
                          '',
                          DateTime.now().toUtc(),
                          DateTime.now().toUtc(),
                          DateTime.utc(1970, 1, 1),
                          DateTime.utc(1970, 1, 1),
                          DateTime.utc(1970, 1, 1),
                          DateTime.utc(1970, 1, 1),
                          noteType: noteTypeList[index]);
                      realm.write(() {
                        realm.add<Notes>(note, update: true);
                      });
                      Get.to(() => CheckListEditPage(
                            note: note,
                            onPageClosed: () {
                              onDialogClosed();
                            },
                          ));
                    } else if (noteTypeList[index] == '.日子') {
                      Navigator.pop(context);
                      DateTime now = DateTime.now();
                      Anniversary anniversary = Anniversary(
                          date: DateTime(now.year, now.month, now.day),
                          alarmSpecialDate:
                              DateTime(now.year, now.month, now.day));
                      Notes note = Notes(
                          Uuid.v4(),
                          '',
                          '',
                          jsonEncode(anniversary.toJson()),
                          DateTime.now().toUtc(),
                          DateTime.now().toUtc(),
                          DateTime.utc(1970, 1, 1),
                          DateTime.utc(1970, 1, 1),
                          DateTime.utc(1970, 1, 1),
                          DateTime.utc(1970, 1, 1),
                          noteType: noteTypeList[index]);
                      realm.write(() {
                        realm.add<Notes>(note, update: true);
                      });
                      Get.to(() => AnniversaryInputPage(
                            note: note,
                            onPageClosed: () {
                              onDialogClosed();
                            },
                            mod: 0,
                            anniversary: anniversary,
                          ));
                    } else {
                      Navigator.pop(context);
                      Notes note = Notes(
                          Uuid.v4(),
                          '',
                          '',
                          '',
                          DateTime.now().toUtc(),
                          DateTime.now().toUtc(),
                          DateTime.utc(1970, 1, 1),
                          DateTime.utc(1970, 1, 1),
                          DateTime.utc(1970, 1, 1),
                          DateTime.utc(1970, 1, 1),
                          noteType: noteTypeList[index]);
                      realm.write(() {
                        realm.add<Notes>(note, update: true);
                      });
                      Get.to(() =>
                          ChangePage(onPageClosed: () {}, note: note, mod: 0));
                    }
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class BottomRecordTypeSheet extends StatelessWidget {
  const BottomRecordTypeSheet(
      {super.key,
      required this.recordProjectList,
      required this.onDialogClosed});
  final List<String> recordProjectList;
  final VoidCallback onDialogClosed;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: recordProjectList.length,
              itemBuilder: (context, index) {
                return ListTile(
                  leading: const Icon(Icons.data_thresholding),
                  title: Text(recordProjectList[index]),
                  onTap: () {
                    Navigator.pop(context);
                    Notes note = Notes(
                        Uuid.v4(),
                        '',
                        '',
                        '',
                        DateTime.now().toUtc(),
                        DateTime.now().toUtc(),
                        DateTime.utc(1970, 1, 1),
                        DateTime.utc(1970, 1, 1),
                        DateTime.utc(1970, 1, 1),
                        DateTime.utc(1970, 1, 1),
                        noteProject: recordProjectList[index],
                        noteType: '.记录');
                    realm.write(() {
                      realm.add<Notes>(note, update: true);
                    });
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => RecordChangePage(
                          onPageClosed: () {
                            onDialogClosed();
                          },
                          note: note,
                          mod: 0,
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class TimeBar extends StatefulWidget {
  const TimeBar({super.key});

  @override
  TimeBarState createState() => TimeBarState();
}

class TimeBarState extends State<TimeBar> {
  String time = "";
  late Timer timer;
  @override
  void initState() {
    super.initState();
    updateTime();
    timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      updateTime();
    });
  }

  @override
  void dispose() {
    timer.cancel();
    super.dispose();
  }

  void updateTime() {
    final now = DateTime.now().toUtc();
    setState(() {
      time =
          "${now.year}年${now.month.toString().padLeft(2, '0')}月${now.day..toString().padLeft(2, '0')}日 "
          "${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}:${now.second.toString().padLeft(2, '0')}";
    });
  }

  @override
  Widget build(BuildContext context) {
    return Text(
      time,
      style: const TextStyle(
        fontSize: 22,
      ),
    );
  }
}

class SearchPage extends StatefulWidget {
  SearchPage({super.key, required this.mod, required this.txt});
  final String txt;
  final int mod;
  final SearchPageState state = SearchPageState();
  @override
  SearchPageState createState() => SearchPageState();
}

class SearchPageState extends State<SearchPage> {
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final RefreshController _refreshController =
      RefreshController(initialRefresh: false);
  final SyncProcessController syncProcessController =
      Get.put(SyncProcessController());
  String searchText = '';
  List<String> folderList = ['全部'];
  List<String> typeList = ['全部'];
  List<String> projectList = ['全部'];
  String searchType = '';
  String searchProject = '';
  String searchFolder = '';
  int isSyncing = 0;
  // String searchFinishState = '';
  late String time;
  void refreshList() {
    double scrollPosition = _scrollController.position.pixels;
    setState(() {
      switch (widget.mod) {
        case 0:
          searchnotesList.searchall(
              searchText, 0, searchType, searchProject, searchFolder, '');
          break;
        case 1:
          searchnotesList.search(searchText, 0);
          break;
        case 2:
          searchnotesList.searchDeleted(searchText, 0);
          break;
        case 3:
          searchnotesList.searchTodo(searchText, 0);
          break;
        case 4:
          searchnotesList.searchStar(searchText, 0);
          break;
      }
      _scrollController.jumpTo(scrollPosition);
    });
  }

  void refreshListTotop() {
    setState(() {
      switch (widget.mod) {
        case 0:
          searchnotesList.searchall(
              searchText, 0, searchType, searchProject, searchFolder, '');
          break;
        case 1:
          searchnotesList.search(searchText, 0);
          break;
        case 2:
          searchnotesList.searchDeleted(searchText, 0);
          break;
        case 3:
          searchnotesList.searchTodo(searchText, 0);
          break;
        case 4:
          searchnotesList.searchStar(searchText, 0);
          break;
      }
    });
  }

  @override
  void initState() {
    super.initState();
    isSyncing = 0;
    _scrollController.addListener(_scrollListener);
    switch (widget.mod) {
      case 0:
        searchnotesList.searchall(
            searchText, 0, searchType, searchProject, searchFolder, '');
        break;
      case 1:
        searchnotesList.search(searchText, 0);
        break;
      case 2:
        searchnotesList.searchDeleted(searchText, 0);
        break;
      case 3:
        searchnotesList.searchTodo(searchText, 0);
        break;
      case 4:
        searchnotesList.searchStar(searchText, 0);
        break;
    }
    List<Notes> typeDistinctList = realm
        .query<Notes>(
            "noteType !='' DISTINCT(noteType) SORT(noteCreateDate DESC)")
        .toList();

    for (int i = 0; i < typeDistinctList.length; i++) {
      typeList.add(typeDistinctList[i].noteType);
    }
    List<Notes> folderDistinctList = realm
        .query<Notes>(
            "noteFolder !='' DISTINCT(noteFolder) SORT(noteCreateDate DESC)")
        .toList();

    for (int i = 0; i < folderDistinctList.length; i++) {
      folderList.add(folderDistinctList[i].noteFolder);
    }
    List<Notes> projectDistinctList = realm
        .query<Notes>(
            "noteProject !='' DISTINCT(noteProject) SORT(noteCreateDate DESC)")
        .toList();

    for (int i = 0; i < projectDistinctList.length; i++) {
      projectList.add(projectDistinctList[i].noteProject);
    }
    // List<Notes> finishStateDistinctList = realm
    //     .query<Notes>("noteFinishState !='' DISTINCT(noteFinishState)")
    //     .toList();

    // for (int i = 0; i < finishStateDistinctList.length; i++) {
    //   if ((finishStateDistinctList[i].noteFinishState != '未完') &&
    //       (finishStateDistinctList[i].noteFinishState != '已完')) {
    //     finishStateList.add(finishStateDistinctList[i].noteFinishState);
    //   }
    // }
    // finishStateList.add('全部');
  }

  @override
  void dispose() {
    _scrollController.removeListener(_scrollListener);
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollListener() async {
    if (_scrollController.position.pixels ==
        _scrollController.position.maxScrollExtent) {
      setState(() {
        switch (widget.mod) {
          case 0:
            searchnotesList.searchall(
                searchText, 50, searchType, searchProject, searchFolder, '');
            break;
          case 1:
            searchnotesList.search(searchText, 50);
            break;
          case 2:
            searchnotesList.searchDeleted(searchText, 50);
            break;
          case 3:
            searchnotesList.searchTodo(searchText, 50);
            break;
          case 4:
            searchnotesList.searchStar(searchText, 50);
            break;
        }
        refreshList();
      });
    }
    if (Platform.isWindows == true) {
      if (_scrollController.position.pixels == 0 && widget.mod == 0) {
        switch (widget.mod) {
          case 0:
            searchnotesList.searchall(
                searchText, 0, searchType, searchProject, searchFolder, '');
            break;
          case 1:
            searchnotesList.search(searchText, 0);
            break;
          case 2:
            searchnotesList.searchDeleted(searchText, 0);
            break;
          case 3:
            searchnotesList.searchTodo(searchText, 0);
            break;
          case 4:
            searchnotesList.searchStar(searchText, 0);
            break;
        }
        refreshList();
        setState(() {});
      }
    }
  }

  PreferredSizeWidget buildAppBar() {
    if (widget.mod == 0 || widget.mod == 3) {
      return PreferredSize(
        preferredSize: const Size.fromHeight(60.0),
        child: Row(
          children: [
            const SizedBox(
              width: 30,
            ),
            Expanded(
              child: TextField(
                controller: _searchController,
                decoration: const InputDecoration(
                  hintText: '搜索',
                  border: UnderlineInputBorder(
                    borderSide: BorderSide.none,
                  ),
                ),
                onChanged: (value) {
                  setState(
                    () {
                      searchText = value;
                      searchnotesList.searchall(
                          searchText, 0, '', searchProject, searchFolder, '');
                      refreshList();
                    },
                  );
                },
              ),
            ),

            const SizedBox(
              width: 5,
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
                    searchProject == '' ? '项目' : searchProject,
                    style: searchProject == ''
                        ? const TextStyle(color: Colors.grey)
                        : const TextStyle(
                            color: Color.fromARGB(255, 215, 55, 55)),
                  ),
                );
              },
              menuChildren: projectList.map((project) {
                return MenuItemButton(
                  style: menuChildrenButtonStyle,
                  child: Text(project),
                  onPressed: () {
                    if (project == '全部') {
                      searchProject = '';
                    } else {
                      searchProject = project;
                    }
                    refreshList();
                  },
                );
              }).toList(),
            ),
            const SizedBox(
              width: 5,
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
                    searchFolder == '' ? '路径' : searchFolder,
                    style: searchFolder == ''
                        ? const TextStyle(color: Colors.grey)
                        : const TextStyle(
                            color: Color.fromARGB(255, 4, 123, 60)),
                  ),
                );
              },
              menuChildren: folderList.map((folder) {
                return MenuItemButton(
                  style: menuChildrenButtonStyle,
                  child: Text(folder),
                  onPressed: () {
                    if (folder == '全部') {
                      searchFolder = '';
                    } else {
                      searchFolder = folder;
                    }
                    refreshList();
                  },
                );
              }).toList(),
            ),
            const SizedBox(
              width: 5,
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
                    searchType == '' ? '类型' : searchType,
                    style: searchType == ''
                        ? const TextStyle(color: Colors.grey)
                        : const TextStyle(
                            color: Color.fromARGB(255, 56, 128, 186)),
                  ),
                );
              },
              menuChildren: typeList.map((type) {
                return MenuItemButton(
                  style: menuChildrenButtonStyle,
                  child: Text(type),
                  onPressed: () {
                    if (type == '全部') {
                      searchType = '';
                    } else {
                      searchType = type;
                    }
                    refreshList();
                  },
                );
              }).toList(),
            ),
            // MenuAnchor(
            //   builder: (context, controller, child) {
            //     return FilledButton.tonal(
            //       style: selectButtonStyle,
            //       onPressed: () {
            //         if (controller.isOpen) {
            //           controller.close();
            //         } else {
            //           controller.open();
            //         }
            //       },
            //       child: Text(
            //         searchFinishState == '' ? '全部' : searchFinishState,
            //         style: searchFinishState == ''
            //             ? const TextStyle(color: Colors.grey)
            //             : const TextStyle(
            //                 color: Color.fromARGB(255, 139, 78, 236)),
            //       ),
            //     );
            //   },
            //   menuChildren: finishStateList.map((finishState) {
            //     return MenuItemButton(
            //       child: Text(finishState),
            //       onPressed: () {
            //         if (finishState == '全部') {
            //           searchFinishState = '';
            //         } else {
            //           searchFinishState = finishState;
            //         }
            //         refreshList();
            //       },
            //     );
            //   }).toList(),
            // ),

            const SizedBox(
              width: 30,
            ),
          ],
        ),
      );
    } else if (widget.mod == 1) {
      return AppBar(title: const Text("搜索"));
    } else if (widget.mod == 3) {
      return AppBar(title: const Text("待办"));
    } else {
      return AppBar(
        title: const Text("回收站"),
        actions: [
          TextButton(
              onPressed: () {
                var result = realm.query<Notes>(
                    "noteIsDeleted == true SORT(noteCreateDate DESC)");
                for (int i = 0; result.isNotEmpty;) {
                  realm.write(() {
                    realm.delete(result[i]);
                  });
                }
                Get.snackbar(
                  '恭喜',
                  '清空回收站成功',
                  duration: const Duration(seconds: 1),
                  backgroundColor: const Color.fromARGB(60, 0, 140, 198),
                );
                setState(() {});
              },
              child: const Text("清空回收站"))
        ],
      );
    }
  }

  Widget buildCard(Notes note, int mod) {
    if (note.noteType == '.TODO' ||
        note.noteType == '.todo' ||
        note.noteType == '.待办' ||
        note.noteType == '.Todo') {
      return TodoCard(
        note: note,
        mod: mod, //mod: 0-正常 1-搜索 2-回收站 3-待办 4-星标 5-锁定
        context: context,
        refreshList: refreshList,
        searchText: searchText,
      );
    } else if (note.noteType == '.记录' &&
        recordTemplates[note.noteProject] != null &&
        recordTemplatesSettings[note.noteProject] != null) {
      if (recordTemplatesSettings[note.noteProject]!['卡片'] != null) {
        List<int> properties = [];
        for (int i = 0;
            i < recordTemplatesSettings[note.noteProject]!['卡片']!.length;
            i++) {
          int? tmp = int.tryParse(
              recordTemplatesSettings[note.noteProject]!['卡片']![i]);
          if (tmp != null) {
            properties.add(tmp);
          }
        }
        return buildRecordCardOfList(
            note, widget.mod, context, refreshList, properties);
      } else {
        return buildRecordCardOfList(note, widget.mod, context, refreshList,
            recordTemplates[note.noteProject]!.keys.toList());
      }
    } else if (note.noteType == '.清单') {
      return CheckListCard(
        note: note,
        mod: mod,
        context: context,
        refreshList: refreshList,
        searchText: searchText,
      );
    } else if (note.noteType == '.日子') {
      DateTime now = DateTime.now();
      Anniversary anniversary = Anniversary(
          date: DateTime(now.year, now.month, now.day),
          alarmSpecialDate: DateTime(now.year, now.month, now.day));
      if (note.noteContext != '') {
        anniversary = Anniversary.fromJson(jsonDecode(note.noteContext));
      } else {
        realm.write(() {
          note.noteTitle = anniversary.title;
          note.noteContext = jsonEncode(anniversary.toJson());
          note.noteUpdateDate = DateTime.now().toUtc();
        });
      }
      return AnniversaryCard(
        note: note,
        mod: mod,
        context: context,
        refreshList: refreshList,
        searchText: searchText,
        anniversary: anniversary,
      );
    } else {
      return NormalCard(
        note: note,
        mod: mod,
        context: context,
        refreshList: refreshList,
        searchText: searchText,
      );
    }
  }

  Future<void> syncDate() async {
    if (isSyncing == 0) {
      isSyncing++;
      int p1 = await checkRemoteDatabase();
      if (p1 == 1) {
        await exchangeSmart();
      }
      isSyncing--;
      Get.snackbar(
        '恭喜',
        '远程同步已完成',
        duration: const Duration(seconds: 1),
        backgroundColor: const Color.fromARGB(60, 0, 140, 198),
      );
    }
  }

  void _onRefresh() async {
    await syncDate();
    _refreshController.refreshCompleted();
  }

  void _onLoading() async {
    // monitor network fetch
    setState(() {
      switch (widget.mod) {
        case 0:
          searchnotesList.searchall(
              searchText, 15, searchType, searchProject, searchFolder, '');
          break;
        case 1:
          searchnotesList.search(searchText, 15);
          break;
        case 2:
          searchnotesList.searchDeleted(searchText, 15);
          break;
        case 3:
          searchnotesList.searchTodo(searchText, 15);
          break;
        case 4:
          searchnotesList.searchStar(searchText, 15);
          break;
      }
      refreshList();
    });
    await Future.delayed(const Duration(milliseconds: 1000));
    // if failed,use loadFailed(),if no data return,use LoadNodata()
    if (mounted) setState(() {});
    _refreshController.loadComplete();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: GestureDetector(
          onLongPress: () {
            showModalBottomSheet(
              context: context,
              builder: (context) {
                return BottomNoteTypeSheet(
                  noteTypeList: defaultAddTypeList,
                  onDialogClosed: () {
                    refreshList();
                  },
                );
              },
            );
          },
          child: FloatingActionButton(
              onPressed: () {
                Notes note = Notes(
                  Uuid.v4(),
                  '',
                  '',
                  '',
                  DateTime.now().toUtc(),
                  DateTime.now().toUtc(),
                  DateTime.utc(1970, 1, 1),
                  DateTime.utc(1970, 1, 1),
                  DateTime.utc(1970, 1, 1),
                  DateTime.utc(1970, 1, 1),
                );
                realm.write(() {
                  realm.add<Notes>(note, update: true);
                });
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ChangePage(
                      onPageClosed: () {
                        refreshList();
                      },
                      note: note,
                      mod: 0,
                    ),
                  ),
                );
              },
              child: const Icon(Icons.add))),
      appBar: buildAppBar(),
      body: Column(
        children: [
          Expanded(
            child: Container(
              color: Colors.white,
              child: SmartRefresher(
                enablePullDown: true,
                enablePullUp: false,
                header: const WaterDropHeader(),
                footer: const ClassicFooter(
                  loadStyle: LoadStyle.ShowWhenLoading,
                  completeDuration: Duration(milliseconds: 500),
                ),
                controller: _refreshController,
                onRefresh: _onRefresh,
                onLoading: _onLoading,
                child: ListView.builder(
                  controller: _scrollController,
                  itemCount: searchnotesList.notesList.length,
                  addAutomaticKeepAlives: false,
                  addRepaintBoundaries: false,
                  itemBuilder: (context, index) {
                    return buildCard(
                      searchnotesList.notesList[index],
                      0,
                    );
                  },
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class BottomPopSheetDeleted extends StatelessWidget {
  const BottomPopSheetDeleted(
      {super.key, required this.note, required this.onDialogClosed});
  final Notes note;
  final VoidCallback onDialogClosed;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: const Icon(Icons.restore),
            title: const Text('还原'),
            onTap: () {
              realm.write(() {
                note.noteIsDeleted = false;
                note.noteUpdateDate = DateTime.now().toUtc();
              });
              onDialogClosed();
              Navigator.pop(context);
            },
          ),
          ListTile(
            leading: const Icon(Icons.delete_forever),
            title: const Text('彻底删除', style: TextStyle(color: Colors.red)),
            onTap: () {
              realm.write(() {
                realm.delete(note);
              });
              onDialogClosed();
              Navigator.pop(context);
            },
          ),
        ],
      ),
    );
  }
}

class SecondComponentList extends StatelessWidget {
  const SecondComponentList({
    super.key,
    required this.scaffoldKey,
  });

  final GlobalKey<ScaffoldState> scaffoldKey;

  @override
  Widget build(BuildContext context) {
    // Fully traverse this list before moving on.
    return FocusTraversalGroup(
      child: ListView(
        padding: const EdgeInsetsDirectional.only(end: smallSpacing),
        children: <Widget>[
          const Actions(),
          colDivider,
          const Communication(),
          colDivider,
          const Containment(),
          colDivider,
          Navigation(scaffoldKey: scaffoldKey),
          colDivider,
          const Selection(),
          colDivider,
          const TextInputs(),
        ],
      ), //右栏的内容
    );
  }
}

class Actions extends StatelessWidget {
  const Actions({super.key});

  @override
  Widget build(BuildContext context) {
    return const ComponentGroupDecoration(label: 'Actions', children: <Widget>[
      Buttons(),
      IconToggleButtons(),
      SegmentedButtons(),
    ]);
  }
}

class Communication extends StatelessWidget {
  const Communication({super.key});

  @override
  Widget build(BuildContext context) {
    return const ComponentGroupDecoration(label: 'Communication', children: [
      NavigationBars(
        selectedIndex: 1,
        isExampleBar: true,
        isBadgeExample: true,
      ),
      ProgressIndicators(),
      SnackBarSection(),
    ]);
  }
}

class Containment extends StatelessWidget {
  const Containment({super.key});

  @override
  Widget build(BuildContext context) {
    return const ComponentGroupDecoration(label: 'Containment', children: [
      BottomSheetSection(),
      Cards(),
      Dialogs(),
      Dividers(),
    ]);
  }
}

class Navigation extends StatelessWidget {
  const Navigation({super.key, required this.scaffoldKey});

  final GlobalKey<ScaffoldState> scaffoldKey;

  @override
  Widget build(BuildContext context) {
    return ComponentGroupDecoration(label: 'Navigation', children: [
      const BottomAppBars(),
      const NavigationBars(
        selectedIndex: 0,
        isExampleBar: true,
      ),
      NavigationDrawers(scaffoldKey: scaffoldKey),
      const NavigationRails(),
      const Tabs(),
      const TopAppBars(),
    ]);
  }
}

class Selection extends StatelessWidget {
  const Selection({super.key});

  @override
  Widget build(BuildContext context) {
    return const ComponentGroupDecoration(label: 'Selection', children: [
      Checkboxes(),
      Chips(),
      Menus(),
      Radios(),
      Sliders(),
      Switches(),
    ]);
  }
}

class TextInputs extends StatelessWidget {
  const TextInputs({super.key});

  @override
  Widget build(BuildContext context) {
    return const ComponentGroupDecoration(
      label: 'Text inputs',
      children: [TextFields()],
    );
  }
}

class Buttons extends StatefulWidget {
  const Buttons({super.key});

  @override
  State<Buttons> createState() => _ButtonsState();
}

class _ButtonsState extends State<Buttons> {
  @override
  Widget build(BuildContext context) {
    return const ComponentDecoration(
      label: 'Common buttons',
      tooltipMessage:
          'Use ElevatedButton, FilledButton, FilledButton.tonal, OutlinedButton, or TextButton',
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: <Widget>[
            ButtonsWithoutIcon(isDisabled: false),
            ButtonsWithIcon(),
            ButtonsWithoutIcon(isDisabled: true),
          ],
        ),
      ),
    );
  }
}

class ButtonsWithoutIcon extends StatelessWidget {
  final bool isDisabled;

  const ButtonsWithoutIcon({super.key, required this.isDisabled});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 5.0),
      child: IntrinsicWidth(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            ElevatedButton(
              onPressed: isDisabled ? null : () {},
              child: const Text('Elevated'),
            ),
            colDivider,
            FilledButton(
              onPressed: isDisabled ? null : () {},
              child: const Text('Filled'),
            ),
            colDivider,
            FilledButton.tonal(
              onPressed: isDisabled ? null : () {},
              child: const Text('Filled tonal'),
            ),
            colDivider,
            OutlinedButton(
              onPressed: isDisabled ? null : () {},
              child: const Text('Outlined'),
            ),
            colDivider,
            TextButton(
              onPressed: isDisabled ? null : () {},
              child: const Text('Text'),
            ),
          ],
        ),
      ),
    );
  }
}

class ButtonsWithIcon extends StatelessWidget {
  const ButtonsWithIcon({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10.0),
      child: IntrinsicWidth(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            ElevatedButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.add),
              label: const Text('Icon'),
            ),
            colDivider,
            FilledButton.icon(
              onPressed: () {},
              label: const Text('Icon'),
              icon: const Icon(Icons.add),
            ),
            colDivider,
            FilledButton.tonalIcon(
              onPressed: () {},
              label: const Text('Icon'),
              icon: const Icon(Icons.add),
            ),
            colDivider,
            OutlinedButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.add),
              label: const Text('Icon'),
            ),
            colDivider,
            TextButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.add),
              label: const Text('Icon'),
            )
          ],
        ),
      ),
    );
  }
}

class Cards extends StatelessWidget {
  const Cards({super.key});

  @override
  Widget build(BuildContext context) {
    return ComponentDecoration(
      label: 'Cards',
      tooltipMessage: 'Use Card',
      child: Wrap(
        alignment: WrapAlignment.spaceEvenly,
        children: [
          SizedBox(
            width: cardWidth,
            child: Card(
              child: Container(
                padding: const EdgeInsets.fromLTRB(10, 5, 5, 10),
                child: Column(
                  children: [
                    Align(
                      alignment: Alignment.topRight,
                      child: IconButton(
                        icon: const Icon(Icons.more_vert),
                        onPressed: () {},
                      ),
                    ),
                    const SizedBox(height: 20),
                    const Align(
                      alignment: Alignment.bottomLeft,
                      child: Text('Elevated'),
                    )
                  ],
                ),
              ),
            ),
          ),
          SizedBox(
            width: cardWidth,
            child: Card(
              color: Theme.of(context).colorScheme.surfaceContainerHighest,
              elevation: 0,
              child: Container(
                padding: const EdgeInsets.fromLTRB(10, 5, 5, 10),
                child: Column(
                  children: [
                    Align(
                      alignment: Alignment.topRight,
                      child: IconButton(
                        icon: const Icon(Icons.more_vert),
                        onPressed: () {},
                      ),
                    ),
                    const SizedBox(height: 20),
                    const Align(
                      alignment: Alignment.bottomLeft,
                      child: Text('Filled'),
                    )
                  ],
                ),
              ),
            ),
          ),
          SizedBox(
            width: cardWidth,
            child: Card(
              elevation: 0,
              shape: RoundedRectangleBorder(
                side: BorderSide(
                  color: Theme.of(context).colorScheme.outline,
                ),
                borderRadius: const BorderRadius.all(Radius.circular(12)),
              ),
              child: Container(
                padding: const EdgeInsets.fromLTRB(10, 5, 5, 10),
                child: Column(
                  children: [
                    Align(
                      alignment: Alignment.topRight,
                      child: IconButton(
                        icon: const Icon(Icons.more_vert),
                        onPressed: () {},
                      ),
                    ),
                    const SizedBox(height: 20),
                    const Align(
                      alignment: Alignment.bottomLeft,
                      child: Text('Outlined'),
                    )
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ClearButton extends StatelessWidget {
  const _ClearButton({required this.controller});

  final TextEditingController controller;

  @override
  Widget build(BuildContext context) => IconButton(
        icon: const Icon(Icons.clear),
        onPressed: () => controller.clear(),
      );
}

class TextFields extends StatefulWidget {
  const TextFields({super.key});

  @override
  State<TextFields> createState() => _TextFieldsState();
}

class _TextFieldsState extends State<TextFields> {
  final TextEditingController _controllerFilled = TextEditingController();
  final TextEditingController _controllerOutlined = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return ComponentDecoration(
      label: 'Text fields',
      tooltipMessage: 'Use TextField with different InputDecoration',
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(smallSpacing),
            child: TextField(
              controller: _controllerFilled,
              decoration: InputDecoration(
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _ClearButton(controller: _controllerFilled),
                labelText: 'Filled',
                hintText: 'hint text',
                helperText: 'supporting text',
                filled: true,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(smallSpacing),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Flexible(
                  child: SizedBox(
                    width: 200,
                    child: TextField(
                      maxLength: 10,
                      maxLengthEnforcement: MaxLengthEnforcement.none,
                      controller: _controllerFilled,
                      decoration: InputDecoration(
                        prefixIcon: const Icon(Icons.search),
                        suffixIcon: _ClearButton(controller: _controllerFilled),
                        labelText: 'Filled',
                        hintText: 'hint text',
                        helperText: 'supporting text',
                        filled: true,
                        errorText: 'error text',
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: smallSpacing),
                Flexible(
                  child: SizedBox(
                    width: 200,
                    child: TextField(
                      controller: _controllerFilled,
                      enabled: false,
                      decoration: InputDecoration(
                        prefixIcon: const Icon(Icons.search),
                        suffixIcon: _ClearButton(controller: _controllerFilled),
                        labelText: 'Disabled',
                        hintText: 'hint text',
                        helperText: 'supporting text',
                        filled: true,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(smallSpacing),
            child: TextField(
              controller: _controllerOutlined,
              decoration: InputDecoration(
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _ClearButton(controller: _controllerOutlined),
                labelText: 'Outlined',
                hintText: 'hint text',
                helperText: 'supporting text',
                border: const OutlineInputBorder(),
              ),
            ),
          ),
          Padding(
              padding: const EdgeInsets.all(smallSpacing),
              child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Flexible(
                      child: SizedBox(
                        width: 200,
                        child: TextField(
                          controller: _controllerOutlined,
                          decoration: InputDecoration(
                            prefixIcon: const Icon(Icons.search),
                            suffixIcon:
                                _ClearButton(controller: _controllerOutlined),
                            labelText: 'Outlined',
                            hintText: 'hint text',
                            helperText: 'supporting text',
                            errorText: 'error text',
                            border: const OutlineInputBorder(),
                            filled: true,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: smallSpacing),
                    Flexible(
                      child: SizedBox(
                        width: 200,
                        child: TextField(
                          controller: _controllerOutlined,
                          enabled: false,
                          decoration: InputDecoration(
                            prefixIcon: const Icon(Icons.search),
                            suffixIcon:
                                _ClearButton(controller: _controllerOutlined),
                            labelText: 'Disabled',
                            hintText: 'hint text',
                            helperText: 'supporting text',
                            border: const OutlineInputBorder(),
                            filled: true,
                          ),
                        ),
                      ),
                    ),
                  ])),
        ],
      ),
    );
  }
}

class Dialogs extends StatefulWidget {
  const Dialogs({super.key});

  @override
  State<Dialogs> createState() => _DialogsState();
}

class _DialogsState extends State<Dialogs> {
  void openDialog(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('What is a dialog?'),
        content: const Text(
            'A dialog is a type of modal window that appears in front of app content to provide critical information, or prompt for a decision to be made.'),
        actions: <Widget>[
          TextButton(
            child: const Text('Okay'),
            onPressed: () => Navigator.of(context).pop(),
          ),
          FilledButton(
            child: const Text('Dismiss'),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ],
      ),
    );
  }

  void openFullscreenDialog(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (context) => Dialog.fullscreen(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Scaffold(
            appBar: AppBar(
              title: const Text('Full-screen dialog'),
              centerTitle: false,
              leading: IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => Navigator.of(context).pop(),
              ),
              actions: [
                TextButton(
                  child: const Text('Close'),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ComponentDecoration(
      label: 'Dialog',
      tooltipMessage:
          'Use showDialog with Dialog.fullscreen, AlertDialog, or SimpleDialog',
      child: Wrap(
        alignment: WrapAlignment.spaceBetween,
        children: [
          TextButton(
            child: const Text(
              'Show dialog',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            onPressed: () => openDialog(context),
          ),
          TextButton(
            child: const Text(
              'Show full-screen dialog',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            onPressed: () => openFullscreenDialog(context),
          ),
        ],
      ),
    );
  }
}

class Dividers extends StatelessWidget {
  const Dividers({super.key});

  @override
  Widget build(BuildContext context) {
    return const ComponentDecoration(
      label: 'Dividers',
      tooltipMessage: 'Use Divider or VerticalDivider',
      child: Column(
        children: <Widget>[
          Divider(key: Key('divider')),
        ],
      ),
    );
  }
}

class Switches extends StatelessWidget {
  const Switches({super.key});

  @override
  Widget build(BuildContext context) {
    return const ComponentDecoration(
      label: 'Switches',
      tooltipMessage: 'Use SwitchListTile or Switch',
      child: Column(
        children: <Widget>[
          SwitchRow(isEnabled: true),
          SwitchRow(isEnabled: false),
        ],
      ),
    );
  }
}

class SwitchRow extends StatefulWidget {
  const SwitchRow({super.key, required this.isEnabled});

  final bool isEnabled;

  @override
  State<SwitchRow> createState() => _SwitchRowState();
}

class _SwitchRowState extends State<SwitchRow> {
  bool value0 = false;
  bool value1 = true;

  final WidgetStateProperty<Icon?> thumbIcon =
      WidgetStateProperty.resolveWith<Icon?>((states) {
    if (states.contains(WidgetState.selected)) {
      return const Icon(Icons.check);
    }
    return const Icon(Icons.close);
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: <Widget>[
        Switch(
          value: value0,
          onChanged: widget.isEnabled
              ? (value) {
                  setState(() {
                    value0 = value;
                  });
                }
              : null,
        ),
        Switch(
          thumbIcon: thumbIcon,
          value: value1,
          onChanged: widget.isEnabled
              ? (value) {
                  setState(() {
                    value1 = value;
                  });
                }
              : null,
        ),
      ],
    );
  }
}

class Checkboxes extends StatefulWidget {
  const Checkboxes({super.key});

  @override
  State<Checkboxes> createState() => _CheckboxesState();
}

class _CheckboxesState extends State<Checkboxes> {
  bool? isChecked0 = true;
  bool? isChecked1;
  bool? isChecked2 = false;

  @override
  Widget build(BuildContext context) {
    return ComponentDecoration(
      label: 'Checkboxes',
      tooltipMessage: 'Use CheckboxListTile or Checkbox',
      child: Column(
        children: <Widget>[
          CheckboxListTile(
            tristate: true,
            value: isChecked0,
            title: const Text('Option 1'),
            onChanged: (value) {
              setState(() {
                isChecked0 = value;
              });
            },
          ),
          CheckboxListTile(
            tristate: true,
            value: isChecked1,
            title: const Text('Option 2'),
            onChanged: (value) {
              setState(() {
                isChecked1 = value;
              });
            },
          ),
          CheckboxListTile(
            tristate: true,
            value: isChecked2,
            title: const Text('Option 3'),
            onChanged: (value) {
              setState(() {
                isChecked2 = value;
              });
            },
          ),
          const CheckboxListTile(
            tristate: true,
            title: Text('Option 4'),
            value: true,
            onChanged: null,
          ),
        ],
      ),
    );
  }
}

enum Value { first, second }

class Radios extends StatefulWidget {
  const Radios({super.key});

  @override
  State<Radios> createState() => _RadiosState();
}

enum Options { option1, option2, option3 }

class _RadiosState extends State<Radios> {
  Options? _selectedOption = Options.option1;

  @override
  Widget build(BuildContext context) {
    return ComponentDecoration(
      label: 'Radio buttons',
      tooltipMessage: 'Use RadioListTile<T> or Radio<T>',
      child: Column(
        children: <Widget>[
          RadioListTile<Options>(
            title: const Text('Option 1'),
            value: Options.option1,
            groupValue: _selectedOption,
            onChanged: (value) {
              setState(() {
                _selectedOption = value;
              });
            },
          ),
          RadioListTile<Options>(
            title: const Text('Option 2'),
            value: Options.option2,
            groupValue: _selectedOption,
            onChanged: (value) {
              setState(() {
                _selectedOption = value;
              });
            },
          ),
          RadioListTile<Options>(
            title: const Text('Option 3'),
            value: Options.option3,
            groupValue: _selectedOption,
            onChanged: null,
          ),
        ],
      ),
    );
  }
}

class ProgressIndicators extends StatefulWidget {
  const ProgressIndicators({super.key});

  @override
  State<ProgressIndicators> createState() => _ProgressIndicatorsState();
}

class _ProgressIndicatorsState extends State<ProgressIndicators> {
  bool playProgressIndicator = false;

  @override
  Widget build(BuildContext context) {
    final double? progressValue = playProgressIndicator ? null : 0.7;

    return ComponentDecoration(
      label: 'Progress indicators',
      tooltipMessage:
          'Use CircularProgressIndicator or LinearProgressIndicator',
      child: Column(
        children: <Widget>[
          Row(
            children: [
              IconButton(
                isSelected: playProgressIndicator,
                selectedIcon: const Icon(Icons.pause),
                icon: const Icon(Icons.play_arrow),
                onPressed: () {
                  setState(() {
                    playProgressIndicator = !playProgressIndicator;
                  });
                },
              ),
              Expanded(
                child: Row(
                  children: <Widget>[
                    CircularProgressIndicator(
                      value: progressValue,
                    ),
                    Expanded(
                      child: LinearProgressIndicator(
                        value: progressValue,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

const List<NavigationDestination> appBarDestinations = [
  NavigationDestination(
    tooltip: '',
    icon: Icon(Icons.star_border_outlined),
    label: 'Stars',
    selectedIcon: Icon(Icons.star),
  ),
  NavigationDestination(
    tooltip: '',
    icon: Icon(Icons.widgets_outlined),
    label: 'Notes',
    selectedIcon: Icon(Icons.widgets),
  ),
  NavigationDestination(
    tooltip: '',
    icon: Icon(Icons.indeterminate_check_box_rounded),
    label: 'Todo',
    selectedIcon: Icon(Icons.check_box_rounded),
  ),
  NavigationDestination(
    tooltip: '',
    icon: Icon(Icons.dashboard_outlined),
    label: 'Dashboard',
    selectedIcon: Icon(Icons.dashboard),
  ),
  // NavigationDestination(
  //   tooltip: '',
  //   icon: Icon(Icons.explore_outlined),
  //   label: 'Typography',
  //   selectedIcon: Icon(Icons.text_snippet),
  // ),
  // NavigationDestination(
  //   tooltip: '',
  //   icon: Icon(Icons.invert_colors_on_outlined),
  //   label: 'Elevation',
  //   selectedIcon: Icon(Icons.opacity),
  // )
];

const List<Widget> exampleBarDestinations = [
  NavigationDestination(
    tooltip: '',
    icon: Icon(Icons.explore_outlined),
    label: 'Explore',
    selectedIcon: Icon(Icons.explore),
  ),
  NavigationDestination(
    tooltip: '',
    icon: Icon(Icons.pets_outlined),
    label: 'Pets',
    selectedIcon: Icon(Icons.pets),
  ),
  NavigationDestination(
    tooltip: '',
    icon: Icon(Icons.account_box_outlined),
    label: 'Account',
    selectedIcon: Icon(Icons.account_box),
  )
];

List<Widget> barWithBadgeDestinations = [
  NavigationDestination(
    tooltip: '',
    icon: Badge.count(count: 1000, child: const Icon(Icons.mail_outlined)),
    label: 'Mail',
    selectedIcon: Badge.count(count: 1000, child: const Icon(Icons.mail)),
  ),
  const NavigationDestination(
    tooltip: '',
    icon: Badge(label: Text('10'), child: Icon(Icons.chat_bubble_outline)),
    label: 'Chat',
    selectedIcon: Badge(label: Text('10'), child: Icon(Icons.chat_bubble)),
  ),
  const NavigationDestination(
    tooltip: '',
    icon: Badge(child: Icon(Icons.group_outlined)),
    label: 'Rooms',
    selectedIcon: Badge(child: Icon(Icons.group_rounded)),
  ),
  NavigationDestination(
    tooltip: '',
    icon: Badge.count(count: 3, child: const Icon(Icons.videocam_outlined)),
    label: 'Meet',
    selectedIcon: Badge.count(count: 3, child: const Icon(Icons.videocam)),
  )
];

class NavigationBars extends StatefulWidget {
  const NavigationBars({
    super.key,
    this.onSelectItem,
    required this.selectedIndex,
    required this.isExampleBar,
    this.isBadgeExample = false,
  });

  final void Function(int)? onSelectItem;
  final int selectedIndex;
  final bool isExampleBar;
  final bool isBadgeExample;

  @override
  State<NavigationBars> createState() => _NavigationBarsState();
}

class _NavigationBarsState extends State<NavigationBars> {
  late int selectedIndex;

  @override
  void initState() {
    super.initState();
    selectedIndex = widget.selectedIndex;
  }

  @override
  void didUpdateWidget(covariant NavigationBars oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.selectedIndex != oldWidget.selectedIndex) {
      selectedIndex = widget.selectedIndex;
    }
  }

  @override
  Widget build(BuildContext context) {
    // App NavigationBar should get first focus.
    Widget navigationBar = Focus(
      autofocus: !(widget.isExampleBar || widget.isBadgeExample),
      child: NavigationBar(
        selectedIndex: selectedIndex,
        onDestinationSelected: (index) {
          setState(() {
            selectedIndex = index;
          });
          if (!widget.isExampleBar) widget.onSelectItem!(index);
        },
        destinations: widget.isExampleBar && widget.isBadgeExample
            ? barWithBadgeDestinations
            : widget.isExampleBar
                ? exampleBarDestinations
                : appBarDestinations,
      ),
    );

    if (widget.isExampleBar && widget.isBadgeExample) {
      navigationBar = ComponentDecoration(
          label: 'Badges',
          tooltipMessage: 'Use Badge or Badge.count',
          child: navigationBar);
    } else if (widget.isExampleBar) {
      navigationBar = ComponentDecoration(
          label: 'Navigation bar',
          tooltipMessage: 'Use NavigationBar',
          child: navigationBar);
    }

    return navigationBar;
  }
}

class IconToggleButtons extends StatefulWidget {
  const IconToggleButtons({super.key});

  @override
  State<IconToggleButtons> createState() => _IconToggleButtonsState();
}

class _IconToggleButtonsState extends State<IconToggleButtons> {
  @override
  Widget build(BuildContext context) {
    return const ComponentDecoration(
      label: 'Icon buttons',
      tooltipMessage: 'Use IconButton',
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: <Widget>[
          Column(
            // Standard IconButton
            children: <Widget>[
              IconToggleButton(
                isEnabled: true,
                tooltip: 'Standard',
              ),
              colDivider,
              IconToggleButton(
                isEnabled: false,
                tooltip: 'Standard (disabled)',
              ),
            ],
          ),
          Column(
            children: <Widget>[
              // Filled IconButton
              IconToggleButton(
                isEnabled: true,
                tooltip: 'Filled',
                getDefaultStyle: enabledFilledButtonStyle,
              ),
              colDivider,
              IconToggleButton(
                isEnabled: false,
                tooltip: 'Filled (disabled)',
                getDefaultStyle: disabledFilledButtonStyle,
              ),
            ],
          ),
          Column(
            children: <Widget>[
              // Filled Tonal IconButton
              IconToggleButton(
                isEnabled: true,
                tooltip: 'Filled tonal',
                getDefaultStyle: enabledFilledTonalButtonStyle,
              ),
              colDivider,
              IconToggleButton(
                isEnabled: false,
                tooltip: 'Filled tonal (disabled)',
                getDefaultStyle: disabledFilledTonalButtonStyle,
              ),
            ],
          ),
          Column(
            children: <Widget>[
              // Outlined IconButton
              IconToggleButton(
                isEnabled: true,
                tooltip: 'Outlined',
                getDefaultStyle: enabledOutlinedButtonStyle,
              ),
              colDivider,
              IconToggleButton(
                isEnabled: false,
                tooltip: 'Outlined (disabled)',
                getDefaultStyle: disabledOutlinedButtonStyle,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class IconToggleButton extends StatefulWidget {
  const IconToggleButton({
    required this.isEnabled,
    required this.tooltip,
    this.getDefaultStyle,
    super.key,
  });

  final bool isEnabled;
  final String tooltip;
  final ButtonStyle? Function(bool, ColorScheme)? getDefaultStyle;

  @override
  State<IconToggleButton> createState() => _IconToggleButtonState();
}

class _IconToggleButtonState extends State<IconToggleButton> {
  bool selected = false;

  @override
  Widget build(BuildContext context) {
    final ColorScheme colors = Theme.of(context).colorScheme;
    final VoidCallback? onPressed = widget.isEnabled
        ? () {
            setState(() {
              selected = !selected;
            });
          }
        : null;
    ButtonStyle? style = widget.getDefaultStyle?.call(selected, colors);

    return IconButton(
      visualDensity: VisualDensity.standard,
      isSelected: selected,
      tooltip: widget.tooltip,
      icon: const Icon(Icons.settings_outlined),
      selectedIcon: const Icon(Icons.settings),
      onPressed: onPressed,
      style: style,
    );
  }
}

ButtonStyle enabledFilledButtonStyle(bool selected, ColorScheme colors) {
  return IconButton.styleFrom(
    foregroundColor: selected ? colors.onPrimary : colors.primary,
    backgroundColor: selected ? colors.primary : colors.surfaceContainerHighest,
    disabledForegroundColor: colors.onSurface.withOpacity(0.38),
    disabledBackgroundColor: colors.onSurface.withOpacity(0.12),
    hoverColor: selected
        ? colors.onPrimary.withOpacity(0.08)
        : colors.primary.withOpacity(0.08),
    focusColor: selected
        ? colors.onPrimary.withOpacity(0.12)
        : colors.primary.withOpacity(0.12),
    highlightColor: selected
        ? colors.onPrimary.withOpacity(0.12)
        : colors.primary.withOpacity(0.12),
  );
}

ButtonStyle disabledFilledButtonStyle(bool selected, ColorScheme colors) {
  return IconButton.styleFrom(
    disabledForegroundColor: colors.onSurface.withOpacity(0.38),
    disabledBackgroundColor: colors.onSurface.withOpacity(0.12),
  );
}

ButtonStyle enabledFilledTonalButtonStyle(bool selected, ColorScheme colors) {
  return IconButton.styleFrom(
    foregroundColor:
        selected ? colors.onSecondaryContainer : colors.onSurfaceVariant,
    backgroundColor:
        selected ? colors.secondaryContainer : colors.surfaceContainerHighest,
    hoverColor: selected
        ? colors.onSecondaryContainer.withOpacity(0.08)
        : colors.onSurfaceVariant.withOpacity(0.08),
    focusColor: selected
        ? colors.onSecondaryContainer.withOpacity(0.12)
        : colors.onSurfaceVariant.withOpacity(0.12),
    highlightColor: selected
        ? colors.onSecondaryContainer.withOpacity(0.12)
        : colors.onSurfaceVariant.withOpacity(0.12),
  );
}

ButtonStyle disabledFilledTonalButtonStyle(bool selected, ColorScheme colors) {
  return IconButton.styleFrom(
    disabledForegroundColor: colors.onSurface.withOpacity(0.38),
    disabledBackgroundColor: colors.onSurface.withOpacity(0.12),
  );
}

ButtonStyle enabledOutlinedButtonStyle(bool selected, ColorScheme colors) {
  return IconButton.styleFrom(
    backgroundColor: selected ? colors.inverseSurface : null,
    hoverColor: selected
        ? colors.onInverseSurface.withOpacity(0.08)
        : colors.onSurfaceVariant.withOpacity(0.08),
    focusColor: selected
        ? colors.onInverseSurface.withOpacity(0.12)
        : colors.onSurfaceVariant.withOpacity(0.12),
    highlightColor: selected
        ? colors.onInverseSurface.withOpacity(0.12)
        : colors.onSurface.withOpacity(0.12),
    side: BorderSide(color: colors.outline),
  ).copyWith(
    foregroundColor: WidgetStateProperty.resolveWith((states) {
      if (states.contains(WidgetState.selected)) {
        return colors.onInverseSurface;
      }
      if (states.contains(WidgetState.pressed)) {
        return colors.onSurface;
      }
      return null;
    }),
  );
}

ButtonStyle disabledOutlinedButtonStyle(bool selected, ColorScheme colors) {
  return IconButton.styleFrom(
    disabledForegroundColor: colors.onSurface.withOpacity(0.38),
    disabledBackgroundColor:
        selected ? colors.onSurface.withOpacity(0.12) : null,
    side: selected ? null : BorderSide(color: colors.outline.withOpacity(0.12)),
  );
}

class Chips extends StatefulWidget {
  const Chips({super.key});

  @override
  State<Chips> createState() => _ChipsState();
}

class _ChipsState extends State<Chips> {
  bool isFiltered = true;

  @override
  Widget build(BuildContext context) {
    return ComponentDecoration(
      label: 'Chips',
      tooltipMessage:
          'Use ActionChip, FilterChip, or InputChip. \nActionChip can also be used for suggestion chip',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Wrap(
            spacing: smallSpacing,
            runSpacing: smallSpacing,
            children: <Widget>[
              ActionChip(
                label: const Text('Assist'),
                avatar: const Icon(Icons.event),
                onPressed: () {},
              ),
              FilterChip(
                label: const Text('Filter'),
                selected: isFiltered,
                onSelected: (selected) {
                  setState(() => isFiltered = selected);
                },
              ),
              InputChip(
                label: const Text('Input'),
                onPressed: () {},
                onDeleted: () {},
              ),
              ActionChip(
                label: const Text('Suggestion'),
                onPressed: () {},
              ),
            ],
          ),
          colDivider,
          Wrap(
            spacing: smallSpacing,
            runSpacing: smallSpacing,
            children: <Widget>[
              const ActionChip(
                label: Text('Assist'),
                avatar: Icon(Icons.event),
              ),
              FilterChip(
                label: const Text('Filter'),
                selected: isFiltered,
                onSelected: null,
              ),
              InputChip(
                label: const Text('Input'),
                onDeleted: () {},
                isEnabled: false,
              ),
              const ActionChip(
                label: Text('Suggestion'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class SegmentedButtons extends StatelessWidget {
  const SegmentedButtons({super.key});

  @override
  Widget build(BuildContext context) {
    return const ComponentDecoration(
      label: 'Segmented buttons',
      tooltipMessage: 'Use SegmentedButton<T>',
      child: Column(
        children: <Widget>[
          SingleChoice(),
          colDivider,
          MultipleChoice(),
        ],
      ),
    );
  }
}

enum Calendar { day, week, month, year }

class SingleChoice extends StatefulWidget {
  const SingleChoice({super.key});

  @override
  State<SingleChoice> createState() => _SingleChoiceState();
}

class _SingleChoiceState extends State<SingleChoice> {
  Calendar calendarView = Calendar.day;

  @override
  Widget build(BuildContext context) {
    return SegmentedButton<Calendar>(
      segments: const <ButtonSegment<Calendar>>[
        ButtonSegment<Calendar>(
            value: Calendar.day,
            label: Text('Day'),
            icon: Icon(Icons.calendar_view_day)),
        ButtonSegment<Calendar>(
            value: Calendar.week,
            label: Text('Week'),
            icon: Icon(Icons.calendar_view_week)),
        ButtonSegment<Calendar>(
            value: Calendar.month,
            label: Text('Month'),
            icon: Icon(Icons.calendar_view_month)),
        ButtonSegment<Calendar>(
            value: Calendar.year,
            label: Text('Year'),
            icon: Icon(Icons.calendar_today)),
      ],
      selected: <Calendar>{calendarView},
      onSelectionChanged: (newSelection) {
        setState(() {
          // By default there is only a single segment that can be
          // selected at one time, so its value is always the first
          // item in the selected set.
          calendarView = newSelection.first;
        });
      },
    );
  }
}

enum Sizes { extraSmall, small, medium, large, extraLarge }

class MultipleChoice extends StatefulWidget {
  const MultipleChoice({super.key});

  @override
  State<MultipleChoice> createState() => _MultipleChoiceState();
}

class _MultipleChoiceState extends State<MultipleChoice> {
  Set<Sizes> selection = <Sizes>{Sizes.large, Sizes.extraLarge};

  @override
  Widget build(BuildContext context) {
    return SegmentedButton<Sizes>(
      segments: const <ButtonSegment<Sizes>>[
        ButtonSegment<Sizes>(value: Sizes.extraSmall, label: Text('XS')),
        ButtonSegment<Sizes>(value: Sizes.small, label: Text('S')),
        ButtonSegment<Sizes>(value: Sizes.medium, label: Text('M')),
        ButtonSegment<Sizes>(
          value: Sizes.large,
          label: Text('L'),
        ),
        ButtonSegment<Sizes>(value: Sizes.extraLarge, label: Text('XL')),
      ],
      selected: selection,
      onSelectionChanged: (newSelection) {
        setState(() {
          selection = newSelection;
        });
      },
      multiSelectionEnabled: true,
    );
  }
}

class SnackBarSection extends StatelessWidget {
  const SnackBarSection({super.key});

  @override
  Widget build(BuildContext context) {
    return ComponentDecoration(
      label: 'Snackbar',
      tooltipMessage:
          'Use ScaffoldMessenger.of(context).showSnackBar with SnackBar',
      child: TextButton(
        onPressed: () {
          final snackBar = SnackBar(
            behavior: SnackBarBehavior.floating,
            width: 400.0,
            content: const Text('This is a snackbar'),
            action: SnackBarAction(
              label: 'Close',
              onPressed: () {},
            ),
          );

          ScaffoldMessenger.of(context).hideCurrentSnackBar();
          ScaffoldMessenger.of(context).showSnackBar(snackBar);
        },
        child: const Text(
          'Show snackbar',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}

class BottomSheetSection extends StatefulWidget {
  const BottomSheetSection({super.key});

  @override
  State<BottomSheetSection> createState() => _BottomSheetSectionState();
}

class _BottomSheetSectionState extends State<BottomSheetSection> {
  bool isNonModalBottomSheetOpen = false;

  @override
  Widget build(BuildContext context) {
    List<Widget> buttonList = <Widget>[
      IconButton(onPressed: () {}, icon: const Icon(Icons.share_outlined)),
      IconButton(onPressed: () {}, icon: const Icon(Icons.add)),
      IconButton(onPressed: () {}, icon: const Icon(Icons.delete_outline)),
      IconButton(onPressed: () {}, icon: const Icon(Icons.archive_outlined)),
      IconButton(onPressed: () {}, icon: const Icon(Icons.settings_outlined)),
      IconButton(onPressed: () {}, icon: const Icon(Icons.favorite_border)),
    ];
    List<Text> labelList = const <Text>[
      Text('Share'),
      Text('Add to'),
      Text('Trash'),
      Text('Archive'),
      Text('Settings'),
      Text('Favorite')
    ];

    buttonList = List.generate(
        buttonList.length,
        (index) => Padding(
              padding: const EdgeInsets.fromLTRB(20.0, 30.0, 20.0, 20.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  buttonList[index],
                  labelList[index],
                ],
              ),
            ));

    return ComponentDecoration(
      label: 'Bottom sheet',
      tooltipMessage: 'Use showModalBottomSheet<T> or showBottomSheet<T>',
      child: Wrap(
        alignment: WrapAlignment.spaceEvenly,
        children: [
          TextButton(
            child: const Text(
              'Show modal bottom sheet',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            onPressed: () {
              showModalBottomSheet<void>(
                context: context,
                constraints: const BoxConstraints(maxWidth: 640),
                builder: (context) {
                  return SizedBox(
                    height: 150,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 32.0),
                      child: ListView(
                        shrinkWrap: true,
                        scrollDirection: Axis.horizontal,
                        children: buttonList,
                      ),
                    ),
                  );
                },
              );
            },
          ),
        ],
      ),
    );
  }
}

class BottomAppBars extends StatelessWidget {
  const BottomAppBars({super.key});

  @override
  Widget build(BuildContext context) {
    return ComponentDecoration(
      label: 'Bottom app bar',
      tooltipMessage: 'Use BottomAppBar',
      child: Column(
        children: [
          SizedBox(
            height: 80,
            child: Scaffold(
              floatingActionButton: FloatingActionButton(
                onPressed: () {},
                elevation: 0.0,
                child: GestureDetector(
                  onTap: () {
                    HapticFeedback.lightImpact();
                  },
                  onLongPress: () {
                    HapticFeedback.heavyImpact();
                  },
                  child: const Icon(Icons.add),
                ),
              ),
              floatingActionButtonLocation:
                  FloatingActionButtonLocation.endContained,
              bottomNavigationBar: BottomAppBar(
                child: Row(
                  children: <Widget>[
                    const IconButtonAnchorExample(),
                    IconButton(
                      tooltip: 'Search',
                      icon: const Icon(Icons.search),
                      onPressed: () {},
                    ),
                    IconButton(
                      tooltip: 'Favorite',
                      icon: const Icon(Icons.favorite),
                      onPressed: () {},
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class IconButtonAnchorExample extends StatelessWidget {
  const IconButtonAnchorExample({super.key});

  @override
  Widget build(BuildContext context) {
    return MenuAnchor(
      builder: (context, controller, child) {
        return IconButton(
          onPressed: () {
            if (controller.isOpen) {
              controller.close();
            } else {
              controller.open();
            }
          },
          icon: const Icon(Icons.more_vert),
        );
      },
      menuChildren: [
        MenuItemButton(
          child: const Text('Menu 1'),
          onPressed: () {},
        ),
        MenuItemButton(
          child: const Text('Menu 2'),
          onPressed: () {},
        ),
        SubmenuButton(
          menuChildren: <Widget>[
            MenuItemButton(
              onPressed: () {},
              child: const Text('Menu 3.1'),
            ),
            MenuItemButton(
              onPressed: () {},
              child: const Text('Menu 3.2'),
            ),
            MenuItemButton(
              onPressed: () {},
              child: const Text('Menu 3.3'),
            ),
          ],
          child: const Text('Menu 3'),
        ),
      ],
    );
  }
}

class ButtonAnchorExample extends StatelessWidget {
  const ButtonAnchorExample({super.key});

  @override
  Widget build(BuildContext context) {
    return MenuAnchor(
      builder: (context, controller, child) {
        return FilledButton.tonal(
          onPressed: () {
            if (controller.isOpen) {
              controller.close();
            } else {
              controller.open();
            }
          },
          child: const Text('Show menu'),
        );
      },
      menuChildren: [
        MenuItemButton(
          leadingIcon: const Icon(Icons.people_alt_outlined),
          child: const Text('Item 1'),
          onPressed: () {},
        ),
        MenuItemButton(
          leadingIcon: const Icon(Icons.remove_red_eye_outlined),
          child: const Text('Item 2'),
          onPressed: () {},
        ),
        MenuItemButton(
          leadingIcon: const Icon(Icons.refresh),
          onPressed: () {},
          child: const Text('Item 3'),
        ),
      ],
    );
  }
}

class NavigationDrawers extends StatelessWidget {
  const NavigationDrawers({super.key, required this.scaffoldKey});
  final GlobalKey<ScaffoldState> scaffoldKey;

  @override
  Widget build(BuildContext context) {
    return ComponentDecoration(
      label: 'Navigation drawer',
      tooltipMessage:
          'Use NavigationDrawer. For modal navigation drawers, see Scaffold.endDrawer',
      child: Column(
        children: [
          const SizedBox(height: 520, child: NavigationDrawerSection()),
          colDivider,
          colDivider,
          TextButton(
            child: const Text('Show modal navigation drawer',
                style: TextStyle(fontWeight: FontWeight.bold)),
            onPressed: () {
              scaffoldKey.currentState!.openEndDrawer();
            },
          ),
        ],
      ),
    );
  }
}

class NavigationDrawerSection extends StatefulWidget {
  const NavigationDrawerSection({super.key});

  @override
  State<NavigationDrawerSection> createState() =>
      _NavigationDrawerSectionState();
}

class _NavigationDrawerSectionState extends State<NavigationDrawerSection> {
  int navDrawerIndex = 0;

  @override
  Widget build(BuildContext context) {
    return NavigationDrawer(
      onDestinationSelected: (selectedIndex) {
        setState(() {
          navDrawerIndex = selectedIndex;
        });
      },
      selectedIndex: navDrawerIndex,
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.fromLTRB(28, 16, 16, 10),
          child: Text(
            'Mail',
            style: Theme.of(context).textTheme.titleSmall,
          ),
        ),
        ...destinations.map((destination) {
          return NavigationDrawerDestination(
            label: Text(destination.label),
            icon: destination.icon,
            selectedIcon: destination.selectedIcon,
          );
        }),
        const Divider(indent: 28, endIndent: 28),
        Padding(
          padding: const EdgeInsets.fromLTRB(28, 16, 16, 10),
          child: Text(
            'Labels',
            style: Theme.of(context).textTheme.titleSmall,
          ),
        ),
        ...labelDestinations.map((destination) {
          return NavigationDrawerDestination(
            label: Text(destination.label),
            icon: destination.icon,
            selectedIcon: destination.selectedIcon,
          );
        }),
      ],
    );
  }
}

class ExampleDestination {
  const ExampleDestination(this.label, this.icon, this.selectedIcon);

  final String label;
  final Widget icon;
  final Widget selectedIcon;
}

const List<ExampleDestination> destinations = <ExampleDestination>[
  ExampleDestination('Inbox', Icon(Icons.inbox_outlined), Icon(Icons.inbox)),
  ExampleDestination('Outbox', Icon(Icons.send_outlined), Icon(Icons.send)),
  ExampleDestination(
      'Favorites', Icon(Icons.favorite_outline), Icon(Icons.favorite)),
  ExampleDestination('Trash', Icon(Icons.delete_outline), Icon(Icons.delete)),
];

const List<ExampleDestination> labelDestinations = <ExampleDestination>[
  ExampleDestination(
      'Family', Icon(Icons.bookmark_border), Icon(Icons.bookmark)),
  ExampleDestination(
      'School', Icon(Icons.bookmark_border), Icon(Icons.bookmark)),
  ExampleDestination('Work', Icon(Icons.bookmark_border), Icon(Icons.bookmark)),
];

class NavigationRails extends StatelessWidget {
  const NavigationRails({super.key});

  @override
  Widget build(BuildContext context) {
    return const ComponentDecoration(
      label: 'Navigation rail',
      tooltipMessage: 'Use NavigationRail',
      child: IntrinsicWidth(
          child: SizedBox(height: 420, child: NavigationRailSection())),
    );
  }
}

class NavigationRailSection extends StatefulWidget {
  const NavigationRailSection({super.key});

  @override
  State<NavigationRailSection> createState() => _NavigationRailSectionState();
}

class _NavigationRailSectionState extends State<NavigationRailSection> {
  int navRailIndex = 0;

  @override
  Widget build(BuildContext context) {
    return NavigationRail(
      onDestinationSelected: (selectedIndex) {
        setState(() {
          navRailIndex = selectedIndex;
        });
      },
      elevation: 4,
      leading: FloatingActionButton(
          child: const Icon(Icons.create), onPressed: () {}),
      groupAlignment: 0.0,
      selectedIndex: navRailIndex,
      labelType: NavigationRailLabelType.selected,
      destinations: <NavigationRailDestination>[
        ...destinations.map((destination) {
          return NavigationRailDestination(
            label: Text(destination.label),
            icon: destination.icon,
            selectedIcon: destination.selectedIcon,
          );
        }),
      ],
    );
  }
}

class Tabs extends StatefulWidget {
  const Tabs({super.key});

  @override
  State<Tabs> createState() => _TabsState();
}

class _TabsState extends State<Tabs> with TickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    return ComponentDecoration(
      label: 'Tabs',
      tooltipMessage: 'Use TabBar',
      child: SizedBox(
        height: 80,
        child: Scaffold(
          appBar: AppBar(
            bottom: TabBar(
              controller: _tabController,
              tabs: const <Widget>[
                Tab(
                  icon: Icon(Icons.videocam_outlined),
                  text: 'Video',
                  iconMargin: EdgeInsets.only(bottom: 0.0),
                ),
                Tab(
                  icon: Icon(Icons.photo_outlined),
                  text: 'Photos',
                  iconMargin: EdgeInsets.only(bottom: 0.0),
                ),
                Tab(
                  icon: Icon(Icons.audiotrack_sharp),
                  text: 'Audio',
                  iconMargin: EdgeInsets.only(bottom: 0.0),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class TopAppBars extends StatelessWidget {
  const TopAppBars({super.key});

  static final actions = [
    IconButton(icon: const Icon(Icons.attach_file), onPressed: () {}),
    IconButton(icon: const Icon(Icons.event), onPressed: () {}),
    IconButton(icon: const Icon(Icons.more_vert), onPressed: () {}),
  ];

  @override
  Widget build(BuildContext context) {
    return ComponentDecoration(
      label: 'Top app bars',
      tooltipMessage:
          'Use AppBar, SliverAppBar, SliverAppBar.medium, or  SliverAppBar.large',
      child: Column(
        children: [
          AppBar(
            title: const Text('Center-aligned'),
            leading: const BackButton(),
            actions: [
              IconButton(
                iconSize: 32,
                icon: const Icon(Icons.account_circle_outlined),
                onPressed: () {},
              ),
            ],
            centerTitle: true,
          ),
          colDivider,
          AppBar(
            title: const Text('Small'),
            leading: const BackButton(),
            actions: actions,
            centerTitle: false,
          ),
          colDivider,
          SizedBox(
            height: 100,
            child: CustomScrollView(
              slivers: [
                SliverAppBar.medium(
                  title: const Text('Medium'),
                  leading: const BackButton(),
                  actions: actions,
                ),
                const SliverFillRemaining(),
              ],
            ),
          ),
          colDivider,
          SizedBox(
            height: 130,
            child: CustomScrollView(
              slivers: [
                SliverAppBar.large(
                  title: const Text('Large'),
                  leading: const BackButton(),
                  actions: actions,
                ),
                const SliverFillRemaining(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class Menus extends StatefulWidget {
  const Menus({super.key});

  @override
  State<Menus> createState() => _MenusState();
}

class _MenusState extends State<Menus> {
  final TextEditingController colorController = TextEditingController();
  final TextEditingController iconController = TextEditingController();
  IconLabel? selectedIcon = IconLabel.smile;
  ColorLabel? selectedColor;

  @override
  Widget build(BuildContext context) {
    final List<DropdownMenuEntry<ColorLabel>> colorEntries =
        <DropdownMenuEntry<ColorLabel>>[];
    for (final ColorLabel color in ColorLabel.values) {
      colorEntries.add(DropdownMenuEntry<ColorLabel>(
          value: color, label: color.label, enabled: color.label != 'Grey'));
    }

    final List<DropdownMenuEntry<IconLabel>> iconEntries =
        <DropdownMenuEntry<IconLabel>>[];
    for (final IconLabel icon in IconLabel.values) {
      iconEntries
          .add(DropdownMenuEntry<IconLabel>(value: icon, label: icon.label));
    }

    return ComponentDecoration(
      label: 'Menus',
      tooltipMessage: 'Use MenuAnchor or DropdownMenu<T>',
      child: Column(
        children: [
          const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              ButtonAnchorExample(),
              IconButtonAnchorExample(),
            ],
          ),
          colDivider,
          Wrap(
            alignment: WrapAlignment.spaceAround,
            runAlignment: WrapAlignment.center,
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: smallSpacing,
            runSpacing: smallSpacing,
            children: [
              DropdownMenu<ColorLabel>(
                controller: colorController,
                label: const Text('Color'),
                enableFilter: true,
                dropdownMenuEntries: colorEntries,
                inputDecorationTheme: const InputDecorationTheme(filled: true),
                onSelected: (color) {
                  setState(() {
                    selectedColor = color;
                  });
                },
              ),
              DropdownMenu<IconLabel>(
                initialSelection: IconLabel.smile,
                controller: iconController,
                leadingIcon: const Icon(Icons.search),
                label: const Text('Icon'),
                dropdownMenuEntries: iconEntries,
                onSelected: (icon) {
                  setState(() {
                    selectedIcon = icon;
                  });
                },
              ),
              Icon(
                selectedIcon?.icon,
                color: selectedColor?.color ?? Colors.grey.withOpacity(0.5),
              )
            ],
          ),
        ],
      ),
    );
  }
}

enum ColorLabel {
  blue('Blue', Colors.blue),
  pink('Pink', Colors.pink),
  green('Green', Colors.green),
  yellow('Yellow', Colors.yellow),
  grey('Grey', Colors.grey);

  const ColorLabel(this.label, this.color);
  final String label;
  final Color color;
}

enum IconLabel {
  smile('Smile', Icons.sentiment_satisfied_outlined),
  cloud(
    'Cloud',
    Icons.cloud_outlined,
  ),
  brush('Brush', Icons.brush_outlined),
  heart('Heart', Icons.favorite);

  const IconLabel(this.label, this.icon);
  final String label;
  final IconData icon;
}

class Sliders extends StatefulWidget {
  const Sliders({super.key});

  @override
  State<Sliders> createState() => _SlidersState();
}

class _SlidersState extends State<Sliders> {
  double sliderValue0 = 30.0;
  double sliderValue1 = 20.0;

  @override
  Widget build(BuildContext context) {
    return ComponentDecoration(
        label: 'Sliders',
        tooltipMessage: 'Use Slider or RangeSlider',
        child: Column(
          children: <Widget>[
            Slider(
              max: 100,
              value: sliderValue0,
              onChanged: (value) {
                setState(() {
                  sliderValue0 = value;
                });
              },
            ),
            const SizedBox(height: 20),
            Slider(
              max: 100,
              divisions: 5,
              value: sliderValue1,
              label: sliderValue1.round().toString(),
              onChanged: (value) {
                setState(() {
                  sliderValue1 = value;
                });
              },
            ),
          ],
        ));
  }
}

class ComponentDecoration extends StatefulWidget {
  const ComponentDecoration({
    super.key,
    required this.label,
    required this.child,
    this.tooltipMessage = '',
  });

  final String label;
  final Widget child;
  final String? tooltipMessage;

  @override
  State<ComponentDecoration> createState() => _ComponentDecorationState();
}

class _ComponentDecorationState extends State<ComponentDecoration> {
  final focusNode = FocusNode();

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: smallSpacing),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(widget.label,
                    style: Theme.of(context).textTheme.titleSmall),
                Tooltip(
                  message: widget.tooltipMessage,
                  child: const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 5.0),
                      child: Icon(Icons.info_outline, size: 16)),
                ),
              ],
            ),
            ConstrainedBox(
              constraints:
                  const BoxConstraints.tightFor(width: widthConstraint),
              // Tapping within the a component card should request focus
              // for that component's children.
              child: Focus(
                focusNode: focusNode,
                canRequestFocus: true,
                child: GestureDetector(
                  onTapDown: (_) {
                    focusNode.requestFocus();
                  },
                  behavior: HitTestBehavior.opaque,
                  child: Card(
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      side: BorderSide(
                        color: Theme.of(context).colorScheme.outlineVariant,
                      ),
                      borderRadius: const BorderRadius.all(Radius.circular(12)),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 5.0, vertical: 20.0),
                      child: Center(
                        child: widget.child,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ComponentGroupDecoration extends StatelessWidget {
  const ComponentGroupDecoration(
      {super.key, required this.label, required this.children});

  final String label;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    // Fully traverse this component group before moving on
    return FocusTraversalGroup(
      child: Card(
        margin: EdgeInsets.zero,
        elevation: 0,
        color: Theme.of(context)
            .colorScheme
            .surfaceContainerHighest
            .withOpacity(0.3),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 20.0),
          child: Center(
            child: Column(
              children: [
                Text(label, style: Theme.of(context).textTheme.titleLarge),
                colDivider,
                ...children
              ],
            ),
          ),
        ),
      ),
    );
  }
}
