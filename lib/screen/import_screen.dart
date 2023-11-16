// ignore_for_file: prefer_final_fields

import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:csv/csv.dart';
import 'package:realm/realm.dart';
import '../constants.dart';
import '../main.dart';
import '../notes.dart';
import 'input_screen.dart';

class ImportPage extends StatefulWidget {
  const ImportPage({super.key});

  @override
  ImportPageState createState() => ImportPageState();
}

class ImportPageState extends State<ImportPage> {
  final _scaffoldMessengerKey = GlobalKey<ScaffoldMessengerState>();
  // final _defaultFileNameController = TextEditingController();
  final _dialogTitleController = TextEditingController();
  final _initialDirectoryController = TextEditingController();
  String? _fileName;
  List<PlatformFile>? _paths;
  String? _directoryPath;
  String? _extension;
  bool _isLoading = false;
  bool _lockParentWindow = false;
  bool _userAborted = false;
  bool _multiPick = false;
  FileType _pickingType = FileType.any;
  String content = '';
  String importType = '';
  String importProject = '';
  String importFolder = '';
  List<String> typeList = ['新建', '清空'];
  List<String> folderList = ['新建', '清空'];
  List<String> projectList = ['新建', '清空'];
  late File file;
  @override
  void initState() {
    super.initState();
    file = File('');
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
  }

  @override
  void dispose() {
    super.dispose();
  }

  void _pickFiles() async {
    _resetState();
    try {
      _directoryPath = null;
      _paths = (await FilePicker.platform.pickFiles(
        type: _pickingType,
        allowMultiple: _multiPick,
        onFileLoading: (FilePickerStatus status) {},
        allowedExtensions: (_extension?.isNotEmpty ?? false)
            ? _extension?.replaceAll(' ', '').split(',')
            : null,
        dialogTitle: _dialogTitleController.text,
        initialDirectory: _initialDirectoryController.text,
        lockParentWindow: _lockParentWindow,
      ))
          ?.files;
    } on PlatformException catch (e) {
      _logException('Unsupported operation$e');
    } catch (e) {
      _logException(e.toString());
    }
    if (!mounted) return;
    _isLoading = false;
    _fileName = _paths != null ? _paths!.map((e) => e.name).toString() : '...';
    _userAborted = _paths == null;
    if (_paths != null) {
      file = File(_paths!.first.path.toString());
      content = await file.readAsString();
    }

    setState(() {});
  }

  // void _clearCachedFiles() async {
  //   _resetState();
  //   try {
  //     bool? result = await FilePicker.platform.clearTemporaryFiles();
  //     _scaffoldMessengerKey.currentState?.hideCurrentSnackBar();
  //     _scaffoldMessengerKey.currentState?.showSnackBar(
  //       SnackBar(
  //         content: Text(
  //           (result!
  //               ? 'Temporary files removed with success.'
  //               : 'Failed to clean temporary files'),
  //           style: const TextStyle(
  //             color: Colors.white,
  //           ),
  //         ),
  //       ),
  //     );
  //   } on PlatformException catch (e) {
  //     _logException('Unsupported operation$e');
  //   } catch (e) {
  //     _logException(e.toString());
  //   } finally {
  //     setState(() => _isLoading = false);
  //   }
  // }

  void _selectFolder() async {
    _resetState();
    try {
      String? path = await FilePicker.platform.getDirectoryPath(
        dialogTitle: _dialogTitleController.text,
        initialDirectory: _initialDirectoryController.text,
        lockParentWindow: _lockParentWindow,
      );
      setState(() {
        _directoryPath = path;
        _userAborted = path == null;
      });
    } on PlatformException catch (e) {
      _logException('Unsupported operation$e');
    } catch (e) {
      _logException(e.toString());
    } finally {
      setState(() => _isLoading = false);
    }
  }

  // Future<void> _saveFile() async {
  //   _resetState();
  //   try {
  //     String? fileName = await FilePicker.platform.saveFile(
  //       allowedExtensions: (_extension?.isNotEmpty ?? false)
  //           ? _extension?.replaceAll(' ', '').split(',')
  //           : null,
  //       type: _pickingType,
  //       dialogTitle: _dialogTitleController.text,
  //       fileName: _defaultFileNameController.text,
  //       initialDirectory: _initialDirectoryController.text,
  //       lockParentWindow: _lockParentWindow,
  //     );
  //     setState(() {
  //       _userAborted = fileName == null;
  //     });
  //   } on PlatformException catch (e) {
  //     _logException('Unsupported operation$e');
  //   } catch (e) {
  //     _logException(e.toString());
  //   } finally {
  //     setState(() => _isLoading = false);
  //   }
  // }

