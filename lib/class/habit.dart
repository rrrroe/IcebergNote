import 'package:realm/realm.dart';

part 'habit.g.dart';

@RealmModel()
class _Habit {
  @PrimaryKey()
  late Uuid id;
  late String name;
  late String color = "";
  late String description = "";
  late int freqDen = 1; //衡量周期，每x天y次的x
  late int freqNum = 1; //衡量周期，每x天y次的y
  late int highlight = 1;
  late int position; //排序
  late int reminderHour = 0; //提醒时刻的小时
  late int reminderMin = 0; //提醒时刻的分钟
  late int reminderDay = 0; //提醒日
  late int type; //0打卡式，1量化式
  late int targetType; //目标类型：0至少，1至多
  late double targetValue; //目标值
  late double weight = 0; //打分的权重
  late bool archived = false; //是否归档
  late bool delete = false; //是否删除
  late bool reminder = false; //是否提醒
  late String question = ""; //问句提醒
  late String unit = ""; //单位
  late DateTime createDate;
  late DateTime updateDate;
  late DateTime startDate;
  late DateTime stopDate;
}

@RealmModel()
class _HabitRecord {
  @PrimaryKey()
  late Uuid id;
  late Uuid habit;
  late int value;
  late String notes = "";
  late DateTime currentDate;
  late DateTime createDate;
  late DateTime updateDate;
}
