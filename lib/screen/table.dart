import 'dart:math';

import 'package:clipboard/clipboard.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:realm/realm.dart';
import 'package:yaml/yaml.dart';

import '../constants.dart';
import '../main.dart';
import '../notes.dart';
import 'input_screen.dart';

class KeyboardManager extends ChangeNotifier {
  double keyboardHeight = 0.0;

  void updateHeight(double height) {
    keyboardHeight = height;
    notifyListeners();
  }
}

String mapToyaml(Map map) {
  String yaml = '';
  for (var i = 0; i < map.length; i++) {
    yaml = yaml + '${map.keys.elementAt(i)}: ${map.values.elementAt(i)}\n';
  }
  return yaml;
}

creatRecordClass() {
  late RealmResults<Notes> tableNotesList, tableTemplate;
  tableTemplate = realm.query<Notes>(
      "noteType == \$0 AND noteProject == \$1 AND noteIsDeleted != true SORT(id DESC) LIMIT(1)",
      [
        '.表头',
        '~跑步',
      ]);
  tableNotesList = realm.query<Notes>(
      "noteType == \$0 AND noteProject == \$1 AND noteIsDeleted != true SORT(id DESC)",
      [
        '.记录',
        '~跑步',
      ]);
  List<dynamic> recordList = [];
  Map template = loadYaml(tableTemplate.toList()[0].noteContext) as YamlMap;
  if (tableNotesList.isNotEmpty) {
    for (var i = 0; i < tableNotesList.length; i++) {
      recordList
          .add(loadYaml(tableNotesList.toList()[i].noteContext) as YamlMap);
    }
  }
  recordList.sort((a, b) => a['序号'].compareTo(b['序号']));
  print(tableTemplate.toList()[0].noteContext);
  print(
      tableTemplate.toList()[0].noteContext.replaceAll(RegExp(r': .*'), ': '));
}

class RecordChangePage extends StatefulWidget {
  RecordChangePage({
    Key? key,
    required this.onPageClosed,
    required this.note,
    required this.mod,
  }) : super(key: key);
  final VoidCallback onPageClosed;
  final Notes note;
  final int mod;
  List<String> typeList = ['新建', '清空'];
  List<String> folderList = ['新建', '清空'];
  List<String> projectList = ['新建', '清空'];
  List<String> finishStateList = [
    '未完',
    '已完',
  ];

  @override
  RecordChangePageState createState() => RecordChangePageState();
}

class RecordChangePageState extends State<RecordChangePage> {
  TextEditingController titleController = TextEditingController();
  TextEditingController contentController = TextEditingController();
  List<TextEditingController> propertyControllerList = [];
  TextEditingController otherController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  late final Notes templateNote;
  Map template = {};
  Map record = {};

  // late QuillController _controller;

  var wordCount1 = 0;
  var wordCount2 = 0;
  FocusNode focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    focusNode.requestFocus();
    titleController.text = widget.note.noteTitle;
    contentController.text = widget.note.noteContext;

    wordCount1 = titleController.text.length;
    wordCount2 = contentController.text.length;
    final KeyboardManager keyboardManager = KeyboardManager();
    focusNode.addListener(() {
      keyboardManager.updateHeight(MediaQuery.of(context).viewInsets.bottom);
    });
    List<Notes> typeDistinctList =
        realm.query<Notes>("noteType !='' DISTINCT(noteType)").toList();

    for (int i = 0; i < typeDistinctList.length; i++) {
      widget.typeList.add(typeDistinctList[i].noteType);
    }
    List<Notes> folderDistinctList =
        realm.query<Notes>("noteFolder !='' DISTINCT(noteFolder)").toList();

    for (int i = 0; i < folderDistinctList.length; i++) {
      widget.folderList.add(folderDistinctList[i].noteFolder);
    }
    List<Notes> projectDistinctList =
        realm.query<Notes>("noteProject !='' DISTINCT(noteProject)").toList();

    for (int i = 0; i < projectDistinctList.length; i++) {
      widget.projectList.add(projectDistinctList[i].noteProject);
    }
    List<Notes> finishStateDistinctList = realm
        .query<Notes>("noteFinishState !='' DISTINCT(noteFinishState)")
        .toList();

