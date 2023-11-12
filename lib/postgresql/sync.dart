// ignore_for_file: unused_local_variable, unnecessary_null_comparison

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
