// ignore_for_file: unused_local_variable, unnecessary_null_comparison

import 'dart:async';
import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:icebergnote/class/habit.dart';
import 'package:icebergnote/main.dart';
import 'package:icebergnote/class/notes.dart';
import 'package:postgres/postgres.dart';
import 'package:realm/realm.dart';
import 'package:shared_preferences/shared_preferences.dart';

String? userEmail;
String? userOther;
String? userID;
String? userName;
String? userCreatDate;
SharedPreferences? userLocalInfo;
// String syncProcess = '';

class SyncProcessController extends GetxController {
  var syncProcess = ''.obs;
  syncProcessAddLine(String s) {
    syncProcess.value = '$syncProcess\n$s';
  }

  syncProcessAdd(String s) {
    syncProcess.value = '$syncProcess$s';
  }

  syncProcessClear() {
    syncProcess.value = '';
  }

  syncProcessReplace(String s1, String s2) {
    syncProcess.value = syncProcess.value.replaceAll(s1, s2);
  }
}

// Future<void> postgreSQLQuery() async {
//   final postgreSQLConnection = await Connection.open(Endpoint(
//       host: '118.25.189.25',
//       database: 'users',
//       username: "admin",
//       password: "456321rrRR"));

//   if (postgreSQLConnection == null) {
//     Get.snackbar('错误', '云端数据库连接失败');
//   } else {
//     final result = await postgreSQLConnection.execute("SELECT * FROM userinfo");
//     List<Map> results =
//         await postgreSQLConnection.mappedResultsQuery("SELECT * FROM userinfo");
//     final result2 = await postgreSQLConnection.execute(
//         "INSERT INTO userinfo VALUES ('小仙女', '3', 'rrrr.zhao@qq.com', '18795880371', 1, 't', 't', '1')");
//     final result3 = await postgreSQLConnection
//         .execute("SELECT name, password FROM userinfo");
//     postgreSQLConnection.close();
//   }
// }

class SyncPage extends StatefulWidget {
  const SyncPage({super.key});

  @override
  State<SyncPage> createState() => SyncPageState();
}

