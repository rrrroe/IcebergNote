// ignore_for_file: avoid_function_literals_in_foreach_calls

import 'dart:math';

import 'package:clipboard/clipboard.dart';
import 'package:flutter/material.dart';
import 'package:flutter_pickers/time_picker/model/date_mode.dart';
import 'package:flutter_pickers/time_picker/model/suffix.dart';
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

List templateTypeList = ['数字', '文本', '单选', '多选', '时间', '日期', '长文'];

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
        "noteType == \$0 AND noteProject == \$1 AND noteIsDeleted != true SORT(id DESC) LIMIT(1)",
        [
          '.表头',
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

  const PropertyCard({
    super.key,
    required this.note,
    required this.templateNote,
    required this.templateProperty,
    required this.index,
    required this.record,
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
      case '多选':
        return buildMultiSelectCard();
      default:
        return buildTextCard();
    }
  }

  Widget buildNumberCard() {
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
                    if (double.tryParse(value) != null) {
                      widget.record[template.keys.elementAt(widget.index)] =
                          value;
                      realm.write(() {
                        widget.note.noteContext = mapToyaml(widget.record);
                      });
                      setState(() {
                        error = '';
                      });
                    } else {
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

  Widget buildSingleSelectCard() {
    List<String> selectList = propertySettings.last.split("||");
    List<String> currentList = widget
        .record[template.keys.elementAt(widget.index)]
        .toString()
        .split(", ");
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

  Widget buildDateCard() {
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
                        height: 300,
                        context: context,
                        locale: const Locale("zh", "CN"),
                        theme: ThemeData(primarySwatch: Colors.lightBlue),
                      );
                      if (newDateTime != null) {
                        setState(() {
                          widget.record[template.keys.elementAt(widget.index)] =
                              '${newDateTime.year}-${newDateTime.month}-${newDateTime.day}';
                          realm.write(() {
                            widget.note.noteContext = mapToyaml(widget.record);
                          });
                        });
                      }
                    },
                    child: Text(
                      widget.record[template.keys.elementAt(widget.index)]
                                  .toString() ==
                              'null'
                          ? ''
                          : widget.record[template.keys.elementAt(widget.index)]
                              .toString(),
                      style: const TextStyle(color: Colors.black),
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
    List<String> timeList = widget.record[template.keys.elementAt(widget.index)]
        .toString()
        .split(':');
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
                              hour: int.parse(timeList[0]),
                              minute: int.parse(timeList[1]),
                              second: int.parse(timeList[2]))
                          : PDuration(),
                      onConfirm: (p) {
                        setState(() {
                          widget.record[template.keys.elementAt(widget.index)] =
                              '${p.hour}:${p.minute}:${p.second}';
                          realm.write(() {
                            widget.note.noteContext = mapToyaml(widget.record);
                          });
                        });
                      },
                    );
                  },
                  child: Text(
                    widget.record[template.keys.elementAt(widget.index)] == null
                        ? '0:0:0'
                        : widget.record[template.keys.elementAt(widget.index)]
                                    .toString()[0] !=
                                '0'
                            ? widget
                                .record[template.keys.elementAt(widget.index)]
                                .toString()
                            : '${widget.record[template.keys.elementAt(widget.index)].toString().substring(2).replaceAll(':', '′')}″',
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
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            setState(() {
              template.addAll({generateKey(): ',,'});
              realm.write(() {
                widget.note.noteContext =
                    '${mapToyaml(template)}settings: ${mapToyaml(templateProperty)}';
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
      title: Wrap(
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
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _controller,
            autofocus: true,
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
          Container(
            width: 200,
            constraints: const BoxConstraints(
              minHeight: 100,
              maxHeight: 400,
            ),
            color: Colors.white,
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
          )
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
        // TextButton(
        //   child: Text(
        //     '新建',
        //     style: TextStyle(color: widget.fontColor),
        //   ),
        //   onPressed: () {
        //     showDialog(
        //       context: context,
        //       builder: (ctx) {
        //         return InputAlertDialog(
        //           onSubmitted: (text) {
        //             setState(() {
        //               if (!widget.isMultiSelect) {
        //                 widget.currentList.clear();
        //               }
        //               widget.selectList.add(text);
        //               widget.currentList.add(text);
        //               filterSelectList.add(text);
        //             });
        //           },
        //         );
        //       },
        //     );
        //   },
        // ),
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
