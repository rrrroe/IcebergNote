// Copyright 2021 The Flutter team. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
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
    if (notesList[0].noteTitle + notesList[0].noteContext == '') {
      realm.write(() {
        realm.delete(notesList[0]);
        visibleItemCount = visibleItemCount - 1;
      });
    }
  }

  increase(int n) {
    visibleItemCount = notesList.length + n;
    notesList = realm.query<Notes>(
        "noteIsDeleted != true SORT(id DESC) LIMIT($visibleItemCount)");
    if (notesList[0].noteTitle + notesList[0].noteContext == '') {
      realm.write(() {
        realm.delete(notesList[0]);
        visibleItemCount = visibleItemCount - 1;
      });
    }
  }

  reinit(int n) {
    notesList = realm.query<Notes>(
        "noteIsDeleted != true SORT(id DESC) LIMIT($visibleItemCount)");
    if (notesList[0].noteTitle + notesList[0].noteContext == '') {
      realm.write(() {
        realm.delete(notesList[0]);
        visibleItemCount = visibleItemCount - 1;
      });
    }
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

  searchall(String n, int m, String type, String project, String folder,
      String finishstate) {
    visibleItemCount = visibleItemCount + m;
    notesList = realm.query<Notes>(
        "( noteTitle CONTAINS[c] \$0 OR noteContext CONTAINS[c] \$0 ) AND ( noteType CONTAINS[c] \$1 AND noteProject CONTAINS[c] \$2 AND noteFolder CONTAINS[c] \$3 AND noteFinishState CONTAINS[c] \$4 ) AND noteIsDeleted != true SORT(id DESC) LIMIT($visibleItemCount)",
        [n, type, project, folder, finishstate]);
    if (notesList[0].noteTitle + notesList[0].noteContext == '') {
      realm.write(() {
        realm.delete(notesList[0]);
        visibleItemCount = visibleItemCount - 1;
      });
    }
  }
}

var mainnotesList = NotesList();
late Realm realm;

void main() {
  final config = Configuration.local([Notes.schema], schemaVersion: 11);
  realm = Realm(config);

  var deleteOvertime = realm.query<Notes>(
      "noteIsDeleted == true AND noteUpdateTime < \$0 AND noteCreatTime < \$0 SORT(id DESC)",
      [DateTime.now().add(const Duration(days: -80)).toString()]);
  for (int i = 0; i < deleteOvertime.length; i++) {
    realm.write(() {
      realm.delete(deleteOvertime[i]);
    });
  }
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
        return View.of(context).platformDispatcher.platformBrightness ==
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
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('en', 'US'), // English
        Locale('zh', 'CN'), // Thai
      ],
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
