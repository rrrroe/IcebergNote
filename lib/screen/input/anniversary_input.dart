import 'dart:convert';

import 'package:clipboard/clipboard.dart';
import 'package:flutter/material.dart';
import 'package:icebergnote/class/anniversary_class.dart';
import 'package:icebergnote/constants.dart';
import 'package:icebergnote/main.dart';
import 'package:icebergnote/notes.dart';
import 'package:icebergnote/postgresql/sync.dart';
import 'package:icebergnote/screen/input/input_screen.dart';
import 'package:realm/realm.dart';

// ignore: must_be_immutable
class AnniversaryInputPage extends StatefulWidget {
  final VoidCallback onPageClosed;
  final Notes note;
  final int mod; //0正常，
  List<String> typeList = ['新建', '清空'];
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

    List<Notes> typeDistinctList = realm
        .query<Notes>(
            "noteType !='' DISTINCT(noteType) SORT(noteCreateDate DESC)")
        .toList();

    for (int i = 0; i < typeDistinctList.length; i++) {
      widget.typeList.add(typeDistinctList[i].noteType);
    }
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
    titleController.clear();
    contentController.clear();
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
                  child: SingleChildScrollView(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 25, // 左右间距
                          vertical: 0 // 上下间距
                          ),
                      child: Column(
                        children: [
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Expanded(
                                child: TextField(
                                  textAlign: TextAlign.center,
                                  controller: titleController,
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w600,
                                  ),
                                  minLines: 1,
                                  maxLines: 2,
                                  decoration: const InputDecoration(
                                      labelText: "日子",
                                      labelStyle: TextStyle(
                                        color: Colors.grey,
                                      )
                                      // border: OutlineInputBorder(),
                                      // focusedBorder:
                                      //     OutlineInputBorder(borderSide: BorderSide(color: Colors.red)),
                                      // enabledBorder: OutlineInputBorder(
                                      //     borderSide: BorderSide(color: Colors.blue)),
                                      ),
                                  onChanged: (value) async {
                                    // setState(() {
                                    //   wordCount1 = value.length;
                                    // });
                                    await realm.writeAsync(() {
                                      widget.note.noteTitle = value;
                                      widget.note.noteUpdateDate =
                                          DateTime.now().toUtc();
                                    });
                                  },
                                ),
                              )
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
                      onPressed: () {},
                      child: const Text('高级'),
                    ),
                    TextButton(
                      onPressed: () {
                        realm.write(() {
                          widget.note.noteContext = contentController.text
                              .replaceAll(RegExp(r'\n+'), '\n\n');
                          widget.note.noteUpdateDate = DateTime.now().toUtc();
                        });

                        save();
                        Navigator.pop(context);
                        widget.onPageClosed();
                      },
                      child: const Text('格式'),
                    ),
                    TextButton(
                      onPressed: () {
                        FlutterClipboard.copy(contentController.text);
                        poplog(1, '复制', context);
                      },
                      child: const Text('复制'),
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
      if (titleController.text == '' &&
          widget.note.noteType == '.todo' &&
          contentController.text != '') {
        List<String> tmpList = contentController.text.split('\n');
        List<Notes> tmpnoteList = [];
        for (int i = 0; i < tmpList.length; i++) {
          tmpnoteList.add(Notes(
              Uuid.v4(),
              widget.note.noteFolder,
              tmpList[i],
              '',
              DateTime.now().toUtc(),
              DateTime.now().toUtc(),
              DateTime.utc(1970, 1, 1),
              DateTime.utc(1970, 1, 1),
              DateTime.utc(1970, 1, 1),
              DateTime.utc(1970, 1, 1),
              noteType: '.todo',
              noteProject: widget.note.noteProject,
              noteFinishState: '未完'));
          realm.add(tmpnoteList[i]);
        }
        realm.delete(widget.note);
      } else {
        widget.note.noteTitle = titleController.text;
        widget.note.noteUpdateDate = DateTime.now().toUtc();
      }
    });
  }
}
