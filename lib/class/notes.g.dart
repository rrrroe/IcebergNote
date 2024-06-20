// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'notes.dart';

// **************************************************************************
// RealmObjectGenerator
// **************************************************************************

// ignore_for_file: type=lint
class Notes extends _Notes with RealmEntity, RealmObjectBase, RealmObject {
  static var _defaultsSet = false;

  Notes(
    Uuid id,
    String noteFolder,
    String noteTitle,
    String noteContext,
    DateTime noteCreateDate,
    DateTime noteUpdateDate,
    DateTime noteAchiveDate,
    DateTime noteDeleteDate,
    DateTime noteFinishDate,
    DateTime noteAlarmDate, {
    String noteType = "",
    String noteProject = "",
    String noteTags = "",
    String noteAttachments = "",
    String noteReferences = "",
    String noteSource = "",
    String noteAuthor = "",
    String noteNext = "",
    String noteLast = "",
    String notePlace = "",
    bool noteIsStarred = false,
    bool noteIsLocked = false,
    bool noteIstodo = false,
    bool noteIsDeleted = false,
    bool noteIsShared = false,
    bool noteIsAchive = false,
    String noteFinishState = "",
    bool noteIsReviewed = false,
  }) {
    if (!_defaultsSet) {
      _defaultsSet = RealmObjectBase.setDefaults<Notes>({
        'noteType': "",
        'noteProject': "",
        'noteTags': "",
        'noteAttachments': "",
        'noteReferences': "",
        'noteSource': "",
        'noteAuthor': "",
        'noteNext': "",
        'noteLast': "",
        'notePlace': "",
        'noteIsStarred': false,
        'noteIsLocked': false,
        'noteIstodo': false,
        'noteIsDeleted': false,
        'noteIsShared': false,
        'noteIsAchive': false,
        'noteFinishState': "",
        'noteIsReviewed': false,
      });
    }
    RealmObjectBase.set(this, 'id', id);
    RealmObjectBase.set(this, 'noteFolder', noteFolder);
    RealmObjectBase.set(this, 'noteTitle', noteTitle);
    RealmObjectBase.set(this, 'noteContext', noteContext);
    RealmObjectBase.set(this, 'noteType', noteType);
    RealmObjectBase.set(this, 'noteProject', noteProject);
    RealmObjectBase.set(this, 'noteTags', noteTags);
    RealmObjectBase.set(this, 'noteAttachments', noteAttachments);
    RealmObjectBase.set(this, 'noteReferences', noteReferences);
    RealmObjectBase.set(this, 'noteSource', noteSource);
    RealmObjectBase.set(this, 'noteAuthor', noteAuthor);
    RealmObjectBase.set(this, 'noteNext', noteNext);
    RealmObjectBase.set(this, 'noteLast', noteLast);
    RealmObjectBase.set(this, 'notePlace', notePlace);
    RealmObjectBase.set(this, 'noteIsStarred', noteIsStarred);
    RealmObjectBase.set(this, 'noteIsLocked', noteIsLocked);
    RealmObjectBase.set(this, 'noteIstodo', noteIstodo);
    RealmObjectBase.set(this, 'noteIsDeleted', noteIsDeleted);
    RealmObjectBase.set(this, 'noteIsShared', noteIsShared);
    RealmObjectBase.set(this, 'noteIsAchive', noteIsAchive);
    RealmObjectBase.set(this, 'noteFinishState', noteFinishState);
    RealmObjectBase.set(this, 'noteIsReviewed', noteIsReviewed);
    RealmObjectBase.set(this, 'noteCreateDate', noteCreateDate);
    RealmObjectBase.set(this, 'noteUpdateDate', noteUpdateDate);
    RealmObjectBase.set(this, 'noteAchiveDate', noteAchiveDate);
    RealmObjectBase.set(this, 'noteDeleteDate', noteDeleteDate);
    RealmObjectBase.set(this, 'noteFinishDate', noteFinishDate);
    RealmObjectBase.set(this, 'noteAlarmDate', noteAlarmDate);
  }

  Notes._();

  @override
  Uuid get id => RealmObjectBase.get<Uuid>(this, 'id') as Uuid;
  @override
  set id(Uuid value) => RealmObjectBase.set(this, 'id', value);

  @override
  String get noteFolder =>
      RealmObjectBase.get<String>(this, 'noteFolder') as String;
  @override
  set noteFolder(String value) =>
      RealmObjectBase.set(this, 'noteFolder', value);

