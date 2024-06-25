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
    DateTime stopDate,
    DateTime updateDate,
    DateTime startDate, {
    int reward = 1,
    String name = '',
    String color = 'FFB4CCAB',
    String fontColor = 'FFFFFFFF',
    String description = "",
    int freqDen = 1,
    int freqNum = 1,
    int highlight = 1,
    int position = 0,
    int reminderHour = 0,
    int reminderMin = 0,
    int todayAfterMin = 0,
    int targetType = 0,
    double targetValue = 1,
    int targetFreq = 1,
    double weight = 0,
    bool archived = false,
    bool delete = false,
    bool reminder = false,
    String question = "",
    int todayAfterHour = 0,
    int todayBeforeHour = 0,
    String group = "",
    String icon = '',
    bool isButtonAdd = false,
    double buttonAddNum = 1,
    bool needlog = false,
    bool canExpire = true,
    int expireDays = 1,
    int todayBeforeMin = 0,
    String unit = "",
    int reminderDay = 0,
    int type = 0,
  }) {
    if (!_defaultsSet) {
      _defaultsSet = RealmObjectBase.setDefaults<Habit>({
        'reward': 1,
        'name': '',
        'color': 'FFB4CCAB',
        'fontColor': 'FFFFFFFF',
        'description': "",
        'freqDen': 1,
        'freqNum': 1,
        'highlight': 1,
        'position': 0,
        'reminderHour': 0,
        'reminderMin': 0,
        'todayAfterMin': 0,
        'targetType': 0,
        'targetValue': 1,
        'targetFreq': 1,
        'weight': 0,
        'archived': false,
        'delete': false,
        'reminder': false,
        'question': "",
        'todayAfterHour': 0,
        'todayBeforeHour': 0,
        'group': "",
        'icon': '',
        'isButtonAdd': false,
        'buttonAddNum': 1,
        'needlog': false,
        'canExpire': true,
        'expireDays': 1,
        'todayBeforeMin': 0,
        'unit': "",
        'reminderDay': 0,
        'type': 0,
      });
    }
    RealmObjectBase.set(this, 'reward', reward);
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
    RealmObjectBase.set(this, 'todayAfterMin', todayAfterMin);
    RealmObjectBase.set(this, 'id', id);
    RealmObjectBase.set(this, 'targetType', targetType);
    RealmObjectBase.set(this, 'targetValue', targetValue);
    RealmObjectBase.set(this, 'targetFreq', targetFreq);
    RealmObjectBase.set(this, 'weight', weight);
    RealmObjectBase.set(this, 'archived', archived);
    RealmObjectBase.set(this, 'delete', delete);
    RealmObjectBase.set(this, 'reminder', reminder);
    RealmObjectBase.set(this, 'question', question);
    RealmObjectBase.set(this, 'todayAfterHour', todayAfterHour);
    RealmObjectBase.set(this, 'createDate', createDate);
    RealmObjectBase.set(this, 'todayBeforeHour', todayBeforeHour);
    RealmObjectBase.set(this, 'group', group);
    RealmObjectBase.set(this, 'stopDate', stopDate);
    RealmObjectBase.set(this, 'icon', icon);
    RealmObjectBase.set(this, 'isButtonAdd', isButtonAdd);
    RealmObjectBase.set(this, 'buttonAddNum', buttonAddNum);
    RealmObjectBase.set(this, 'needlog', needlog);
    RealmObjectBase.set(this, 'canExpire', canExpire);
    RealmObjectBase.set(this, 'expireDays', expireDays);
    RealmObjectBase.set(this, 'todayBeforeMin', todayBeforeMin);
    RealmObjectBase.set(this, 'unit', unit);
    RealmObjectBase.set(this, 'reminderDay', reminderDay);
    RealmObjectBase.set(this, 'updateDate', updateDate);
    RealmObjectBase.set(this, 'type', type);
    RealmObjectBase.set(this, 'startDate', startDate);
  }

  Habit._();

  @override
  int get reward => RealmObjectBase.get<int>(this, 'reward') as int;
  @override
  set reward(int value) => RealmObjectBase.set(this, 'reward', value);

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
  int get todayAfterMin =>
      RealmObjectBase.get<int>(this, 'todayAfterMin') as int;
  @override
  set todayAfterMin(int value) =>
      RealmObjectBase.set(this, 'todayAfterMin', value);

  @override
  Uuid get id => RealmObjectBase.get<Uuid>(this, 'id') as Uuid;
  @override
  set id(Uuid value) => RealmObjectBase.set(this, 'id', value);

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
  int get todayAfterHour =>
      RealmObjectBase.get<int>(this, 'todayAfterHour') as int;
  @override
  set todayAfterHour(int value) =>
      RealmObjectBase.set(this, 'todayAfterHour', value);

  @override
  DateTime get createDate =>
      RealmObjectBase.get<DateTime>(this, 'createDate') as DateTime;
  @override
  set createDate(DateTime value) =>
      RealmObjectBase.set(this, 'createDate', value);

  @override
  int get todayBeforeHour =>
      RealmObjectBase.get<int>(this, 'todayBeforeHour') as int;
  @override
  set todayBeforeHour(int value) =>
      RealmObjectBase.set(this, 'todayBeforeHour', value);

  @override
  String get group => RealmObjectBase.get<String>(this, 'group') as String;
  @override
  set group(String value) => RealmObjectBase.set(this, 'group', value);

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
  int get todayBeforeMin =>
      RealmObjectBase.get<int>(this, 'todayBeforeMin') as int;
  @override
  set todayBeforeMin(int value) =>
      RealmObjectBase.set(this, 'todayBeforeMin', value);

  @override
  String get unit => RealmObjectBase.get<String>(this, 'unit') as String;
  @override
  set unit(String value) => RealmObjectBase.set(this, 'unit', value);

  @override
  int get reminderDay => RealmObjectBase.get<int>(this, 'reminderDay') as int;
  @override
  set reminderDay(int value) => RealmObjectBase.set(this, 'reminderDay', value);

  @override
  DateTime get updateDate =>
      RealmObjectBase.get<DateTime>(this, 'updateDate') as DateTime;
  @override
  set updateDate(DateTime value) =>
      RealmObjectBase.set(this, 'updateDate', value);

  @override
  int get type => RealmObjectBase.get<int>(this, 'type') as int;
  @override
  set type(int value) => RealmObjectBase.set(this, 'type', value);

  @override
  DateTime get startDate =>
      RealmObjectBase.get<DateTime>(this, 'startDate') as DateTime;
  @override
  set startDate(DateTime value) =>
      RealmObjectBase.set(this, 'startDate', value);

  @override
  Stream<RealmObjectChanges<Habit>> get changes =>
      RealmObjectBase.getChanges<Habit>(this);

  @override
  Habit freeze() => RealmObjectBase.freezeObject<Habit>(this);

  static SchemaObject get schema => _schema ??= _initSchema();
  static SchemaObject? _schema;
  static SchemaObject _initSchema() {
    RealmObjectBase.registerFactory(Habit._);
    return SchemaObject(ObjectType.realmObject, Habit, 'Habit', [
      SchemaProperty('reward', RealmPropertyType.int),
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
      SchemaProperty('todayAfterMin', RealmPropertyType.int),
      SchemaProperty('id', RealmPropertyType.uuid, primaryKey: true),
      SchemaProperty('targetType', RealmPropertyType.int),
      SchemaProperty('targetValue', RealmPropertyType.double),
      SchemaProperty('targetFreq', RealmPropertyType.int),
      SchemaProperty('weight', RealmPropertyType.double),
      SchemaProperty('archived', RealmPropertyType.bool),
      SchemaProperty('delete', RealmPropertyType.bool),
      SchemaProperty('reminder', RealmPropertyType.bool),
      SchemaProperty('question', RealmPropertyType.string),
      SchemaProperty('todayAfterHour', RealmPropertyType.int),
      SchemaProperty('createDate', RealmPropertyType.timestamp),
      SchemaProperty('todayBeforeHour', RealmPropertyType.int),
      SchemaProperty('group', RealmPropertyType.string),
      SchemaProperty('stopDate', RealmPropertyType.timestamp),
      SchemaProperty('icon', RealmPropertyType.string),
      SchemaProperty('isButtonAdd', RealmPropertyType.bool),
      SchemaProperty('buttonAddNum', RealmPropertyType.double),
      SchemaProperty('needlog', RealmPropertyType.bool),
      SchemaProperty('canExpire', RealmPropertyType.bool),
      SchemaProperty('expireDays', RealmPropertyType.int),
      SchemaProperty('todayBeforeMin', RealmPropertyType.int),
      SchemaProperty('unit', RealmPropertyType.string),
      SchemaProperty('reminderDay', RealmPropertyType.int),
      SchemaProperty('updateDate', RealmPropertyType.timestamp),
      SchemaProperty('type', RealmPropertyType.int),
      SchemaProperty('startDate', RealmPropertyType.timestamp),
    ]);
  }
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
    String notes = "",
  }) {
    if (!_defaultsSet) {
      _defaultsSet = RealmObjectBase.setDefaults<HabitRecord>({
        'notes': "",
      });
    }
    RealmObjectBase.set(this, 'id', id);
    RealmObjectBase.set(this, 'habit', habit);
    RealmObjectBase.set(this, 'value', value);
    RealmObjectBase.set(this, 'notes', notes);
    RealmObjectBase.set(this, 'currentDate', currentDate);
    RealmObjectBase.set(this, 'createDate', createDate);
    RealmObjectBase.set(this, 'updateDate', updateDate);
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
  Stream<RealmObjectChanges<HabitRecord>> get changes =>
      RealmObjectBase.getChanges<HabitRecord>(this);

  @override
  HabitRecord freeze() => RealmObjectBase.freezeObject<HabitRecord>(this);

  static SchemaObject get schema => _schema ??= _initSchema();
  static SchemaObject? _schema;
  static SchemaObject _initSchema() {
    RealmObjectBase.registerFactory(HabitRecord._);
    return SchemaObject(ObjectType.realmObject, HabitRecord, 'HabitRecord', [
      SchemaProperty('id', RealmPropertyType.uuid, primaryKey: true),
      SchemaProperty('habit', RealmPropertyType.uuid),
      SchemaProperty('value', RealmPropertyType.int),
      SchemaProperty('notes', RealmPropertyType.string),
      SchemaProperty('currentDate', RealmPropertyType.timestamp),
      SchemaProperty('createDate', RealmPropertyType.timestamp),
      SchemaProperty('updateDate', RealmPropertyType.timestamp),
    ]);
  }
}
