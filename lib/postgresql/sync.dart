// ignore_for_file: unused_local_variable, unnecessary_null_comparison

import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:icebergnote/main.dart';
import 'package:icebergnote/notes.dart';
import 'package:postgres/postgres.dart';
import 'package:realm/realm.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<void> initConnect() async {}

Future<void> postgreSQLQuery() async {
  PostgreSQLConnection? postgreSQLConnection = PostgreSQLConnection(
      "111.229.224.55", 5432, "users",
      username: "admin", password: "456321rrRR");
  if (postgreSQLConnection == null) {
    Get.snackbar('错误', '云端数据库连接失败');
  } else {
    await postgreSQLConnection.open();
    final result = await postgreSQLConnection.query("SELECT * FROM userinfo");
    List<Map> results =
        await postgreSQLConnection.mappedResultsQuery("SELECT * FROM userinfo");
    final result2 = await postgreSQLConnection.execute(
        "INSERT INTO userinfo VALUES ('小仙女', '3', 'rrrr.zhao@qq.com', '18795880371', 1, 't', 't', '1')");
    final result3 =
        await postgreSQLConnection.query("SELECT name, password FROM userinfo");
    postgreSQLConnection.close();
  }
}

class SyncPage extends StatefulWidget {
  const SyncPage({super.key});

  @override
  State<SyncPage> createState() => _SyncPageState();
}

class _SyncPageState extends State<SyncPage> {
  String? email;
  String? other;
  String? id;
  String syncProcess = '';
  Future<int> checkRemoteDatabase() async {
    postgreSQLConnection = PostgreSQLConnection("111.229.224.55", 5432, "users",
        username: "admin", password: "456321rrRR");
    if (postgreSQLConnection == null) {
      setState(() {
        syncProcess = '$syncProcess\n连接云端数据库失败';
      });
      return 0;
    } else {
      setState(() {
        syncProcess = '$syncProcess\n连接云端数据库成功';
      });
      final SharedPreferences userLocalInfo =
          await SharedPreferences.getInstance();
      email = userLocalInfo.getString('userEmail');
      other = userLocalInfo.getString('userOther');
      id = userLocalInfo.getString('userID');
      if (email == null || other == null || id == null) {
        setState(() {
          syncProcess = '$syncProcess\n本地用户数据异常';
        });
        return 0;
      } else {
        await postgreSQLConnection!.open();
        final user = await postgreSQLConnection!
            .query("SELECT * FROM userinfo WHERE email = '$email'");
        final other0 =
            sha512.convert(utf8.encode('${other}IceBergNote')).toString();
        if (user[0][5] != other0) {
          setState(() {
            syncProcess = '$syncProcess\n用户权限验证失败';
          });
          return 0;
        } else {
          setState(() {
            syncProcess = '$syncProcess\n用户权限验证通过';
          });
          final checkSchema = await postgreSQLConnection!.query(
              "SELECT EXISTS( SELECT 1 FROM pg_catalog.pg_tables WHERE tablename = 'n$id' AND schemaname = 'u$id')");
          if (checkSchema[0][0] == false) {
            setState(() {
              syncProcess = '$syncProcess\n未检测到云端数据库';
            });
            return 2;
          } else {
            setState(() {
              syncProcess = '$syncProcess\n查询到已有云端数据库';
              syncProcess =
                  '$syncProcess\n--------------------云端连接成功--------------------';
            });
            setState(() {});
            return 1;
          }
        }
      }
    }
  }

  Future<bool> createRemoteDatabase() async {
    setState(() {
      syncProcess = '$syncProcess\n准备新建云端数据库';
    });
    await postgreSQLConnection!.execute("CREATE SCHEMA u$id");
    await postgreSQLConnection!
        .execute("CREATE TABLE u$id.n$id AS TABLE public.notetemplate");
    await postgreSQLConnection!.execute(
        "ALTER TABLE u$id.n$id ALTER COLUMN id SET NOT NULL, ADD PRIMARY KEY (id)");
    final checkSchema1 = await postgreSQLConnection!.query(
        "SELECT EXISTS( SELECT 1 FROM pg_catalog.pg_tables WHERE tablename = 'n$id' AND schemaname = 'u$id')");
    if (checkSchema1[0][0] == false) {
      setState(() {
        syncProcess =
            '$syncProcess\n--------------------云端创建失败--------------------';
      });
      return false;
    } else {
      setState(() {
        syncProcess =
            '$syncProcess\n--------------------云端创建成功--------------------';
      });
      return true;
    }
  }