    for (int i = 0; i < finishStateDistinctList.length; i++) {
      if ((finishStateDistinctList[i].noteFinishState != '未完') &&
          (finishStateDistinctList[i].noteFinishState != '已完')) {
        widget.finishStateList.add(finishStateDistinctList[i].noteFinishState);
      }
    }
    widget.finishStateList.add('新建');
    templateNote = realm.query<Notes>(
        "noteType == \$0 AND noteProject == \$1 AND noteIsDeleted != true SORT(id DESC) LIMIT(1)",
        [
          '.表头',
          '~跑步',
        ])[0];
    template = loadYaml(templateNote.noteContext) as YamlMap;
    realm.write(() {
      if (widget.note.noteContext == '') {
        widget.note.noteContext =
            templateNote.noteContext.replaceAll(RegExp(r': .*'), ': ');
      }
    });
    record =
        Map.fromEntries((loadYaml(widget.note.noteContext) as YamlMap).entries);
    for (var i = 0; i < template.length; i++) {
      propertyControllerList.add(TextEditingController());
      propertyControllerList[i].text =
          record[template.keys.elementAt(i)] == null
              ? ''
              : record[template.keys.elementAt(i)].toString();
    }
  }

  save() {}

  @override
  void dispose() {
    titleController.clear();
    contentController.clear();
    focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () {
        widget.onPageClosed;
        return Future.value(true);
      },
      child: Scaffold(
        resizeToAvoidBottomInset: true,
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () {
              Navigator.pop(context);
              widget.onPageClosed();
            },
          ),
          title: const Text(""),
          actions: const [],
        ),
        body: Stack(
          children: [
            Column(
              mainAxisSize: MainAxisSize.max,
              children: [
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 25, // 左右间距
                        vertical: 0 // 上下间距
                        ),
                    child: Column(
                      children: [
                        TextField(
                          textAlign: TextAlign.center,
                          controller: titleController,
                          style: const TextStyle(
                            fontSize: 22,
                          ),
                          decoration: const InputDecoration(
                              labelText: "标题",
                              labelStyle: TextStyle(
                                color: Colors.grey,
                              )
                              // border: OutlineInputBorder(),
                              // focusedBorder:
                              //     OutlineInputBorder(borderSide: BorderSide(color: Colors.red)),
                              // enabledBorder: OutlineInputBorder(
                              //     borderSide: BorderSide(color: Colors.blue)),
                              ),
                          onChanged: (value) {
                            setState(() {
                              wordCount1 = value.length;
                            });
                          },
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Text('${wordCount1 + wordCount2}字符'),
                          ],
                        ),
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
                                    widget.note.noteType == ''
                                        ? '类型'
                                        : widget.note.noteType,
                                    style: widget.note.noteType == ''
                                        ? const TextStyle(color: Colors.grey)
                                        : const TextStyle(
                                            color: Color.fromARGB(
                                                255, 56, 128, 186)),
                                  ),
                                );
                              },
                              menuChildren: widget.typeList.map((type) {
                                return MenuItemButton(
                                  child: Text(type),
                                  onPressed: () {
                                    switch (type) {
                                      case '清空':
                                        setState(() {
                                          realm.write(() {
                                            widget.note.noteType = '';
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
                                                  if (!text.startsWith('.')) {
                                                    text = '.$text';
                                                  }
                                                  widget.typeList.add(text);
                                                  realm.write(() {
                                                    widget.note.noteType = text;
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
                                            widget.note.noteType = type;
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
                                  child: Text(project),
                                  onPressed: () {
                                    switch (project) {
                                      case '清空':
                                        setState(() {
                                          realm.write(() {
                                            widget.note.noteProject = '';
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
                                                  widget.projectList.add(text);
                                                  realm.write(() {
                                                    widget.note.noteProject =
                                                        text;
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
                                  child: Text(folder),
                                  onPressed: () {
                                    switch (folder) {
                                      case '清空':
                                        setState(() {
                                          realm.write(() {
                                            widget.note.noteFolder = '';
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
                                          });
                                        });
                                    }
                                  },
                                );
                              }).toList(),
                            ),
                          ],
                        ),
                        ListView.builder(
                          controller: _scrollController,
                          itemCount: template.length,
                          shrinkWrap: true,
                          padding: const EdgeInsets.all(0),
                          itemBuilder: (context, index) {
                            List propertySettings =
                                template.values.elementAt(index).split(',');
                            return Card(
                              child: ListTile(
                                horizontalTitleGap: 0,
                                minVerticalPadding: 0,
                                title: Row(
                                  children: [
                                    Expanded(
                                      flex: 2,
                                      child: Text(
                                        template.keys.elementAt(index) + '：',
                                        textAlign: TextAlign.center,
                                        style: const TextStyle(),
                                      ),
                                    ),
                                    Expanded(
                                      flex: 1,
                                      child: Text(
                                        propertySettings[1],
                                        textAlign: TextAlign.right,
                                        style: const TextStyle(),
                                      ),
                                    ),
                                    Expanded(
                                      flex: 6,
                                      child: Padding(
                                        padding: const EdgeInsets.only(
                                            top: 0,
                                            bottom: 0,
                                            left: 5,
                                            right: 5),
                                        child: SizedBox(
                                          height: 45,
                                          child: TextField(
                                            textAlign: TextAlign.center,
                                            style: const TextStyle(
                                              fontSize: 18,
                                              height: 1,
                                              fontWeight: FontWeight.w600,
                                            ),
                                            controller:
                                                propertyControllerList[index],
                                            decoration: InputDecoration(
                                              border:
                                                  const UnderlineInputBorder(),
                                              contentPadding:
                                                  const EdgeInsets.fromLTRB(
                                                      10, 0, 10, 0),
                                              // prefixIcon: Text(
                                              //   propertySettings[1],
                                              // ),
                                              // suffixIcon: Text(
                                              //   propertySettings[2],
                                              // ),
                                            ),
                                            maxLines:
                                                propertySettings[0] == 'Text'
                                                    ? 1
                                                    : null,
                                            minLines:
                                                propertySettings[0] == 'Text'
                                                    ? 1
                                                    : 1,
                                            onChanged: (value) {
                                              record[template.keys
                                                  .elementAt(index)] = value;
                                              realm.write(() {
                                                widget.note.noteContext =
                                                    mapToyaml(record);
                                              });
                                              setState(() {
                                                wordCount2 = value.length;
                                              });
                                            },
                                          ),
                                        ),
                                      ),
                                    ),
                                    Expanded(
                                      flex: 1,
                                      child: Text(
                                        propertySettings[2],
                                        textAlign: TextAlign.left,
                                        style: const TextStyle(),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ],
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
                      onPressed: () async {
                        await FlutterClipboard.copy(contentController.text);
                        poplog(1, '复制', context);
                      },
                      child: const Text('复制'),
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
}
