import 'package:clipboard/clipboard.dart';
import 'package:flutter/material.dart';
import 'package:yaml/yaml.dart';

import '../constants.dart';
import '../main.dart';
import '../notes.dart';
import 'input_screen.dart';

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

    for (String key in templateKeys) {
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
                        ListView.builder(
                          controller: _scrollController,
                          itemCount: template.length,
                          shrinkWrap: true,
                          padding: const EdgeInsets.all(0),
                          itemBuilder: (context, index) {
                            return buildPropertyCard(
                                widget.note,
                                template,
                                templateProperty,
                                index,
                                propertyControllerList,
                                record);
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

Widget buildPropertyCard(Notes note, Map template, Map templateProperty,
    int index, List<TextEditingController> propertyControllerList, Map record) {
  List propertySettings = template.values.elementAt(index);
  EdgeInsets edgeInsets = const EdgeInsets.fromLTRB(0, 0, 0, 0);
  TextStyle textStyle =
      const TextStyle(overflow: TextOverflow.fade, fontSize: 14);
  if (propertySettings[0] == 'LongText') {
    return Container();
  } else {
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
              propertySettings[1] ?? '',
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
                    record[template.keys.elementAt(index)] = (value ?? 'null');
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
              propertySettings[2] ?? '',
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
                            Expanded(
                              flex: 1,
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
                            return buildTemplatePropertyCard(
                                template,
                                templateProperty,
                                index,
                                propertyControllerList);
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

  Widget buildTemplatePropertyCard(Map template, Map templateProperty,
      int index, List<TextEditingController> propertyControllerList) {
    List propertySettings = template.values.elementAt(index);
    List templateTypeList = ['数字', '文本', '单选', '多选', '时间', '日期', '长文'];
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
            flex: 4,
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
                    propertySettings[0] == '' ? '类型' : propertySettings[0],
                    style: propertySettings[0] == ''
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
                          realm.write(() {
                            widget.note.noteType = type;
                          });
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