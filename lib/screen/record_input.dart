// ignore_for_file: avoid_function_literals_in_foreach_calls

import 'dart:math';

import 'package:clipboard/clipboard.dart';
import 'package:flutter/material.dart';
import 'package:flutter_pickers/time_picker/model/date_mode.dart';
import 'package:flutter_pickers/time_picker/model/suffix.dart';
import 'package:icebergnote/screen/noteslist_screen.dart';
import 'package:yaml/yaml.dart';
import '../constants.dart';
import '../main.dart';
import '../notes.dart';
import 'input_screen.dart';
import 'package:flutter_rounded_date_picker/flutter_rounded_date_picker.dart';
import 'package:flutter_pickers/pickers.dart';
import 'package:flutter_pickers/time_picker/model/pduration.dart';

EdgeInsets edgeInsets = const EdgeInsets.fromLTRB(0, 0, 0, 0);
TextStyle textStyle =
    const TextStyle(overflow: TextOverflow.fade, fontSize: 14);

class KeyboardManager extends ChangeNotifier {
  double keyboardHeight = 0.0;

  void updateHeight(double height) {
    keyboardHeight = height;
    notifyListeners();
  }
}

List templateTypeList = ['数字', '文本', '单选', '多选', '时间', '日期', '长文', '时长'];

