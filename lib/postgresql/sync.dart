// ignore_for_file: unused_local_variable, unnecessary_null_comparison

import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
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
//       host: '111.229.224.55',
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
                    host: '111.229.224.55',
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

                    final checkSchema = await postgreSQLConnection.execute(
                        "SELECT EXISTS( SELECT 1 FROM pg_catalog.pg_tables WHERE tablename = 'n$userID' AND schemaname = 'u$userID')");
                    if (checkSchema[0][0] == false) {
                      syncProcess = '$syncProcess\n未检测到云端数据库';
                      setState(() {});
                      syncProcess = '$syncProcess\n准备新建云端数据库';
                      setState(() {});
                      await postgreSQLConnection
                          .execute("CREATE SCHEMA u$userID");
                      await postgreSQLConnection.execute(
                          "CREATE TABLE u$userID.n$userID AS TABLE public.notetemplate");
                      await postgreSQLConnection.execute(
                          "ALTER TABLE u$userID.n$userID ALTER COLUMN id SET NOT NULL, ADD PRIMARY KEY (id)");
                      final checkSchema1 = await postgreSQLConnection.execute(
                          "SELECT EXISTS( SELECT 1 FROM pg_catalog.pg_tables WHERE tablename = 'n$userID' AND schemaname = 'u$userID')");
                      if (checkSchema1[0][0] == false) {
                        syncProcess =
                            '$syncProcess\n--------------------云端创建失败--------------------';
                        setState(() {});
                      } else {
                        syncProcess =
                            '$syncProcess\n--------------------云端创建成功--------------------';
                        setState(() {});
                        var localResults = realm.all<Notes>();

                        syncProcess =
                            '$syncProcess\n开始上传${localResults.length}条本地数据';
                        setState(() {});
                        syncProcess =
                            '$syncProcess\n上传进度: 0 / ${localResults.length}条本地数据';
                        setState(() {});

                        for (int i = 0; i < localResults.length; i++) {
                          syncProcess = syncProcess.replaceAll(
                              '上传进度: $i', '上传进度: ${i + 1}');
                          setState(() {});
                          await postgreSQLConnection
                              .execute(insertRemote(localResults[i], userID!));
                        }
                        //100条大概半分钟
                        await postgreSQLConnection.close();
                        syncProcess =
                            '$syncProcess\n--------------------本地上传完成--------------------';
                        setState(() {});
                      }
                    } else {
                      syncProcess = '$syncProcess\n查询到已有云端数据库';
                      setState(() {});
                      syncProcess =
                          '$syncProcess\n--------------------云端连接成功--------------------';
                      setState(() {});
                      var num = await postgreSQLConnection
                          .execute("DELETE FROM u$userID.n$userID");
                      if (num.affectedRows != 0) {
                        '开始清空$num条云端数据';

                        num = await postgreSQLConnection
                            .execute("DELETE FROM u$userID.n$userID");
                        if (num.affectedRows != 0) {
                          syncProcess = '$syncProcess\n清空失败 剩余$num条云端数据';
                        } else {
                          syncProcess =
                              '$syncProcess\n--------------------云端清空完成--------------------';
                        }
                      } else {
                        syncProcess =
                            '$syncProcess\n--------------------云端暂无数据--------------------';
                      }
                      var localResults = realm.all<Notes>();

                      syncProcess =
                          '$syncProcess\n开始上传${localResults.length}条本地数据';
                      setState(() {});
                      syncProcess =
                          '$syncProcess\n上传进度: 0 / ${localResults.length}条本地数据';
                      setState(() {});

                      for (int i = 0; i < localResults.length; i++) {
                        syncProcess = syncProcess.replaceAll(
                            '上传进度: $i', '上传进度: ${i + 1}');
                        setState(() {});
                        await postgreSQLConnection
                            .execute(insertRemote(localResults[i], userID!));
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
                    host: '111.229.224.55',
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

                    final checkSchema = await postgreSQLConnection.execute(
                        "SELECT EXISTS( SELECT 1 FROM pg_catalog.pg_tables WHERE tablename = 'n$userID' AND schemaname = 'u$userID')");
                    if (checkSchema[0][0] == false) {
                      syncProcess = '$syncProcess\n未检测到云端数据库';
                      setState(() {});
                    } else {
                      syncProcess = '$syncProcess\n查询到已有云端数据库';
                      setState(() {});
                      syncProcess =
                          '$syncProcess\n--------------------云端连接成功--------------------';
                      setState(() {});
                      var localResults = realm.all<Notes>();

                      syncProcess =
                          '$syncProcess\n开始清空${localResults.length}条本地数据';
                      setState(() {});
                      realm.write(() {
                        realm.deleteAll<Notes>();
                      });

                      syncProcess =
                          '$syncProcess\n--------------------本地清空完成--------------------';
                      setState(() {});
                      var remoteResults = await postgreSQLConnection
                          .execute("SELECT * FROM u$userID.n$userID");
                      syncProcess =
                          '$syncProcess\n下载进度: 0 / ${remoteResults.length}条云端数据';
                      setState(() {});
                      for (int i = 0; i < remoteResults.length; i++) {
                        await insertLocal(remoteResults[i]);
                        syncProcess = syncProcess.replaceAll(
                            '下载进度: $i', '下载进度: ${i + 1}');
                        setState(() {});
                      }
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
      host: '111.229.224.55',
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
      host: '111.229.224.55',
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
      host: '111.229.224.55',
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
      host: '111.229.224.55',
      database: 'users',
      username: "admin",
      password: "456321rrRR"));
  syncProcessController.syncProcessAddLine('开始上传${localResults.length}条本地数据');
  syncProcessController
      .syncProcessAddLine('上传进度: 0 / ${localResults.length}条本地数据');

  for (int i = 0; i < localResults.length; i++) {
    syncProcessController.syncProcessReplace('上传进度: $i', '上传进度: ${i + 1}');
    await postgreSQLConnection.execute(insertRemote(localResults[i], userID!));
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
      host: '111.229.224.55',
      database: 'users',
      username: "admin",
      password: "456321rrRR"));

  var remoteResults =
      await postgreSQLConnection.execute("SELECT * FROM u$userID.n$userID");
  syncProcessController
      .syncProcessAddLine('下载进度: 0 / ${remoteResults.length}条云端数据');
  for (int i = 0; i < remoteResults.length; i++) {
    syncProcessController.syncProcessReplace('下载进度: $i', '下载进度: ${i + 1}');
    await insertLocal(remoteResults[i]);
  }
  await postgreSQLConnection.close();
  syncProcessController
      .syncProcessAddLine('--------------------云端下载完成--------------------');
}