  @override
  String get noteTitle =>
      RealmObjectBase.get<String>(this, 'noteTitle') as String;
  @override
  set noteTitle(String value) => RealmObjectBase.set(this, 'noteTitle', value);

  @override
  String get noteContext =>
      RealmObjectBase.get<String>(this, 'noteContext') as String;
  @override
  set noteContext(String value) =>
      RealmObjectBase.set(this, 'noteContext', value);

  @override
  String get noteType =>
      RealmObjectBase.get<String>(this, 'noteType') as String;
  @override
  set noteType(String value) => RealmObjectBase.set(this, 'noteType', value);

  @override
  String get noteProject =>
      RealmObjectBase.get<String>(this, 'noteProject') as String;
  @override
  set noteProject(String value) =>
      RealmObjectBase.set(this, 'noteProject', value);

  @override
  String get noteTags =>
      RealmObjectBase.get<String>(this, 'noteTags') as String;
  @override
  set noteTags(String value) => RealmObjectBase.set(this, 'noteTags', value);

  @override
  String get noteAttachments =>
      RealmObjectBase.get<String>(this, 'noteAttachments') as String;
  @override
  set noteAttachments(String value) =>
      RealmObjectBase.set(this, 'noteAttachments', value);

  @override
  String get noteReferences =>
      RealmObjectBase.get<String>(this, 'noteReferences') as String;
  @override
  set noteReferences(String value) =>
      RealmObjectBase.set(this, 'noteReferences', value);

  @override
  String get noteSource =>
      RealmObjectBase.get<String>(this, 'noteSource') as String;
  @override
  set noteSource(String value) =>
      RealmObjectBase.set(this, 'noteSource', value);

  @override
  String get noteAuthor =>
      RealmObjectBase.get<String>(this, 'noteAuthor') as String;
  @override
  set noteAuthor(String value) =>
      RealmObjectBase.set(this, 'noteAuthor', value);

  @override
  String get noteNext =>
      RealmObjectBase.get<String>(this, 'noteNext') as String;
  @override
  set noteNext(String value) => RealmObjectBase.set(this, 'noteNext', value);

  @override
  String get noteLast =>
      RealmObjectBase.get<String>(this, 'noteLast') as String;
  @override
  set noteLast(String value) => RealmObjectBase.set(this, 'noteLast', value);

  @override
  String get notePlace =>
      RealmObjectBase.get<String>(this, 'notePlace') as String;
  @override
  set notePlace(String value) => RealmObjectBase.set(this, 'notePlace', value);

  @override
  bool get noteIsStarred =>
      RealmObjectBase.get<bool>(this, 'noteIsStarred') as bool;
  @override
  set noteIsStarred(bool value) =>
      RealmObjectBase.set(this, 'noteIsStarred', value);

  @override
  bool get noteIsLocked =>
      RealmObjectBase.get<bool>(this, 'noteIsLocked') as bool;
  @override
  set noteIsLocked(bool value) =>
      RealmObjectBase.set(this, 'noteIsLocked', value);

  @override
  bool get noteIstodo => RealmObjectBase.get<bool>(this, 'noteIstodo') as bool;
  @override
  set noteIstodo(bool value) => RealmObjectBase.set(this, 'noteIstodo', value);

  @override
  bool get noteIsDeleted =>
      RealmObjectBase.get<bool>(this, 'noteIsDeleted') as bool;
  @override
  set noteIsDeleted(bool value) =>
      RealmObjectBase.set(this, 'noteIsDeleted', value);

  @override
  bool get noteIsShared =>
      RealmObjectBase.get<bool>(this, 'noteIsShared') as bool;
  @override
  set noteIsShared(bool value) =>
      RealmObjectBase.set(this, 'noteIsShared', value);

  @override
  bool get noteIsAchive =>
      RealmObjectBase.get<bool>(this, 'noteIsAchive') as bool;
  @override
  set noteIsAchive(bool value) =>
      RealmObjectBase.set(this, 'noteIsAchive', value);

  @override
  String get noteFinishState =>
      RealmObjectBase.get<String>(this, 'noteFinishState') as String;
  @override
  set noteFinishState(String value) =>
      RealmObjectBase.set(this, 'noteFinishState', value);

