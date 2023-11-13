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
        final results = await connection!
            .query("SELECT * FROM userinfo WHERE email = '${data.name}'");
        if (results.isNotEmpty) {
          var tmp = sha512.convert(utf8.encode('${data.password}IceBergNote'));
          if (tmp.toString() == results[0][5]) {
            final SharedPreferences userLocalInfo =
                await SharedPreferences.getInstance();
            userLocalInfo.setString('userName', results[0][0]);
            userLocalInfo.setString('userID', results[0][1]);
            userLocalInfo.setString('userEmail', results[0][2]);
            userLocalInfo.setString('userPhone', results[0][3] ?? '');
            userLocalInfo.setBool('userIsAdmin', results[0][4]);
            userLocalInfo.setString('userCreatDate', results[0][6].toString());
            userLocalInfo.setString('userVIPDate', results[0][7].toString());
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
    try {
      connection = PostgreSQLConnection("111.229.224.55", 5432, "users",
          username: "admin", password: "456321rrRR");

      if (connection == null) {
        return '远程数据库连接失败';
      } else {
        await connection!.open();
        final results = await connection!
            .query("SELECT * FROM userinfo WHERE email = '${data.name}'");
        var no = await connection!.query("SELECT COUNT(*) FROM userinfo");
        print(no);
        String date1 = DateTime.now()
            .add(const Duration(days: 50))
            .toString()
            .substring(0, 10);
        String date2 = DateTime.now().toString().substring(0, 10);
        if (results.isNotEmpty) {
          return '该用户已存在  请登录';
        } else {
          var tmp = sha512.convert(utf8.encode('${data.password}IceBergNote'));
          int back = await connection!.execute(
              "INSERT INTO userinfo (id, name, email, password, isadmin, createtime, viptime) VALUES (${no[0][0]}, '${data.name}', '${data.name}', '$tmp', 'f', '$date1', '$date2')");
          if (back == 1) {
            final SharedPreferences userLocalInfo =
                await SharedPreferences.getInstance();
            userLocalInfo.setString('userName', data.name!);
            userLocalInfo.setString('userID', no[0][0].toString());
            userLocalInfo.setString('userEmail', data.name!);
            userLocalInfo.setString('userPhone', '');
            userLocalInfo.setBool('userIsAdmin', false);
            userLocalInfo.setString('userCreatDate', date2);
            userLocalInfo.setString('userVIPDate', date1);
            Get.find<UserController>().refreshLocalUser();
            return null;
          } else {
            return '注册失败';
          }
        }
      }
    } catch (e) {
      await Future.delayed(const Duration(seconds: 5));
      return '网络错误';
    }
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
      messages: LoginMessages(
        userHint: '邮箱',
        passwordHint: '密码',
        confirmPasswordHint: '确认密码',
        forgotPasswordButton: '忘记密码',
        loginButton: '登录',
        signupButton: '注册',
        recoverPasswordButton: '恢复密码',
        confirmPasswordError: '密码不一致',
        recoverPasswordSuccess: '恢复密码成功',
        goBackButton: '返回',
        resendCodeButton: '重新发送',
        resendCodeSuccess: '发送成功',
        recoverPasswordDescription: '我们将会给这个邮箱发送明文密码',
        recoverPasswordIntro: '重置密码',
        flushbarTitleError: '错误',
        flushbarTitleSuccess: '成功',
      ),
      theme: LoginTheme(
        titleStyle: const TextStyle(color: Colors.white),
        primaryColor: const Color.fromARGB(255, 0, 140, 198),
        accentColor: Colors.white,
        switchAuthTextColor: const Color.fromARGB(255, 0, 140, 198),
        primaryColorAsInputLabel: false,
        pageColorDark: const Color.fromARGB(255, 18, 107, 174),
        pageColorLight: const Color.fromARGB(255, 18, 170, 156),
        footerBackgroundColor: Colors.red,
      ),
    );
  }
}
