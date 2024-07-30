// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'habit.dart';

// **************************************************************************
// RealmObjectGenerator
// **************************************************************************

// ignore_for_file: type=lint
class Habit extends _Habit with RealmEntity, RealmObjectBase, RealmObject {
  static var _defaultsSet = false;

  Habit(
    Uuid id,
    DateTime createDate,
    DateTime updateDate,
    DateTime startDate,
    DateTime stopDate, {
    String name = '',
    String color = 'FFB4CCAB',
    String fontColor = 'FFFFFFFF',
    String description = '',
    int freqDen = 1,
    int freqNum = 1,
    int highlight = 1,
    int position = 0,
    int reminderHour = 0,
    int reminderMin = 0,
    int reminderDay = 0,
    int type = 0,
    int targetType = 0,
    double targetValue = 1,
    int targetFreq = 1,
    double weight = 0,
    bool archived = false,
    bool delete = false,
    bool reminder = false,
    String question = '',
    String unit = '',
    String icon = '',
    bool isButtonAdd = false,
    double buttonAddNum = 1,
    bool needlog = false,
    bool canExpire = true,
    int expireDays = 1,
    int reward = 1,
    int todayAfterHour = 0,
    int todayAfterMin = 0,
    int todayBeforeHour = 0,
    int todayBeforeMin = 0,
    String group = '',
    int size = 1,
    String string1 = '',
    String string2 = '',
    String string3 = '',
    int int1 = 0,
    int int2 = 0,
    int int3 = 0,
    int int4 = 0,
    int int5 = 0,
    double double1 = 0,
    double double2 = 0,
    double double3 = 0,
    bool bool1 = false,
    bool bool2 = false,
    bool bool3 = false,
  }) {
    if (!_defaultsSet) {
      _defaultsSet = RealmObjectBase.setDefaults<Habit>({
        'name': '',
        'color': 'FFB4CCAB',
        'fontColor': 'FFFFFFFF',
        'description': '',
        'freqDen': 1,
        'freqNum': 1,
        'highlight': 1,
        'position': 0,
        'reminderHour': 0,
        'reminderMin': 0,
        'reminderDay': 0,
        'type': 0,
        'targetType': 0,
        'targetValue': 1,
        'targetFreq': 1,
        'weight': 0,
        'archived': false,
        'delete': false,
        'reminder': false,
        'question': '',
        'unit': '',
        'icon': '',
        'isButtonAdd': false,
        'buttonAddNum': 1,
        'needlog': false,
        'canExpire': true,
        'expireDays': 1,
        'reward': 1,
        'todayAfterHour': 0,
        'todayAfterMin': 0,
        'todayBeforeHour': 0,
        'todayBeforeMin': 0,
        'group': '',
        'size': 1,
        'string1': '',
        'string2': '',
        'string3': '',
        'int1': 0,
        'int2': 0,
        'int3': 0,
        'int4': 0,
        'int5': 0,
        'double1': 0,
        'double2': 0,
        'double3': 0,
        'bool1': false,
        'bool2': false,
        'bool3': false,
      });
    }
    RealmObjectBase.set(this, 'id', id);
    RealmObjectBase.set(this, 'name', name);
    RealmObjectBase.set(this, 'color', color);
    RealmObjectBase.set(this, 'fontColor', fontColor);
    RealmObjectBase.set(this, 'description', description);
    RealmObjectBase.set(this, 'freqDen', freqDen);
    RealmObjectBase.set(this, 'freqNum', freqNum);
    RealmObjectBase.set(this, 'highlight', highlight);
    RealmObjectBase.set(this, 'position', position);
    RealmObjectBase.set(this, 'reminderHour', reminderHour);
    RealmObjectBase.set(this, 'reminderMin', reminderMin);
    RealmObjectBase.set(this, 'reminderDay', reminderDay);
    RealmObjectBase.set(this, 'type', type);
    RealmObjectBase.set(this, 'targetType', targetType);
    RealmObjectBase.set(this, 'targetValue', targetValue);
    RealmObjectBase.set(this, 'targetFreq', targetFreq);
    RealmObjectBase.set(this, 'weight', weight);
    RealmObjectBase.set(this, 'archived', archived);
    RealmObjectBase.set(this, 'delete', delete);
    RealmObjectBase.set(this, 'reminder', reminder);
    RealmObjectBase.set(this, 'question', question);
    RealmObjectBase.set(this, 'unit', unit);
    RealmObjectBase.set(this, 'createDate', createDate);
    RealmObjectBase.set(this, 'updateDate', updateDate);
    RealmObjectBase.set(this, 'startDate', startDate);
    RealmObjectBase.set(this, 'stopDate', stopDate);
    RealmObjectBase.set(this, 'icon', icon);
    RealmObjectBase.set(this, 'isButtonAdd', isButtonAdd);
    RealmObjectBase.set(this, 'buttonAddNum', buttonAddNum);
    RealmObjectBase.set(this, 'needlog', needlog);
    RealmObjectBase.set(this, 'canExpire', canExpire);
    RealmObjectBase.set(this, 'expireDays', expireDays);
    RealmObjectBase.set(this, 'reward', reward);
    RealmObjectBase.set(this, 'todayAfterHour', todayAfterHour);
    RealmObjectBase.set(this, 'todayAfterMin', todayAfterMin);
    RealmObjectBase.set(this, 'todayBeforeHour', todayBeforeHour);
    RealmObjectBase.set(this, 'todayBeforeMin', todayBeforeMin);
    RealmObjectBase.set(this, 'group', group);
    RealmObjectBase.set(this, 'size', size);
    RealmObjectBase.set(this, 'string1', string1);
    RealmObjectBase.set(this, 'string2', string2);
    RealmObjectBase.set(this, 'string3', string3);
    RealmObjectBase.set(this, 'int1', int1);
    RealmObjectBase.set(this, 'int2', int2);
    RealmObjectBase.set(this, 'int3', int3);
    RealmObjectBase.set(this, 'int4', int4);
    RealmObjectBase.set(this, 'int5', int5);
    RealmObjectBase.set(this, 'double1', double1);
    RealmObjectBase.set(this, 'double2', double2);
    RealmObjectBase.set(this, 'double3', double3);
    RealmObjectBase.set(this, 'bool1', bool1);
    RealmObjectBase.set(this, 'bool2', bool2);
    RealmObjectBase.set(this, 'bool3', bool3);
  }