  @override
  bool get noteIsReviewed =>
      RealmObjectBase.get<bool>(this, 'noteIsReviewed') as bool;
  @override
  set noteIsReviewed(bool value) =>
      RealmObjectBase.set(this, 'noteIsReviewed', value);

  @override
  DateTime get noteCreateDate =>
      RealmObjectBase.get<DateTime>(this, 'noteCreateDate') as DateTime;
  @override
  set noteCreateDate(DateTime value) =>
      RealmObjectBase.set(this, 'noteCreateDate', value);

  @override
  DateTime get noteUpdateDate =>
      RealmObjectBase.get<DateTime>(this, 'noteUpdateDate') as DateTime;
  @override
  set noteUpdateDate(DateTime value) =>
      RealmObjectBase.set(this, 'noteUpdateDate', value);

  @override
  DateTime get noteAchiveDate =>
      RealmObjectBase.get<DateTime>(this, 'noteAchiveDate') as DateTime;
  @override
  set noteAchiveDate(DateTime value) =>
      RealmObjectBase.set(this, 'noteAchiveDate', value);

  @override
  DateTime get noteDeleteDate =>
      RealmObjectBase.get<DateTime>(this, 'noteDeleteDate') as DateTime;
  @override
  set noteDeleteDate(DateTime value) =>
      RealmObjectBase.set(this, 'noteDeleteDate', value);

  @override
  DateTime get noteFinishDate =>
      RealmObjectBase.get<DateTime>(this, 'noteFinishDate') as DateTime;
  @override
  set noteFinishDate(DateTime value) =>
      RealmObjectBase.set(this, 'noteFinishDate', value);

  @override
  DateTime get noteAlarmDate =>
      RealmObjectBase.get<DateTime>(this, 'noteAlarmDate') as DateTime;
  @override
  set noteAlarmDate(DateTime value) =>
      RealmObjectBase.set(this, 'noteAlarmDate', value);

  @override
  Stream<RealmObjectChanges<Notes>> get changes =>
      RealmObjectBase.getChanges<Notes>(this);

  @override
  Notes freeze() => RealmObjectBase.freezeObject<Notes>(this);

  static SchemaObject get schema => _schema ??= _initSchema();
  static SchemaObject? _schema;
  static SchemaObject _initSchema() {
    RealmObjectBase.registerFactory(Notes._);
    return SchemaObject(ObjectType.realmObject, Notes, 'Notes', [
      SchemaProperty('id', RealmPropertyType.uuid, primaryKey: true),
      SchemaProperty('noteFolder', RealmPropertyType.string),
      SchemaProperty('noteTitle', RealmPropertyType.string),
      SchemaProperty('noteContext', RealmPropertyType.string),
      SchemaProperty('noteType', RealmPropertyType.string),
      SchemaProperty('noteProject', RealmPropertyType.string),
      SchemaProperty('noteTags', RealmPropertyType.string),
      SchemaProperty('noteAttachments', RealmPropertyType.string),
      SchemaProperty('noteReferences', RealmPropertyType.string),
      SchemaProperty('noteSource', RealmPropertyType.string),
      SchemaProperty('noteAuthor', RealmPropertyType.string),
      SchemaProperty('noteNext', RealmPropertyType.string),
      SchemaProperty('noteLast', RealmPropertyType.string),
      SchemaProperty('notePlace', RealmPropertyType.string),
      SchemaProperty('noteIsStarred', RealmPropertyType.bool),
      SchemaProperty('noteIsLocked', RealmPropertyType.bool),
      SchemaProperty('noteIstodo', RealmPropertyType.bool),
      SchemaProperty('noteIsDeleted', RealmPropertyType.bool),
      SchemaProperty('noteIsShared', RealmPropertyType.bool),
      SchemaProperty('noteIsAchive', RealmPropertyType.bool),
      SchemaProperty('noteFinishState', RealmPropertyType.string),
      SchemaProperty('noteIsReviewed', RealmPropertyType.bool),
      SchemaProperty('noteCreateDate', RealmPropertyType.timestamp),
      SchemaProperty('noteUpdateDate', RealmPropertyType.timestamp),
      SchemaProperty('noteAchiveDate', RealmPropertyType.timestamp),
      SchemaProperty('noteDeleteDate', RealmPropertyType.timestamp),
      SchemaProperty('noteFinishDate', RealmPropertyType.timestamp),
      SchemaProperty('noteAlarmDate', RealmPropertyType.timestamp),
    ]);
  }
}
