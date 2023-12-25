import 'dart:math';

import 'package:flutter/material.dart';
import 'package:icebergnote/notes.dart';
import 'package:icebergnote/screen/record_input.dart';
import 'package:yaml/yaml.dart';
import 'screen/noteslist_screen.dart';

Widget buildRecordCardOfList(Notes note, int mod, BuildContext context,
    VoidCallback refreshList, Map template, Map templateProperty) {
  // var templateNote = realm.query<Notes>(
  //     "noteType == \$0 AND noteProject == \$1 AND noteIsDeleted != true SORT(noteCreateDate DESC) LIMIT(1)",
  //     [
  //       '.表单',
  //       note.noteProject,
  //     ])[0];

  // if (note.noteContext == '') {
  //   realm.write(() {
  //     note.noteContext =
  //         templateNote.noteContext.replaceAll(RegExp(r': .*'), ': ');
  //   });
  // }

  // Map template = loadYaml(templateNote.noteContext
  //     .substring(0, templateNote.noteContext.indexOf('settings'))) as YamlMap;
  // Map templateProperty = loadYaml(templateNote.noteContext
  //     .substring(templateNote.noteContext.indexOf('settings'))) as YamlMap;
  Map noteMapInit = loadYaml(note.noteContext) as Map;
  Map noteMap = template.map((key, value) {
    MapEntry entry = MapEntry(key, noteMapInit[key]);
    return entry;
  });
  Map noteMapOther = {...noteMap};
  noteMapOther.remove(noteMapOther.keys.first);
  noteMapOther.removeWhere((key, value) => value == null);
  Color backgroundColor = Color.fromARGB(
    40,
    templateProperty['color'][0],
    templateProperty['color'][1],
    templateProperty['color'][2],
  );
  Color fontColor = Color.fromARGB(
    255,
    max(0, min(templateProperty['color'][0] - 50, 255)),
    max(0, min(templateProperty['color'][1] - 50, 255)),
    max(0, min(templateProperty['color'][2] - 50, 255)),
  );
  List propertySettings1 = template.values.elementAt(0).split(",");
  return Card(
    margin: const EdgeInsets.fromLTRB(15, 0, 15, 10),
    elevation: 0,
    shadowColor: const Color.fromARGB(255, 255, 132, 132),
    color: backgroundColor,
    child: ListTile(
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '${mod == 3 ? '' : '${note.noteProject}  '}${propertySettings1[2] ?? ''}${noteMap[noteMap.keys.first] ?? ''}${propertySettings1[3] ?? ''}',
            maxLines: 3,
            overflow: TextOverflow.fade,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: fontColor,
            ),
          ),
          const SizedBox(height: 8)
        ],
      ),
      subtitle: Wrap(
        spacing: 5,
        runSpacing: 5,
        children: List.generate(
          noteMapOther.length,
          (index) {
            List propertySettings = ['', '', '', ''];
            if (template.containsKey(noteMapOther.keys.elementAt(index))) {
              propertySettings =
                  template[noteMapOther.keys.elementAt(index)].split(",");
            }
            if (noteMapOther.values.elementAt(index) != null &&
                noteMapOther.values.elementAt(index) != '') {
              switch (propertySettings[1]) {
                case '长文':
                  return Row(
                    crossAxisAlignment: CrossAxisAlignment.baseline,
                    textBaseline: TextBaseline.ideographic,
                    children: [
                      Container(
                        margin: const EdgeInsets.all(0),
                        padding: const EdgeInsets.fromLTRB(5, 0, 5, 0),
                        constraints: const BoxConstraints(maxWidth: 43),
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
                        padding: const EdgeInsets.fromLTRB(5, 0, 5, 0),
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
                                margin: const EdgeInsets.fromLTRB(0, 0, 5, 0),
                                padding: const EdgeInsets.fromLTRB(5, 0, 5, 0),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(20),
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
                  Duration? setDuration = stringToDuration(
                      noteMapOther.values.elementAt(index).toString());
                  List<String> timeList = noteMapOther.values
                      .elementAt(index)
                      .toString()
                      .split(':');
                  return Row(
                    mainAxisSize: MainAxisSize.max,
                    children: [
                      Container(
                        margin: const EdgeInsets.all(0),
                        padding: const EdgeInsets.fromLTRB(5, 0, 5, 0),
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
                      Text(
                        setDuration == null
                            ? noteMapOther.values.elementAt(index).toString()
                            : '${timeList[0] == '0' ? '' : '${timeList[0]}时'}${timeList[1]}分${timeList[2] == '0' ? '' : '${timeList[2]}秒'}',
                        style: TextStyle(
                          fontFamily: 'LXGWWenKai',
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: setDuration == null ? Colors.red : fontColor,
                        ),
                      ),
                    ],
                  );
                case '时长':
                  Duration? duration = stringToDuration(
                      noteMapOther.values.elementAt(index).toString());
                  if (duration == null) {
                    return Row(
                      mainAxisSize: MainAxisSize.max,
                      children: [
                        Container(
                          margin: const EdgeInsets.all(0),
                          padding: const EdgeInsets.fromLTRB(5, 0, 5, 0),
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
                          ' : ',
                          style: TextStyle(
                            fontFamily: 'LXGWWenKai',
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: fontColor,
                          ),
                        ),
                        Text(
                          noteMapOther.values.elementAt(index).toString(),
                          style: const TextStyle(
                            fontFamily: 'LXGWWenKai',
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.red,
                          ),
                        ),
                      ],
                    );
                  } else {
                    return Row(
                      mainAxisSize: MainAxisSize.max,
                      children: [
                        Container(
                          margin: const EdgeInsets.all(0),
                          padding: const EdgeInsets.fromLTRB(5, 0, 5, 0),
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
                          ' : ${duration.inDays == 0 ? '' : '${duration.inDays}天'}${duration.inHours == 0 ? '' : '${duration.inHours % 24}时'}${duration.inMinutes == 0 ? '' : '${duration.inMinutes % 60}分'}${duration.inSeconds == 0 ? '' : '${duration.inSeconds % 60}秒'}',
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
                case '数字':
                  double? number = double.tryParse(
                      noteMapOther.values.elementAt(index).toString());
                  return Row(
                    mainAxisSize: MainAxisSize.max,
                    children: [
                      Container(
                        margin: const EdgeInsets.all(0),
                        padding: const EdgeInsets.fromLTRB(5, 0, 5, 0),
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
                        ' : ',
                        style: TextStyle(
                          fontFamily: 'LXGWWenKai',
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: fontColor,
                        ),
                      ),
                      Text(
                        '${propertySettings[2] ?? ''}${noteMapOther.values.elementAt(index).toString().replaceAll('    ', '\n${' ' * (propertySettings[0].runes.length * 2 + 2)}')}${propertySettings[3] ?? ''}',
                        style: TextStyle(
                          fontFamily: 'LXGWWenKai',
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: number == null ? Colors.red : fontColor,
                        ),
                      ),
                    ],
                  );
                case '日期':
                  return Row(
                    mainAxisSize: MainAxisSize.max,
                    children: [
                      Container(
                        margin: const EdgeInsets.all(0),
                        padding: const EdgeInsets.fromLTRB(5, 0, 5, 0),
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
                        ' : ',
                        style: TextStyle(
                          fontFamily: 'LXGWWenKai',
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: fontColor,
                        ),
                      ),
                      Text(
                        '${propertySettings[2] ?? ''}${noteMapOther.values.elementAt(index).toString()}${propertySettings[3] ?? ''}',
                        style: TextStyle(
                          fontFamily: 'LXGWWenKai',
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: RegExp(r'\d{4}-\d{1,2}-\d{1,2}').hasMatch(
                                  noteMapOther.values
                                      .elementAt(index)
                                      .toString())
                              ? fontColor
                              : Colors.red,
                        ),
                      ),
                    ],
                  );
                case '清单':
                  List<String?> todoList =
                      noteMapOther.values.elementAt(index).split('////');
                  return Row(
                    crossAxisAlignment: CrossAxisAlignment.baseline,
                    textBaseline: TextBaseline.ideographic,
                    children: [
                      Container(
                        margin: const EdgeInsets.all(0),
                        padding: const EdgeInsets.fromLTRB(5, 0, 5, 0),
                        constraints: const BoxConstraints(maxWidth: 43),
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
                        ' : ',
                        style: TextStyle(
                          fontFamily: 'LXGWWenKai',
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: fontColor,
                        ),
                      ),
                      Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: List.generate(
                          todoList.length,
                          (index) => todoList[index] != null
                              ? Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  mainAxisSize: MainAxisSize.max,
                                  children: [
                                    Visibility(
                                      visible:
                                          todoList[index]!.startsWith('- [ ] '),
                                      child: SizedBox(
                                        width: 23,
                                        height: 23,
                                        child: Checkbox.adaptive(
                                          fillColor: MaterialStateProperty.all(
                                              const Color.fromARGB(0, 0, 0, 0)),
                                          checkColor: fontColor,
                                          value: false,
                                          onChanged: (bool? value) {},
                                        ),
                                      ),
                                    ),
                                    Visibility(
                                      visible:
                                          todoList[index]!.startsWith('- [x] '),
                                      child: SizedBox(
                                        width: 23,
                                        height: 23,
                                        child: Checkbox.adaptive(
                                          fillColor: MaterialStateProperty.all(
                                              fontColor),
                                          value: true,
                                          onChanged: (bool? value) {},
                                        ),
                                      ),
                                    ),
                                    Text(
                                      todoList[index]!
                                          .replaceFirst('- [ ] ', '')
                                          .replaceFirst('- [x] ', ''),
                                      maxLines: 5,
                                      style: TextStyle(
                                        fontFamily: 'LXGWWenKai',
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                        color: fontColor,
                                      ),
                                    )
                                  ],
                                )
                              : const Row(),
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
                        padding: const EdgeInsets.fromLTRB(5, 0, 5, 0),
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
              onPageClosed: () {
                refreshList();
              },
              note: note,
              mod: 1,
            ),
          ),
        );
      },
      onLongPress: () {
        showModalBottomSheet(
          context: context,
          builder: (context) {
            if (mod == 2) {
              return BottomPopSheetDeleted(
                note: note,
                onDialogClosed: () {
                  refreshList();
                },
              );
            } else {
              return BottomPopSheet(
                note: note,
                onDialogClosed: () {
                  refreshList();
                },
              );
            }
          },
        );
      },
    ),
  );
}
