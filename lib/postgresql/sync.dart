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
    Get.snackbar('错误', '远程数据库连接失败');
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

  Future<void> checkRemoteDatabase() async {
    postgreSQLConnection = PostgreSQLConnection("111.229.224.55", 5432, "users",
        username: "admin", password: "456321rrRR");
    if (postgreSQLConnection == null) {
      setState(() {
        syncProcess = '$syncProcess\n连接云端数据库失败';
      });
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
        } else {
          setState(() {
            syncProcess = '$syncProcess\n用户权限验证通过';
          });
          final checkSchema = await postgreSQLConnection!.query(
              "SELECT EXISTS( SELECT 1 FROM pg_catalog.pg_tables WHERE tablename = 'n$id' AND schemaname = 'u$id')");
          if (checkSchema[0][0] == false) {
            setState(() {
              syncProcess = '$syncProcess\n未检测到数据库 新建中……';
            });
            await postgreSQLConnection!.execute("CREATE SCHEMA u$id");
            await postgreSQLConnection!
                .execute("CREATE TABLE u$id.n$id AS TABLE public.notetemplate");
            final checkSchema1 = await postgreSQLConnection!.query(
                "SELECT EXISTS( SELECT 1 FROM pg_catalog.pg_tables WHERE tablename = 'n$id' AND schemaname = 'u$id')");
            if (checkSchema1[0][0] == false) {
              setState(() {
                syncProcess = '$syncProcess\n创建错误';
              });
            } else {
              setState(() {
                syncProcess = '$syncProcess\n创建完成';
              });
            }
          } else {
            setState(() {
              syncProcess = '$syncProcess\n查询到已有数据库';
            });
          }
        }
      }
    }
    setState(() {
      syncProcess =
          '$syncProcess\n--------------------云端校验完成--------------------';
    });
  }

  Future<void> clearRemoteDatabase() async {
    var num = await postgreSQLConnection!.execute("DELETE FROM u$id.n$id");
    if (num != 0) {
      setState(() {
        syncProcess = '$syncProcess\n开始清空$num条云端数据';
      });

      await postgreSQLConnection!.execute("DELETE FROM u$id.n$id");

      num = await postgreSQLConnection!.execute("DELETE FROM u$id.n$id");
      if (num != 0) {
        setState(() {
          syncProcess = '$syncProcess\n清空失败 剩余$num条云端数据 请重试';
        });
      } else {
        setState(() {
          syncProcess =
              '$syncProcess\n--------------------云端清空完成--------------------';
        });
      }
    } else {
      setState(() {
        syncProcess =
            '$syncProcess\n--------------------云端清空完成--------------------';
      });
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
      await postgreSQLConnection!.execute(localtoremote(localResults[i], id!));
    }
    //100条大概半分钟
    setState(() {
      syncProcess =
          '$syncProcess\n--------------------本地上传完成--------------------';
    });
  }

  Future<void> remotetolocal(List result) async {
    var noteList = realm.query<Notes>("id == '${result[0]}' SORT(id DESC)");
    if (noteList.isEmpty) {
      realm.add(Notes(
        ObjectId(),
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
    } else if (noteList.length == 1) {
      Notes note = noteList[0];
      if (note.noteUpdateDate.isBefore(result[23])) {
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
      } else {
        await postgreSQLConnection!.execute(localtoremote(note, id!));
      }
    } else {
      setState(() {
        syncProcess = '$syncProcess\n!!!本地存在两条记录冲突!!!';
      });
    }
  }

  String localtoremote(Notes note, String id) {
    return "INSERT INTO u$id.n$id VALUES ('${note.id}', '${note.noteFolder}', '${note.noteTitle}', '${note.noteContext}', '${note.noteType}', '${note.noteProject}', '${note.noteTags}', '${note.noteAttachments}', '${note.noteReferences}', '${note.noteSource}', '${note.noteAuthor}', '${note.noteNext}', '${note.noteLast}', '${note.notePlace}', '${note.noteIsStarred}', '${note.noteIsLocked}', '${note.noteIstodo}', '${note.noteIsDeleted}', '${note.noteIsShared}', '${note.noteIsAchive}', '${note.noteFinishState}', '${note.noteIsReviewed}', '${note.noteCreateDate.toString().substring(0, 19)}','${note.noteUpdateDate.toString().substring(0, 19)}', '${note.noteAchiveDate.toString().substring(0, 19)}', '${note.noteDeleteDate.toString().substring(0, 19)}', '${note.noteFinishDate.toString().substring(0, 19)}', '${note.noteAlarmDate.toString().substring(0, 19)}')";
  }

  String syncProcess = '';
  PostgreSQLConnection? postgreSQLConnection;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('同步'),
      ),
      body: Align(
        alignment: Alignment.center,
        child: Column(
          children: [
            ElevatedButton(
              onPressed: () async {
                syncProcess = '';
                await checkRemoteDatabase();
                await clearRemoteDatabase();
                allLocalToRemote();
              },
              child: const Text('DEV===>CLOUDE'),
            ),
            const Text('清空云端，本设备全部同步到云端'),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {},
              child: const Text('CLOUDE===>DEV'),
            ),
            const Text('清空设备，全部从云端同步'),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {},
              child: const Text('DEV<===>CLOUDE'),
            ),
            const Text('双向全量遍历同步'),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {},
              child: const Text('DEV<=>CLOUDE'),
            ),
            const Text('双向本周遍历同步'),
            const SizedBox(height: 40),
            Text(
              syncProcess,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
