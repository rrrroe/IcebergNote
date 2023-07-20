// Copyright 2021 The Flutter team. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:realm/realm.dart';
import 'constants.dart';
import 'home.dart';
import 'notes.dart';

class NotesList {
  var visibleItemCount = 15;
  late RealmResults<Notes> notesList;
  NotesList() {
    notesList = realm.query<Notes>(
        "noteIsDeleted != true SORT(id DESC) LIMIT($visibleItemCount)");
  }

  increase(int n) {
    visibleItemCount = notesList.length + n;
    notesList = realm.query<Notes>(
        "noteIsDeleted != true SORT(id DESC) LIMIT($visibleItemCount)");
  }

  reinit(int n) {
    notesList = realm.query<Notes>(
        "noteIsDeleted != true SORT(id DESC) LIMIT($visibleItemCount)");
  }

  search(String n, int m) {
    visibleItemCount = visibleItemCount + m;
    notesList = realm.query<Notes>(
        "( noteTitle CONTAINS[c] \$0 OR noteContext CONTAINS[c] \$0 ) AND noteIsDeleted != true SORT(id DESC) LIMIT($visibleItemCount)",
        [n]);
  }

  searchDeleted(String n, int m) {
    visibleItemCount = visibleItemCount + m;
    notesList = realm.query<Notes>(
        "( noteTitle CONTAINS[c] \$0 OR noteContext CONTAINS[c] \$0 ) AND noteIsDeleted == true SORT(id DESC) LIMIT($visibleItemCount)",
        [n]);
  }

  searchTodo(String n, int m) {
    visibleItemCount = visibleItemCount + m;
    notesList = realm.query<Notes>(
        "( noteTitle CONTAINS[c] \$0 OR noteContext CONTAINS[c] \$0 ) AND ( noteType == '.TODO' OR noteType == '.todo' OR noteType == '.Todo' OR noteType == '.待办' ) SORT(id DESC) LIMIT($visibleItemCount)",
        [n]);
  }

  searchall(String n, int m, String type, String project, String folder) {
    visibleItemCount = visibleItemCount + m;
    notesList = realm.query<Notes>(
        "( noteTitle CONTAINS[c] \$0 OR noteContext CONTAINS[c] \$0 ) AND ( noteType CONTAINS[c] \$1 AND noteProject CONTAINS[c] \$2 AND noteFolder CONTAINS[c] \$3 ) SORT(id DESC) LIMIT($visibleItemCount)",
        [n, type, project, folder]);
  }
}

var mainnotesList = NotesList();

late Realm realm;

void main() {
  final config = Configuration.local([Notes.schema], schemaVersion: 8);
  realm = Realm(config);
  runApp(
    const App(),
  );
}

class App extends StatefulWidget {
  const App({super.key});

  @override
  State<App> createState() => _AppState();
}

class _AppState extends State<App> {
  bool useMaterial3 = true;
  ThemeMode themeMode = ThemeMode.system;
  ColorSeed colorSelected = ColorSeed.blue;

  bool get useLightMode {
    switch (themeMode) {
      case ThemeMode.system:
        return SchedulerBinding.instance.window.platformBrightness ==
            Brightness.light;
      case ThemeMode.light:
        return true;
      case ThemeMode.dark:
        return false;
    }
  }

  void handleBrightnessChange(bool useLightMode) {
    setState(() {
      themeMode = useLightMode ? ThemeMode.light : ThemeMode.dark;
    });
  }

  void handleMaterialVersionChange() {
    setState(() {
      useMaterial3 = !useMaterial3;
    });
  }

  void handleColorSelect(int value) {
    setState(() {
      colorSelected = ColorSeed.values[value];
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Material 3',
      themeMode: themeMode,
      theme: ThemeData(
        colorSchemeSeed: colorSelected.color,
        useMaterial3: useMaterial3,
        brightness: Brightness.light,
        fontFamily: 'LXGWWenKai',
      ),
      darkTheme: ThemeData(
        colorSchemeSeed: colorSelected.color,
        useMaterial3: useMaterial3,
        brightness: Brightness.dark,
        fontFamily: 'LXGWWenKai',
      ),
      home: Home(
        useLightMode: useLightMode,
        useMaterial3: useMaterial3,
        colorSelected: colorSelected,
        handleBrightnessChange: handleBrightnessChange,
        handleMaterialVersionChange: handleMaterialVersionChange,
        handleColorSelect: handleColorSelect,
      ),
    );
  }
}
