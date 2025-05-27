// Copyright 2021 The Flutter team. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:cherry_toast/cherry_toast.dart';
import 'package:cherry_toast/resources/arrays.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:get/get.dart';
import 'package:icebergnote/class/habit.dart';
import 'package:icebergnote/postgresql/sync.dart';
import 'package:icebergnote/screen/login_screen.dart';
import 'package:realm/realm.dart';
import 'constants.dart';
import 'home.dart';
import 'class/notes.dart';
import 'settings/record_temlates.dart';
import 'system/device_id.dart';

class NotesList {
  var visibleItemCount = 50;
  late RealmResults<Notes> notesList;
  NotesList() {
    notesList = realm.query<Notes>(
        "noteIsDeleted != true SORT(noteCreateDate DESC) LIMIT(1)");
    if (notesList.isEmpty != true) {
      if (notesList[0].noteTitle + notesList[0].noteContext == '') {
        realm.write(() {
          realm.delete(notesList[0]);
          visibleItemCount = visibleItemCount - 1;
        });
      }
    }
  }

  increase(int n) {
    visibleItemCount = notesList.length + n;
    notesList = realm.query<Notes>(
        "noteIsDeleted != true SORT(noteCreateDate DESC) LIMIT($visibleItemCount)");
    if (notesList.isEmpty != true) {
      if (notesList[0].noteTitle + notesList[0].noteContext == '') {
        realm.write(() {
          realm.delete(notesList[0]);
          visibleItemCount = visibleItemCount - 1;
        });
      }
    }
  }

  reinit(int n) {
    notesList = realm.query<Notes>(
        "noteIsDeleted != true SORT(noteCreateDate DESC) LIMIT($visibleItemCount)");
    if (notesList.isEmpty != true) {
      if (notesList[0].noteTitle + notesList[0].noteContext == '') {
        realm.write(() {
          realm.delete(notesList[0]);
          visibleItemCount = visibleItemCount - 1;
        });
      }
    }
    Get.forceAppUpdate();
  }

  search(String n, int m) {
    visibleItemCount = visibleItemCount + m;
    notesList = realm.query<Notes>(
        "( noteTitle CONTAINS[c] \$0 OR noteContext CONTAINS[c] \$0 ) AND noteIsDeleted != true SORT(noteCreateDate DESC) LIMIT($visibleItemCount)",
        [n]);
  }

  searchDeleted(String n, int m) {
    visibleItemCount = visibleItemCount + m;
    notesList = realm.query<Notes>(
        "( noteTitle CONTAINS[c] \$0 OR noteContext CONTAINS[c] \$0 ) AND noteIsDeleted == true SORT(noteCreateDate DESC) LIMIT($visibleItemCount)",
        [n]);
  }

  searchTodo(String n, int m) {
    visibleItemCount = visibleItemCount + m;
    notesList = realm.query<Notes>(
        "( noteTitle CONTAINS[c] \$0 OR noteContext CONTAINS[c] \$0 ) AND ( noteType == '.TODO' OR noteType == '.todo' OR noteType == '.Todo' OR noteType == '.待办' OR noteType == '.清单' ) SORT(noteCreateDate DESC) LIMIT($visibleItemCount)",
        [n]);
  }

  searchall(String n, int m, String type, String project, String folder,
      String finishstate) {
    visibleItemCount = visibleItemCount + m;
    notesList = realm.query<Notes>(
        "( noteTitle CONTAINS[c] \$0 OR noteContext CONTAINS[c] \$0 ) AND ( noteType CONTAINS[c] \$1 AND noteProject CONTAINS[c] \$2 AND noteFolder CONTAINS[c] \$3 AND noteFinishState CONTAINS[c] \$4 ) AND noteIsDeleted != true SORT(noteCreateDate DESC) LIMIT($visibleItemCount)",
        [n, type, project, folder, finishstate]);
    if (notesList.isEmpty != true) {
      if (notesList[0].noteTitle + notesList[0].noteContext == '') {
        realm.write(() {
          realm.delete(notesList[0]);
          visibleItemCount = visibleItemCount - 1;
        });
      }
    }
  }

  searchallTodo(String n, int m, String type, String project, String folder,
      String finishstate) {
    visibleItemCount = visibleItemCount + m;
    notesList = realm.query<Notes>(
        "( noteTitle CONTAINS[c] \$0 OR noteContext CONTAINS[c] \$0 ) AND ( noteType == '.TODO' OR noteType == '.todo' OR noteType == '.Todo' OR noteType == '.待办' OR noteType == '.清单' ) AND ( noteProject CONTAINS[c] \$2 AND noteFolder CONTAINS[c] \$3 AND noteFinishState CONTAINS[c] \$4 ) AND noteIsDeleted != true SORT(noteCreateDate DESC) LIMIT($visibleItemCount)",
        [n, type, project, folder, finishstate]);
    if (notesList.isEmpty != true) {
      if (notesList[0].noteTitle + notesList[0].noteContext == '') {
        realm.write(() {
          realm.delete(notesList[0]);
          visibleItemCount = visibleItemCount - 1;
        });
      }
    }
  }