  Habit._();

  @override
  Uuid get id => RealmObjectBase.get<Uuid>(this, 'id') as Uuid;
  @override
  set id(Uuid value) => RealmObjectBase.set(this, 'id', value);

  @override
  String get name => RealmObjectBase.get<String>(this, 'name') as String;
  @override
  set name(String value) => RealmObjectBase.set(this, 'name', value);

  @override
  String get color => RealmObjectBase.get<String>(this, 'color') as String;
  @override
  set color(String value) => RealmObjectBase.set(this, 'color', value);

  @override
  String get fontColor =>
      RealmObjectBase.get<String>(this, 'fontColor') as String;
  @override
  set fontColor(String value) => RealmObjectBase.set(this, 'fontColor', value);

  @override
  String get description =>
      RealmObjectBase.get<String>(this, 'description') as String;
  @override
  set description(String value) =>
      RealmObjectBase.set(this, 'description', value);

  @override
  int get freqDen => RealmObjectBase.get<int>(this, 'freqDen') as int;
  @override
  set freqDen(int value) => RealmObjectBase.set(this, 'freqDen', value);

  @override
  int get freqNum => RealmObjectBase.get<int>(this, 'freqNum') as int;
  @override
  set freqNum(int value) => RealmObjectBase.set(this, 'freqNum', value);

  @override
  int get highlight => RealmObjectBase.get<int>(this, 'highlight') as int;
  @override
  set highlight(int value) => RealmObjectBase.set(this, 'highlight', value);

  @override
  int get position => RealmObjectBase.get<int>(this, 'position') as int;
  @override
  set position(int value) => RealmObjectBase.set(this, 'position', value);

  @override
  int get reminderHour => RealmObjectBase.get<int>(this, 'reminderHour') as int;
  @override
  set reminderHour(int value) =>
      RealmObjectBase.set(this, 'reminderHour', value);

  @override
  int get reminderMin => RealmObjectBase.get<int>(this, 'reminderMin') as int;
  @override
  set reminderMin(int value) => RealmObjectBase.set(this, 'reminderMin', value);

