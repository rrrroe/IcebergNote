import 'package:flutter/material.dart';
import 'package:flutter_login/flutter_login.dart';
import 'package:get/get.dart';
import 'package:icebergnote/constants.dart';
import 'package:icebergnote/system/device_id.dart';
import 'package:icebergnote/users.dart';
import 'package:postgres/postgres.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:crypto/crypto.dart';
import 'dart:convert';
// import 'package:font_awesome_flutter/font_awesome_flutter.dart';

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

            if (deviceUniqueId != '未知设备') {
              if (results[0][8] == null || results[0][8] == '') {
                await connection!.query(
                    "UPDATE userinfo SET devices='$deviceUniqueId' WHERE id='${results[0][1]}'");
                userLocalInfo.setInt('deviceNO', 1);
              } else if (!results[0][8]
                  .toString()
                  .split('|||')
                  .contains(deviceUniqueId)) {
                String devices = results[0][8] + '|||' + deviceUniqueId;
                await connection!.query(
                    "UPDATE userinfo SET devices='$devices' WHERE id='${results[0][1]}'");
                userLocalInfo.setInt('deviceNO', devices.split('|||').length);
              } else {
                userLocalInfo.setInt(
                    'deviceNO',
                    results[0][8]
                            .toString()
                            .split('|||')
                            .indexOf(deviceUniqueId) +
                        1);
              }
            }
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
        String date1 = DateTime.now().toString().substring(0, 10);
        String date2 = DateTime.now()
            .add(const Duration(days: 50))
            .toString()
            .substring(0, 10);
        if (results.isNotEmpty && results[0][5] != '') {
          return '该用户已存在  请登录';
        } else if (results.isEmpty) {
          var tmp = sha512.convert(utf8.encode('${data.password}IceBergNote'));
          int back = await connection!.execute(
              "INSERT INTO userinfo (id, name, email, password, isadmin, createtime, viptime, phone, devices) VALUES (${no[0][0]}, '${data.additionalSignupData!['昵称'] ?? ''}', '${data.name}', '$tmp', 'f', '$date1', '$date2','${data.additionalSignupData!['手机'] ?? ''}', '${deviceUniqueId == '未知设备' ? '' : deviceUniqueId}')");
          if (back == 1) {
            final SharedPreferences userLocalInfo =
                await SharedPreferences.getInstance();
            userLocalInfo.setString(
                'userName', data.additionalSignupData!['昵称'] ?? '');
            userLocalInfo.setString('userID', no[0][0].toString());
            userLocalInfo.setString('userEmail', data.name!);
            userLocalInfo.setString(
                'userPhone', data.additionalSignupData!['手机'] ?? '');
            userLocalInfo.setBool('userIsAdmin', false);
            userLocalInfo.setString('userCreatDate', date1);
            userLocalInfo.setString('userVIPDate', date2);
            userLocalInfo.setInt('deviceNO', 1);
            Get.find<UserController>().refreshLocalUser();
          } else {
            return '注册失败';
          }
        } else {
          if (data.additionalSignupData!['昵称'] == results[0][0] &&
              data.additionalSignupData!['手机'] == results[0][3]) {
            var tmp =
                sha512.convert(utf8.encode('${data.password}IceBergNote'));
            String? devices = results[0][8];
            if (deviceUniqueId != '未知设备') {
              if (devices == null || devices == '') {
                devices = deviceUniqueId;
              } else if (!devices.split('|||').contains(deviceUniqueId)) {
                devices = '$devices|||$deviceUniqueId';
              }
            }
            int back = await connection!.execute(
                "UPDATE userinfo SET password='$tmp', devices='$devices' WHERE id='${results[0][1]}'");

            if (back == 1) {
              final SharedPreferences userLocalInfo =
                  await SharedPreferences.getInstance();
              userLocalInfo.setString('userName', results[0][0]);
              userLocalInfo.setString('userID', no[0][0].toString());
              userLocalInfo.setString('userEmail', data.name!);
              userLocalInfo.setString(
                  'userPhone', data.additionalSignupData!['手机'] ?? '');
              userLocalInfo.setBool('userIsAdmin', false);
              userLocalInfo.setString('userCreatDate', date1);
              userLocalInfo.setString('userVIPDate', date2);
              userLocalInfo.setInt('deviceNO',
                  devices!.split('|||').indexOf(deviceUniqueId) + 1);
              Get.find<UserController>().refreshLocalUser();
              Get.toNamed('/');
            } else {
              return '重置密码失败';
            }
          } else {
            return '用户验证错误';
          }
          // var tmp = sha512.convert(utf8.encode('${data.password}IceBergNote'));
          // int back = await connection!.execute(
          //     "UPDATE userinfo SET name=${data.additionalSignupData!['昵称'] ?? ''}, password=$tmp, phone=${data.additionalSignupData!['手机'] ?? ''}");
          // if (back == 1) {
          //   final SharedPreferences userLocalInfo =
          //       await SharedPreferences.getInstance();
          //   userLocalInfo.setString(
          //       'userName', data.additionalSignupData!['昵称'] ?? '');
          //   userLocalInfo.setString('userID', no[0][0].toString());
          //   userLocalInfo.setString('userEmail', data.name!);
          //   userLocalInfo.setString(
          //       'userPhone', data.additionalSignupData!['手机'] ?? '');
          //   userLocalInfo.setBool('userIsAdmin', false);
          //   userLocalInfo.setString('userCreatDate', date1);
          //   userLocalInfo.setString('userVIPDate', date2);
          //   Get.find<UserController>().refreshLocalUser();
          //   return null;
          // } else {
          //   return '注册失败';
          // }
        }
      }
    } catch (e) {
      await Future.delayed(const Duration(seconds: 5));
      return '网络错误';
    }
    return null;
  }

  Future<String?> _recoverPassword(String name) async {
    return '请手动发送邮件';
  }

  static String? emailValidator(String? value) {
    if (value == null || value.isEmpty || !Regex.email.hasMatch(value)) {
      return '无效的邮箱';
    }
    return null;
  }

  static String? passwordValidator(String? value) {
    if (value == null || value.isEmpty || value.length <= 2) {
      return '密码太短';
    }
    return null;
  }

  final inputBorder = const BorderRadius.vertical(
    bottom: Radius.circular(10.0),
    top: Radius.circular(20.0),
  );
  @override
  Widget build(BuildContext context) {
    return FlutterLogin(
      title: APPConstants.appName,
      logo: const AssetImage('lib/assets/image/icebergicon.png'),
      onLogin: _authUser,
      onSignup: _signupUser,
      onSubmitAnimationCompleted: () {
        Get.toNamed('/');
      },
      onRecoverPassword: _recoverPassword,
      passwordValidator: passwordValidator,
      userValidator: emailValidator,

      additionalSignupFields: const [
        UserFormField(keyName: '昵称'),
        UserFormField(keyName: '手机')
      ],
      logoTag: APPConstants.logoTag,
      titleTag: APPConstants.titleTag,
      // loginProviders: <LoginProvider>[
      //   LoginProvider(
      //     icon: FontAwesomeIcons.google,
      //     callback: () async {
      //       debugPrint('start google sign in');
      //       await Future.delayed(loginTime);
      //       debugPrint('stop google sign in');
      //       return null;
      //     },
      //   ),
      //   LoginProvider(
      //     icon: FontAwesomeIcons.facebookF,
      //     callback: () async {
      //       debugPrint('start facebook sign in');
      //       await Future.delayed(loginTime);
      //       debugPrint('stop facebook sign in');
      //       return null;
      //     },
      //   ),
      //   LoginProvider(
      //     icon: FontAwesomeIcons.linkedinIn,
      //     callback: () async {
      //       debugPrint('start linkdin sign in');
      //       await Future.delayed(loginTime);
      //       debugPrint('stop linkdin sign in');
      //       return null;
      //     },
      //   ),
      //   LoginProvider(
      //     icon: FontAwesomeIcons.githubAlt,
      //     callback: () async {
      //       debugPrint('start github sign in');
      //       await Future.delayed(loginTime);
      //       debugPrint('stop github sign in');
      //       return null;
      //     },
      //   ),
      //   LoginProvider(
      //     icon: FontAwesomeIcons.tencentWeibo,
      //     callback: () async {
      //       debugPrint('start github sign in');
      //       await Future.delayed(loginTime);
      //       debugPrint('stop github sign in');
      //       return null;
      //     },
      //   ),
      // ],
      messages: LoginMessages(
        userHint: '邮箱',
        passwordHint: '密码',
        confirmPasswordHint: '确认密码',
        forgotPasswordButton: '忘记密码',
        loginButton: '登录',
        signupButton: '注册',
        recoverPasswordButton: '恢复密码',
        confirmPasswordError: '密码不一致',
        recoverPasswordSuccess: '请手动发送邮件',
        goBackButton: '返回',
        resendCodeButton: '重新发送',
        resendCodeSuccess: '发送成功',
        recoverPasswordDescription:
            '请用该注册邮箱给rrrr.zhao@qq.com发送重置密码邮件，稍后您将收到人工回复邮件',
        recoverPasswordIntro: '重置密码',
        flushbarTitleError: '错误',
        flushbarTitleSuccess: '成功',
        additionalSignUpFormDescription: '建议您完善以下信息',
        additionalSignUpSubmitButton: '提交',
        signUpSuccess: '恭喜您注册成功',
      ),
      theme: LoginTheme(
        titleStyle: const TextStyle(color: Color.fromARGB(255, 17, 63, 97)),
        primaryColor: const Color.fromARGB(255, 0, 140, 198),
        accentColor: Colors.white,
        switchAuthTextColor: const Color.fromARGB(255, 0, 140, 198),
        primaryColorAsInputLabel: false,
        pageColorDark: const Color.fromARGB(255, 18, 107, 174),
        pageColorLight: const Color.fromARGB(255, 18, 170, 156),
        footerBackgroundColor: Colors.red,
        beforeHeroFontSize: 48,
        afterHeroFontSize: 24,
        cardTheme: CardTheme(
          color: Colors.white,
          elevation: 50,
          margin: const EdgeInsets.only(top: 15),
          shape: ContinuousRectangleBorder(
              borderRadius: BorderRadius.circular(100.0)),
        ),
        inputTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.green.withOpacity(.1),
          contentPadding: EdgeInsets.zero,
          errorStyle: const TextStyle(
            backgroundColor: Colors.orange,
            color: Colors.white,
          ),
          labelStyle: const TextStyle(fontSize: 12),
          enabledBorder: UnderlineInputBorder(
            borderSide: BorderSide(color: Colors.blue.shade700, width: 4),
            borderRadius: inputBorder,
          ),
          focusedBorder: UnderlineInputBorder(
            borderSide: BorderSide(color: Colors.blue.shade400, width: 5),
            borderRadius: inputBorder,
          ),
          errorBorder: UnderlineInputBorder(
            borderSide: BorderSide(color: Colors.red.shade700, width: 7),
            borderRadius: inputBorder,
          ),
          focusedErrorBorder: UnderlineInputBorder(
            borderSide: BorderSide(color: Colors.red.shade400, width: 8),
            borderRadius: inputBorder,
          ),
          disabledBorder: UnderlineInputBorder(
            borderSide: const BorderSide(color: Colors.grey, width: 5),
            borderRadius: inputBorder,
          ),
        ),
        buttonTheme: LoginButtonTheme(
          splashColor: const Color.fromARGB(255, 18, 170, 156),
          backgroundColor: const Color.fromARGB(255, 18, 107, 174),
          highlightColor: const Color.fromARGB(255, 18, 170, 156),
          elevation: 5.0,
          highlightElevation: 2.0,
          // shape: BeveledRectangleBorder(
          //   borderRadius: BorderRadius.circular(10),
          // ),
          // shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
          // shape: CircleBorder(side: BorderSide(color: Colors.green)),
          shape: ContinuousRectangleBorder(
              borderRadius: BorderRadius.circular(55.0)),
        ),
      ),
    );
  }
}

class Regex {
  // https://stackoverflow.com/a/32686261/9449426
  static final email = RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$');
}
