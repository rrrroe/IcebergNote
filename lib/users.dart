import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UserController extends GetxController {
  var name = '登录'.obs;
  var id = ''.obs;
  var email = ''.obs;
  var phone = ''.obs;
  var no = 0.obs;
  var isAdmin = false.obs;
  var createDate = DateTime.now().obs;
  var vipDate = DateTime.now().obs;
  var deviceNO = 0.obs;
  @override
  void onInit() {
    super.onInit();
    refreshLocalUser();
  }

  void refreshLocalUser() async {
    final SharedPreferences userLocalInfo =
        await SharedPreferences.getInstance();
    name.value = userLocalInfo.getString('userName') ?? '登录';
    id.value = userLocalInfo.getString('userID') ?? '';
    email.value = userLocalInfo.getString('userEmail') ?? '';
    phone.value = userLocalInfo.getString('userPhone') ?? '';
    no.value = userLocalInfo.getInt('userNO') ?? 0;
    isAdmin.value = userLocalInfo.getBool('userIsAdmin') ?? false;
    createDate.value = DateTime.tryParse(
            userLocalInfo.getString('userCreatDate') ?? '1970-01-01') ??
        DateTime(1970, 1, 1);
    vipDate.value = DateTime.tryParse(
            userLocalInfo.getString('userVIPDate') ?? '1970-01-01') ??
        DateTime(1970, 1, 1);
    deviceNO.value = userLocalInfo.getInt('deviceNO') ?? 0;
    print(deviceNO.value);
    update();
  }

  void logout() async {
    final SharedPreferences userLocalInfo =
        await SharedPreferences.getInstance();
    await userLocalInfo.remove('userName');
    await userLocalInfo.remove('userID');
    await userLocalInfo.remove('userEmail');
    await userLocalInfo.remove('userPhone');
    await userLocalInfo.remove('userNO');
    await userLocalInfo.remove('userIsAdmin');
    await userLocalInfo.remove('userCreatDate');
    await userLocalInfo.remove('userVIPDate');
    refreshLocalUser();
    update();
  }
}