  searchStar(String n, int m) {
    visibleItemCount = visibleItemCount + m;
    notesList = realm.query<Notes>(
        "( noteTitle CONTAINS[c] \$0 OR noteContext CONTAINS[c] \$0 ) AND ( noteIsStarred == true ) AND noteIsDeleted != true SORT(noteCreateDate DESC) LIMIT($visibleItemCount)",
        [n]);
  }
}

var mainnotesList = NotesList();
late Realm realm;
late Realm realmHabit;
late Realm realmHabitRecord;
Map<String, Map<int, List>> recordTemplates = {};
Map<String, Map<String, List>> recordTemplatesSettings = {};
bool isFinishSync = false;

void main() async {
  final config = Configuration.local([Notes.schema], schemaVersion: 1);
  realm = Realm(config);
  final configHabit = Configuration.local([Habit.schema], schemaVersion: 1);
  realmHabit = Realm(configHabit);
  final configHabitRecord =
      Configuration.local([HabitRecord.schema], schemaVersion: 1);
  realmHabitRecord = Realm(configHabitRecord);
  // userLocalInfo = await SharedPreferences.getInstance();
  var deleteOvertime = realm.query<Notes>(
      "noteIsDeleted == true AND noteUpdateDate < \$0 AND noteCreateDate < \$0 SORT(noteCreateDate DESC)",
      [DateTime.now().toUtc()]);
  for (int i = 0; i < deleteOvertime.length; i++) {
    realm.write(() {
      realm.delete(deleteOvertime[i]);
    });
  }

  getUniqueId();
  recordTemplateInit();

  // try {
  //   await exchangeSmart().timeout(const Duration(seconds: 3));
  // } catch (e) {
  //   if (kDebugMode) {
  //     print('超时:$e');
  //   }
  // }
  runApp(
    const App(),
  );

  // 在应用启动后执行同步
  WidgetsBinding.instance.addPostFrameCallback((_) async {
    try {
      await exchangeSmart().timeout(const Duration(seconds: 10));
      mainnotesList.reinit(0);
      CherryToast(
              icon: Icons.cloud_done_outlined,
              iconColor: Colors.green,
              themeColor: Colors.grey,
              description:
                  const Text('远程同步完成', style: TextStyle(color: Colors.black)),
              toastPosition: Position.bottom,
              animationType: AnimationType.fromBottom,
              animationDuration: const Duration(milliseconds: 1000),
              autoDismiss: true)
          .show(Get.context!);
    } catch (e) {
      if (kDebugMode) {
        print('同步失败: $e');
      }
      CherryToast(
              icon: Icons.error_outline_outlined,
              iconColor: Colors.red,
              themeColor: Colors.grey,
              description:
                  const Text('远程同步失败', style: TextStyle(color: Colors.black)),
              toastPosition: Position.bottom,
              animationType: AnimationType.fromBottom,
              animationDuration: const Duration(milliseconds: 1000),
              autoDismiss: true)
          .show(Get.context!);
      try {
        await exchangeSmart().timeout(const Duration(seconds: 10));
        mainnotesList.reinit(0);
        CherryToast(
                icon: Icons.cloud_done_outlined,
                iconColor: Colors.green,
                themeColor: Colors.grey,
                description:
                    const Text('远程同步完成', style: TextStyle(color: Colors.black)),
                toastPosition: Position.bottom,
                animationType: AnimationType.fromBottom,
                animationDuration: const Duration(milliseconds: 1000),
                autoDismiss: true)
            .show(Get.context!);
      } catch (e) {
        if (kDebugMode) {
          print('重试失败: $e');
        }
        CherryToast(
                icon: Icons.error_outline_outlined,
                iconColor: Colors.red,
                themeColor: Colors.grey,
                description:
                    const Text('远程重试失败', style: TextStyle(color: Colors.black)),
                toastPosition: Position.bottom,
                animationType: AnimationType.fromBottom,
                animationDuration: const Duration(milliseconds: 1000),
                autoDismiss: true)
            .show(Get.context!);
      }
    }
  });
}

class App extends StatefulWidget {
  const App({super.key});

  @override
  State<App> createState() => _AppState();
}

class _AppState extends State<App> {
  bool useMaterial3 = true;
  ThemeMode themeMode = ThemeMode.light;
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
    return GetMaterialApp(
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('en', 'US'), // English
        Locale('zh', 'CN'), // Thai
      ],
      locale: const Locale('zh', 'CN'),
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
      initialRoute: '/',
      routes: {
        '/': (context) => Home(
              useLightMode: useLightMode,
              useMaterial3: useMaterial3,
              colorSelected: colorSelected,
              handleBrightnessChange: handleBrightnessChange,
              handleMaterialVersionChange: handleMaterialVersionChange,
              handleColorSelect: handleColorSelect,
            ),
        '/login': (context) => const LoginScreen()
      },
    );
  }
}
