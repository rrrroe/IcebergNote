import 'package:flutter/material.dart';
import 'package:flutter_login/flutter_login.dart';
import 'package:get/get.dart';
import 'package:icebergnote/users.dart';
import 'package:postgres/postgres.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:crypto/crypto.dart';
import 'dart:convert';

const users = {
  'dribbble@gmail.com': '12345',
  'hunter@gmail.com': 'hunter',
  'rrrr.zhao@qq.com': '111111',
};

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => LoginScreenState();
}

class LoginScreenState extends State<LoginScreen> {
  Duration get loginTime => const Duration(milliseconds: 0);
  PostgreSQLConnection? connection;

  Future<String?> _authUser(LoginData data) async {
    try {
      connection = PostgreSQLConnection("111.229.224.55", 5432, "users",
          username: "admin", password: "456321rrRR");

      if (connection == null) {
        return '远程数据库连接失败';
      } else {
        await connection!.open();
        final results = await connection!.query(
            "SELECT * FROM userinfo WHERE email = '${data.name}' OR phone = '${data.name}'");
        if (results.isNotEmpty) {
          var tmp = sha512.convert(utf8.encode('${data.password}IceBergNote'));
          if (tmp.toString() == results[0][6]) {
            final SharedPreferences userLocalInfo =
                await SharedPreferences.getInstance();
            userLocalInfo.setString('userName', results[0][0]);
            userLocalInfo.setString('userID', results[0][1]);
            userLocalInfo.setString('userEmail', results[0][2]);
            userLocalInfo.setString('userPhone', results[0][3]);
            userLocalInfo.setInt('userNO', results[0][4]);
            userLocalInfo.setBool('userIsAdmin', results[0][5]);
            userLocalInfo.setString('userCreatDate', results[0][7].toString());
            userLocalInfo.setString('userVIPDate', results[0][8].toString());
            Get.find<UserController>().refreshLocalUser();
            return null;
          } else {
            return '密码错误';
          }
        } else {
          return '用户不存在';
        }
      }
    } catch (e) {
      await Future.delayed(const Duration(seconds: 5));
      return '网络错误';
    }
  }

  Future<String?> _signupUser(SignupData data) async {
    final SharedPreferences userLocalInfo =
        await SharedPreferences.getInstance();
    userLocalInfo.setString('userEmail', data.name.toString());
    userLocalInfo.setString('userID', DateTime.now().toString());
    return Future.delayed(loginTime).then((_) {
      return null;
    });
  }

  Future<String?> _recoverPassword(String name) {
    return Future.delayed(loginTime).then((_) {
      if (!users.containsKey(name)) {
        return '用户不存在';
      }
      return null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return FlutterLogin(
      title: '冰山记',
      logo: const AssetImage('lib/assets/image/icebergicon.png'),
      onLogin: _authUser,
      onSignup: _signupUser,
      onSubmitAnimationCompleted: () {
        Navigator.pushNamed(context, '/');
      },
      onRecoverPassword: _recoverPassword,
    );
  }
}