  Future<bool> clearRemoteDatabase() async {
    var num = await postgreSQLConnection!.execute("DELETE FROM u$id.n$id");
    if (num != 0) {
      setState(() {
        syncProcess = '$syncProcess\n开始清空$num条云端数据';
      });

      num = await postgreSQLConnection!.execute("DELETE FROM u$id.n$id");
      if (num != 0) {
        setState(() {
          syncProcess = '$syncProcess\n清空失败 剩余$num条云端数据';
        });
        return false;
      } else {
        setState(() {
          syncProcess =
              '$syncProcess\n--------------------云端清空完成--------------------';
        });
        return true;
      }
    } else {
      setState(() {
        syncProcess =
            '$syncProcess\n--------------------云端暂无数据--------------------';
      });
      return true;
    }
  }

  Future<void> allLocalToRemote() async {
    var localResults = realm.all<Notes>();
    setState(() {
      syncProcess = '$syncProcess\n开始上传${localResults.length}条本地数据';
      syncProcess = '$syncProcess\n上传进度: 0 / ${localResults.length}条本地数据';
    });
    for (int i = 0; i < localResults.length; i++) {
      setState(() {
        syncProcess = syncProcess.replaceAll('上传进度: $i', '上传进度: ${i + 1}');
      });
      if (i == 74) {
        continue;
      }
      await insertRemote(localResults[i], id!);
    }
    //100条大概半分钟
    setState(() {
      syncProcess =
          '$syncProcess\n--------------------本地上传完成--------------------';
    });
  }

  Future<bool> clearLocalDatabase() async {
    var localResults = realm.all<Notes>();
    if (localResults.isNotEmpty) {
      setState(() {
        syncProcess = '$syncProcess\n开始清空${localResults.length}条本地数据';
      });
      realm.write(() {
        realm.deleteAll<Notes>();
      });
      localResults = realm.all<Notes>();
      if (localResults.isNotEmpty) {
        setState(() {
          syncProcess = '$syncProcess\n清空失败 剩余${localResults.length}条本地数据 正在重试';
        });
        return false;
      } else {
        setState(() {
          syncProcess =
              '$syncProcess\n--------------------本地清空完成--------------------';
        });
        return true;
      }
    } else {
      setState(() {
        syncProcess =
            '$syncProcess\n--------------------本地暂无数据--------------------';
      });
      return true;
    }
  }

  Future<void> allRemoteToLocal() async {
    setState(() {
      syncProcess = '$syncProcess\n开始下载云端数据';
    });
    var remoteResults =
        await postgreSQLConnection!.query("SELECT * FROM u$id.n$id");
    setState(() {
      syncProcess = '$syncProcess\n下载进度: 0 / ${remoteResults.length}条云端数据';
    });
    for (int i = 0; i < remoteResults.length; i++) {
      setState(() {
        syncProcess = syncProcess.replaceAll('下载进度: $i', '下载进度: ${i + 1}');
      });
      await insertLocal(remoteResults[i]);
    }
    //
    setState(() {
      syncProcess =
          '$syncProcess\n--------------------云端下载完成--------------------';
    });
  }

