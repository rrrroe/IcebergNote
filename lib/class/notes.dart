import 'package:realm/realm.dart';
part 'notes.g.dart';

@RealmModel()
class _Notes {
  @PrimaryKey()
  late Uuid id;
  late String noteFolder;
  late String noteTitle;
  late String noteContext;
  late String noteType = "";
  late String noteProject = "";
  // late String noteCreatTime = "";
  // late String noteUpdateTime = "";
  // late String noteAchiveTime = "";
  // late String noteDeleteTime = "";
  late String noteTags = "";
  late String noteAttachments = "";
  late String noteReferences = "";
  late String noteSource = "";
  late String noteAuthor = "";
  late String noteNext = "";
  late String noteLast = "";
  late String notePlace = "";
  late bool noteIsStarred = false;
  late bool noteIsLocked = false;
  late bool noteIstodo = false;
  late bool noteIsDeleted = false;
  late bool noteIsShared = false;
  late bool noteIsAchive = false;
  late String noteFinishState = "";
  // late String noteFinishTime = "";
  // late String noteAlarmTime = "";
  late bool noteIsReviewed = false;
  late DateTime noteCreateDate;
  late DateTime noteUpdateDate;
  late DateTime noteAchiveDate;
  late DateTime noteDeleteDate;
  late DateTime noteFinishDate;
  late DateTime noteAlarmDate;
}
//flutter pub run realm generate，用来生成notes.g.dart
//   // 将 Notes 表加入到 Realm 中
//   realm.schema.add(notesSchema);

//   // 使用 Realm 执行 CRUD 操作
//   // 插入一条新的笔记
//   await realm.write(() {
//     realm.create(
//       'Notes',
//       Notes()
//         ..noteID = '1'
//         ..noteTitle = 'My First Note'
//         ..noteContext = 'This is the content of my first note'
//         ..noteIsStarred = true
//         ..noteIsLocked = false
//         ..noteIstodo = false
//         ..noteIsDeleted = false
//         ..noteIsShared = false
//         ..noteIsAchive = false,
//     );
//   });

//   // 查询所有笔记
//   final allNotes = realm.objects('Notes');
//   print('All notes: $allNotes');

//   // 更新一条笔记
//   await realm.write(() {
//     final note = realm.objects('Notes').findFirst();
//     note.noteTitle = 'Updated Note Title';
//     note.noteContext = 'This is the updated content of my first note';
//     note.noteIsStarred = false;
//   });

//   // 删除一条笔记
//   await realm.write(() {
//     final note = realm.objects('Notes').findFirst();
//     realm.delete(note!);
//   });

//   // 关闭 Realm 实例
//   await realm.close();
// }