  @override
  int get reminderDay => RealmObjectBase.get<int>(this, 'reminderDay') as int;
  @override
  set reminderDay(int value) => RealmObjectBase.set(this, 'reminderDay', value);

  @override
  int get type => RealmObjectBase.get<int>(this, 'type') as int;
  @override
  set type(int value) => RealmObjectBase.set(this, 'type', value);

  @override
  int get targetType => RealmObjectBase.get<int>(this, 'targetType') as int;
  @override
  set targetType(int value) => RealmObjectBase.set(this, 'targetType', value);

  @override
  double get targetValue =>
      RealmObjectBase.get<double>(this, 'targetValue') as double;
  @override
  set targetValue(double value) =>
      RealmObjectBase.set(this, 'targetValue', value);

  @override
  int get targetFreq => RealmObjectBase.get<int>(this, 'targetFreq') as int;
  @override
  set targetFreq(int value) => RealmObjectBase.set(this, 'targetFreq', value);

  @override
  double get weight => RealmObjectBase.get<double>(this, 'weight') as double;
  @override
  set weight(double value) => RealmObjectBase.set(this, 'weight', value);

  @override
  bool get archived => RealmObjectBase.get<bool>(this, 'archived') as bool;
  @override
  set archived(bool value) => RealmObjectBase.set(this, 'archived', value);

  @override
  bool get delete => RealmObjectBase.get<bool>(this, 'delete') as bool;
  @override
  set delete(bool value) => RealmObjectBase.set(this, 'delete', value);

  @override
  bool get reminder => RealmObjectBase.get<bool>(this, 'reminder') as bool;
  @override
  set reminder(bool value) => RealmObjectBase.set(this, 'reminder', value);

  @override
  String get question =>
      RealmObjectBase.get<String>(this, 'question') as String;
  @override
  set question(String value) => RealmObjectBase.set(this, 'question', value);

  @override
  String get unit => RealmObjectBase.get<String>(this, 'unit') as String;
  @override
  set unit(String value) => RealmObjectBase.set(this, 'unit', value);

  @override
  DateTime get createDate =>
      RealmObjectBase.get<DateTime>(this, 'createDate') as DateTime;
  @override
  set createDate(DateTime value) =>
      RealmObjectBase.set(this, 'createDate', value);

  @override
  DateTime get updateDate =>
      RealmObjectBase.get<DateTime>(this, 'updateDate') as DateTime;
  @override
  set updateDate(DateTime value) =>
      RealmObjectBase.set(this, 'updateDate', value);

  @override
  DateTime get startDate =>
      RealmObjectBase.get<DateTime>(this, 'startDate') as DateTime;
  @override
  set startDate(DateTime value) =>
      RealmObjectBase.set(this, 'startDate', value);

  @override
  DateTime get stopDate =>
      RealmObjectBase.get<DateTime>(this, 'stopDate') as DateTime;
  @override
  set stopDate(DateTime value) => RealmObjectBase.set(this, 'stopDate', value);

  @override
  String get icon => RealmObjectBase.get<String>(this, 'icon') as String;
  @override
  set icon(String value) => RealmObjectBase.set(this, 'icon', value);

  @override
  bool get isButtonAdd =>
      RealmObjectBase.get<bool>(this, 'isButtonAdd') as bool;
  @override
  set isButtonAdd(bool value) =>
      RealmObjectBase.set(this, 'isButtonAdd', value);

  @override
  double get buttonAddNum =>
      RealmObjectBase.get<double>(this, 'buttonAddNum') as double;
  @override
  set buttonAddNum(double value) =>
      RealmObjectBase.set(this, 'buttonAddNum', value);

  @override
  bool get needlog => RealmObjectBase.get<bool>(this, 'needlog') as bool;
  @override
  set needlog(bool value) => RealmObjectBase.set(this, 'needlog', value);

  @override
  bool get canExpire => RealmObjectBase.get<bool>(this, 'canExpire') as bool;
  @override
  set canExpire(bool value) => RealmObjectBase.set(this, 'canExpire', value);