  void _logException(String message) {
    _scaffoldMessengerKey.currentState?.hideCurrentSnackBar();
    _scaffoldMessengerKey.currentState?.showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: const TextStyle(
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  void _resetState() {
    if (!mounted) {
      return;
    }
    setState(() {
      _isLoading = true;
      _directoryPath = null;
      _fileName = null;
      _paths = null;
      _userAborted = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("导入")),
      body: Align(
        alignment: Alignment.center,
        child: Column(
          children: [
            Wrap(
              spacing: 20,
              runSpacing: 20,
              children: [
                SizedBox(
                  width: 140,
                  child: ElevatedButton(
                    onPressed: () => _pickFiles(),
                    child: const Text('请选择文件'),
                  ),
                ),
                SizedBox(
                  width: 140,
                  child: ElevatedButton(
                    onPressed: () => _selectFolder(),
                    child: const Text('请选择文件夹'),
                  ),
                ),
              ],
            ),
            // SizedBox(
            //   width: 200,
            //   child: ElevatedButton(
            //     onPressed: () => _clearCachedFiles(),
            //     child: Text('Clear temporary files'),
            //   ),
            // ),
            Builder(
              builder: (BuildContext context) => _isLoading
                  ? const Row(
                      children: [
                        Expanded(
                          child: Center(
                            child: Padding(
                              padding: EdgeInsets.symmetric(
                                vertical: 40.0,
                              ),
                              child: CircularProgressIndicator(),
                            ),
                          ),
                        ),
                      ],
                    )
                  : _userAborted
                      ? const Row(
                          children: [
                            Expanded(
                              child: Center(
                                child: SizedBox(
                                  width: 300,
                                  child: ListTile(
                                    leading: Icon(
                                      Icons.error_outline,
                                    ),
                                    contentPadding:
                                        EdgeInsets.symmetric(vertical: 40.0),
                                    title: Text(
                                      'User has aborted the dialog',
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        )
                      : _directoryPath != null
                          ? ListTile(
                              title: const Text('Directory path'),
                              subtitle: Text(_directoryPath!),
                            )
                          : _paths != null
                              ? Container(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 20.0,
                                  ),
                                  height:
                                      MediaQuery.of(context).size.height * 0.50,
                                  child: Scrollbar(
                                      child: ListView.separated(
                                    itemCount:
                                        _paths != null && _paths!.isNotEmpty
                                            ? _paths!.length
                                            : 1,
                                    itemBuilder:
                                        (BuildContext context, int index) {
                                      final bool isMultiPath =
                                          _paths != null && _paths!.isNotEmpty;
                                      final String name =
                                          'File $index: ${isMultiPath ? _paths!.map((e) => e.name).toList()[index] : _fileName ?? '...'}';
                                      final path = kIsWeb
                                          ? null
                                          : _paths!
                                              .map((e) => e.path)
                                              .toList()[index]
                                              .toString();

                                      return ListTile(
                                        title: Text(
                                          name,
                                        ),
                                        subtitle: Text(path ?? ''),
                                      );
                                    },
                                    separatorBuilder:
                                        (BuildContext context, int index) =>
                                            const Divider(),
                                  )),
                                )
                              : const SizedBox(),
            ),
            file.path.endsWith('.csv')
                ? Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const Text('请选择类型:'),
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
                                  importType == '' ? '类型' : importType,
                                  style: importType == ''
                                      ? const TextStyle(color: Colors.grey)
                                      : const TextStyle(
                                          color: Color.fromARGB(
                                              255, 56, 128, 186)),
                                ),
                              );
                            },
                            menuChildren: typeList.map((type) {
                              return MenuItemButton(
                                style: menuChildrenButtonStyle,
                                child: Text(type),
                                onPressed: () {
                                  switch (type) {
                                    case '清空':
                                      setState(() {
                                        importType = type;
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
                                                typeList.add(text);
                                                importType = text;
                                              });
                                            },
                                          );
                                        },
                                      );
                                      break;
                                    default:
                                      setState(() {
                                        importType = type;
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
                                  importProject == '' ? '项目' : importProject,
                                  style: importProject == ''
                                      ? const TextStyle(color: Colors.grey)
                                      : const TextStyle(
                                          color:
                                              Color.fromARGB(255, 215, 55, 55)),
                                ),
                              );
                            },
                            menuChildren: projectList.map((project) {
                              return MenuItemButton(
                                style: menuChildrenButtonStyle,
                                child: Text(project),
                                onPressed: () {
                                  switch (project) {
                                    case '清空':
                                      setState(() {
                                        importProject = '';
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
                                                projectList.add(text);
                                                importProject = text;
                                              });
                                            },
                                          );
                                        },
                                      );
                                      break;
                                    default:
                                      setState(() {
                                        importProject = project;
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
                                  importFolder == '' ? '路径' : importFolder,
                                  style: importFolder == ''
                                      ? const TextStyle(color: Colors.grey)
                                      : const TextStyle(
                                          color:
                                              Color.fromARGB(255, 4, 123, 60)),
                                ),
                              );
                            },
                            menuChildren: folderList.map((folder) {
                              return MenuItemButton(
                                style: menuChildrenButtonStyle,
                                child: Text(folder),
                                onPressed: () {
                                  switch (folder) {
                                    case '清空':
                                      setState(() {
                                        importFolder = '';
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
                                                folderList.add(text);
                                                importFolder = text;
                                              });
                                            },
                                          );
                                        },
                                      );
                                      break;
                                    default:
                                      setState(() {
                                        importFolder = folder;
                                      });
                                  }
                                },
                              );
                            }).toList(),
                          ),
                          ElevatedButton(
                            style: selectButtonStyle,
                            child: const Text('确认导入'),
                            onPressed: () {
                              // if (_paths!.first.name.endsWith('.csv')) {
                              List<List<dynamic>> rowsAsListOfValues =
                                  const CsvToListConverter().convert(content);
                              int length = rowsAsListOfValues[0].length;
                              for (int i = 0;
                                  i < rowsAsListOfValues.length;
                                  i++) {
                                String noteContent = '';
                                final dateRegex1 =
                                    RegExp(r'\d{4}-\d{1,2}-\d{1,2}');
                                final dateRegex2 =
                                    RegExp(r'\d{4}/\d{1,2}/\d{1,2}');
                                if (i == 0) {
                                  for (int j = 0; j < length; j++) {
                                    noteContent =
                                        '$noteContent${j + 1}: ${rowsAsListOfValues[i][j].toString()},,,,,\n';
                                  }
                                  noteContent =
                                      '${noteContent}settings: 1\ncolor: [135, 198, 181]';
                                  importType = '.表头';
                                } else {
                                  for (int j = 0; j < length; j++) {
                                    if (rowsAsListOfValues[i][j]
                                                .toString()
                                                .length >
                                            10 &&
                                        dateRegex1.hasMatch(
                                            rowsAsListOfValues[i][j]
                                                .toString()
                                                .substring(0, 9))) {
                                    } else if (rowsAsListOfValues[i][j]
                                                .toString()
                                                .length >
                                            10 &&
                                        dateRegex2.hasMatch(
                                            rowsAsListOfValues[i][j]
                                                .toString()
                                                .substring(0, 9))) {
                                    } else if (int.tryParse(
                                                rowsAsListOfValues[i][j]
                                                    .toString()) !=
                                            null &&
                                        rowsAsListOfValues[i][j]
                                                .toString()
                                                .length ==
                                            13) {
                                      DateTime dateTime =
                                          DateTime.fromMillisecondsSinceEpoch(
                                              rowsAsListOfValues[i][j]);
                                      String m = dateTime.month.toString();
                                      String d = dateTime.day.toString();
                                      if (dateTime.month < 10) m = '0$m';
                                      if (dateTime.day < 10) d = '0$d';
                                      noteContent =
                                          '$noteContent${j + 1}: ${dateTime.year.toString()}-$m-$d\n';

                                      // } else if (j == 7) {
                                      //   double? num = double.tryParse(
                                      //       rowsAsListOfValues[i][j].toString());
                                      //   if (num == null) {
                                      //     noteContent =
                                      //         '$noteContent${j + 1}: ${rowsAsListOfValues[i][j].toString().replaceAll('\n', '    ')}\n';
                                      //   } else {
                                      //     int num2 = num.toInt();
                                      //     int num3 = (num % 1 * 60).toInt();
                                      //     noteContent =
                                      //         '$noteContent${j + 1}: ${num2.toString()}:${num3.toString()}:0\n';
                                      //   }
                                    } else if (rowsAsListOfValues[i][j]
                                                .toString()
                                                .length ==
                                            10 &&
                                        rowsAsListOfValues[i][j][4]
                                                .toString() ==
                                            '/' &&
                                        rowsAsListOfValues[i][j][7]
                                                .toString() ==
                                            '/') {
                                      noteContent =
                                          '$noteContent${j + 1}: ${rowsAsListOfValues[i][j].toString().replaceAll('/', '-')}\n';
                                    } else {
                                      noteContent =
                                          '$noteContent${j + 1}: ${rowsAsListOfValues[i][j].toString().replaceAll('\n', '    ')}\n';
                                    }
                                  }
                                  importType = '.记录';
                                }

                                realm.write(() {
                                  realm.add<Notes>(Notes(
                                    Uuid.v4(),
                                    importFolder,
                                    '',
                                    noteContent,
                                    DateTime.now().toUtc(),
                                    DateTime.now().toUtc(),
                                    DateTime(1970, 1, 1),
                                    DateTime(1970, 1, 1),
                                    DateTime(1970, 1, 1),
                                    DateTime(1970, 1, 1),
                                    noteProject: importProject,
                                    noteType: importType,
                                  ));
                                });
                              }
                            },
                          )
                        ],
                      ),
                      const Text('文件内容:'),
                      Text(content),
                    ],
                  )
                : const SizedBox()
          ],
        ),
      ),
    );
  }

  getfile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles();

    if (result != null) {
      File file = File(result.files.single.path ?? '');
      return file;
    } else {
      return null;
    }
  }

  getFileContent() async {
    return file.readAsString();
  }
}