  Future<void> exchangeSmart() async {
    setState(() {
      syncProcess =
          '$syncProcess\n--------------------开始智能同步--------------------';
    });
    DateTime lastRefresh =
        DateTime.utc(2023, 11, 17, 3, 30, 00).add(const Duration(days: -1));
    debugPrint(lastRefresh.toString());
    RealmResults<Notes> localNewNotes = realm.query<Notes>(
        "noteUpdateDate > \$0 SORT(noteUpdateDate ASC)", [lastRefresh]);
    var remoteNewNotes = await postgreSQLConnection!
        .query("SELECT * FROM u$id.n$id WHERE updatedate > '$lastRefresh'");
    List<int> synced = [];
    bool isMatch = false;
    if (remoteNewNotes.isEmpty && localNewNotes.isNotEmpty) {
      setState(() {
        syncProcess = '$syncProcess\n云端为空  开始单向上传';
      });
      await allLocalToRemote();
      setState(() {
        syncProcess = '$syncProcess\n上传完成';
      });
    } else if (remoteNewNotes.isNotEmpty && localNewNotes.isEmpty) {
      setState(() {
        syncProcess = '$syncProcess\n本地为空  开始单向下载';
      });
      await allRemoteToLocal();
      setState(() {
        syncProcess = '$syncProcess\n下载完成';
      });
    } else if (remoteNewNotes.isNotEmpty && localNewNotes.isEmpty) {
      setState(() {
        syncProcess = '$syncProcess\n双端为空  无需同步';
      });
    } else {
      setState(() {
        syncProcess = '$syncProcess\n处理云端数据: 0 / ${localNewNotes.length}';
      });
      debugPrint('------------------开始遍历云端------------------');
      for (int j = 0; j < remoteNewNotes.length; j++) {
        if (synced.contains(j)) {
          debugPrint('${remoteNewNotes[j][3]}:::${remoteNewNotes[j][23]}跳过');
        } else {
          RealmResults<Notes> existedNote = realm.query<Notes>(
              "id == \$0", [Uuid.fromString(remoteNewNotes[j][0])]);
          if (existedNote.isEmpty) {
            debugPrint(
                '${remoteNewNotes[j][3]}:::${remoteNewNotes[j][23]}未匹配到本地 新增到本地');
            insertLocal(remoteNewNotes[j]);
          } else if (existedNote.length == 1) {
            debugPrint(
                '${remoteNewNotes[j][3]}:::${remoteNewNotes[j][23]}已匹配到本地 更新到本地');
            updateLocal(existedNote.first, remoteNewNotes[j]);
          } else {
            debugPrint('本地主键重复');
          }
        }
        setState(() {
          syncProcess =
              syncProcess.replaceAll('处理云端数据: $j', '处理云端数据: ${j + 1}');
        });
      }
      setState(() {
        syncProcess = '$syncProcess\n处理本地数据: 0 / ${localNewNotes.length}';
      });
      debugPrint('------------------开始遍历本地------------------');
      for (int i = 0; i < localNewNotes.length; i++) {
        debugPrint(
            '${localNewNotes[i].noteContext}:::${localNewNotes[i].noteCreateDate}本地');
        isMatch = false;
        for (int j = 0; j < remoteNewNotes.length; j++) {
          if (localNewNotes[i].id.toString() == remoteNewNotes[j][0]) {
            debugPrint(
                '${remoteNewNotes[j][3]}:::${remoteNewNotes[j][23]}匹配到云端');
            isMatch = true;
            synced.add(j);
            if (localNewNotes[i]
                .noteUpdateDate
                .isAfter(remoteNewNotes[j][23])) {
              debugPrint('本地较新 同步云端');
              await updateRemote(localNewNotes[i], id!);
            } else if (localNewNotes[i].noteUpdateDate ==
                remoteNewNotes[j][23]) {
              debugPrint('两端一致 无需同步');
            } else {
              debugPrint('云端较新 同步本地');
              await updateLocal(localNewNotes[i], remoteNewNotes[j]);
            }
          } else {
            if (j == remoteNewNotes.length - 1 && isMatch == false) {
              debugPrint('未匹配到云端 新增到云端');
              await insertOrUpdateRemote(localNewNotes[i], id!);
            }
          }
        }
        setState(() {
          syncProcess =
              syncProcess.replaceAll('处理本地数据: $i', '处理本地数据: ${i + 1}');
        });
      }
      setState(() {
        syncProcess =
            '$syncProcess\n--------------------智能同步成功--------------------';
      });
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

  Future<void> updateRemote(Notes note, String id) async {
    await postgreSQLConnection!.execute(
        "UPDATE u$id.n$id SET folder = '${note.noteFolder}', title = '${note.noteTitle}', context = '${note.noteContext}', type = '${note.noteType}', project = '${note.noteProject}', tags = '${note.noteTags}', attachments = '${note.noteAttachments}', ref = '${note.noteReferences}', source = '${note.noteSource}', author = '${note.noteAuthor}', next = '${note.noteNext}', last = '${note.noteLast}', place = '${note.notePlace}', isstarred = '${note.noteIsStarred}', islocked = '${note.noteIsLocked}', istodo = '${note.noteIstodo}', isdeleted = '${note.noteIsDeleted}', isshared = '${note.noteIsShared}', isachived = '${note.noteIsAchive}', finishstate = '${note.noteFinishState}', isreviewed = '${note.noteIsReviewed}', createdate = '${note.noteCreateDate}', updatedate = '${note.noteUpdateDate}', achivedate = '${note.noteAchiveDate}', deletedate = '${note.noteDeleteDate}', finishdate = '${note.noteFinishDate}', alarmdate = '${note.noteAlarmDate}' WHERE id = '${note.id}'");
  }

  Future<void> insertRemote(Notes note, String id) async {
    await postgreSQLConnection!.execute(
        "INSERT INTO u$id.n$id VALUES ('${note.id}', '${note.noteFolder}', '${note.noteTitle}', '${note.noteContext}', '${note.noteType}', '${note.noteProject}', '${note.noteTags}', '${note.noteAttachments}', '${note.noteReferences}', '${note.noteSource}', '${note.noteAuthor}', '${note.noteNext}', '${note.noteLast}', '${note.notePlace}', '${note.noteIsStarred}', '${note.noteIsLocked}', '${note.noteIstodo}', '${note.noteIsDeleted}', '${note.noteIsShared}', '${note.noteIsAchive}', '${note.noteFinishState}', '${note.noteIsReviewed}', '${note.noteCreateDate}','${note.noteUpdateDate}', '${note.noteAchiveDate}', '${note.noteDeleteDate}', '${note.noteFinishDate}', '${note.noteAlarmDate}')");
  }

  Future<void> insertOrUpdateRemote(Notes note, String id) async {
    await postgreSQLConnection!.execute(
        "INSERT INTO u$id.n$id VALUES ('${note.id}', '${note.noteFolder}', '${note.noteTitle}', '${note.noteContext}', '${note.noteType}', '${note.noteProject}', '${note.noteTags}', '${note.noteAttachments}', '${note.noteReferences}', '${note.noteSource}', '${note.noteAuthor}', '${note.noteNext}', '${note.noteLast}', '${note.notePlace}', '${note.noteIsStarred}', '${note.noteIsLocked}', '${note.noteIstodo}', '${note.noteIsDeleted}', '${note.noteIsShared}', '${note.noteIsAchive}', '${note.noteFinishState}', '${note.noteIsReviewed}', '${note.noteCreateDate}','${note.noteUpdateDate}', '${note.noteAchiveDate}', '${note.noteDeleteDate}', '${note.noteFinishDate}', '${note.noteAlarmDate}') ON CONFLICT (id) DO UPDATE SET folder = '${note.noteFolder}', title = '${note.noteTitle}', context = '${note.noteContext}', type = '${note.noteType}', project = '${note.noteProject}', tags = '${note.noteTags}', attachments = '${note.noteAttachments}', ref = '${note.noteReferences}', source = '${note.noteSource}', author = '${note.noteAuthor}', next = '${note.noteNext}', last = '${note.noteLast}', place = '${note.notePlace}', isstarred = '${note.noteIsStarred}', islocked = '${note.noteIsLocked}', istodo = '${note.noteIstodo}', isdeleted = '${note.noteIsDeleted}', isshared = '${note.noteIsShared}', isachived = '${note.noteIsAchive}', finishstate = '${note.noteFinishState}', isreviewed = '${note.noteIsReviewed}', createdate = '${note.noteCreateDate}', updatedate = '${note.noteUpdateDate}', achivedate = '${note.noteAchiveDate}', deletedate = '${note.noteDeleteDate}', finishdate = '${note.noteFinishDate}', alarmdate = '${note.noteAlarmDate}'");
  }

  PostgreSQLConnection? postgreSQLConnection;
  @override
  Widget build(BuildContext context) {
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
                syncProcess = '';
                int p1 = await checkRemoteDatabase();
                bool p2 = false;
                switch (p1) {
                  case 1:
                    p2 = await clearRemoteDatabase();
                    break;
                  case 2:
                    p2 = await createRemoteDatabase();
                    break;
                }
                if (p2) {
                  await allLocalToRemote();
                }
                postgreSQLConnection!.queueSize;
              },
              child: const Text('本地>>>>云端'),
            ),
            const Text('请确认本地数据完备', style: TextStyle(color: Colors.red)),
            const Text('将清空云端 并将本地数据全部同步到云端'),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                syncProcess = '';
                int p1 = await checkRemoteDatabase();
                if (p1 == 1) {
                  bool p2 = await clearLocalDatabase();
                  if (p2) await allRemoteToLocal();
                } else if (p1 == 2) {
                  await createRemoteDatabase();
                }
              },
              child: const Text('本地<<<<云端'),
            ),
            const Text('请确认云端数据完备', style: TextStyle(color: Colors.red)),
            const Text('将清空本地 并将云端数据全部同步到本地'),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                syncProcess = '';
                int p1 = await checkRemoteDatabase();
                if (p1 == 1) {
                  exchangeSmart();
                }
              },
              child: const Text('本地<===>云端'),
            ),
            const Text('双向全量遍历同步'),
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