  @override
  int get expireDays => RealmObjectBase.get<int>(this, 'expireDays') as int;
  @override
  set expireDays(int value) => RealmObjectBase.set(this, 'expireDays', value);

  @override
  int get reward => RealmObjectBase.get<int>(this, 'reward') as int;
  @override
  set reward(int value) => RealmObjectBase.set(this, 'reward', value);

  @override
  int get todayAfterHour =>
      RealmObjectBase.get<int>(this, 'todayAfterHour') as int;
  @override
  set todayAfterHour(int value) =>
      RealmObjectBase.set(this, 'todayAfterHour', value);

  @override
  int get todayAfterMin =>
      RealmObjectBase.get<int>(this, 'todayAfterMin') as int;
  @override
  set todayAfterMin(int value) =>
      RealmObjectBase.set(this, 'todayAfterMin', value);

  @override
  int get todayBeforeHour =>
      RealmObjectBase.get<int>(this, 'todayBeforeHour') as int;
  @override
  set todayBeforeHour(int value) =>
      RealmObjectBase.set(this, 'todayBeforeHour', value);

  @override
  int get todayBeforeMin =>
      RealmObjectBase.get<int>(this, 'todayBeforeMin') as int;
  @override
  set todayBeforeMin(int value) =>
      RealmObjectBase.set(this, 'todayBeforeMin', value);

  @override
  String get group => RealmObjectBase.get<String>(this, 'group') as String;
  @override
  set group(String value) => RealmObjectBase.set(this, 'group', value);

  @override
  int get size => RealmObjectBase.get<int>(this, 'size') as int;
  @override
  set size(int value) => RealmObjectBase.set(this, 'size', value);

  @override
  String get string1 => RealmObjectBase.get<String>(this, 'string1') as String;
  @override
  set string1(String value) => RealmObjectBase.set(this, 'string1', value);

  @override
  String get string2 => RealmObjectBase.get<String>(this, 'string2') as String;
  @override
  set string2(String value) => RealmObjectBase.set(this, 'string2', value);

  @override
  String get string3 => RealmObjectBase.get<String>(this, 'string3') as String;
  @override
  set string3(String value) => RealmObjectBase.set(this, 'string3', value);

  @override
  int get int1 => RealmObjectBase.get<int>(this, 'int1') as int;
  @override
  set int1(int value) => RealmObjectBase.set(this, 'int1', value);

  @override
  int get int2 => RealmObjectBase.get<int>(this, 'int2') as int;
  @override
  set int2(int value) => RealmObjectBase.set(this, 'int2', value);

  @override
  int get int3 => RealmObjectBase.get<int>(this, 'int3') as int;
  @override
  set int3(int value) => RealmObjectBase.set(this, 'int3', value);

  @override
  int get int4 => RealmObjectBase.get<int>(this, 'int4') as int;
  @override
  set int4(int value) => RealmObjectBase.set(this, 'int4', value);

  @override
  int get int5 => RealmObjectBase.get<int>(this, 'int5') as int;
  @override
  set int5(int value) => RealmObjectBase.set(this, 'int5', value);

  @override
  double get double1 => RealmObjectBase.get<double>(this, 'double1') as double;
  @override
  set double1(double value) => RealmObjectBase.set(this, 'double1', value);

  @override
  double get double2 => RealmObjectBase.get<double>(this, 'double2') as double;
  @override
  set double2(double value) => RealmObjectBase.set(this, 'double2', value);

  @override
  double get double3 => RealmObjectBase.get<double>(this, 'double3') as double;
  @override
  set double3(double value) => RealmObjectBase.set(this, 'double3', value);

  @override
  bool get bool1 => RealmObjectBase.get<bool>(this, 'bool1') as bool;
  @override
  set bool1(bool value) => RealmObjectBase.set(this, 'bool1', value);

  @override
  bool get bool2 => RealmObjectBase.get<bool>(this, 'bool2') as bool;
  @override
  set bool2(bool value) => RealmObjectBase.set(this, 'bool2', value);

  @override
  bool get bool3 => RealmObjectBase.get<bool>(this, 'bool3') as bool;
  @override
  set bool3(bool value) => RealmObjectBase.set(this, 'bool3', value);

  @override
  Stream<RealmObjectChanges<Habit>> get changes =>
      RealmObjectBase.getChanges<Habit>(this);

