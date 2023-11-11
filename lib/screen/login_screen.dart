import 'package:flutter/material.dart';
import 'package:flutter_login/flutter_login.dart';
import 'package:postgres/postgres.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
    connection = PostgreSQLConnection("111.229.224.55", 5432, "users",
        username: "admin", password: "456321rrRR");
    await connection!.open();
    final result = await connection!.query("SELECT * FROM userinfo");
    print(result);
    return Future.delayed(loginTime).then((_) async {
      for (int i = 0; 1 < result.length; i++) {
        print(result[i]);
        if (result[i][0] == data.name ||
            result[i][3] == data.name ||
            result[i][2] == data.name) {
          if (result[i][6] == data.password) {
            final SharedPreferences userLocalInfo =
                await SharedPreferences.getInstance();
            userLocalInfo.setString('userName', result[i][0]);
            userLocalInfo.setString('userID', result[i][1]);
            userLocalInfo.setString('userEmail', result[i][2]);
            userLocalInfo.setString('userPhone', result[i][3]);
            userLocalInfo.setInt('userNO', result[i][4]);
            userLocalInfo.setBool('userIsAdmin', result[i][5]);
            userLocalInfo.setString('userCreatDate', result[i][7].toString());
            userLocalInfo.setString('userVIPDate', result[i][8].toString());
            return null;
          } else {
            return 'Password does not match';
          }
        }
      }
      return 'User not exists';
      // if (!users.containsKey(data.name)) {
      //   return 'User not exists';
      // }
      // if (users[data.name] != data.password) {
      //   return 'Password does not match';
      // }
    });
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
        return 'User not exists';
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