class SyncPageState extends State<SyncPage> {
  final SyncProcessController syncProcessController = Get.find();
  String syncProcess = '';
  @override
  Widget build(BuildContext context) {
    SyncProcessController syncProcessController = Get.find();

    return Scaffold(
      appBar: AppBar(
        title: const Text('高级同步'),
      ),
      body: Align(
        alignment: Alignment.center,
        child: Column(
          children: [
            ElevatedButton(
              onPressed: () async {
                syncProcess =
                    '$syncProcess\n--------------------验证用户信息--------------------';
                setState(() {});
                if (userLocalInfo != null) {
                  userEmail = userLocalInfo!.getString('userEmail');
                  userOther = userLocalInfo!.getString('userOther');
                  userID = userLocalInfo!.getString('userID');
                  syncProcess = '$syncProcess\n用户信息已存在';
                } else {
                  syncProcess = '$syncProcess\n用户信息不存在  初始化';
                  userLocalInfo = await SharedPreferences.getInstance();
                  if (userLocalInfo != null) {
                    syncProcess = '$syncProcess\n用户信息初始化成功';
                    userEmail = userLocalInfo!.getString('userEmail');
                    userOther = userLocalInfo!.getString('userOther');
                    userID = userLocalInfo!.getString('userID');
                  } else {
                    syncProcess = '$syncProcess\n用户信息初始化失败';
                  }
                }
                syncProcess = '$syncProcess\n邮箱    $userEmail';
                syncProcess = '$syncProcess\nID    No.$userID';
                syncProcess = '$syncProcess\n用户名    $userEmail';
                setState(() {});
                syncProcess =
                    '$syncProcess\n--------------------开始上传本地--------------------';
                setState(() {});
                final postgreSQLConnection = await Connection.open(Endpoint(
                    host: '118.25.189.25',
                    database: 'users',
                    username: "admin",
                    password: "456321rrRR"));
                int p1 = await checkRemoteDatabase();
                if (userEmail == null || userOther == null || userID == null) {
                  syncProcess = '$syncProcess\n本地用户数据异常';
                  setState(() {});
                } else {
                  final user = await postgreSQLConnection.execute(
                      "SELECT * FROM userinfo WHERE email = '$userEmail'");
                  final other0 = sha512
                      .convert(utf8.encode('${userOther}IceBergNote'))
                      .toString();
                  if (user[0][5] != other0) {
                    syncProcess = '$syncProcess\n用户权限验证失败';
                    setState(() {});
                  } else {
                    syncProcess = '$syncProcess\n用户权限验证通过';
                    setState(() {});
                    bool checkResult = await checkAndBuildTableALL(
                        postgreSQLConnection, userID!);

                    if (checkResult == false) {
                      syncProcess =
                          '$syncProcess\n--------------------云端创建失败--------------------';
                      setState(() {});
                    } else {
                      syncProcess =
                          '$syncProcess\n--------------------云端连接成功--------------------';
                      setState(() {});

                      var num1 = await postgreSQLConnection
                          .execute("DELETE FROM u$userID.n$userID");
                      var num2 = await postgreSQLConnection
                          .execute("DELETE FROM u$userID.habit$userID");
                      var num3 = await postgreSQLConnection
                          .execute("DELETE FROM u$userID.habitrecord$userID");
                      if (num1.affectedRows != 0 ||
                          num2.affectedRows != 0 ||
                          num3.affectedRows != 0) {
                        '开始清空$num1+$num2+$num3条云端数据';

                        num1 = await postgreSQLConnection
                            .execute("DELETE FROM u$userID.n$userID");
                        num2 = await postgreSQLConnection
                            .execute("DELETE FROM u$userID.habit$userID");
                        num3 = await postgreSQLConnection
                            .execute("DELETE FROM u$userID.habitrecord$userID");
                        if (num1.affectedRows != 0 ||
                            num1.affectedRows != 0 ||
                            num1.affectedRows != 0) {
                          syncProcess =
                              '$syncProcess\n清空失败 剩余$num1+$num2+$num3条云端数据';
                        } else {
                          syncProcess =
                              '$syncProcess\n--------------------云端清空完成--------------------';
                        }
                      } else {
                        syncProcess =
                            '$syncProcess\n--------------------云端暂无数据--------------------';
                      }

                      var localNotes = realm.all<Notes>();
                      syncProcess =
                          '$syncProcess\n开始上传${localNotes.length}条本地Note数据';
                      setState(() {});
                      syncProcess =
                          '$syncProcess\nNote上传进度: 0 / ${localNotes.length}条本地数据';
                      setState(() {});

                      for (int i = 0; i < localNotes.length; i++) {
                        syncProcess = syncProcess.replaceAll(
                            'Note上传进度: $i', 'Note上传进度: ${i + 1}');
                        setState(() {});
                        await postgreSQLConnection
                            .execute(insertRemoteNote(localNotes[i], userID!));
                      }

                      var localHabit = realmHabit.all<Habit>();
                      syncProcess =
                          '$syncProcess\n开始上传${localHabit.length}条本地Habit数据';
                      setState(() {});
                      syncProcess =
                          '$syncProcess\nHabit上传进度: 0 / ${localHabit.length}条本地数据';
                      setState(() {});

                      for (int i = 0; i < localHabit.length; i++) {
                        syncProcess = syncProcess.replaceAll(
                            'Habit上传进度: $i', 'Habit上传进度: ${i + 1}');
                        setState(() {});
                        await postgreSQLConnection
                            .execute(insertRemoteHabit(localHabit[i], userID!));
                      }

                      var localHabitRecords =
                          realmHabitRecord.all<HabitRecord>();
                      syncProcess =
                          '$syncProcess\n开始上传${localHabitRecords.length}条本地HabitRecord数据';
                      setState(() {});
                      syncProcess =
                          '$syncProcess\nHabitRecord上传进度: 0 / ${localHabitRecords.length}条本地数据';
                      setState(() {});

                      for (int i = 0; i < localHabitRecords.length; i++) {
                        syncProcess = syncProcess.replaceAll(
                            'HabitRecord上传进度: $i', 'HabitRecord上传进度: ${i + 1}');
                        setState(() {});
                        await postgreSQLConnection.execute(
                            insertRemoteHabitRecord(
                                localHabitRecords[i], userID!));
                      }

                      //100条大概半分钟
                      await postgreSQLConnection.close();
                      syncProcess =
                          '$syncProcess\n--------------------本地上传完成--------------------';
                      setState(() {});
                    }
                  }
                }
                await postgreSQLConnection.close();
              },
              child: const Text('本地>>>>云端'),
            ),
            const Text('请确认本地数据完备', style: TextStyle(color: Colors.red)),
            const Text('将清空云端 并将本地数据全部同步到云端'),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                syncProcess =
                    '$syncProcess\n--------------------验证用户信息--------------------';
                setState(() {});
                if (userLocalInfo != null) {
                  userEmail = userLocalInfo!.getString('userEmail');
                  userOther = userLocalInfo!.getString('userOther');
                  userID = userLocalInfo!.getString('userID');
                  syncProcess = '$syncProcess\n用户信息已存在';
                } else {
                  syncProcess = '$syncProcess\n用户信息不存在  初始化';
                  userLocalInfo = await SharedPreferences.getInstance();
                  if (userLocalInfo != null) {
                    syncProcess = '$syncProcess\n用户信息初始化成功';
                    userEmail = userLocalInfo!.getString('userEmail');
                    userOther = userLocalInfo!.getString('userOther');
                    userID = userLocalInfo!.getString('userID');
                  } else {
                    syncProcess = '$syncProcess\n用户信息初始化失败';
                  }
                }
                syncProcess = '$syncProcess\n邮箱    $userEmail';
                syncProcess = '$syncProcess\nID    No.$userID';
                syncProcess = '$syncProcess\n用户名    $userEmail';
                setState(() {});
                syncProcess =
                    '$syncProcess\n--------------------开始下载云端--------------------';
                setState(() {});
                final postgreSQLConnection = await Connection.open(Endpoint(
                    host: '118.25.189.25',
                    database: 'users',
                    username: "admin",
                    password: "456321rrRR"));
                int p1 = await checkRemoteDatabase();
                if (userEmail == null || userOther == null || userID == null) {
                  syncProcess = '$syncProcess\n本地用户数据异常';
                  setState(() {});
                } else {
                  final user = await postgreSQLConnection.execute(
                      "SELECT * FROM userinfo WHERE email = '$userEmail'");
                  final other0 = sha512
                      .convert(utf8.encode('${userOther}IceBergNote'))
                      .toString();
                  if (user[0][5] != other0) {
                    syncProcess = '$syncProcess\n用户权限验证失败';
                    setState(() {});
                  } else {
                    syncProcess = '$syncProcess\n用户权限验证通过';
                    setState(() {});
                    bool checkResult = await checkAndBuildTableALL(
                        postgreSQLConnection, userID!);

                    if (checkResult == false) {
                      syncProcess = '$syncProcess\n未检测到云端数据库';
                      setState(() {});
                    } else {
                      syncProcess = '$syncProcess\n查询到已有云端数据库';
                      setState(() {});
                      syncProcess =
                          '$syncProcess\n--------------------云端连接成功--------------------';
                      setState(() {});

                      var notes = realm.all<Notes>();
                      syncProcess =
                          '$syncProcess\n开始清空${notes.length}条本地Note数据';
                      setState(() {});
                      realm.write(() {
                        realm.deleteAll<Notes>();
                      });
                      var habits = realmHabit.all<Habit>();
                      syncProcess =
                          '$syncProcess\n开始清空${habits.length}条本地Habit数据';
                      setState(() {});
                      realmHabit.write(() {
                        realmHabit.deleteAll<Habit>();
                      });
                      var habitRecords = realmHabitRecord.all<HabitRecord>();
                      syncProcess =
                          '$syncProcess\n开始清空${habitRecords.length}条本地HabitRecord数据';
                      setState(() {});
                      realmHabitRecord.write(() {
                        realmHabitRecord.deleteAll<HabitRecord>();
                      });

                      syncProcess =
                          '$syncProcess\n--------------------本地清空完成--------------------';
                      setState(() {});
                      var remoteNotes = await postgreSQLConnection
                          .execute("SELECT * FROM u$userID.n$userID");
                      syncProcess =
                          '$syncProcess\n ${remoteNotes.length}条Note数据';
                      setState(() {});
                      for (int i = 0; i < remoteNotes.length; i++) {
                        await insertLocalNote(remoteNotes[i]);
                      }
                      syncProcess = '$syncProcess   下载完成';
                      setState(() {});

                      var remoteHabits = await postgreSQLConnection
                          .execute("SELECT * FROM u$userID.habit$userID");
                      syncProcess =
                          '$syncProcess\n ${remoteHabits.length}条Habit数据';
                      setState(() {});
                      for (int i = 0; i < remoteHabits.length; i++) {
                        await insertLocalHabit(remoteHabits[i]);
                      }
                      syncProcess = '$syncProcess   下载完成';
                      setState(() {});

                      var remoteHabitRecords = await postgreSQLConnection
                          .execute("SELECT * FROM u$userID.habitrecord$userID");
                      syncProcess =
                          '$syncProcess\n ${remoteHabitRecords.length}条HabitRecords数据';
                      setState(() {});
                      for (int i = 0; i < remoteHabitRecords.length; i++) {
                        await insertLocalHabitRecord(remoteHabitRecords[i]);
                      }
                      syncProcess = '$syncProcess   下载完成';
                      setState(() {});

                      await postgreSQLConnection.close();
                      syncProcess =
                          '$syncProcess\n--------------------云端下载完成--------------------';
                      setState(() {});
                    }
                  }
                }
                await postgreSQLConnection.close();
              },
              child: const Text('本地<<<<云端'),
            ),
            const Text('请确认云端数据完备', style: TextStyle(color: Colors.red)),
            const Text('将清空本地 并将云端数据全部同步到本地'),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                syncProcessController.syncProcessClear();
                int p1 = await checkRemoteDatabase();
                if (p1 == 1) {
                  exchangeSmart();
                }
              },
              child: const Text('本地<===>云端'),
            ),
            const Text('双向增量同步'),
            const SizedBox(height: 40),
            SingleChildScrollView(
              child: Text(
                syncProcess,
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

Future<int> checkRemoteDatabase() async {
  SyncProcessController syncProcessController = Get.find();
  final postgreSQLConnection = await Connection.open(Endpoint(
      host: '118.25.189.25',
      database: 'users',
      username: "admin",
      password: "456321rrRR"));
  if (postgreSQLConnection == null) {
    syncProcessController.syncProcessAddLine('连接云端数据库失败');

    return 0;
  } else {
    // userLocalInfo = await SharedPreferences.getInstance();
    if (userLocalInfo != null) {
      userEmail = userLocalInfo!.getString('userEmail');
      userOther = userLocalInfo!.getString('userOther');
      userID = userLocalInfo!.getString('userID');
    } else {
      userLocalInfo = await SharedPreferences.getInstance();
      if (userLocalInfo != null) {
        userEmail = userLocalInfo!.getString('userEmail');
        userOther = userLocalInfo!.getString('userOther');
        userID = userLocalInfo!.getString('userID');
      } else {
        return 0;
      }
    }
    return 1;
  }
}

Future<bool> createRemoteDatabase() async {
  SyncProcessController syncProcessController = Get.find();
  syncProcessController.syncProcessAddLine('准备新建云端数据库');
  final postgreSQLConnection = await Connection.open(Endpoint(
      host: '118.25.189.25',
      database: 'users',
      username: "admin",
      password: "456321rrRR"));
  await postgreSQLConnection.execute("CREATE SCHEMA u$userID");
  await postgreSQLConnection
      .execute("CREATE TABLE u$userID.n$userID AS TABLE public.notetemplate");
  await postgreSQLConnection.execute(
      "ALTER TABLE u$userID.n$userID ALTER COLUMN id SET NOT NULL, ADD PRIMARY KEY (id)");
  final checkSchema1 = await postgreSQLConnection.execute(
      "SELECT EXISTS( SELECT 1 FROM pg_catalog.pg_tables WHERE tablename = 'n$userID' AND schemaname = 'u$userID')");
  if (checkSchema1[0][0] == false) {
    syncProcessController
        .syncProcessAddLine('--------------------云端创建失败--------------------');
    await postgreSQLConnection.close();
    return false;
  } else {
    syncProcessController
        .syncProcessAddLine('--------------------云端创建成功--------------------');
    await postgreSQLConnection.close();
    return true;
  }
}

Future<bool> clearRemoteDatabase() async {
  SyncProcessController syncProcessController = Get.find();
  final postgreSQLConnection = await Connection.open(Endpoint(
      host: '118.25.189.25',
      database: 'users',
      username: "admin",
      password: "456321rrRR"));
  var num = await postgreSQLConnection.execute("DELETE FROM u$userID.n$userID");
  if (num.affectedRows != 0) {
    syncProcessController.syncProcessAddLine('开始清空$num条云端数据');

    num = await postgreSQLConnection.execute("DELETE FROM u$userID.n$userID");
    if (num.affectedRows != 0) {
      syncProcessController.syncProcessAddLine('清空失败 剩余$num条云端数据');
      await postgreSQLConnection.close();
      return false;
    } else {
      syncProcessController
          .syncProcessAddLine('--------------------云端清空完成--------------------');
      await postgreSQLConnection.close();
      return true;
    }
  } else {
    syncProcessController
        .syncProcessAddLine('--------------------云端暂无数据--------------------');
    await postgreSQLConnection.close();
    return true;
  }
}

Future<void> allLocalToRemote() async {
  SyncProcessController syncProcessController = Get.find();
  var localResults = realm.all<Notes>();
  final postgreSQLConnection = await Connection.open(Endpoint(
      host: '118.25.189.25',
      database: 'users',
      username: "admin",
      password: "456321rrRR"));
  syncProcessController.syncProcessAddLine('开始上传${localResults.length}条本地数据');
  syncProcessController
      .syncProcessAddLine('上传进度: 0 / ${localResults.length}条本地数据');

  for (int i = 0; i < localResults.length; i++) {
    syncProcessController.syncProcessReplace('上传进度: $i', '上传进度: ${i + 1}');
    await postgreSQLConnection
        .execute(insertRemoteNote(localResults[i], userID!));
  }
  //100条大概半分钟
  await postgreSQLConnection.close();
  syncProcessController
      .syncProcessAddLine('--------------------本地上传完成--------------------');
}

Future<bool> clearLocalDatabase() async {
  SyncProcessController syncProcessController = Get.find();
  var localResults = realm.all<Notes>();
  if (localResults.isNotEmpty) {
    syncProcessController.syncProcessAddLine('开始清空${localResults.length}条本地数据');

    realm.write(() {
      realm.deleteAll<Notes>();
    });
    localResults = realm.all<Notes>();
    if (localResults.isNotEmpty) {
      syncProcessController
          .syncProcessAddLine('清空失败 剩余${localResults.length}条本地数据 正在重试');

      return false;
    } else {
      syncProcessController
          .syncProcessAddLine('--------------------本地清空完成--------------------');

      return true;
    }
  } else {
    syncProcessController
        .syncProcessAddLine('--------------------本地暂无数据--------------------');
    return true;
  }
}

Future<void> allRemoteToLocal() async {
  SyncProcessController syncProcessController = Get.find();
  syncProcessController.syncProcessAddLine('开始下载云端数据');
  final postgreSQLConnection = await Connection.open(Endpoint(
      host: '118.25.189.25',
      database: 'users',
      username: "admin",
      password: "456321rrRR"));

  var remoteResults =
      await postgreSQLConnection.execute("SELECT * FROM u$userID.n$userID");
  syncProcessController
      .syncProcessAddLine('下载进度: 0 / ${remoteResults.length}条云端数据');
  for (int i = 0; i < remoteResults.length; i++) {
    syncProcessController.syncProcessReplace('下载进度: $i', '下载进度: ${i + 1}');
    await insertLocalNote(remoteResults[i]);
  }
  await postgreSQLConnection.close();
  syncProcessController
      .syncProcessAddLine('--------------------云端下载完成--------------------');
}

Future<bool> exchangeSmart() async {
  final postgreSQLConnection = await Connection.open(Endpoint(
      host: '118.25.189.25',
      database: 'users',
      username: "admin",
      password: "456321rrRR"));
  try {
    // ignore: prefer_conditional_assignment
    if (userLocalInfo == null) {
      userLocalInfo = await SharedPreferences.getInstance();
    }

    if (userLocalInfo == null) {
      return false;
    } else {
      DateTime lastRefresh = DateTime.parse(
              userLocalInfo!.getString('refreshdate') ??
                  '1969-01-01 00:00:00.000000')
          .add(const Duration(days: -10));
      userLocalInfo!
          .setString('refreshdate', DateTime.now().toUtc().toString());
      userID = userLocalInfo!.getString('userID');

      RealmResults<Notes> localNewNotes = realm.query<Notes>(
          "noteUpdateDate > \$0 SORT(noteUpdateDate ASC)", [lastRefresh]);
      final postgreSQLConnection = await Connection.open(Endpoint(
          host: '118.25.189.25',
          database: 'users',
          username: "admin",
          password: "456321rrRR"));
      var remoteNewNotes = await postgreSQLConnection.execute(
          "SELECT * FROM u$userID.n$userID WHERE updatedate > '$lastRefresh'");
      List<int> synced1 = [];
      for (int i = 0; i < localNewNotes.length; i++) {
        if (remoteNewNotes.isEmpty) {
          await postgreSQLConnection
              .execute(insertOrUpdateRemoteNote(localNewNotes[i], userID!));
        }
        for (int j = 0; j < remoteNewNotes.length; j++) {
          DateTime remoteUpdateDate = DateTime(1969, 1, 1);
          try {
            remoteUpdateDate = DateTime.parse(remoteNewNotes[j][23].toString());
          } catch (e) {
            continue;
          }
          if (localNewNotes[i].id.toString() == remoteNewNotes[j][0]) {
            synced1.add(j);
            if (localNewNotes[i].noteUpdateDate.isAfter(remoteUpdateDate)) {
              await postgreSQLConnection
                  .execute(insertOrUpdateRemoteNote(localNewNotes[i], userID!));
            } else {
              await updateLocalNote(localNewNotes[i], remoteNewNotes[j]);
            }
            break;
          } else {
            if (j == remoteNewNotes.length - 1) {
              await postgreSQLConnection
                  .execute(insertOrUpdateRemoteNote(localNewNotes[i], userID!));
            }
          }
        }
      }
      for (int j = 0; j < remoteNewNotes.length; j++) {
        if (synced1.contains(j)) {
        } else {
          RealmResults<Notes> existedNote = realm.query<Notes>(
              "id == \$0", [Uuid.fromString(remoteNewNotes[j][0].toString())]);
          if (existedNote.isEmpty) {
            insertLocalNote(remoteNewNotes[j]);
          } else if (existedNote.length == 1) {
            updateLocalNote(existedNote.first, remoteNewNotes[j]);
          } else {}
        }
      }
      RealmResults<Habit> localNewHabit = realmHabit
          .query<Habit>("updateDate > \$0 SORT(updateDate ASC)", [lastRefresh]);
      var remoteNewHabit = await postgreSQLConnection.execute(
          "SELECT * FROM u$userID.habit$userID WHERE updatedate > '$lastRefresh'");
      List<int> synced2 = [];
      for (int i = 0; i < localNewHabit.length; i++) {
        if (remoteNewHabit.isEmpty) {
          await postgreSQLConnection
              .execute(insertOrUpdateRemoteHabit(localNewHabit[i], userID!));
        }
        for (int j = 0; j < remoteNewHabit.length; j++) {
          DateTime remoteUpdateDate = DateTime(1969, 1, 1);
          try {
            remoteUpdateDate = DateTime.parse(remoteNewHabit[j][23].toString());
          } catch (e) {
            continue;
          }
          if (localNewHabit[i].id.toString() == remoteNewHabit[j][0]) {
            synced2.add(j);
            if (localNewHabit[i].updateDate.isAfter(remoteUpdateDate)) {
              await postgreSQLConnection.execute(
                  insertOrUpdateRemoteHabit(localNewHabit[i], userID!));
            } else {
              await updateLocalHabit(localNewHabit[i], remoteNewHabit[j]);
            }
            break;
          } else {
            if (j == remoteNewHabit.length - 1) {
              await postgreSQLConnection.execute(
                  insertOrUpdateRemoteHabit(localNewHabit[i], userID!));
            }
          }
        }
      }

      for (int j = 0; j < remoteNewHabit.length; j++) {
        if (synced2.contains(j)) {
        } else {
          RealmResults<Habit> existedHabit = realmHabit.query<Habit>(
              "id == \$0", [Uuid.fromString(remoteNewHabit[j][0].toString())]);
          if (existedHabit.isEmpty) {
            insertLocalHabit(remoteNewHabit[j]);
          } else if (existedHabit.length == 1) {
            updateLocalHabit(existedHabit.first, remoteNewHabit[j]);
          } else {}
        }
      }

      RealmResults<HabitRecord> localNewHabitRecord = realmHabitRecord
          .query<HabitRecord>(
              "updateDate > \$0 SORT(updateDate ASC)", [lastRefresh]);
      var remoteNewHabitRecord = await postgreSQLConnection.execute(
          "SELECT * FROM u$userID.habitrecord$userID WHERE updatedate > '$lastRefresh'");
      List<int> synced3 = [];
      for (int i = 0; i < localNewHabitRecord.length; i++) {
        if (remoteNewHabitRecord.isEmpty) {
          await postgreSQLConnection.execute(
              insertOrUpdateRemoteHabitRecord(localNewHabitRecord[i], userID!));
        }
        for (int j = 0; j < remoteNewHabitRecord.length; j++) {
          DateTime remoteUpdateDate = DateTime(1969, 1, 1);
          try {
            remoteUpdateDate =
                DateTime.parse(remoteNewHabitRecord[j][6].toString());
          } catch (e) {
            continue;
          }
          if (localNewHabitRecord[i].id.toString() ==
              remoteNewHabitRecord[j][0]) {
            synced3.add(j);
            if (localNewHabitRecord[i].updateDate.isAfter(remoteUpdateDate)) {
              await postgreSQLConnection.execute(
                  insertOrUpdateRemoteHabitRecord(
                      localNewHabitRecord[i], userID!));
            } else {
              await updateLocalHabitRecord(
                  localNewHabitRecord[i], remoteNewHabitRecord[j]);
            }
            break;
          } else {
            if (j == remoteNewHabitRecord.length - 1) {
              await postgreSQLConnection.execute(
                  insertOrUpdateRemoteHabitRecord(
                      localNewHabitRecord[i], userID!));
            }
          }
        }
      }
      for (int j = 0; j < remoteNewHabitRecord.length; j++) {
        if (synced3.contains(j)) {
        } else {
          RealmResults<HabitRecord> existedHabitRecord = realmHabitRecord
              .query<HabitRecord>("id == \$0",
                  [Uuid.fromString(remoteNewHabitRecord[j][0].toString())]);
          if (existedHabitRecord.isEmpty) {
            insertLocalHabitRecord(remoteNewHabitRecord[j]);
          } else if (existedHabitRecord.length == 1) {
            updateLocalHabitRecord(
                existedHabitRecord.first, remoteNewHabitRecord[j]);
          } else {}
        }
      }

      return true;
    }
  } catch (e) {
    return false;
  } finally {
    postgreSQLConnection.close();
  }
}

Future<void> compareLR1(Notes note, List result) async {}

Future<void> updateLocalNote(Notes note, List result) async {
  realm.write(() {
    note.noteFolder = result[1];
    note.noteTitle = result[2];
    note.noteContext = result[3];
    note.noteType = result[4];
    note.noteProject = result[5];
    note.noteTags = result[6];
    note.noteAttachments = result[7];
    note.noteReferences = result[8];
    note.noteSource = result[9];
    note.noteAuthor = result[10];
    note.noteNext = result[11];
    note.noteLast = result[12];
    note.notePlace = result[13];
    note.noteIsStarred = result[14];
    note.noteIsLocked = result[15];
    note.noteIstodo = result[16];
    note.noteIsDeleted = result[17];
    note.noteIsShared = result[18];
    note.noteIsAchive = result[19];
    note.noteFinishState = result[20];
    note.noteIsReviewed = result[21];
    note.noteCreateDate = result[22];
    note.noteUpdateDate = result[23];
    note.noteAchiveDate = result[24];
    note.noteDeleteDate = result[25];
    note.noteFinishDate = result[26];
    note.noteAlarmDate = result[27];
  });
}

Future<void> updateLocalHabit(Habit habit, List result) async {
  realmHabit.write(() {
    habit.name = result[1];
    habit.color = result[2];
    habit.fontColor = result[3];
    habit.description = result[4];
    habit.freqDen = result[5];
    habit.freqNum = result[6];
    habit.highlight = result[7];
    habit.position = result[8];
    habit.reminderHour = result[9];
    habit.reminderMin = result[10];
    habit.reminderDay = result[11];
    habit.type = result[12];
    habit.targetType = result[13];
    habit.targetValue = double.parse(result[14]);
    habit.targetFreq = result[15];
    habit.weight = double.parse(result[16]);
    habit.archived = result[17];
    habit.delete = result[18];
    habit.reminder = result[19];
    habit.question = result[20];
    habit.unit = result[21];
    habit.createDate = result[22];
    habit.updateDate = result[23];
    habit.startDate = result[24];
    habit.stopDate = result[25];
    habit.icon = result[26];
    habit.isButtonAdd = result[27];
    habit.buttonAddNum = double.parse(result[28]);
    habit.needlog = result[29];
    habit.canExpire = result[30];
    habit.expireDays = result[31];
    habit.reward = result[32];
    habit.todayAfterHour = result[33];
    habit.todayAfterMin = result[34];
    habit.todayBeforeHour = result[35];
    habit.todayBeforeMin = result[36];
    habit.group = result[37];
    habit.size = result[38];
    habit.string1 = result[39];
    habit.string2 = result[40];
    habit.string3 = result[41];
    habit.int1 = result[42];
    habit.int2 = result[43];
    habit.int3 = result[44];
    habit.int4 = result[45];
    habit.int5 = result[46];
    habit.double1 = double.parse(result[47]);
    habit.double2 = double.parse(result[48]);
    habit.double3 = double.parse(result[49]);
    habit.bool1 = result[50];
    habit.bool2 = result[51];
    habit.bool3 = result[52];
  });
}

Future<void> updateLocalHabitRecord(
    HabitRecord habitRecord, List result) async {
  realmHabitRecord.write(() {
    habitRecord.habit = Uuid.fromString(result[1]);
    habitRecord.value = result[2];
    habitRecord.notes = result[3];
    habitRecord.currentDate = result[4];
    habitRecord.createDate = result[5];
    habitRecord.updateDate = result[6];
    habitRecord.data = double.parse(result[7]);
    habitRecord.score = double.parse(result[8]);
    habitRecord.string1 = result[9];
    habitRecord.string2 = result[10];
    habitRecord.string3 = result[11];
    habitRecord.int1 = result[12];
    habitRecord.int2 = result[13];
    habitRecord.int3 = result[14];
    habitRecord.double1 = double.parse(result[15]);
    habitRecord.double2 = double.parse(result[16]);
    habitRecord.double3 = double.parse(result[17]);
  });
}

Future<void> insertLocalNote(List result) async {
  realm.write(() {
    realm.add(Notes(
      Uuid.fromString(result[0]),
      result[1],
      result[2],
      result[3],
      result[22],
      result[23],
      result[24],
      result[25],
      result[26],
      result[27],
      noteType: result[4],
      noteProject: result[5],
      noteTags: result[6],
      noteAttachments: result[7],
      noteReferences: result[8],
      noteSource: result[9],
      noteAuthor: result[10],
      noteNext: result[11],
      noteLast: result[12],
      notePlace: result[13],
      noteIsStarred: result[14],
      noteIsLocked: result[15],
      noteIstodo: result[16],
      noteIsDeleted: result[17],
      noteIsShared: result[18],
      noteIsAchive: result[19],
      noteFinishState: result[20],
      noteIsReviewed: result[21],
    ));
  });
}

Future<void> insertLocalHabit(List result) async {
  realmHabit.write(() {
    realmHabit.add(Habit(
      Uuid.fromString(result[0]),
      result[22],
      result[23],
      result[24],
      result[25],
      name: result[1],
      color: result[2],
      fontColor: result[3],
      description: result[4],
      freqDen: result[5],
      freqNum: result[6],
      highlight: result[7],
      position: result[8],
      reminderHour: result[9],
      reminderMin: result[10],
      reminderDay: result[11],
      type: result[12],
      targetType: result[13],
      targetValue: double.parse(result[14]),
      targetFreq: result[15],
      weight: double.parse(result[16]),
      archived: result[17],
      delete: result[18],
      reminder: result[19],
      question: result[20],
      unit: result[21],
      icon: result[26],
      isButtonAdd: result[27],
      buttonAddNum: double.parse(result[28]),
      needlog: result[29],
      canExpire: result[30],
      expireDays: result[31],
      reward: result[32],
      todayAfterHour: result[33],
      todayAfterMin: result[34],
      todayBeforeHour: result[35],
      todayBeforeMin: result[36],
      group: result[37],
      size: result[38],
      string1: result[39],
      string2: result[40],
      string3: result[41],
      int1: result[42],
      int2: result[43],
      int3: result[44],
      int4: result[45],
      int5: result[46],
      double1: double.parse(result[47]),
      double2: double.parse(result[48]),
      double3: double.parse(result[49]),
      bool1: result[50],
      bool2: result[51],
      bool3: result[52],
    ));
  });
}

Future<void> insertLocalHabitRecord(List result) async {
  realmHabitRecord.write(() {
    realmHabitRecord.add(HabitRecord(
      Uuid.fromString(result[0]),
      Uuid.fromString(result[1]),
      result[2],
      result[4],
      result[5],
      result[6],
      notes: result[3],
      data: double.parse(result[7]),
      score: double.parse(result[8]),
      string1: result[9],
      string2: result[10],
      string3: result[11],
      int1: result[12],
      int2: result[13],
      int3: result[14],
      double1: double.parse(result[15]),
      double2: double.parse(result[16]),
      double3: double.parse(result[17]),
    ));
  });
}

String updateRemote(Notes note, String id) {
  return "UPDATE u$id.n$id SET folder = '${note.noteFolder}', title = '${note.noteTitle}', context = '${note.noteContext}', type = '${note.noteType}', project = '${note.noteProject}', tags = '${note.noteTags}', attachments = '${note.noteAttachments}', ref = '${note.noteReferences}', source = '${note.noteSource}', author = '${note.noteAuthor}', next = '${note.noteNext}', last = '${note.noteLast}', place = '${note.notePlace}', isstarred = '${note.noteIsStarred}', islocked = '${note.noteIsLocked}', istodo = '${note.noteIstodo}', isdeleted = '${note.noteIsDeleted}', isshared = '${note.noteIsShared}', isachived = '${note.noteIsAchive}', finishstate = '${note.noteFinishState}', isreviewed = '${note.noteIsReviewed}', createdate = '${note.noteCreateDate}', updatedate = '${note.noteUpdateDate}', achivedate = '${note.noteAchiveDate}', deletedate = '${note.noteDeleteDate}', finishdate = '${note.noteFinishDate}', alarmdate = '${note.noteAlarmDate}' WHERE id = '${note.id}'";
}

String insertRemoteNote(Notes note, String id) {
  return "INSERT INTO u$id.n$id VALUES ('${note.id}', '${note.noteFolder}', '${note.noteTitle}', '${note.noteContext}', '${note.noteType}', '${note.noteProject}', '${note.noteTags}', '${note.noteAttachments}', '${note.noteReferences}', '${note.noteSource}', '${note.noteAuthor}', '${note.noteNext}', '${note.noteLast}', '${note.notePlace}', '${note.noteIsStarred}', '${note.noteIsLocked}', '${note.noteIstodo}', '${note.noteIsDeleted}', '${note.noteIsShared}', '${note.noteIsAchive}', '${note.noteFinishState}', '${note.noteIsReviewed}', '${note.noteCreateDate}','${note.noteUpdateDate}', '${note.noteAchiveDate}', '${note.noteDeleteDate}', '${note.noteFinishDate}', '${note.noteAlarmDate}')";
}

String insertRemoteHabit(Habit habit, String id) {
  return "INSERT INTO u$id.habit$id VALUES ('${habit.id}', '${habit.name}', '${habit.color}', '${habit.fontColor}', '${habit.description}', '${habit.freqDen}', '${habit.freqNum}', '${habit.highlight}', '${habit.position}', '${habit.reminderHour}', '${habit.reminderMin}', '${habit.reminderDay}', '${habit.type}', '${habit.targetType}', '${habit.targetValue}', '${habit.targetFreq}', '${habit.weight}', '${habit.archived}', '${habit.delete}', '${habit.reminder}', '${habit.question}', '${habit.unit}', '${habit.createDate}','${habit.updateDate}', '${habit.startDate}', '${habit.stopDate}', '${habit.icon}', '${habit.isButtonAdd}', '${habit.buttonAddNum}', '${habit.needlog}', '${habit.canExpire}', '${habit.expireDays}', '${habit.reward}', '${habit.todayAfterHour}', '${habit.todayAfterMin}', '${habit.todayBeforeHour}', '${habit.todayBeforeMin}', '${habit.group}', '${habit.size}', '${habit.string1}', '${habit.string2}', '${habit.string3}', '${habit.int1}', '${habit.int2}', '${habit.int3}', '${habit.int4}', '${habit.int5}', '${habit.double1}', '${habit.double2}', '${habit.double3}', '${habit.bool1}', '${habit.bool2}', '${habit.bool3}')";
}

String insertRemoteHabitRecord(HabitRecord habitRecord, String id) {
  return "INSERT INTO u$id.habitrecord$id VALUES ('${habitRecord.id}', '${habitRecord.habit}', '${habitRecord.value}', '${habitRecord.notes}', '${habitRecord.currentDate}', '${habitRecord.createDate}', '${habitRecord.updateDate}', '${habitRecord.data}', '${habitRecord.score}', '${habitRecord.string1}', '${habitRecord.string2}', '${habitRecord.string3}', '${habitRecord.int1}', '${habitRecord.int2}', '${habitRecord.int3}', '${habitRecord.double1}', '${habitRecord.double2}', '${habitRecord.double3}')";
}

String insertOrUpdateRemoteNote(Notes note, String id) {
  return "INSERT INTO u$id.n$id VALUES ('${note.id}', '${note.noteFolder}', '${note.noteTitle}', '${note.noteContext}', '${note.noteType}', '${note.noteProject}', '${note.noteTags}', '${note.noteAttachments}', '${note.noteReferences}', '${note.noteSource}', '${note.noteAuthor}', '${note.noteNext}', '${note.noteLast}', '${note.notePlace}', '${note.noteIsStarred}', '${note.noteIsLocked}', '${note.noteIstodo}', '${note.noteIsDeleted}', '${note.noteIsShared}', '${note.noteIsAchive}', '${note.noteFinishState}', '${note.noteIsReviewed}', '${note.noteCreateDate}','${note.noteUpdateDate}', '${note.noteAchiveDate}', '${note.noteDeleteDate}', '${note.noteFinishDate}', '${note.noteAlarmDate}') ON CONFLICT (id) DO UPDATE SET folder = '${note.noteFolder}', title = '${note.noteTitle}', context = '${note.noteContext}', type = '${note.noteType}', project = '${note.noteProject}', tags = '${note.noteTags}', attachments = '${note.noteAttachments}', ref = '${note.noteReferences}', source = '${note.noteSource}', author = '${note.noteAuthor}', next = '${note.noteNext}', last = '${note.noteLast}', place = '${note.notePlace}', isstarred = '${note.noteIsStarred}', islocked = '${note.noteIsLocked}', istodo = '${note.noteIstodo}', isdeleted = '${note.noteIsDeleted}', isshared = '${note.noteIsShared}', isachived = '${note.noteIsAchive}', finishstate = '${note.noteFinishState}', isreviewed = '${note.noteIsReviewed}', createdate = '${note.noteCreateDate}', updatedate = '${note.noteUpdateDate}', achivedate = '${note.noteAchiveDate}', deletedate = '${note.noteDeleteDate}', finishdate = '${note.noteFinishDate}', alarmdate = '${note.noteAlarmDate}'";
}

String insertOrUpdateRemoteHabit(Habit habit, String id) {
  return "insert into u$id.habit$id values ('${habit.id}', '${habit.name}', '${habit.color}', '${habit.fontColor}', '${habit.description}', '${habit.freqDen}', '${habit.freqNum}', '${habit.highlight}', '${habit.position}', '${habit.reminderHour}', '${habit.reminderMin}', '${habit.reminderDay}', '${habit.type}', '${habit.targetType}', '${habit.targetValue}', '${habit.targetFreq}', '${habit.weight}', '${habit.archived}', '${habit.delete}', '${habit.reminder}', '${habit.question}', '${habit.unit}', '${habit.createDate}','${habit.updateDate}', '${habit.startDate}', '${habit.stopDate}', '${habit.icon}', '${habit.isButtonAdd}', '${habit.buttonAddNum}', '${habit.needlog}', '${habit.canExpire}', '${habit.expireDays}', '${habit.reward}', '${habit.todayAfterHour}', '${habit.todayAfterMin}', '${habit.todayBeforeHour}', '${habit.todayBeforeMin}', '${habit.group}', '${habit.size}', '${habit.string1}', '${habit.string2}', '${habit.string3}', '${habit.int1}', '${habit.int2}', '${habit.int3}', '${habit.int4}', '${habit.int5}', '${habit.double1}', '${habit.double2}', '${habit.double3}', '${habit.bool1}', '${habit.bool2}', '${habit.bool3}') on conflict (id) do update set name = '${habit.name}', color = '${habit.color}', fontcolor = '${habit.fontColor}', description = '${habit.description}', freqden = '${habit.freqDen}', freqnum = '${habit.freqNum}', highlight = '${habit.highlight}', position = '${habit.position}', reminderhour = '${habit.reminderHour}', remindermin = '${habit.reminderMin}', reminderday = '${habit.reminderDay}', type = '${habit.type}', targettype = '${habit.targetType}', targetvalue = '${habit.targetValue}', targetfreq = '${habit.targetFreq}', weight = '${habit.weight}', archived = '${habit.archived}', delete = '${habit.delete}', reminder = '${habit.reminder}', question = '${habit.question}', unit = '${habit.unit}', createdate = '${habit.createDate}', updatedate = '${habit.updateDate}', startdate = '${habit.startDate}', stopdate = '${habit.stopDate}', icon = '${habit.icon}', isbuttonadd = '${habit.isButtonAdd}', buttonaddnum = '${habit.buttonAddNum}', needlog = '${habit.needlog}', canexpire = '${habit.canExpire}', expiredays = '${habit.expireDays}', reward = '${habit.reward}', todayafterhour = '${habit.todayAfterHour}', todayaftermin = '${habit.todayAfterMin}', todaybeforehour = '${habit.todayBeforeHour}', todaybeforemin = '${habit.todayBeforeMin}', groupgroup = '${habit.group}', size = '${habit.size}', string1 = '${habit.string1}', string2 = '${habit.string2}', string3 = '${habit.string3}', int1 = '${habit.int1}', int2 = '${habit.int2}', int3 = '${habit.int3}', int4 = '${habit.int4}', int5 = '${habit.int5}', double1 = '${habit.double1}', double2 = '${habit.double2}', double3 = '${habit.double3}', bool1 = '${habit.bool1}', bool2 = '${habit.bool2}', bool3 = '${habit.bool3}'";
}

String insertOrUpdateRemoteHabitRecord(HabitRecord habitRecord, String id) {
  return "INSERT INTO u$id.habitrecord$id VALUES ('${habitRecord.id}', '${habitRecord.habit}', '${habitRecord.value}', '${habitRecord.notes}', '${habitRecord.currentDate}', '${habitRecord.createDate}', '${habitRecord.updateDate}', '${habitRecord.data}', '${habitRecord.score}', '${habitRecord.string1}', '${habitRecord.string2}', '${habitRecord.string3}', '${habitRecord.int1}', '${habitRecord.int2}', '${habitRecord.int3}', '${habitRecord.double1}', '${habitRecord.double2}', '${habitRecord.double3}') ON CONFLICT (id) DO UPDATE SET habit = '${habitRecord.habit}', value = '${habitRecord.value}', notes = '${habitRecord.notes}', currentdate = '${habitRecord.currentDate}', createdate = '${habitRecord.createDate}', updatedate = '${habitRecord.updateDate}', data = '${habitRecord.data}', score = '${habitRecord.score}', string1 = '${habitRecord.string1}', string2 = '${habitRecord.string2}', string3 = '${habitRecord.string3}', int1 = '${habitRecord.int1}', int2 = '${habitRecord.int2}', int3 = '${habitRecord.int3}', double1 = '${habitRecord.double1}', double2 = '${habitRecord.double2}', double3 = '${habitRecord.double3}'";
}

void syncNoteToRemote(Notes note) async {
  final postgreSQLConnection = await Connection.open(Endpoint(
      host: '118.25.189.25',
      database: 'users',
      username: "admin",
      password: "456321rrRR"));
  if (userLocalInfo != null) {
    userID = userLocalInfo!.getString('userID');
    await postgreSQLConnection.execute(insertOrUpdateRemoteNote(note, userID!));
    await postgreSQLConnection.close();
  } else {
    userLocalInfo = await SharedPreferences.getInstance();
    if (userLocalInfo != null) {
      userID = userLocalInfo!.getString('userID');
      await postgreSQLConnection
          .execute(insertOrUpdateRemoteNote(note, userID!));
      await postgreSQLConnection.close();
    } else {
      Get.snackbar(
        '错误',
        '本地用户数据为空',
        duration: const Duration(seconds: 3),
        backgroundColor: const Color.fromARGB(60, 0, 140, 198),
      );
    }
  }
}

void syncHabitToRemote(Habit habit) async {
  final postgreSQLConnection = await Connection.open(Endpoint(
      host: '118.25.189.25',
      database: 'users',
      username: "admin",
      password: "456321rrRR"));
  if (userLocalInfo != null) {
    userID = userLocalInfo!.getString('userID');
    await postgreSQLConnection
        .execute(insertOrUpdateRemoteHabit(habit, userID!));
    await postgreSQLConnection.close();
  } else {
    userLocalInfo = await SharedPreferences.getInstance();
    if (userLocalInfo != null) {
      userID = userLocalInfo!.getString('userID');
      await postgreSQLConnection
          .execute(insertOrUpdateRemoteHabit(habit, userID!));
      await postgreSQLConnection.close();
    } else {
      Get.snackbar(
        '错误',
        '本地用户数据为空',
        duration: const Duration(seconds: 3),
        backgroundColor: const Color.fromARGB(60, 0, 140, 198),
      );
    }
  }
}

void syncHabitRecordToRemote(HabitRecord habitRecord) async {
  final postgreSQLConnection = await Connection.open(Endpoint(
      host: '118.25.189.25',
      database: 'users',
      username: "admin",
      password: "456321rrRR"));
  if (userLocalInfo != null) {
    userID = userLocalInfo!.getString('userID');
    await postgreSQLConnection
        .execute(insertOrUpdateRemoteHabitRecord(habitRecord, userID!));
    await postgreSQLConnection.close();
  } else {
    userLocalInfo = await SharedPreferences.getInstance();
    if (userLocalInfo != null) {
      userID = userLocalInfo!.getString('userID');
      await postgreSQLConnection
          .execute(insertOrUpdateRemoteHabitRecord(habitRecord, userID!));
      await postgreSQLConnection.close();
    } else {
      Get.snackbar(
        '错误',
        '本地用户数据为空',
        duration: const Duration(seconds: 3),
        backgroundColor: const Color.fromARGB(60, 0, 140, 198),
      );
    }
  }
}

Future<bool> checkAndBuildTableALL(
    Connection postgreSQLConnection, String userID) async {
  var check1 = await postgreSQLConnection.execute(
      "SELECT EXISTS( SELECT 1 FROM pg_catalog.pg_tables WHERE tablename = 'n$userID' AND schemaname = 'u$userID')");
  if (check1[0][0] == false) {
    await postgreSQLConnection.execute("CREATE SCHEMA u$userID");
    await postgreSQLConnection
        .execute("CREATE TABLE u$userID.n$userID AS TABLE public.notetemplate");
    await postgreSQLConnection.execute(
        "ALTER TABLE u$userID.n$userID ALTER COLUMN id SET NOT NULL, ADD PRIMARY KEY (id)");
    check1 = await postgreSQLConnection.execute(
        "SELECT EXISTS( SELECT 1 FROM pg_catalog.pg_tables WHERE tablename = 'n$userID' AND schemaname = 'u$userID')");
  }

  var check2 = await postgreSQLConnection.execute(
      "SELECT EXISTS( SELECT 1 FROM pg_catalog.pg_tables WHERE tablename = 'habit$userID' AND schemaname = 'u$userID')");
  if (check2[0][0] == false) {
    await postgreSQLConnection.execute(
        "CREATE TABLE u$userID.habit$userID AS TABLE public.habittemplate");
    await postgreSQLConnection.execute(
        "ALTER TABLE u$userID.habit$userID ALTER COLUMN id SET NOT NULL, ADD PRIMARY KEY (id)");
    check2 = await postgreSQLConnection.execute(
        "SELECT EXISTS( SELECT 1 FROM pg_catalog.pg_tables WHERE tablename = 'habit$userID' AND schemaname = 'u$userID')");
  }

  var check3 = await postgreSQLConnection.execute(
      "SELECT EXISTS( SELECT 1 FROM pg_catalog.pg_tables WHERE tablename = 'habitrecord$userID' AND schemaname = 'u$userID')");
  if (check3[0][0] == false) {
    await postgreSQLConnection.execute(
        "CREATE TABLE u$userID.habitrecord$userID AS TABLE public.habitrecordtemplate");
    await postgreSQLConnection.execute(
        "ALTER TABLE u$userID.habitrecord$userID ALTER COLUMN id SET NOT NULL, ADD PRIMARY KEY (id)");
    check3 = await postgreSQLConnection.execute(
        "SELECT EXISTS( SELECT 1 FROM pg_catalog.pg_tables WHERE tablename = 'habitrecord$userID' AND schemaname = 'u$userID')");
  }
  if ((check1[0][0] == false) ||
      (check2[0][0] == false) ||
      (check3[0][0] == false)) {
    return false;
  } else {
    return true;
  }
}

Future<bool> checkAndBuildTableNote(
    Connection postgreSQLConnection, String userID) async {
  var check1 = await postgreSQLConnection.execute(
      "SELECT EXISTS( SELECT 1 FROM pg_catalog.pg_tables WHERE tablename = 'n$userID' AND schemaname = 'u$userID')");
  if (check1[0][0] == false) {
    await postgreSQLConnection.execute("CREATE SCHEMA u$userID");
    await postgreSQLConnection
        .execute("CREATE TABLE u$userID.n$userID AS TABLE public.notetemplate");
    await postgreSQLConnection.execute(
        "ALTER TABLE u$userID.n$userID ALTER COLUMN id SET NOT NULL, ADD PRIMARY KEY (id)");
    check1 = await postgreSQLConnection.execute(
        "SELECT EXISTS( SELECT 1 FROM pg_catalog.pg_tables WHERE tablename = 'n$userID' AND schemaname = 'u$userID')");
  }

  return check1[0][0] != false;
}