  @override
  Stream<RealmObjectChanges<Habit>> changesFor([List<String>? keyPaths]) =>
      RealmObjectBase.getChangesFor<Habit>(this, keyPaths);

  @override
  Habit freeze() => RealmObjectBase.freezeObject<Habit>(this);

  EJsonValue toEJson() {
    return <String, dynamic>{
      'id': id.toEJson(),
      'name': name.toEJson(),
      'color': color.toEJson(),
      'fontColor': fontColor.toEJson(),
      'description': description.toEJson(),
      'freqDen': freqDen.toEJson(),
      'freqNum': freqNum.toEJson(),
      'highlight': highlight.toEJson(),
      'position': position.toEJson(),
      'reminderHour': reminderHour.toEJson(),
      'reminderMin': reminderMin.toEJson(),
      'reminderDay': reminderDay.toEJson(),
      'type': type.toEJson(),
      'targetType': targetType.toEJson(),
      'targetValue': targetValue.toEJson(),
      'targetFreq': targetFreq.toEJson(),
      'weight': weight.toEJson(),
      'archived': archived.toEJson(),
      'delete': delete.toEJson(),
      'reminder': reminder.toEJson(),
      'question': question.toEJson(),
      'unit': unit.toEJson(),
      'createDate': createDate.toEJson(),
      'updateDate': updateDate.toEJson(),
      'startDate': startDate.toEJson(),
      'stopDate': stopDate.toEJson(),
      'icon': icon.toEJson(),
      'isButtonAdd': isButtonAdd.toEJson(),
      'buttonAddNum': buttonAddNum.toEJson(),
      'needlog': needlog.toEJson(),
      'canExpire': canExpire.toEJson(),
      'expireDays': expireDays.toEJson(),
      'reward': reward.toEJson(),
      'todayAfterHour': todayAfterHour.toEJson(),
      'todayAfterMin': todayAfterMin.toEJson(),
      'todayBeforeHour': todayBeforeHour.toEJson(),
      'todayBeforeMin': todayBeforeMin.toEJson(),
      'group': group.toEJson(),
      'size': size.toEJson(),
      'string1': string1.toEJson(),
      'string2': string2.toEJson(),
      'string3': string3.toEJson(),
      'int1': int1.toEJson(),
      'int2': int2.toEJson(),
      'int3': int3.toEJson(),
      'int4': int4.toEJson(),
      'int5': int5.toEJson(),
      'double1': double1.toEJson(),
      'double2': double2.toEJson(),
      'double3': double3.toEJson(),
      'bool1': bool1.toEJson(),
      'bool2': bool2.toEJson(),
      'bool3': bool3.toEJson(),
    };
  }

