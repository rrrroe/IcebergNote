// ignore_for_file: unused_local_variable, unnecessary_null_comparison

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:postgres/postgres.dart';

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
  String syncProcess = '连接云端中……';
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
              onPressed: () {},
              child: const Text('DEV===>CLOUDE'),
            ),
            const Text('清空云端，本设备全部同步到云端'),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {},
              child: const Text('CLOUDE===>DEV'),
            ),
            const Text('清空设备，全部从云端同步'),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {},
              child: const Text('DEV===>CLOUDE'),
            ),
            const Text('双向全量遍历同步'),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {},
              child: const Text('DEV===>CLOUDE'),
            ),
            const Text('双向本周遍历同步'),
            const SizedBox(height: 40),
            Text(syncProcess),
          ],
        ),
      ),
    );
  }
}
