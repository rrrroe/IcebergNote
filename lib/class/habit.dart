import 'package:realm/realm.dart';

part 'habit.realm.dart';

@RealmModel()
class _Habit {
  @PrimaryKey()
  late Uuid id;
  late String name = '';
  late String color = 'FFB4CCAB';
  late String fontColor = 'FFFFFFFF';
  late String description = '';
  late int freqDen = 1; //每x天y次的x
  late int freqNum = 1; //每x天y次的y
  late int highlight = 1;
  late int position = 0; //排序
  late int reminderHour = 0; //提醒的小时
  late int reminderMin = 0; //提醒的分钟
  late int reminderDay = 0; //提醒日
  late int type = 0; //0打卡式，1量化式
  late int targetType = 0; //目标类型：0至少1至多
  late double targetValue = 1; //目标值
  late int targetFreq = 1; //目标值周期
  late double weight = 0; //打分的权重
  late bool archived = false; //是否归档
  late bool delete = false; //是否删除
  late bool reminder = false; //是否提醒
  late String question = ''; //问句提醒
  late String unit = ''; //单位
  late DateTime createDate;
  late DateTime updateDate;
  late DateTime startDate;
  late DateTime stopDate;
  late String icon = '';
  late bool isButtonAdd = false; //是否按键输入
  late double buttonAddNum = 1; //按键默认输入数量
  late bool needlog = false; //是否弹出日志
  late bool canExpire = true; //是否允许补签
  late int expireDays = 1; //允许补签天数
  late int reward = 1; //奖励
  late int todayAfterHour = 0; //当日签到上限的小时
  late int todayAfterMin = 0; //当日签到上限的分钟
  late int todayBeforeHour = 0; //当日签到下限的小时
  late int todayBeforeMin = 0; //当日签到下限的分钟
  late String group = '';
  late int size = 1; //大小
  late String string1 = '';
  late String string2 = '';
  late String string3 = '';
  late int int1 = 0; //data 小数位数
  late int int2 = 0;
  late int int3 = 0;
  late int int4 = 0;
  late int int5 = 0;
  late double double1 = 0;
  late double double2 = 0;
  late double double3 = 0;
  late bool bool1 = false;
  late bool bool2 = false;
  late bool bool3 = false;
}

@RealmModel()
class _HabitRecord {
  @PrimaryKey()
  late Uuid id;
  late Uuid habit;
  late int value; //0未完成，1完成，2跳过
  late String notes = '';
  late DateTime currentDate;
  late DateTime createDate;
  late DateTime updateDate;
  late double data = 0;
  late double score = 0;
  late String string1 = '';
  late String string2 = '';
  late String string3 = '';
  late int int1 = 0;
  late int int2 = 0;
  late int int3 = 0;
  late double double1 = 0;
  late double double2 = 0;
  late double double3 = 0;
}