  static EJsonValue _toEJson(Habit value) => value.toEJson();
  static Habit _fromEJson(EJsonValue ejson) {
    return switch (ejson) {
      {
        'id': EJsonValue id,
        'name': EJsonValue name,
        'color': EJsonValue color,
        'fontColor': EJsonValue fontColor,
        'description': EJsonValue description,
        'freqDen': EJsonValue freqDen,
        'freqNum': EJsonValue freqNum,
        'highlight': EJsonValue highlight,
        'position': EJsonValue position,
        'reminderHour': EJsonValue reminderHour,
        'reminderMin': EJsonValue reminderMin,
        'reminderDay': EJsonValue reminderDay,
        'type': EJsonValue type,
        'targetType': EJsonValue targetType,
        'targetValue': EJsonValue targetValue,
        'targetFreq': EJsonValue targetFreq,
        'weight': EJsonValue weight,
        'archived': EJsonValue archived,
        'delete': EJsonValue delete,
        'reminder': EJsonValue reminder,
        'question': EJsonValue question,
        'unit': EJsonValue unit,
        'createDate': EJsonValue createDate,
        'updateDate': EJsonValue updateDate,
        'startDate': EJsonValue startDate,
        'stopDate': EJsonValue stopDate,
        'icon': EJsonValue icon,
        'isButtonAdd': EJsonValue isButtonAdd,
        'buttonAddNum': EJsonValue buttonAddNum,
        'needlog': EJsonValue needlog,
        'canExpire': EJsonValue canExpire,
        'expireDays': EJsonValue expireDays,
        'reward': EJsonValue reward,
        'todayAfterHour': EJsonValue todayAfterHour,
        'todayAfterMin': EJsonValue todayAfterMin,
        'todayBeforeHour': EJsonValue todayBeforeHour,
        'todayBeforeMin': EJsonValue todayBeforeMin,
        'group': EJsonValue group,
        'size': EJsonValue size,
        'string1': EJsonValue string1,
        'string2': EJsonValue string2,
        'string3': EJsonValue string3,
        'int1': EJsonValue int1,
        'int2': EJsonValue int2,
        'int3': EJsonValue int3,
        'int4': EJsonValue int4,
        'int5': EJsonValue int5,
        'double1': EJsonValue double1,
        'double2': EJsonValue double2,
        'double3': EJsonValue double3,
        'bool1': EJsonValue bool1,
        'bool2': EJsonValue bool2,
        'bool3': EJsonValue bool3,
      } =>
        Habit(
          fromEJson(id),
          fromEJson(createDate),
          fromEJson(updateDate),
          fromEJson(startDate),
          fromEJson(stopDate),
          name: fromEJson(name),
          color: fromEJson(color),
          fontColor: fromEJson(fontColor),
          description: fromEJson(description),
          freqDen: fromEJson(freqDen),
          freqNum: fromEJson(freqNum),
          highlight: fromEJson(highlight),
          position: fromEJson(position),
          reminderHour: fromEJson(reminderHour),
          reminderMin: fromEJson(reminderMin),
          reminderDay: fromEJson(reminderDay),
          type: fromEJson(type),
          targetType: fromEJson(targetType),
          targetValue: fromEJson(targetValue),
          targetFreq: fromEJson(targetFreq),
          weight: fromEJson(weight),
          archived: fromEJson(archived),
          delete: fromEJson(delete),
          reminder: fromEJson(reminder),
          question: fromEJson(question),
          unit: fromEJson(unit),
          icon: fromEJson(icon),
          isButtonAdd: fromEJson(isButtonAdd),
          buttonAddNum: fromEJson(buttonAddNum),
          needlog: fromEJson(needlog),
          canExpire: fromEJson(canExpire),
          expireDays: fromEJson(expireDays),
          reward: fromEJson(reward),
          todayAfterHour: fromEJson(todayAfterHour),
          todayAfterMin: fromEJson(todayAfterMin),
          todayBeforeHour: fromEJson(todayBeforeHour),
          todayBeforeMin: fromEJson(todayBeforeMin),
          group: fromEJson(group),
          size: fromEJson(size),
          string1: fromEJson(string1),
          string2: fromEJson(string2),
          string3: fromEJson(string3),
          int1: fromEJson(int1),
          int2: fromEJson(int2),
          int3: fromEJson(int3),
          int4: fromEJson(int4),
          int5: fromEJson(int5),
          double1: fromEJson(double1),
          double2: fromEJson(double2),
          double3: fromEJson(double3),
          bool1: fromEJson(bool1),
          bool2: fromEJson(bool2),
          bool3: fromEJson(bool3),
        ),
      _ => raiseInvalidEJson(ejson),
    };
  }