String mapToyaml(Map map) {
  String yaml = '';
  for (var i = 0; i < map.length; i++) {
    yaml = '$yaml${map.keys.elementAt(i)}: ${map.values.elementAt(i)}\n';
  }
  return yaml;
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
  final List<String> typeList = ['新建', '清空'];
  final List<String> folderList = ['新建', '清空'];
  final List<String> projectList = ['新建', '清空'];
  final List<String> finishStateList = [
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
  Map templateProperty = {};
  Map record = {};
  FocusNode focusNode = FocusNode();
  @override
  void initState() {
    super.initState();
    focusNode.requestFocus();
    titleController.text = widget.note.noteTitle;
    contentController.text = widget.note.noteContext;

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
    templateNote = realm.query<Notes>(
        "noteType == \$0 AND noteProject == \$1 AND noteIsDeleted != true SORT(noteCreateDate DESC) LIMIT(1)",
        [
          '.表单',
          widget.note.noteProject,
        ])[0];
    template = loadYaml(templateNote.noteContext
        .substring(0, templateNote.noteContext.indexOf('settings'))) as YamlMap;
    templateProperty = loadYaml(templateNote.noteContext
        .substring(templateNote.noteContext.indexOf('settings'))) as YamlMap;

    realm.write(() {
      if (widget.note.noteContext == '') {
        widget.note.noteContext =
            templateNote.noteContext.replaceAll(RegExp(r': .*'), ': ');
      }
    });
    record =
        Map.fromEntries((loadYaml(widget.note.noteContext) as YamlMap).entries);

    var keys = record.keys.toList();
    keys.forEach((key) {
      if (!template.containsKey(key)) {
        record.remove(key);
      }
    });
    keys = template.keys.toList();
    keys.forEach((key) {
      if (!record.containsKey(key)) {
        record[key] = null;
      }
    });
    List templateKeys = template.keys.toList();
    Map sortedRecord = {};

    for (int key in templateKeys) {
      if (record.containsKey(key)) {
        sortedRecord[key] = record[key];
      }
    }

    record = sortedRecord;
    realm.write(() {
      widget.note.noteContext = mapToyaml(record);
      widget.note.noteUpdateDate = DateTime.now().toUtc();
    });
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
    return PopScope(
      onPopInvoked: (a) {
        widget.onPageClosed;
      },
      child: Scaffold(
        resizeToAvoidBottomInset: true,
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () {
              save();
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
                          onChanged: (value) {},
                        ),
                        const SizedBox(
                          height: 5,
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
                                  style: menuChildrenButtonStyle,
                                  child: Text(type),
                                  onPressed: () {
                                    switch (type) {
                                      case '清空':
                                        setState(() {
                                          realm.write(() {
                                            widget.note.noteType = '';
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
                                                  if (!text.startsWith('.')) {
                                                    text = '.$text';
                                                  }
                                                  widget.typeList.add(text);
                                                  realm.write(() {
                                                    widget.note.noteType = text;
                                                    widget.note.noteUpdateDate =
                                                        DateTime.now().toUtc();
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
                                                  widget.projectList.add(text);
                                                  realm.write(() {
                                                    widget.note.noteProject =
                                                        text;
                                                    widget.note.noteUpdateDate =
                                                        DateTime.now().toUtc();
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
                                                    widget.note.noteUpdateDate =
                                                        DateTime.now().toUtc();
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
                        Expanded(
                          child: ListView.builder(
                            controller: _scrollController,
                            itemCount: template.length,
                            shrinkWrap: true,
                            padding: const EdgeInsets.all(0),
                            itemBuilder: (context, index) {
                              return PropertyCard(
                                note: widget.note,
                                templateNote: templateNote,
                                templateProperty: templateProperty,
                                index: index,
                                record: record,
                                mod: widget.mod,
                              );
                            },
                          ),
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
                    // TextButton(
                    //   onPressed: () {
                    //     FlutterClipboard.copy(contentController.text);
                    //     poplog(1, '复制', context);
                    //   },
                    //   child: const Text('复制'),
                    // ),
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

class PropertyCard extends StatefulWidget {
  final Notes note;
  final Notes templateNote;
  final Map templateProperty;
  final int index;
  final Map record;
  final int mod;

  const PropertyCard({
    super.key,
    required this.note,
    required this.templateNote,
    required this.templateProperty,
    required this.index,
    required this.record,
    required this.mod,
  });

  @override
  State<StatefulWidget> createState() => _PropertyCardState();
}

class _PropertyCardState extends State<PropertyCard> {
  late List propertySettings;
  Map template = {};
  TextEditingController contentController = TextEditingController();
  EdgeInsets edgeInsets = const EdgeInsets.fromLTRB(5, 5, 5, 5);
  TextStyle textStyle = const TextStyle(
    overflow: TextOverflow.fade,
    fontSize: 14,
  );
  TextStyle errtextStyle = const TextStyle(
    overflow: TextOverflow.fade,
    fontSize: 14,
    color: Colors.red,
  );
  late Color backgroundColor;
  late Color fontColor;
  String error = '';
  @override
  Widget build(BuildContext context) {
    return buildCard();
  }

  @override
  void initState() {
    super.initState();
    template = loadYaml(widget.templateNote.noteContext.substring(
        0, widget.templateNote.noteContext.indexOf('settings'))) as YamlMap;
    propertySettings = template.values.elementAt(widget.index).split(",");
    contentController.text = widget
        .record[template.keys.elementAt(widget.index)]
        .toString()
        .replaceAll('    ', '\n');
    if (contentController.text == 'null') {
      contentController.text = '';
    }
    backgroundColor = Color.fromARGB(
      40,
      widget.templateProperty['color'][0],
      widget.templateProperty['color'][1],
      widget.templateProperty['color'][2],
    );
    fontColor = Color.fromARGB(
      255,
      max(0, min(widget.templateProperty['color'][0] - 50, 255)),
      max(0, min(widget.templateProperty['color'][1] - 50, 255)),
      max(0, min(widget.templateProperty['color'][2] - 50, 255)),
    );
  }

  Widget buildCard() {
    switch (propertySettings[1]) {
      case '数字':
        return buildNumberCard();
      case '单选':
        return buildSingleSelectCard();
      case '长文':
        return buildLongTextCard();
      case '日期':
        return buildDateCard();
      case '时间':
        return buildTimeCard();
      case '时长':
        return buildDurationCard();
      case '多选':
        return buildMultiSelectCard();
      default:
        return buildTextCard();
    }
  }

  Widget buildNumberCard() {
    if (widget.record[template.keys.elementAt(widget.index)] == null &&
        widget.mod == 0) {
      if (num.tryParse(propertySettings.last) != null) {
        widget.record[template.keys.elementAt(widget.index)] =
            num.tryParse(propertySettings.last);

        contentController.text =
            propertySettings.last == null && propertySettings.last == 'null'
                ? ''
                : propertySettings.last.toString();

        // } else if (double.tryParse(propertySettings.last) != null) {
        //   widget.record[template.keys.elementAt(widget.index)] =
        //       double.tryParse(propertySettings.last);
      } else if (propertySettings.last == '上次') {
        var searchResult = realm.query<Notes>(
            " noteProject == \$0 AND noteType == '.记录' AND noteIsDeleted != true SORT(noteCreateDate DESC) LIMIT(2)",
            [widget.note.noteProject]);
        if (searchResult.length > 1) {
          if (checkNoteFormat(searchResult[1])) {
            var lastNoteMap = loadYaml(searchResult[1].noteContext) as YamlMap;
            if (lastNoteMap[template.keys.elementAt(widget.index)] != null) {
              contentController.text =
                  lastNoteMap[template.keys.elementAt(widget.index)].toString();
              widget.record[template.keys.elementAt(widget.index)] =
                  lastNoteMap[template.keys.elementAt(widget.index)];
            }
          }
        }
      } else if (propertySettings.last == '递增') {
        var searchResult = realm.query<Notes>(
            " noteProject == \$0 AND noteType == '.记录' AND noteIsDeleted != true SORT(noteCreateDate DESC) LIMIT(2)",
            [widget.note.noteProject]);
        if (searchResult.length > 1) {
          if (checkNoteFormat(searchResult[1])) {
            var lastNoteMap = loadYaml(searchResult[1].noteContext) as YamlMap;

            if (lastNoteMap[template.keys.elementAt(widget.index)]
                        .runtimeType ==
                    int ||
                lastNoteMap[template.keys.elementAt(widget.index)]
                        .runtimeType ==
                    double) {
              var number =
                  lastNoteMap[template.keys.elementAt(widget.index)] + 1;
              contentController.text = number.toString();
              widget.record[template.keys.elementAt(widget.index)] = number;
            }
          }
        }
      }
      if (num.tryParse(contentController.text) == null) {
        error = '请输入数字';
      }
      realm.write(() {
        widget.note.noteContext = mapToyaml(widget.record);
        widget.note.noteUpdateDate = DateTime.now().toUtc();
      });
    }
    return Card(
      elevation: 0,
      color: Color.fromARGB(
          50,
          widget.templateProperty['color'][0],
          widget.templateProperty['color'][1],
          widget.templateProperty['color'][2]),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Text(
              propertySettings[0] + ':',
              textAlign: TextAlign.center,
              style: textStyle,
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              propertySettings[2] ?? '',
              textAlign: TextAlign.right,
              style: textStyle,
            ),
          ),
          Expanded(
            flex: 6,
            child: Padding(
              padding: edgeInsets,
              child: Container(
                constraints: const BoxConstraints(
                  minHeight: 30,
                ),
                alignment: Alignment.center,
                color: Colors.white,
                child: TextField(
                  textAlign: TextAlign.center,
                  style: error == '' ? textStyle : errtextStyle,
                  controller: contentController,
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    isCollapsed: true,
                    contentPadding: edgeInsets,
                  ),
                  keyboardType: TextInputType.number,
                  maxLines: 1,
                  minLines: 1,
                  onChanged: (value) {
                    if (num.tryParse(value) != null) {
                      widget.record[template.keys.elementAt(widget.index)] =
                          value;
                      realm.write(() {
                        widget.note.noteContext = mapToyaml(widget.record);
                        widget.note.noteUpdateDate = DateTime.now().toUtc();
                      });
                      setState(() {
                        error = '';
                      });
                    } else {
                      widget.record[template.keys.elementAt(widget.index)] =
                          value;
                      realm.write(() {
                        widget.note.noteContext = mapToyaml(widget.record);
                        widget.note.noteUpdateDate = DateTime.now().toUtc();
                      });
                      setState(() {
                        error = '请输入数字';
                      });
                    }
                  },
                ),
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              propertySettings[3] ?? '',
              textAlign: TextAlign.left,
              style: textStyle,
            ),
          ),
        ],
      ),
    );
  }

  Widget buildLongTextCard() {
    if (widget.record[template.keys.elementAt(widget.index)] == null &&
        widget.mod == 0) {
      widget.record[template.keys.elementAt(widget.index)] =
          propertySettings.last.toString();
      realm.write(() {
        widget.note.noteContext = mapToyaml(widget.record);
        widget.note.noteUpdateDate = DateTime.now().toUtc();
      });
      contentController.text =
          propertySettings.last.toString().replaceAll('    ', '\n');
    }
    return Card(
      elevation: 0,
      color: Color.fromARGB(
          50,
          widget.templateProperty['color'][0],
          widget.templateProperty['color'][1],
          widget.templateProperty['color'][2]),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Text(
              propertySettings[0] + ':',
              textAlign: TextAlign.center,
              style: textStyle,
            ),
          ),
          Expanded(
            flex: 10,
            child: Padding(
              padding: edgeInsets,
              child: Container(
                constraints: const BoxConstraints(
                  minHeight: 30,
                ),
                color: Colors.white,
                child: TextField(
                  keyboardType: TextInputType.multiline,
                  textAlign: TextAlign.start,
                  style: textStyle,
                  controller: contentController,
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    isCollapsed: true,
                    contentPadding: edgeInsets,
                  ),
                  maxLines: 10,
                  minLines: 5,
                  onChanged: (value) {
                    widget.record[template.keys.elementAt(widget.index)] =
                        value.replaceAll('\n', '    ').trim();
                    realm.write(() {
                      widget.note.noteContext = mapToyaml(widget.record);
                      widget.note.noteUpdateDate = DateTime.now().toUtc();
                    });
                  },
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildTextCard() {
    if (widget.record[template.keys.elementAt(widget.index)] == null &&
        widget.mod == 0) {
      widget.record[template.keys.elementAt(widget.index)] =
          propertySettings.last.toString();
      realm.write(() {
        widget.note.noteContext = mapToyaml(widget.record);
        widget.note.noteUpdateDate = DateTime.now().toUtc();
      });
      contentController.text = propertySettings.last.toString();
    }
    return Card(
      elevation: 0,
      color: Color.fromARGB(
          50,
          widget.templateProperty['color'][0],
          widget.templateProperty['color'][1],
          widget.templateProperty['color'][2]),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Text(
              propertySettings[0] + ':',
              textAlign: TextAlign.center,
              style: textStyle,
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              propertySettings[2] ?? '',
              textAlign: TextAlign.right,
              style: textStyle,
            ),
          ),
          Expanded(
            flex: 6,
            child: Padding(
              padding: edgeInsets,
              child: Container(
                alignment: Alignment.center,
                color: Colors.white,
                child: TextField(
                  keyboardType: TextInputType.text,
                  textAlign: TextAlign.center,
                  style: textStyle,
                  controller: contentController,
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    isCollapsed: true,
                    contentPadding: edgeInsets,
                  ),
                  maxLines: 2,
                  minLines: 1,
                  onChanged: (value) {
                    widget.record[template.keys.elementAt(widget.index)] =
                        value;
                    realm.write(() {
                      widget.note.noteContext = mapToyaml(widget.record);
                      widget.note.noteUpdateDate = DateTime.now().toUtc();
                    });
                  },
                ),
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              propertySettings[3] ?? '',
              textAlign: TextAlign.left,
              style: textStyle,
            ),
          ),
        ],
      ),
    );
  }

  Widget buildMultiSelectCard() {
    List<String> selectList = propertySettings.last.split("||");
    List<String> currentList = widget
        .record[template.keys.elementAt(widget.index)]
        .toString()
        .split(", ");
    if (widget.record[template.keys.elementAt(widget.index)] == null &&
        widget.mod == 0) {
      currentList[0] = selectList[0];
      widget.record[template.keys.elementAt(widget.index)] =
          currentList.join(', ');
      realm.write(() {
        widget.note.noteContext = mapToyaml(widget.record);
        widget.note.noteUpdateDate = DateTime.now().toUtc();
      });
    }

    selectList.removeWhere((element) => element == 'null' || element == '');
    currentList.removeWhere((element) => element == 'null' || element == '');
    return Card(
      elevation: 0,
      color: Color.fromARGB(
          50,
          widget.templateProperty['color'][0],
          widget.templateProperty['color'][1],
          widget.templateProperty['color'][2]),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Text(
              propertySettings[0] + ':',
              textAlign: TextAlign.center,
              style: textStyle,
            ),
          ),
          // Expanded(
          //   flex: 2,
          //   child: Text(
          //     propertySettings[2] ?? '',
          //     textAlign: TextAlign.right,
          //     style: textStyle,
          //   ),
          // ),
          Expanded(
            flex: 10,
            child: Padding(
              padding: edgeInsets,
              child: GestureDetector(
                child: Container(
                  constraints: const BoxConstraints(
                    minHeight: 30,
                  ),
                  alignment: Alignment.center,
                  child: currentList.isEmpty
                      ? Icon(
                          Icons.add,
                          size: 20,
                          color: fontColor,
                        )
                      : Wrap(
                          alignment: WrapAlignment.start,
                          crossAxisAlignment: WrapCrossAlignment.start,
                          spacing: 5,
                          runSpacing: 5,
                          children: List.generate(currentList.length, (index) {
                            return Container(
                              margin: const EdgeInsets.all(0),
                              padding: const EdgeInsets.fromLTRB(5, 0, 5, 0),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(20),
                                color: fontColor,
                              ),
                              child: Text(
                                currentList[index],
                                style: const TextStyle(
                                  fontFamily: 'LXGWWenKai',
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white,
                                ),
                              ),
                            );
                          }),
                        ),
                ),
                onTap: () {
                  showDialog(
                    context: context,
                    builder: (ctx) {
                      return InputSelectAlertDialog(
                        onSubmitted: (text) {
                          setState(() {
                            widget.record[
                                template.keys.elementAt(widget.index)] = text;
                            realm.write(() {
                              widget.note.noteContext =
                                  mapToyaml(widget.record);
                              widget.note.noteUpdateDate =
                                  DateTime.now().toUtc();
                            });
                          });
                          List testList = (text.split(', '));
                          List newList =
                              (propertySettings.last.toString().split('||'));
                          for (int i = 0; i < testList.length; i++) {
                            if (!newList.contains(testList[i])) {
                              realm.write(() {
                                widget.templateNote.noteContext =
                                    widget.templateNote.noteContext.replaceAll(
                                        propertySettings.join(','),
                                        '${propertySettings.join(',')}||${testList[i]}');
                                widget.templateNote.noteUpdateDate =
                                    DateTime.now().toUtc();
                              });
                            }
                          }
                        },
                        currentList: currentList,
                        selectList: selectList,
                        fontColor: fontColor,
                        isMultiSelect: true,
                        backgroundColor: backgroundColor,
                      );
                    },
                  );
                },
              ),
            ),
          ),
          // Expanded(
          //   flex: 2,
          //   child: Text(
          //     propertySettings[3] ?? '',
          //     textAlign: TextAlign.left,
          //     style: textStyle,
          //   ),
          // ),
        ],
      ),
    );
  }

  Widget buildSingleSelectCard() {
    List<String> selectList = propertySettings.last.toString().split("||");
    List<String> currentList = widget
        .record[template.keys.elementAt(widget.index)]
        .toString()
        .split(", ");
    print(widget.mod);
    if (widget.record[template.keys.elementAt(widget.index)] == null &&
        widget.mod == 0) {
      currentList[0] = selectList[0];
      widget.record[template.keys.elementAt(widget.index)] =
          currentList.join(', ');
      realm.write(() {
        widget.note.noteContext = mapToyaml(widget.record);
        widget.note.noteUpdateDate = DateTime.now().toUtc();
      });
      print(currentList[0]);
    }
    print(3);
    selectList.removeWhere((element) => element == 'null' || element == '');
    currentList.removeWhere((element) => element == 'null' || element == '');
    return Card(
      elevation: 0,
      color: Color.fromARGB(
          50,
          widget.templateProperty['color'][0],
          widget.templateProperty['color'][1],
          widget.templateProperty['color'][2]),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Text(
              propertySettings[0] + ':',
              textAlign: TextAlign.center,
              style: textStyle,
            ),
          ),
          // Expanded(
          //   flex: 2,
          //   child: Text(
          //     propertySettings[2] ?? '',
          //     textAlign: TextAlign.right,
          //     style: textStyle,
          //   ),
          // ),
          Expanded(
            flex: 10,
            child: Padding(
              padding: edgeInsets,
              child: GestureDetector(
                child: Container(
                  constraints: const BoxConstraints(
                    minHeight: 30,
                  ),
                  alignment: Alignment.center,
                  child: currentList.isEmpty
                      ? Icon(
                          Icons.add,
                          size: 20,
                          color: fontColor,
                        )
                      : Wrap(
                          alignment: WrapAlignment.start,
                          crossAxisAlignment: WrapCrossAlignment.start,
                          spacing: 5,
                          runSpacing: 5,
                          children: List.generate(currentList.length, (index) {
                            return Container(
                              margin: const EdgeInsets.all(0),
                              padding: const EdgeInsets.fromLTRB(5, 0, 5, 0),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(20),
                                color: fontColor,
                              ),
                              child: Text(
                                currentList[index],
                                style: const TextStyle(
                                  fontFamily: 'LXGWWenKai',
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white,
                                ),
                              ),
                            );
                          }),
                        ),
                ),
                onTap: () {
                  showDialog(
                    context: context,
                    builder: (ctx) {
                      return InputSelectAlertDialog(
                        onSubmitted: (text) {
                          setState(() {
                            widget.record[
                                template.keys.elementAt(widget.index)] = text;
                            realm.write(() {
                              widget.note.noteContext =
                                  mapToyaml(widget.record);
                              widget.note.noteUpdateDate =
                                  DateTime.now().toUtc();
                            });
                          });
                          List testList = (text.split(', '));
                          List newList =
                              (propertySettings.last.toString().split('||'));
                          for (int i = 0; i < testList.length; i++) {
                            if (!newList.contains(testList[i])) {
                              realm.write(() {
                                widget.templateNote.noteContext =
                                    widget.templateNote.noteContext.replaceAll(
                                        propertySettings.join(','),
                                        '${propertySettings.join(',')}||${testList[i]}');
                                widget.templateNote.noteUpdateDate =
                                    DateTime.now().toUtc();
                              });
                            }
                          }
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
              ),
            ),
          ),
          // Expanded(
          //   flex: 2,
          //   child: Text(
          //     propertySettings[3] ?? '',
          //     textAlign: TextAlign.left,
          //     style: textStyle,
          //   ),
          // ),
        ],
      ),
    );
  }

  Widget buildDateCard() {
    DateTime? tmpDate;
    if (widget.record[template.keys.elementAt(widget.index)] != null) {
      tmpDate = DateTime.tryParse(
          widget.record[template.keys.elementAt(widget.index)].toString());
    } else {
      tmpDate = null;
    }
    DateTime setDay = DateTime.now();
    bool dateError = false;
    if (widget.record[template.keys.elementAt(widget.index)] == null &&
        widget.mod == 0) {
      DateTime now = DateTime.now();

      switch (propertySettings.last.toString()) {
        case '今日':
        case '今天':
          break;
        case '昨日':
        case '昨天':
          setDay = now.subtract(const Duration(days: 1));
          break;
        case '明日':
        case '明天':
          setDay = now.add(const Duration(days: 1));
          break;
        case '后日':
        case '后天':
          setDay = now.subtract(const Duration(days: 2));
          break;
        case '前日':
        case '前天':
          setDay = now.add(const Duration(days: 2));
          break;
        case '周一':
          setDay = now.subtract(Duration(days: now.weekday - 1));
          break;
        case '周二':
          setDay = now.subtract(Duration(days: now.weekday - 2));
          break;
        case '周三':
          setDay = now.subtract(Duration(days: now.weekday - 3));
          break;
        case '周四':
          setDay = now.subtract(Duration(days: now.weekday - 4));
          break;
        case '周五':
          setDay = now.subtract(Duration(days: now.weekday - 5));
          break;
        case '周六':
          setDay = now.subtract(Duration(days: now.weekday - 6));
          break;
        case '周日':
          setDay = now.subtract(Duration(days: now.weekday - 7));
          break;
        case '月初':
          setDay = DateTime(now.year, now.month, 1);
          break;
        case '月末':
          setDay = DateTime(now.year, now.month + 1, 1)
              .subtract(const Duration(days: 1));
          break;
        case '季初':
          int quarter = ((now.month - 1) ~/ 3) + 1;
          if (quarter == 1) {
            setDay = DateTime(now.year, 1, 1);
          } else if (quarter == 2) {
            setDay = DateTime(now.year, 4, 1);
          } else if (quarter == 3) {
            setDay = DateTime(now.year, 7, 1);
          } else {
            setDay = DateTime(now.year, 10, 1);
          }
          break;
        case '季末':
          int quarter = ((now.month - 1) ~/ 3) + 1;
          if (quarter == 1) {
            setDay = DateTime(now.year, 3, 31);
          } else if (quarter == 2) {
            setDay = DateTime(now.year, 6, 30);
          } else if (quarter == 3) {
            setDay = DateTime(now.year, 9, 30);
          } else {
            setDay = DateTime(now.year, 12, 31);
          }
          break;
        case '年初':
          setDay = DateTime(now.year, 1, 1);
          break;
        case '年末':
          setDay = DateTime(now.year, 12, 31);
          break;
      }
      if (propertySettings.last.toString() != '') {
        String m = setDay.month.toString();
        String d = setDay.day.toString();
        if (setDay.month < 10) m = '0$m';
        if (setDay.day < 10) d = '0$d';
        widget.record[template.keys.elementAt(widget.index)] =
            '${setDay.year}-$m-$d';
        realm.write(() {
          widget.note.noteContext = mapToyaml(widget.record);
          widget.note.noteUpdateDate = DateTime.now().toUtc();
        });
      }
    } else if (tmpDate != null) {
      setDay = tmpDate;
    } else {
      dateError = true;
    }
    return Card(
      elevation: 0,
      color: Color.fromARGB(
          50,
          widget.templateProperty['color'][0],
          widget.templateProperty['color'][1],
          widget.templateProperty['color'][2]),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Text(
              propertySettings[0] + ':',
              textAlign: TextAlign.center,
              style: textStyle,
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              propertySettings[2] ?? '',
              textAlign: TextAlign.right,
              style: textStyle,
            ),
          ),
          Expanded(
            flex: 6,
            child: Padding(
              padding: edgeInsets,
              child: Container(
                  constraints: const BoxConstraints(
                    minHeight: 30,
                  ),
                  color: Colors.white,
                  height: 30,
                  child: FilledButton.tonal(
                    style: selectedContextButtonStyle,
                    onPressed: () async {
                      DateTime? newDateTime = await showRoundedDatePicker(
                        initialDate: setDay,
                        height: 300,
                        context: context,
                        locale: const Locale("zh", "CN"),
                        theme: ThemeData(primarySwatch: Colors.lightBlue),
                      );
                      if (newDateTime != null) {
                        setState(() {
                          String m = newDateTime.month.toString();
                          String d = newDateTime.day.toString();
                          if (newDateTime.month < 10) m = '0$m';
                          if (newDateTime.day < 10) d = '0$d';
                          widget.record[template.keys.elementAt(widget.index)] =
                              '${newDateTime.year}-$m-$d';
                          realm.write(() {
                            widget.note.noteContext = mapToyaml(widget.record);
                            widget.note.noteUpdateDate = DateTime.now().toUtc();
                          });
                        });
                      }
                    },
                    child: Text(
                      widget.record[template.keys.elementAt(widget.index)] ==
                              null
                          ? ''
                          : widget.record[template.keys.elementAt(widget.index)]
                              .toString(),
                      style: dateError
                          ? const TextStyle(color: Colors.red)
                          : const TextStyle(color: Colors.black),
                    ),
                  )),
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              propertySettings[3] ?? '',
              textAlign: TextAlign.left,
              style: textStyle,
            ),
          ),
        ],
      ),
    );
  }

  Widget buildTimeCard() {
    List<int> timeList = [0, 0, 0];
    Duration? tmpDuration = stringToDuration(propertySettings.last);
    Duration? setDuration = stringToDuration(
        widget.record[template.keys.elementAt(widget.index)].toString());
    if (widget.record[template.keys.elementAt(widget.index)] == null &&
        widget.mod == 0) {
      if (propertySettings.last == '此刻') {
        DateTime now = DateTime.now();
        widget.record[template.keys.elementAt(widget.index)] =
            '${now.hour}:${now.minute}:${now.second}';
        timeList = [now.hour, now.minute, now.second];
      } else if (tmpDuration != null) {
        widget.record[template.keys.elementAt(widget.index)] =
            '${(tmpDuration.inHours)}:${(tmpDuration.inMinutes) % 60}:${(tmpDuration.inSeconds) % 60}';
        timeList = [
          tmpDuration.inHours,
          tmpDuration.inMinutes % 60,
          tmpDuration.inSeconds % 60
        ];
        setDuration = tmpDuration;
      } else {
        widget.record[template.keys.elementAt(widget.index)] = '';
      }
      realm.write(() {
        widget.note.noteContext = mapToyaml(widget.record);
        widget.note.noteUpdateDate = DateTime.now().toUtc();
      });
    } else if (setDuration != null) {
      timeList = [
        setDuration.inHours,
        setDuration.inMinutes % 60,
        setDuration.inSeconds % 60
      ];
    }
    return Card(
      elevation: 0,
      color: Color.fromARGB(
          50,
          widget.templateProperty['color'][0],
          widget.templateProperty['color'][1],
          widget.templateProperty['color'][2]),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Text(
              propertySettings[0] + ':',
              textAlign: TextAlign.center,
              style: textStyle,
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              propertySettings[2] ?? '',
              textAlign: TextAlign.right,
              style: textStyle,
            ),
          ),
          Expanded(
            flex: 6,
            child: Padding(
              padding: edgeInsets,
              child: Container(
                constraints: const BoxConstraints(
                  minHeight: 30,
                ),
                height: 30,
                color: Colors.white,
                child: FilledButton.tonal(
                  style: selectedContextButtonStyle,
                  onPressed: () {
                    Pickers.showDatePicker(
                      context,
                      mode: DateMode.HMS,
                      suffix: Suffix.normal(),
                      selectDate: PDuration(
                          hour: timeList[0],
                          minute: timeList[1],
                          second: timeList[2]),
                      onConfirm: (p) {
                        setState(() {
                          widget.record[template.keys.elementAt(widget.index)] =
                              '${p.hour}:${p.minute}:${p.second}';
                          realm.write(() {
                            widget.note.noteContext = mapToyaml(widget.record);
                            widget.note.noteUpdateDate = DateTime.now().toUtc();
                          });
                        });
                      },
                    );
                  },
                  child: Text(
                    setDuration == null
                        ? widget.record[
                                    template.keys.elementAt(widget.index)] ==
                                null
                            ? ''
                            : widget
                                .record[template.keys.elementAt(widget.index)]
                                .toString()
                        : '${timeList[0] == 0 ? '' : '${timeList[0]}时'}${timeList[1]}分${timeList[2] == 0 ? '' : '${timeList[2]}秒'}',
                    style: setDuration != null
                        ? const TextStyle(color: Colors.black)
                        : const TextStyle(color: Colors.red),
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              propertySettings[3] ?? '',
              textAlign: TextAlign.left,
              style: textStyle,
            ),
          ),
        ],
      ),
    );
  }

  Widget buildDurationCard() {
    Duration? duration = stringToDuration(
        widget.record[template.keys.elementAt(widget.index)].toString());
    if (widget.record[template.keys.elementAt(widget.index)] == null &&
        widget.mod == 0) {
      if (duration != null) {
        widget.record[template.keys.elementAt(widget.index)] =
            '${(duration.inHours)}:${(duration.inMinutes) % 60}:${(duration.inSeconds) % 60}';
      } else {
        widget.record[template.keys.elementAt(widget.index)] = '';
      }
      realm.write(() {
        widget.note.noteContext = mapToyaml(widget.record);
        widget.note.noteUpdateDate = DateTime.now().toUtc();
      });
    }
    return Card(
      elevation: 0,
      color: Color.fromARGB(
          50,
          widget.templateProperty['color'][0],
          widget.templateProperty['color'][1],
          widget.templateProperty['color'][2]),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Text(
              propertySettings[0] + ':',
              textAlign: TextAlign.center,
              style: textStyle,
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              propertySettings[2] ?? '',
              textAlign: TextAlign.right,
              style: textStyle,
            ),
          ),
          Expanded(
            flex: 6,
            child: Padding(
              padding: edgeInsets,
              child: Container(
                constraints: const BoxConstraints(
                  minHeight: 30,
                ),
                height: 30,
                color: Colors.white,
                child: FilledButton.tonal(
                  style: selectedContextButtonStyle,
                  onPressed: () {
                    Pickers.showDatePicker(
                      context,
                      mode: DateMode.HMS,
                      suffix: Suffix.normal(),
                      selectDate: widget
                                  .record[template.keys.elementAt(widget.index)]
                                  .toString() !=
                              'null'
                          ? PDuration(
                              second: duration == null
                                  ? 0
                                  : duration.inSeconds % 60,
                              hour: duration == null ? 0 : duration.inHours,
                              minute: duration == null
                                  ? 0
                                  : duration.inMinutes % 60)
                          : PDuration(),
                      onConfirm: (p) {
                        setState(() {
                          widget.record[template.keys.elementAt(widget.index)] =
                              '${p.hour}:${p.minute}:${p.second}';
                          realm.write(() {
                            widget.note.noteContext = mapToyaml(widget.record);
                            widget.note.noteUpdateDate = DateTime.now().toUtc();
                          });
                        });
                      },
                    );
                  },
                  child: Text(
                    duration == null
                        ? ''
                        : (duration.inDays == 0 ? '' : '${duration.inDays}天') +
                            (duration.inHours == 0
                                ? ''
                                : '${duration.inHours % 24}时') +
                            (duration.inMinutes == 0
                                ? ''
                                : '${duration.inMinutes % 60}分') +
                            (duration.inSeconds == 0
                                ? ''
                                : '${duration.inSeconds % 60}秒'),
                    style: const TextStyle(color: Colors.black),
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              propertySettings[3] ?? '',
              textAlign: TextAlign.left,
              style: textStyle,
            ),
          ),
        ],
      ),
    );
  }
}

Widget buildPropertyCard(
  Notes note,
  Map template,
  Map templateProperty,
  int index,
  List<TextEditingController> propertyControllerList,
  Map record,
  RecordChangePageState state,
) {
  List propertySettings = template.values.elementAt(index).split(",");
  EdgeInsets edgeInsets = const EdgeInsets.fromLTRB(0, 0, 0, 0);
  TextStyle textStyle =
      const TextStyle(overflow: TextOverflow.fade, fontSize: 14);
  String error = 'ree';
  switch (propertySettings[1]) {
    case '数字':
      return Card(
        elevation: 0,
        color: Color.fromARGB(50, templateProperty['color'][0],
            templateProperty['color'][1], templateProperty['color'][2]),
        child: Row(
          children: [
            Expanded(
              flex: 2,
              child: Text(
                template.keys.elementAt(index) + ':',
                textAlign: TextAlign.center,
                style: textStyle,
              ),
            ),
            Expanded(
              flex: 1,
              child: Text(
                propertySettings[2] ?? '',
                textAlign: TextAlign.right,
                style: textStyle,
              ),
            ),
            Expanded(
              flex: 6,
              child: Padding(
                padding: edgeInsets,
                child: SizedBox(
                  height: 45,
                  child: TextField(
                    textAlign: TextAlign.center,
                    style: textStyle,
                    controller: propertyControllerList[index],
                    decoration: InputDecoration(
                      border: const UnderlineInputBorder(),
                      errorText: error,
                      contentPadding: edgeInsets,
                    ),
                    keyboardType: TextInputType.number,
                    maxLines: 1,
                    minLines: 1,
                    onChanged: (value) {
                      if (double.tryParse(value) != null) {
                        record[template.keys.elementAt(index)] = value;
                        realm.write(() {
                          note.noteContext = mapToyaml(record);
                          note.noteUpdateDate = DateTime.now().toUtc();
                        });
                        error = '';
                      } else {
                        error = '请输入数字';
                      }
                    },
                  ),
                ),
              ),
            ),
            Expanded(
              flex: 2,
              child: Text(
                propertySettings[3] ?? '',
                textAlign: TextAlign.left,
                style: textStyle,
              ),
            ),
          ],
        ),
      );
    default:
      return Card(
        elevation: 0,
        color: Color.fromARGB(50, templateProperty['color'][0],
            templateProperty['color'][1], templateProperty['color'][2]),
        child: Row(
          children: [
            Expanded(
              flex: 2,
              child: Text(
                template.keys.elementAt(index) + ':',
                textAlign: TextAlign.center,
                style: textStyle,
              ),
            ),
            Expanded(
              flex: 1,
              child: Text(
                propertySettings[2] ?? '',
                textAlign: TextAlign.right,
                style: textStyle,
              ),
            ),
            Expanded(
              flex: 6,
              child: Padding(
                padding: edgeInsets,
                child: SizedBox(
                  height: 45,
                  child: TextField(
                    textAlign: TextAlign.center,
                    style: textStyle,
                    controller: propertyControllerList[index],
                    decoration: InputDecoration(
                      border: const UnderlineInputBorder(),
                      contentPadding: edgeInsets,
                    ),
                    maxLines: 1,
                    minLines: 1,
                    onChanged: (value) {
                      record[template.keys.elementAt(index)] = value;
                      realm.write(() {
                        note.noteContext = mapToyaml(record);
                        note.noteUpdateDate = DateTime.now().toUtc();
                      });
                    },
                  ),
                ),
              ),
            ),
            Expanded(
              flex: 2,
              child: Text(
                propertySettings[3] ?? '',
                textAlign: TextAlign.left,
                style: textStyle,
              ),
            ),
          ],
        ),
      );
  }
}

class RecordTemplateChangePage extends StatefulWidget {
  RecordTemplateChangePage({
    Key? key,
    required this.onPageClosed,
    required this.note,
  }) : super(key: key);
  final VoidCallback onPageClosed;
  final Notes note;
  final List<String> typeList = ['新建', '清空'];
  final List<String> folderList = ['新建', '清空'];
  final List<String> projectList = ['新建', '清空'];
  final List<String> finishStateList = [
    '未完',
    '已完',
  ];

  @override
  RecordTemplateChangePageState createState() =>
      RecordTemplateChangePageState();
}

class RecordTemplateChangePageState extends State<RecordTemplateChangePage> {
  TextEditingController titleController = TextEditingController();
  TextEditingController contentController = TextEditingController();
  List<TextEditingController> propertyControllerList = [];
  TextEditingController otherController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  Map template = {};
  Map templateProperty = {};
  Map templateNew = {};
  FocusNode focusNode = FocusNode();
  int key = 0;
  String generateKey() {
    key++;
    return 'key_$key';
  }

  @override
  void initState() {
    super.initState();
    focusNode.requestFocus();
    titleController.text = widget.note.noteTitle;
    contentController.text = widget.note.noteContext;

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
    template = loadYaml(widget.note.noteContext
        .substring(0, widget.note.noteContext.indexOf('settings'))) as YamlMap;
    templateNew = Map.from(template);
    templateProperty = loadYaml(widget.note.noteContext
        .substring(widget.note.noteContext.indexOf('settings'))) as YamlMap;
    for (var i = 0; i < template.length; i++) {
      propertyControllerList.add(TextEditingController());
      propertyControllerList[i].text =
          template[template.keys.elementAt(i)] == null
              ? ''
              : template[template.keys.elementAt(i)].toString();
    }
  }

  save() {
    realm.write(() {
      widget.note.noteCreateDate = DateTime.now().toUtc();
    });
  }

  @override
  void dispose() {
    titleController.clear();
    contentController.clear();
    focusNode.dispose();
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
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            setState(() {
              template.addAll({generateKey(): ',,'});
              realm.write(() {
                widget.note.noteContext =
                    '${mapToyaml(template)}settings: ${mapToyaml(templateProperty)}';
                widget.note.noteUpdateDate = DateTime.now().toUtc();
              });
            });
          },
        ),
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
                          onChanged: (value) {},
                        ),
                        const SizedBox(
                          height: 5,
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
                                  style: menuChildrenButtonStyle,
                                  child: Text(type),
                                  onPressed: () {
                                    switch (type) {
                                      case '清空':
                                        setState(() {
                                          realm.write(() {
                                            widget.note.noteType = '';
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
                                                  if (!text.startsWith('.')) {
                                                    text = '.$text';
                                                  }
                                                  widget.typeList.add(text);
                                                  realm.write(() {
                                                    widget.note.noteType = text;
                                                    widget.note.noteUpdateDate =
                                                        DateTime.now().toUtc();
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
                                                  widget.projectList.add(text);
                                                  realm.write(() {
                                                    widget.note.noteProject =
                                                        text;
                                                    widget.note.noteUpdateDate =
                                                        DateTime.now().toUtc();
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
                                                    widget.note.noteUpdateDate =
                                                        DateTime.now().toUtc();
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
                        Row(
                          children: [
                            Expanded(
                              flex: 4,
                              child: Text(
                                '名称',
                                textAlign: TextAlign.center,
                                style: textStyle,
                              ),
                            ),
                            Expanded(
                              flex: 4,
                              child: Text(
                                '类型',
                                textAlign: TextAlign.center,
                                style: textStyle,
                              ),
                            ),
                            Expanded(
                              flex: 4,
                              child: Text(
                                '前缀',
                                textAlign: TextAlign.center,
                                style: textStyle,
                              ),
                            ),
                            Expanded(
                              flex: 4,
                              child: Text(
                                '后缀',
                                textAlign: TextAlign.center,
                                style: textStyle,
                              ),
                            ),
                          ],
                        ),
                        ListView.builder(
                          controller: _scrollController,
                          itemCount: template.length,
                          shrinkWrap: true,
                          padding: edgeInsets,
                          itemBuilder: (context, index) {
                            return buildTemplatePropertyCard(templateProperty,
                                index, propertyControllerList);
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
                      onPressed: () {
                        FlutterClipboard.copy(contentController.text);
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

  Widget buildTemplatePropertyCard(Map templateProperty, int index,
      List<TextEditingController> propertyControllerList) {
    List propertySettings = template.values.elementAt(index).split(",");
    return Card(
      elevation: 0,
      color: Color.fromARGB(50, templateProperty['color'][0],
          templateProperty['color'][1], templateProperty['color'][2]),
      child: Row(
        children: [
          Expanded(
            flex: 4,
            child: TextField(
              textAlign: TextAlign.center,
              style: textStyle,
              controller: propertyControllerList[index],
              onChanged: (value) {},
            ),
          ),
          Expanded(
            flex: 2,
            child: MenuAnchor(
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
                    propertySettings[1] == '' ? '类型' : propertySettings[1],
                    style: propertySettings[1] == ''
                        ? const TextStyle(color: Colors.grey)
                        : TextStyle(
                            color: Color.fromARGB(
                                255,
                                templateProperty['color'][0],
                                templateProperty['color'][1],
                                templateProperty['color'][2])),
                  ),
                );
              },
              menuChildren: templateTypeList.map((type) {
                return MenuItemButton(
                  style: menuChildrenButtonStyle,
                  child: Text(type),
                  onPressed: () {
                    switch (type) {
                      case '清空':
                        setState(() {
                          realm.write(() {
                            widget.note.noteType = '';
                            widget.note.noteUpdateDate = DateTime.now().toUtc();
                          });
                        });
                        break;
                      default:
                        setState(() {
                          // propertySettings[0] = type;
                          templateNew[template.keys.elementAt(index)][0] = type;
                        });
                    }
                  },
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}

class InputSelectAlertDialog extends StatefulWidget {
  final Function(String) onSubmitted;
  final List<String> selectList;
  final List<String> currentList;
  final Color fontColor;
  final Color backgroundColor;
  final bool isMultiSelect;
  const InputSelectAlertDialog(
      {super.key,
      required this.onSubmitted,
      required this.selectList,
      required this.currentList,
      required this.fontColor,
      required this.isMultiSelect,
      required this.backgroundColor});

  @override
  // ignore: library_private_types_in_public_api
  _InputSelectAlertDialogState createState() => _InputSelectAlertDialogState();
}

class _InputSelectAlertDialogState extends State<InputSelectAlertDialog> {
  late String inputText;
  final TextEditingController _controller = TextEditingController();
  List<String> filterSelectList = [];
  void _submit() {
    final text = widget.currentList.join(', ');
    widget.onSubmitted(text);
    Navigator.of(context).pop();
  }

  @override
  void initState() {
    super.initState();
    filterSelectList = List.from(widget.selectList);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      titlePadding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
      contentPadding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
      insetPadding: const EdgeInsets.all(20),
      actionsPadding: const EdgeInsets.all(10),
      title: Container(
        width: 600,
        constraints: const BoxConstraints(
          minHeight: 24,
          maxHeight: 81,
        ),
        padding: const EdgeInsets.all(0),
        // color: Colors.white,
        child: SingleChildScrollView(
          scrollDirection: Axis.vertical,
          child: Wrap(
            alignment: WrapAlignment.start,
            crossAxisAlignment: WrapCrossAlignment.start,
            spacing: 5,
            runSpacing: 5,
            children: List.generate(
              widget.currentList.length,
              (index) {
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      widget.currentList.removeAt(index);
                    });
                  },
                  child: Container(
                    margin: const EdgeInsets.all(0),
                    padding: const EdgeInsets.fromLTRB(5, 0, 5, 0),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      color: widget.fontColor,
                      border: Border.all(
                        color: widget.fontColor,
                        width: 1,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          widget.currentList[index],
                          style: const TextStyle(
                            fontFamily: 'LXGWWenKai',
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                        const Icon(
                          Icons.close,
                          size: 15,
                          color: Colors.white,
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _controller,
            autofocus: false,
            decoration: const InputDecoration(hintText: '搜索'),
            onChanged: (text) {
              filterSelectList = List.from(widget.selectList);
              filterSelectList.retainWhere((element) => element.contains(text));
              setState(() {});
            },
            onSubmitted: (text) {
              setState(() {
                if (!widget.isMultiSelect) {
                  widget.currentList.clear();
                }
                if (!widget.selectList.contains(text)) {
                  widget.selectList.add(text);
                }
                if (!widget.currentList.contains(text)) {
                  widget.currentList.add(text);
                }
                _controller.text = '';
                filterSelectList = List.from(widget.selectList);
              });
            },
          ),
          const SizedBox(
            height: 10,
          ),
          Flexible(
            child: SingleChildScrollView(
              child: Wrap(
                alignment: WrapAlignment.start,
                crossAxisAlignment: WrapCrossAlignment.start,
                spacing: 5,
                runSpacing: 5,
                children: List.generate(
                  filterSelectList.length,
                  (index) {
                    bool isContain =
                        widget.currentList.contains(filterSelectList[index]);
                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          if (!widget.isMultiSelect) {
                            widget.currentList.clear();
                          }
                          if (!widget.currentList
                              .contains(filterSelectList[index])) {
                            widget.currentList.add(filterSelectList[index]);
                          } else {
                            widget.currentList.remove(filterSelectList[index]);
                          }
                        });
                      },
                      child: Container(
                        margin: const EdgeInsets.all(0),
                        padding: const EdgeInsets.fromLTRB(5, 0, 5, 0),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
                          color: isContain ? widget.fontColor : Colors.white,
                          border: Border.all(
                            color: widget.fontColor,
                            width: 1,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              filterSelectList[index],
                              style: TextStyle(
                                fontFamily: 'LXGWWenKai',
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color:
                                    isContain ? Colors.white : widget.fontColor,
                              ),
                            ),
                            isContain
                                ? const Icon(
                                    Icons.close,
                                    size: 15,
                                    color: Colors.white,
                                  )
                                : Icon(
                                    Icons.add,
                                    size: 15,
                                    color: widget.fontColor,
                                  ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          ),
        ],
      ),
      actions: <Widget>[
        TextButton(
          child: Text(
            '取消',
            style: TextStyle(color: widget.fontColor),
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
        TextButton(
          onPressed: _submit,
          child: Text(
            '确定',
            style: TextStyle(color: widget.fontColor),
          ),
        ),
      ],
      actionsAlignment: MainAxisAlignment.spaceAround,
    );
  }
}

Map stringToMapTemplate(String str) {
  Map map = {};
  str.split('\n').forEach((element) {
    String key = element.split(': ')[0];
    String value = element.split(': ')[1];
    if (int.tryParse(key) == null) {
      map[key] = value;
    } else {
      map[int.tryParse(key)] = value;
    }
  });
  return map;
}

Duration? stringToDuration(String str) {
  bool isContainD = str.contains('d');
  bool isContainH = str.contains('h');
  bool isContainM = str.contains('m');
  bool isContainS = str.contains('s');
  RegExp colonRegExp = RegExp(r":");
  int colonCount = colonRegExp.allMatches(str).length;
  if (colonCount == 2) {
    var tmp = str.replaceAll(' ', '').split(':');

    return Duration(
        hours: int.parse(tmp[0]),
        minutes: int.parse(tmp[1]),
        seconds: int.parse(tmp[2]));
  } else if (colonCount == 1) {
    var tmp = str.replaceAll(' ', '').split(':');
    if (tmp.length == 3 &&
        int.tryParse(tmp[0]) != null &&
        int.tryParse(tmp[1]) != null) {
      return Duration(hours: int.parse(tmp[0]), minutes: int.parse(tmp[1]));
    } else {
      return null;
    }
  }
  if (isContainD && isContainH && isContainM && isContainS) {
    var regx = RegExp(r'(\d+d)?(\d+h)?(\d+m)?(\d+s)?');
    var matches = regx.firstMatch(str);
    if (matches != null) {
      var d = int.parse(matches[1]?.replaceFirst('d', '') ?? '0');
      var h = int.parse(matches[2]?.replaceFirst('h', '') ?? '0');
      var m = int.parse(matches[3]?.replaceFirst('m', '') ?? '0');
      var s = int.parse(matches[4]?.replaceFirst('s', '') ?? '0');
      return Duration(days: d, hours: h, minutes: m, seconds: s);
    } else {
      return null;
    }
  } else if (isContainH && isContainM && isContainS) {
    var regx = RegExp(r'(\d+h)?(\d+m)?(\d+s)?');
    var matches = regx.firstMatch(str);
    if (matches != null) {
      var h = int.parse(matches[1]?.replaceFirst('h', '') ?? '0');
      var m = int.parse(matches[2]?.replaceFirst('m', '') ?? '0');
      var s = int.parse(matches[3]?.replaceFirst('s', '') ?? '0');
      return Duration(hours: h, minutes: m, seconds: s);
    } else {
      return null;
    }
  } else if (isContainD && isContainH && isContainM) {
    var regx = RegExp(r'(\d+d)?(\d+h)?(\d+m)?');
    var matches = regx.firstMatch(str);
    if (matches != null) {
      var d = int.parse(matches[1]?.replaceFirst('d', '') ?? '0');
      var h = int.parse(matches[2]?.replaceFirst('h', '') ?? '0');
      var m = int.parse(matches[3]?.replaceFirst('m', '') ?? '0');
      return Duration(days: d, hours: h, minutes: m);
    } else {
      return null;
    }
  } else if (isContainD && isContainH) {
    var regx = RegExp(r'(\d+d)?(\d+h)?');
    var matches = regx.firstMatch(str);
    if (matches != null) {
      var d = int.parse(matches[1]?.replaceFirst('d', '') ?? '0');
      var h = int.parse(matches[2]?.replaceFirst('h', '') ?? '0');
      return Duration(days: d, hours: h);
    } else {
      return null;
    }
  } else if (isContainH && isContainM) {
    var regx = RegExp(r'(\d+h)?(\d+m)?');
    var matches = regx.firstMatch(str);
    if (matches != null) {
      var h = int.parse(matches[1]?.replaceFirst('h', '') ?? '0');
      var m = int.parse(matches[2]?.replaceFirst('m', '') ?? '0');
      return Duration(hours: h, minutes: m);
    } else {
      return null;
    }
  } else if (isContainM && isContainS) {
    var regx = RegExp(r'(\d+m)?(\d+s)?');
    var matches = regx.firstMatch(str);
    if (matches != null) {
      var m = int.parse(matches[1]?.replaceFirst('m', '') ?? '0');
      var s = int.parse(matches[2]?.replaceFirst('s', '') ?? '0');
      return Duration(minutes: m, seconds: s);
    } else {
      return null;
    }
  } else if (isContainD) {
    var regx = RegExp(r'(\d+d)?');
    var matches = regx.firstMatch(str);
    if (matches != null) {
      var d = int.parse(matches[1]?.replaceFirst('d', '') ?? '0');
      return Duration(days: d);
    } else {
      return null;
    }
  } else if (isContainH) {
    var regx = RegExp(r'(\d+h)?');
    var matches = regx.firstMatch(str);
    if (matches != null) {
      var h = int.parse(matches[1]?.replaceFirst('h', '') ?? '0');
      return Duration(hours: h);
    } else {
      return null;
    }
  } else if (isContainM) {
    var regx = RegExp(r'(\d+m)?');
    var matches = regx.firstMatch(str);
    if (matches != null) {
      var m = int.parse(matches[1]?.replaceFirst('m', '') ?? '0');
      return Duration(minutes: m);
    } else {
      return null;
    }
  } else if (isContainS) {
    var regx = RegExp(r'(\d+s)?');
    var matches = regx.firstMatch(str);
    if (matches != null) {
      var s = int.parse(matches[1]?.replaceFirst('s', '') ?? '0');
      return Duration(seconds: s);
    } else {
      return null;
    }
  } else {
    return null;
  }
}
