import 'dart:convert';
import 'package:clipboard/clipboard.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_rounded_date_picker/flutter_rounded_date_picker.dart';
import 'package:icebergnote/class/anniversary_class.dart';
import 'package:icebergnote/constants.dart';
import 'package:icebergnote/main.dart';
import 'package:icebergnote/notes.dart';
import 'package:icebergnote/postgresql/sync.dart';
import 'package:icebergnote/screen/card/anniversary_card.dart';
import 'package:icebergnote/screen/input/input_screen.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';

// ignore: must_be_immutable
class AnniversaryInputPage extends StatefulWidget {
  final VoidCallback onPageClosed;
  final Notes note;
  final int mod; //0正常，
  List<String> folderList = ['新建', '清空'];
  List<String> projectList = ['新建', '清空'];
  AnniversaryInputPage({
    super.key,
    required this.onPageClosed,
    required this.note,
    required this.mod,
  });

  @override
  State<AnniversaryInputPage> createState() => _AnniversaryInputPageState();
}

class _AnniversaryInputPageState extends State<AnniversaryInputPage> {
  Anniversary anniversary = Anniversary();

  TextEditingController titleController = TextEditingController();
  TextEditingController contentController = TextEditingController();
  TextEditingController otherController = TextEditingController();
  final bgColorTextController = TextEditingController(text: '#FF7062DB');
  @override
  void initState() {
    super.initState();
    if (widget.note.noteContext != '') {
      anniversary = Anniversary.fromJson(jsonDecode(widget.note.noteContext));
    } else {
      realm.write(() {
        widget.note.noteTitle = anniversary.title;
        widget.note.noteContext = jsonEncode(anniversary.toJson());
        widget.note.noteUpdateDate = DateTime.now().toUtc();
      });
    }

    titleController.text = widget.note.noteTitle;
    contentController.text = widget.note.noteContext;

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
    otherController.dispose();
    bgColorTextController.dispose();
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
                const SizedBox(height: 20),
                AnniversaryCard(
                    note: widget.note,
                    mod: 0,
                    context: context,
                    refreshList: () {},
                    searchText: ''),
                Expanded(
                  child: SingleChildScrollView(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 25, vertical: 0),
                      child: Column(
                        children: [
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Expanded(
                                child: TextField(
                                  textAlign: TextAlign.left,
                                  controller: titleController,
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w600,
                                  ),
                                  minLines: 1,
                                  maxLines: 2,
                                  decoration: const InputDecoration(
                                    border: InputBorder.none,
                                    contentPadding: EdgeInsets.zero,
                                    labelText: "日子",
                                    labelStyle: TextStyle(
                                      color: Colors.grey,
                                    ),
                                  ),
                                  onChanged: (value) async {
                                    anniversary.title = value;
                                  },
                                ),
                              )
                            ],
                          ),
                          const Divider(),
                          Container(
                              alignment: Alignment.centerLeft,
                              constraints: const BoxConstraints(
                                minHeight: 30,
                              ),
                              color: Colors.white,
                              height: 30,
                              child: FilledButton.tonal(
                                style: selectedContextButtonStyle,
                                onPressed: () async {
                                  DateTime? newDateTime =
                                      await showRoundedDatePicker(
                                    initialDate: anniversary.date,
                                    height: 300,
                                    context: context,
                                    locale: const Locale("zh", "CN"),
                                    theme: ThemeData(
                                        primarySwatch: Colors.lightBlue),
                                  );
                                  if (newDateTime != null) {
                                    setState(() {
                                      anniversary.date = newDateTime;
                                    });
                                  }
                                },
                                child: Text(
                                  anniversary.date == null
                                      ? ''
                                      : anniversary.date
                                          .toString()
                                          .substring(0, 10),
                                  style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold),
                                ),
                              )),
                          const Divider(),
                          Row(
                            children: [
                              const Text(
                                '背景',
                                style: TextStyle(
                                    fontSize: 18, fontWeight: FontWeight.bold),
                              ),
                              Expanded(child: Container()),
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
                                              pickerColor: anniversary.bgColor,
                                              onColorChanged:
                                                  (Color color) async {
                                                setState(() {
                                                  anniversary.bgColor = color;
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
                                  height: 20,
                                  width: 10,
                                  decoration: BoxDecoration(
                                    color: anniversary.bgColor,
                                    borderRadius:
                                        BorderRadius.circular(2), // 设置圆角
                                  ),
                                ),
                              ),
                              const SizedBox(width: 10),
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
                              Expanded(
                                child: TextField(
                                  textAlign: TextAlign.left,
                                  controller: titleController,
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  minLines: 1,
                                  maxLines: 2,
                                  decoration: const InputDecoration(
                                    border: InputBorder.none,
                                    contentPadding: EdgeInsets.zero,
                                  ),
                                  onChanged: (value) async {
                                    anniversary.title = value;
                                  },
                                ),
                              ),
                            ],
                          ),
                          const Divider(),
                          const Divider(),
                          const Divider(),
                          const Divider(),
                          const Divider(),
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
                          Container(
                            constraints: const BoxConstraints(maxWidth: 800),
                            child: TextField(
                              style: const TextStyle(
                                fontSize: 18,
                                height: 2,
                                wordSpacing: 4,
                              ),
                              controller: contentController,
                              decoration: const InputDecoration(
                                border: InputBorder.none,
                              ),
                              maxLines: null,
                              minLines: 6,
                              onChanged: (value) async {
                                await realm.writeAsync(() {
                                  widget.note.noteContext = value;
                                  widget.note.noteUpdateDate =
                                      DateTime.now().toUtc();
                                });
                                // setState(() {
                                //   wordCount2 = value.length;
                                // });
                              },
                            ),
                          ),
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
    anniversary = Anniversary.fromJson(jsonDecode(contentController.text));
    anniversary.date ??=
        DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day);
    realm.write(() {
      widget.note.noteContext = jsonEncode(anniversary.toJson());
      widget.note.noteTitle = anniversary.title;
      widget.note.noteUpdateDate = DateTime.now().toUtc();
    });
  }
}