  static final schema = () {
    RealmObjectBase.registerFactory(Habit._);
    register(_toEJson, _fromEJson);
    return SchemaObject(ObjectType.realmObject, Habit, 'Habit', [
      SchemaProperty('id', RealmPropertyType.uuid, primaryKey: true),
      SchemaProperty('name', RealmPropertyType.string),
      SchemaProperty('color', RealmPropertyType.string),
      SchemaProperty('fontColor', RealmPropertyType.string),
      SchemaProperty('description', RealmPropertyType.string),
      SchemaProperty('freqDen', RealmPropertyType.int),
      SchemaProperty('freqNum', RealmPropertyType.int),
      SchemaProperty('highlight', RealmPropertyType.int),
      SchemaProperty('position', RealmPropertyType.int),
      SchemaProperty('reminderHour', RealmPropertyType.int),
      SchemaProperty('reminderMin', RealmPropertyType.int),
      SchemaProperty('reminderDay', RealmPropertyType.int),
      SchemaProperty('type', RealmPropertyType.int),
      SchemaProperty('targetType', RealmPropertyType.int),
      SchemaProperty('targetValue', RealmPropertyType.double),
      SchemaProperty('targetFreq', RealmPropertyType.int),
      SchemaProperty('weight', RealmPropertyType.double),
      SchemaProperty('archived', RealmPropertyType.bool),
      SchemaProperty('delete', RealmPropertyType.bool),
      SchemaProperty('reminder', RealmPropertyType.bool),
      SchemaProperty('question', RealmPropertyType.string),
      SchemaProperty('unit', RealmPropertyType.string),
      SchemaProperty('createDate', RealmPropertyType.timestamp),
      SchemaProperty('updateDate', RealmPropertyType.timestamp),
      SchemaProperty('startDate', RealmPropertyType.timestamp),
      SchemaProperty('stopDate', RealmPropertyType.timestamp),
      SchemaProperty('icon', RealmPropertyType.string),
      SchemaProperty('isButtonAdd', RealmPropertyType.bool),
      SchemaProperty('buttonAddNum', RealmPropertyType.double),
      SchemaProperty('needlog', RealmPropertyType.bool),
      SchemaProperty('canExpire', RealmPropertyType.bool),
      SchemaProperty('expireDays', RealmPropertyType.int),
      SchemaProperty('reward', RealmPropertyType.int),
      SchemaProperty('todayAfterHour', RealmPropertyType.int),
      SchemaProperty('todayAfterMin', RealmPropertyType.int),
      SchemaProperty('todayBeforeHour', RealmPropertyType.int),
      SchemaProperty('todayBeforeMin', RealmPropertyType.int),
      SchemaProperty('group', RealmPropertyType.string),
      SchemaProperty('size', RealmPropertyType.int),
      SchemaProperty('string1', RealmPropertyType.string),
      SchemaProperty('string2', RealmPropertyType.string),
      SchemaProperty('string3', RealmPropertyType.string),
      SchemaProperty('int1', RealmPropertyType.int),
      SchemaProperty('int2', RealmPropertyType.int),
      SchemaProperty('int3', RealmPropertyType.int),
      SchemaProperty('int4', RealmPropertyType.int),
      SchemaProperty('int5', RealmPropertyType.int),
      SchemaProperty('double1', RealmPropertyType.double),
      SchemaProperty('double2', RealmPropertyType.double),
      SchemaProperty('double3', RealmPropertyType.double),
      SchemaProperty('bool1', RealmPropertyType.bool),
      SchemaProperty('bool2', RealmPropertyType.bool),
      SchemaProperty('bool3', RealmPropertyType.bool),
    ]);
  }();

  @override
  SchemaObject get objectSchema => RealmObjectBase.getSchema(this) ?? schema;
}