Future<void> exchangeSmart() async {
  final postgreSQLConnection = await Connection.open(Endpoint(
      host: '111.229.224.55',
      database: 'users',
      username: "admin",
      password: "456321rrRR"));
  try {
    userLocalInfo ??= await SharedPreferences.getInstance();
    if (userLocalInfo != null) {
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
          host: '111.229.224.55',
          database: 'users',
          username: "admin",
          password: "456321rrRR"));
      var remoteNewNotes = await postgreSQLConnection.execute(
          "SELECT * FROM u$userID.n$userID WHERE updatedate > '$lastRefresh'");
      List<int> synced = [];
      for (int i = 0; i < localNewNotes.length; i++) {
        if (remoteNewNotes.isEmpty) {
          await postgreSQLConnection
              .execute(insertOrUpdateRemote(localNewNotes[i], userID!));
        }
        for (int j = 0; j < remoteNewNotes.length; j++) {
          DateTime remoteUpdateDate = DateTime(1969, 1, 1);
          try {
            remoteUpdateDate = DateTime.parse(remoteNewNotes[j][23].toString());
          } catch (e) {
            continue;
          }
          if (localNewNotes[i].id.toString() == remoteNewNotes[j][0]) {
            synced.add(j);
            if (localNewNotes[i].noteUpdateDate.isAfter(remoteUpdateDate)) {
              await postgreSQLConnection
                  .execute(updateRemote(localNewNotes[i], userID!));
            } else {
              await updateLocal(localNewNotes[i], remoteNewNotes[j]);
            }
            break;
          } else {
            if (j == remoteNewNotes.length - 1) {
              await postgreSQLConnection
                  .execute(insertOrUpdateRemote(localNewNotes[i], userID!));
            }
          }
        }
      }

      for (int j = 0; j < remoteNewNotes.length; j++) {
        if (synced.contains(j)) {
        } else {
          RealmResults<Notes> existedNote = realm.query<Notes>(
              "id == \$0", [Uuid.fromString(remoteNewNotes[j][0].toString())]);
          if (existedNote.isEmpty) {
            insertLocal(remoteNewNotes[j]);
          } else if (existedNote.length == 1) {
            updateLocal(existedNote.first, remoteNewNotes[j]);
          } else {}
        }
      }
      // Get.snackbar(
      //   '同步成功',
      //   '',
      //   duration: const Duration(seconds: 1),
      //   backgroundColor: const Color.fromARGB(60, 0, 140, 198),
      // );
      if (kDebugMode) {
        print('同步成功');
      }
    } else {
      if (kDebugMode) {
        print('本地用户信息错误');
      }
    }
  } catch (e) {
    // Get.snackbar(
    //   '同步失败',
    //   e.toString(),
    //   duration: const Duration(seconds: 3),
    //   backgroundColor: const Color.fromARGB(60, 0, 140, 198),
    // );
    if (kDebugMode) {
      print('同步失败:$e');
    }
  } finally {
    postgreSQLConnection.close();
  }
}

Future<void> compareLR1(Notes note, List result) async {}

