import 'package:flutter/material.dart';
import 'package:realm/realm.dart';

import '../notes.dart';

class RecordTable extends StatefulWidget {
  const RecordTable({
    super.key,
    required this.recordList,
    required this.notesList,
    required this.color,
    required this.template,
  });
  final List<Map> recordList;
  final RealmResults<Notes> notesList;
  final Color color;
  final Map template;

  @override
  State<RecordTable> createState() => _RecordTableState();
}

class _RecordTableState extends State<RecordTable> {
  List<int> showList = [];
  Map template = {};
  @override
  Widget build(BuildContext context) {
    return Table(
      border: TableBorder.all(),
      children: buildRow() + buildRow(),
    );
  }

  @override
  void initState() {
    super.initState();
    widget.template.forEach((key, value) {
      showList.add(key);
      template[key] = value.toString().split(',');
    });
    print(showList);
    print(template);
  }

  List<TableRow> buildRow() {
    List<TableRow> list = [];
    for (var element in showList) {
      list.add(TableRow(children: [
        Center(child: Text(template[element][0].toString())),
      ]));
    }
    return list;
  }
}