class HabitRecord extends _HabitRecord
    with RealmEntity, RealmObjectBase, RealmObject {
  static var _defaultsSet = false;

  HabitRecord(
    Uuid id,
    Uuid habit,
    int value,
    DateTime currentDate,
    DateTime createDate,
    DateTime updateDate, {
    String notes = '',
    double finish = 0,
    double score = 0,
  }) {
    if (!_defaultsSet) {
      _defaultsSet = RealmObjectBase.setDefaults<HabitRecord>({
        'notes': '',
        'finish': 0,
        'score': 0,
      });
    }
    RealmObjectBase.set(this, 'id', id);
    RealmObjectBase.set(this, 'habit', habit);
    RealmObjectBase.set(this, 'value', value);
    RealmObjectBase.set(this, 'notes', notes);
    RealmObjectBase.set(this, 'currentDate', currentDate);
    RealmObjectBase.set(this, 'createDate', createDate);
    RealmObjectBase.set(this, 'updateDate', updateDate);
    RealmObjectBase.set(this, 'finish', finish);
    RealmObjectBase.set(this, 'score', score);
  }

  HabitRecord._();

  @override
  Uuid get id => RealmObjectBase.get<Uuid>(this, 'id') as Uuid;
  @override
  set id(Uuid value) => RealmObjectBase.set(this, 'id', value);

  @override
  Uuid get habit => RealmObjectBase.get<Uuid>(this, 'habit') as Uuid;
  @override
  set habit(Uuid value) => RealmObjectBase.set(this, 'habit', value);

  @override
  int get value => RealmObjectBase.get<int>(this, 'value') as int;
  @override
  set value(int value) => RealmObjectBase.set(this, 'value', value);

  @override
  String get notes => RealmObjectBase.get<String>(this, 'notes') as String;
  @override
  set notes(String value) => RealmObjectBase.set(this, 'notes', value);

  @override
  DateTime get currentDate =>
      RealmObjectBase.get<DateTime>(this, 'currentDate') as DateTime;
  @override
  set currentDate(DateTime value) =>
      RealmObjectBase.set(this, 'currentDate', value);

  @override
  DateTime get createDate =>
      RealmObjectBase.get<DateTime>(this, 'createDate') as DateTime;
  @override
  set createDate(DateTime value) =>
      RealmObjectBase.set(this, 'createDate', value);

  @override
  DateTime get updateDate =>
      RealmObjectBase.get<DateTime>(this, 'updateDate') as DateTime;
  @override
  set updateDate(DateTime value) =>
      RealmObjectBase.set(this, 'updateDate', value);

  @override
  double get finish => RealmObjectBase.get<double>(this, 'finish') as double;
  @override
  set finish(double value) => RealmObjectBase.set(this, 'finish', value);

  @override
  double get score => RealmObjectBase.get<double>(this, 'score') as double;
  @override
  set score(double value) => RealmObjectBase.set(this, 'score', value);

  @override
  Stream<RealmObjectChanges<HabitRecord>> get changes =>
      RealmObjectBase.getChanges<HabitRecord>(this);

  @override
  Stream<RealmObjectChanges<HabitRecord>> changesFor(
          [List<String>? keyPaths]) =>
      RealmObjectBase.getChangesFor<HabitRecord>(this, keyPaths);

  @override
  HabitRecord freeze() => RealmObjectBase.freezeObject<HabitRecord>(this);

  EJsonValue toEJson() {
    return <String, dynamic>{
      'id': id.toEJson(),
      'habit': habit.toEJson(),
      'value': value.toEJson(),
      'notes': notes.toEJson(),
      'currentDate': currentDate.toEJson(),
      'createDate': createDate.toEJson(),
      'updateDate': updateDate.toEJson(),
      'finish': finish.toEJson(),
      'score': score.toEJson(),
    };
  }

  static EJsonValue _toEJson(HabitRecord value) => value.toEJson();
  static HabitRecord _fromEJson(EJsonValue ejson) {
    return switch (ejson) {
      {
        'id': EJsonValue id,
        'habit': EJsonValue habit,
        'value': EJsonValue value,
        'notes': EJsonValue notes,
        'currentDate': EJsonValue currentDate,
        'createDate': EJsonValue createDate,
        'updateDate': EJsonValue updateDate,
        'finish': EJsonValue finish,
        'score': EJsonValue score,
      } =>
        HabitRecord(
          fromEJson(id),
          fromEJson(habit),
          fromEJson(value),
          fromEJson(currentDate),
          fromEJson(createDate),
          fromEJson(updateDate),
          notes: fromEJson(notes),
          finish: fromEJson(finish),
          score: fromEJson(score),
        ),
      _ => raiseInvalidEJson(ejson),
    };
  }

  static final schema = () {
    RealmObjectBase.registerFactory(HabitRecord._);
    register(_toEJson, _fromEJson);
    return SchemaObject(ObjectType.realmObject, HabitRecord, 'HabitRecord', [
      SchemaProperty('id', RealmPropertyType.uuid, primaryKey: true),
      SchemaProperty('habit', RealmPropertyType.uuid),
      SchemaProperty('value', RealmPropertyType.int),
      SchemaProperty('notes', RealmPropertyType.string),
      SchemaProperty('currentDate', RealmPropertyType.timestamp),
      SchemaProperty('createDate', RealmPropertyType.timestamp),
      SchemaProperty('updateDate', RealmPropertyType.timestamp),
      SchemaProperty('finish', RealmPropertyType.double),
      SchemaProperty('score', RealmPropertyType.double),
    ]);
  }();

  @override
  SchemaObject get objectSchema => RealmObjectBase.getSchema(this) ?? schema;
}
