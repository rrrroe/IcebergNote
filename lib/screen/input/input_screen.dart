import 'package:clipboard/clipboard.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:icebergnote/postgresql/sync.dart';
import 'package:realm/realm.dart';
import '../../constants.dart';
import '../../notes.dart';
import '../../main.dart';
import 'check_list_input.dart';
import 'record_input.dart';
import 'rich_input_screen.dart';

String tmpTitle = "", tmpContext = "";
late Notes latestNote;

class KeyboardManager extends ChangeNotifier {
  double keyboardHeight = 0.0;

  void updateHeight(double height) {
    keyboardHeight = height;
    notifyListeners();
  }
}

// ignore: must_be_immutable
class ChangePage extends StatefulWidget {
  ChangePage({
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
  ChangePageState createState() => ChangePageState();
}

class ChangePageState extends State<ChangePage> {
  TextEditingController titleController = TextEditingController();
  TextEditingController contentController = TextEditingController();
  TextEditingController otherController = TextEditingController();

  // late QuillController _controller;

  // var wordCount1 = 0;
  // var wordCount2 = 0;
  FocusNode focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    focusNode.requestFocus();
    titleController.text = widget.note.noteTitle;
    contentController.text = widget.note.noteContext;
    // wordCount1 = titleController.text.length;
    // wordCount2 = contentController.text.length;
    final KeyboardManager keyboardManager = KeyboardManager();
    focusNode.addListener(() {
      keyboardManager.updateHeight(MediaQuery.of(context).viewInsets.bottom);
    });
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
                          TextField(
                            textAlign: TextAlign.center,
                            controller: titleController,
                            style: const TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.w600,
                            ),
                            minLines: 1,
                            maxLines: 2,
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
                          // Row(
                          //   mainAxisAlignment: MainAxisAlignment.end,
                          //   crossAxisAlignment: CrossAxisAlignment.center,
                          //   children: [
                          //     Text('${wordCount1 + wordCount2}字符'),
                          //   ],
                          // ),
                          Wrap(
                            direction: Axis.horizontal,
                            alignment: WrapAlignment.start, // Left align
                            spacing: 8.0,
                            runSpacing: 4.0,
                            children: [
                              MenuAnchor(
                                style: menuAnchorStyle,
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
                                                      widget.note.noteType =
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
                              Visibility(
                                visible: widget.note.noteType == ".todo",
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
                                        widget.note.noteFinishState == ''
                                            ? '未完'
                                            : widget.note.noteFinishState,
                                        style: const TextStyle(
                                            color: Color.fromARGB(
                                                255, 180, 68, 255)),
                                      ),
                                    );
                                  },
                                  menuChildren:
                                      widget.finishStateList.map((finishState) {
                                    return MenuItemButton(
                                      style: menuChildrenButtonStyle,
                                      child: Text(finishState),
                                      onPressed: () {
                                        switch (finishState) {
                                          case '新建':
                                            showDialog(
                                              context: context,
                                              builder: (ctx) {
                                                return InputAlertDialog(
                                                  onSubmitted: (text) {
                                                    setState(() {
                                                      widget.finishStateList
                                                          .add(text);
                                                      realm.write(() {
                                                        widget.note
                                                                .noteFinishState =
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
                                                widget.note.noteFinishState =
                                                    finishState;
                                                widget.note.noteUpdateDate =
                                                    DateTime.now().toUtc();
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
                          Container(
                            constraints: const BoxConstraints(maxWidth: 800),
                            child: TextField(
                              focusNode: focusNode,
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
                      onPressed: () {
                        if (widget.note.noteType == '.表单') {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => RecordTemplateChangePage(
                                note: widget.note,
                                onPageClosed: () {
                                  setState(() {});
                                },
                              ),
                            ),
                          );
                        } else if (widget.note.noteType == '.清单') {
                          Get.to(() => CheckListEditPage(
                                note: widget.note,
                                onPageClosed: () {},
                              ));
                        } else {
                          Get.to(const RichEditorPage());
                        }
                      },
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

class InputAlertDialog extends StatefulWidget {
  final Function(String) onSubmitted;

  const InputAlertDialog({super.key, required this.onSubmitted});

  @override
  // ignore: library_private_types_in_public_api
  _InputAlertDialogState createState() => _InputAlertDialogState();
}

class _InputAlertDialogState extends State<InputAlertDialog> {
  late String inputText;
  final TextEditingController _controller = TextEditingController();

  void _submit() {
    final text = _controller.text;
    widget.onSubmitted(text);
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('新建'),
      content: TextField(controller: _controller),
      actions: <Widget>[
        TextButton(
          child: const Text('取消'),
          onPressed: () => Navigator.of(context).pop(),
        ),
        TextButton(
          onPressed: _submit,
          child: const Text('确定'),
        ),
      ],
    );
  }
}

void poplog(int n, String m, BuildContext context) {
  if (n == 1) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        width: 90,
        content: Text(
          '$m成功',
          textAlign: TextAlign.start,
          style: TextStyle(
            color: Theme.of(context).colorScheme.onSecondary,
          ),
        ),
        backgroundColor: Theme.of(context).colorScheme.secondary,
        shape: RoundedRectangleBorder(
          // 设置形状
          borderRadius: BorderRadius.circular(20.0),
        ),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 1),
        elevation: 8.0,
      ),
    );
  } else {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        width: 90,
        content: Text(
          '$m失败',
          textAlign: TextAlign.start,
          style: TextStyle(
            color: Theme.of(context).colorScheme.onError,
          ),
        ),
        backgroundColor: Theme.of(context).colorScheme.error,
        shape: RoundedRectangleBorder(
          // 设置形状
          borderRadius: BorderRadius.circular(20.0),
        ),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 3),
        elevation: 8.0,
      ),
    );
  }
}

class MenuWidget extends StatelessWidget {
  const MenuWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        TextButton(child: const Text('菜单'), onPressed: () {/* 点击按钮的操作 */}),
      ],
    );
  }
}

// class NewNoteDialog extends StatefulWidget {
//   const NewNoteDialog({super.key, required this.onDialogClosed});
//   final VoidCallback onDialogClosed;
//   @override
//   _NewNoteDialogState createState() => _NewNoteDialogState();
// }

// class _NewNoteDialogState extends State<NewNoteDialog> {
//   final TextEditingController _titleController = TextEditingController();
//   final TextEditingController _contentController = TextEditingController();

//   @override
//   void initState() {
//     super.initState();
//     // 在初始化阶段，从持久化存储中获取上次编辑内容
//     _titleController.text = tmpTitle;
//     _contentController.text = tmpContext;
//   }

//   @override
//   void dispose() {
//     _titleController.dispose();
//     _contentController.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return WillPopScope(
//       onWillPop: () async {
//         tmpTitle = _titleController.text;
//         tmpContext = _contentController.text;
//         return true;
//       },
//       child: AlertDialog(
//         contentPadding: const EdgeInsets.fromLTRB(20.0, 20.0, 20.0, 0.0),
//         title: const Text('新建'),
//         content: SizedBox(
//           width: 800.0, // 设置对话框的宽度
//           height: 400.0, // 设置对话框的高度
//           child: Column(
//             mainAxisSize: MainAxisSize.min,
//             children: [
//               TextField(
//                 controller: _titleController,
//                 maxLines: 1,
//                 decoration: const InputDecoration(
//                   hintText: '标题',
//                   border: OutlineInputBorder(),
//                 ),
//               ),
//               const SizedBox(height: 5),
//               TextField(
//                 controller: _contentController,
//                 maxLines: 3,
//                 minLines: 3,
//                 decoration: const InputDecoration(
//                   hintText: '内容',
//                   border: OutlineInputBorder(),
//                 ),
//               ),
//             ],
//           ),
//         ),
//         actions: [
//           TextButton(
//             onPressed: () {
//               var lastestNote = Notes(ObjectId(), "", _titleController.text,
//                   _contentController.text,
//                   noteUpdateTime: DateTime.now().toString());
//               realm.write(() {
//                 realm.add<Notes>(lastestNote, update: true);
//               });
//               tmpTitle = "";
//               tmpContext = "";
//               Navigator.pop(context);
//               widget.onDialogClosed();
//             },
//             child: const Text('确定'),
//           ),
//         ],
//       ),
//     );
//   }
// }

// class OldNoteDialog extends StatefulWidget {
//   const OldNoteDialog({
//     Key? key,
//     required this.onDialogClosed,
//     required this.notes,
//   }) : super(key: key);
//   final Notes notes;
//   final VoidCallback onDialogClosed;

//   @override
//   OldNoteDialogState createState() => OldNoteDialogState();
// }

// class OldNoteDialogState extends State<OldNoteDialog> {
//   final TextEditingController _titleController = TextEditingController();
//   final TextEditingController _contentController = TextEditingController();
//   bool _isEditingEnabled = true;

//   @override
//   void initState() {
//     super.initState();
//     _titleController.text = widget.notes.noteTitle;
//     _contentController.text = widget.notes.noteContext;
//   }

//   @override
//   void dispose() {
//     _titleController.dispose();
//     _contentController.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return WillPopScope(
//       onWillPop: () async {
//         // latestNote.noteTitle = _titleController.text;
//         // latestNote.noteContext = _contentController.text;
//         return true;
//       },
//       child: AlertDialog(
//         contentPadding: const EdgeInsets.fromLTRB(20.0, 20.0, 20.0, 0.0),
//         title: const Text('编辑'),
//         content: SizedBox(
//           width: 800.0,
//           height: 400.0,
//           child: Column(
//             mainAxisSize: MainAxisSize.min,
//             children: [
//               TextField(
//                 controller: _titleController..text = widget.notes.noteTitle,
//                 maxLines: 1,
//                 enabled: _isEditingEnabled,
//                 decoration: const InputDecoration(
//                   hintText: '标题',
//                   border: OutlineInputBorder(),
//                 ),
//               ),
//               const SizedBox(height: 5),
//               TextField(
//                 controller: _contentController..text = widget.notes.noteContext,
//                 maxLines: 3,
//                 minLines: 3,
//                 enabled: _isEditingEnabled,
//                 decoration: const InputDecoration(
//                   hintText: '内容',
//                   border: OutlineInputBorder(),
//                 ),
//               ),
//             ],
//           ),
//         ),
//         actions: [
//           TextButton(
//             onPressed: () {
//               setState(() {
//                 _isEditingEnabled = !_isEditingEnabled;
//               });
//             },
//             child: Text(
//               _isEditingEnabled ? '完成' : '编辑',
//               style: const TextStyle(fontWeight: FontWeight.bold),
//             ),
//           ),
//           TextButton(
//             onPressed: () {
//               realm.write(() {
//                 widget.notes.noteTitle = _titleController.text;
//                 widget.notes.noteContext = _contentController.text;
//                 widget.notes.noteCreatTime = DateTime.now().toString();
//               });
//               Navigator.pop(context);
//               widget.onDialogClosed();
//             },
//             child: const Text(
//               '确定',
//               style: TextStyle(fontWeight: FontWeight.bold),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }

// class InputPage extends StatefulWidget {
//   final VoidCallback onPageClosed;

//   const InputPage({super.key, required this.onPageClosed});
//   _InputPageState createState() => _InputPageState();
// }

// class _InputPageState extends State<InputPage> {
//   TextEditingController titleController = TextEditingController();
//   TextEditingController contentController = TextEditingController();
//   TextEditingController typeController = TextEditingController();

//   FocusNode focusNode = FocusNode();
//   @override
//   void initState() {
//     super.initState();
//     focusNode.requestFocus();
//     List<Notes> typeDistinctList =
//         realm.query<Notes>("noteType !=NULL DISTINCT(noteType)").toList();
//     late List<String> typeList = [];
//     for (int i = 0; i < typeDistinctList.length; i++) {
//       typeList.add(typeDistinctList[i].noteType);
//     }
//     print(typeList);
//     print(typeList.length);
//   }

//   @override
//   void dispose() {
//     titleController.clear();
//     contentController.clear();
//     focusNode.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return WillPopScope(
//       onWillPop: () async {
//         // 保存状态
//         await save();
//         widget.onPageClosed;
//         return Future.value(true);
//       },
//       child: Scaffold(
//         resizeToAvoidBottomInset: true,
//         appBar: AppBar(
//           leading: IconButton(
//             icon: const Icon(Icons.arrow_back),
//             onPressed: () {
//               save();
//               Navigator.pop(context);
//               widget.onPageClosed();
//             },
//           ),
//           title: const Text(""),
//           actions: [],
//         ),
//         body: Column(
//           mainAxisSize: MainAxisSize.max,
//           children: [
//             Expanded(
//               child: SingleChildScrollView(
//                 child: Padding(
//                   padding: const EdgeInsets.symmetric(
//                       horizontal: 25, // 左右间距
//                       vertical: 0 // 上下间距
//                       ),
//                   child: Column(
//                     children: [
//                       TextField(
//                         textAlign: TextAlign.center,
//                         controller: titleController,
//                         style: const TextStyle(
//                           fontSize: 22,
//                           fontWeight: FontWeight.w600,
//                         ),
//                         decoration: const InputDecoration(
//                           labelText: "标题",
//                           labelStyle: TextStyle(
//                             color: Colors.grey,
//                           ),
//                           // border: OutlineInputBorder(),
//                           // focusedBorder:
//                           //     OutlineInputBorder(borderSide: BorderSide(color: Colors.red)),
//                           // enabledBorder: OutlineInputBorder(
//                           //     borderSide: BorderSide(color: Colors.blue)),
//                         ),
//                       ),
//                       Row(children: [
//                         Column(
//                           children: [
//                             Container(
//                               child: TextField(
//                                 style: const TextStyle(
//                                   fontSize: 14,
//                                 ),
//                                 decoration: InputDecoration(
//                                   prefixIcon:
//                                       Icon(Icons.indeterminate_check_box),
//                                   hintText: '类型：',
//                                   border: OutlineInputBorder(
//                                     borderRadius:
//                                         BorderRadius.all(Radius.circular(8)),
//                                     borderSide: const BorderSide(width: 2),
//                                   ),
//                                 ),
//                                 controller: typeController,
//                               ),
//                             ),
//                           ],
//                         ),
//                         Column(
//                           children: [
//                             //  Column 里的内容
//                           ],
//                         )
//                       ]),
//                       TextField(
//                         focusNode: focusNode,
//                         style: const TextStyle(
//                           fontSize: 18,
//                           height: 1.5,
//                           fontWeight: FontWeight.w600,
//                         ),
//                         controller: contentController,
//                         decoration: const InputDecoration(
//                           border: InputBorder.none,
//                         ),
//                         maxLines: null,
//                         minLines: 10,
//                       ),
//                       Row(
//                         mainAxisAlignment: MainAxisAlignment.end,
//                         crossAxisAlignment: CrossAxisAlignment.center,
//                         children: [
//                           TextButton(
//                             onPressed: () async {
//                               await FlutterClipboard.copy(
//                                   contentController.text);
//                               poplog(1, '复制', context);
//                             },
//                             child: const Text('复制'),
//                           ),
//                           TextButton(
//                             onPressed: () {
//                               save();
//                               Navigator.pop(context);
//                               widget.onPageClosed();
//                             },
//                             child: const Text('保存'),
//                           ),
//                         ],
//                       ),
//                       SizedBox(height: 5),
//                     ],
//                   ),
//                 ),
//               ),
//             ),
//             // Positioned(
//             //   bottom: 0,
//             //   child: Container(
//             //     height: 30,
//             //     decoration: const BoxDecoration(
//             //       border: Border(
//             //           top: BorderSide(width: 1, color: Colors.grey),
//             //           bottom: BorderSide(width: 1, color: Colors.grey)),
//             //     ),
//             //     child: Row(
//             //       mainAxisAlignment: MainAxisAlignment.end,
//             //       crossAxisAlignment: CrossAxisAlignment.center,
//             //       children: [
//             //         TextButton(
//             //           onPressed: () {
//             //             save();
//             //           },
//             //           child: const Text('保存'),
//             //         ),
//             //       ],
//             //     ),
//             //   ),
//             // ),
//             // const SizedBox(height: 6),
//           ],
//         ),
//       ),
//     );
//   }

//   save() {
//     if (contentController.text + titleController.text != '') {
//       var lastestNote = Notes(
//           ObjectId(), "", titleController.text, contentController.text,
//           noteCreatTime: DateTime.now().toString(),
//           noteType: typeController.text);
//       realm.write(() {
//         realm.add<Notes>(lastestNote, update: true);
//         tmpContext = '';
//         tmpTitle = '';
//         poplog(1, '保存', context);
//       });
//     }
//   }
// }