Future<void> updateLocal(Notes note, List result) async {
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

Future<void> insertLocal(List result) async {
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

String updateRemote(Notes note, String id) {
  return "UPDATE u$id.n$id SET folder = '${note.noteFolder}', title = '${note.noteTitle}', context = '${note.noteContext}', type = '${note.noteType}', project = '${note.noteProject}', tags = '${note.noteTags}', attachments = '${note.noteAttachments}', ref = '${note.noteReferences}', source = '${note.noteSource}', author = '${note.noteAuthor}', next = '${note.noteNext}', last = '${note.noteLast}', place = '${note.notePlace}', isstarred = '${note.noteIsStarred}', islocked = '${note.noteIsLocked}', istodo = '${note.noteIstodo}', isdeleted = '${note.noteIsDeleted}', isshared = '${note.noteIsShared}', isachived = '${note.noteIsAchive}', finishstate = '${note.noteFinishState}', isreviewed = '${note.noteIsReviewed}', createdate = '${note.noteCreateDate}', updatedate = '${note.noteUpdateDate}', achivedate = '${note.noteAchiveDate}', deletedate = '${note.noteDeleteDate}', finishdate = '${note.noteFinishDate}', alarmdate = '${note.noteAlarmDate}' WHERE id = '${note.id}'";
}

String insertRemote(Notes note, String id) {
  return "INSERT INTO u$id.n$id VALUES ('${note.id}', '${note.noteFolder}', '${note.noteTitle}', '${note.noteContext}', '${note.noteType}', '${note.noteProject}', '${note.noteTags}', '${note.noteAttachments}', '${note.noteReferences}', '${note.noteSource}', '${note.noteAuthor}', '${note.noteNext}', '${note.noteLast}', '${note.notePlace}', '${note.noteIsStarred}', '${note.noteIsLocked}', '${note.noteIstodo}', '${note.noteIsDeleted}', '${note.noteIsShared}', '${note.noteIsAchive}', '${note.noteFinishState}', '${note.noteIsReviewed}', '${note.noteCreateDate}','${note.noteUpdateDate}', '${note.noteAchiveDate}', '${note.noteDeleteDate}', '${note.noteFinishDate}', '${note.noteAlarmDate}')";
}

String insertOrUpdateRemote(Notes note, String id) {
  return "INSERT INTO u$id.n$id VALUES ('${note.id}', '${note.noteFolder}', '${note.noteTitle}', '${note.noteContext}', '${note.noteType}', '${note.noteProject}', '${note.noteTags}', '${note.noteAttachments}', '${note.noteReferences}', '${note.noteSource}', '${note.noteAuthor}', '${note.noteNext}', '${note.noteLast}', '${note.notePlace}', '${note.noteIsStarred}', '${note.noteIsLocked}', '${note.noteIstodo}', '${note.noteIsDeleted}', '${note.noteIsShared}', '${note.noteIsAchive}', '${note.noteFinishState}', '${note.noteIsReviewed}', '${note.noteCreateDate}','${note.noteUpdateDate}', '${note.noteAchiveDate}', '${note.noteDeleteDate}', '${note.noteFinishDate}', '${note.noteAlarmDate}') ON CONFLICT (id) DO UPDATE SET folder = '${note.noteFolder}', title = '${note.noteTitle}', context = '${note.noteContext}', type = '${note.noteType}', project = '${note.noteProject}', tags = '${note.noteTags}', attachments = '${note.noteAttachments}', ref = '${note.noteReferences}', source = '${note.noteSource}', author = '${note.noteAuthor}', next = '${note.noteNext}', last = '${note.noteLast}', place = '${note.notePlace}', isstarred = '${note.noteIsStarred}', islocked = '${note.noteIsLocked}', istodo = '${note.noteIstodo}', isdeleted = '${note.noteIsDeleted}', isshared = '${note.noteIsShared}', isachived = '${note.noteIsAchive}', finishstate = '${note.noteFinishState}', isreviewed = '${note.noteIsReviewed}', createdate = '${note.noteCreateDate}', updatedate = '${note.noteUpdateDate}', achivedate = '${note.noteAchiveDate}', deletedate = '${note.noteDeleteDate}', finishdate = '${note.noteFinishDate}', alarmdate = '${note.noteAlarmDate}'";
}

void syncNoteToRemote(Notes note) async {
  final postgreSQLConnection = await Connection.open(Endpoint(
      host: '111.229.224.55',
      database: 'users',
      username: "admin",
      password: "456321rrRR"));
  if (userLocalInfo != null) {
    userID = userLocalInfo!.getString('userID');
    await postgreSQLConnection.execute(insertOrUpdateRemote(note, userID!));
    await postgreSQLConnection.close();
  } else {
    userLocalInfo = await SharedPreferences.getInstance();
    if (userLocalInfo != null) {
      userID = userLocalInfo!.getString('userID');
      await postgreSQLConnection.execute(insertOrUpdateRemote(note, userID!));
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
