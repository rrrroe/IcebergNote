import 'package:flutter/material.dart';
import 'package:icebergnote/main.dart';
import 'package:realm/realm.dart';
import 'package:swipable_stack/swipable_stack.dart';
import 'dart:math' as math;

import '../constants.dart';
import '../notes.dart';
import 'input/input_screen.dart';
import 'noteslist_screen.dart';

const _labelAngle = math.pi / 2 * 0.2;

class ReviewPage extends StatefulWidget {
  const ReviewPage({super.key});

  @override
  ReviewPageState createState() => ReviewPageState();
}

class ReviewPageState extends State<ReviewPage> {
  late final SwipableStackController _controller;
  late List<Notes> reviewList;
  late final List<Widget> titleList;
  void _listenController() => setState(() {});
  String blankTip = '恭喜您，已完成今日复盘！';
  late DateTime now;
  late DateTime todayMoring;

  bool isToday = true;
  List<Notes> blankList = [
    Notes(
      Uuid.v4(),
      '',
      '恭喜您，已完成所有复盘！',
      math.Random().nextInt(100).toString(),
      DateTime.now().toUtc(),
      DateTime.now().toUtc(),
      DateTime.utc(1970, 1, 1),
      DateTime.utc(1970, 1, 1),
      DateTime.utc(1970, 1, 1),
      DateTime.utc(1970, 1, 1),
    ),
    Notes(
      Uuid.v4(),
      '',
      '恭喜您，已完成所有复盘！',
      math.Random().nextInt(100).toString(),
      DateTime.now().toUtc(),
      DateTime.now().toUtc(),
      DateTime.utc(1970, 1, 1),
      DateTime.utc(1970, 1, 1),
      DateTime.utc(1970, 1, 1),
      DateTime.utc(1970, 1, 1),
    ),
    Notes(
      Uuid.v4(),
      '',
      '恭喜您，已完成所有复盘！',
      math.Random().nextInt(100).toString(),
      DateTime.now().toUtc(),
      DateTime.now().toUtc(),
      DateTime.utc(1970, 1, 1),
      DateTime.utc(1970, 1, 1),
      DateTime.utc(1970, 1, 1),
      DateTime.utc(1970, 1, 1),
    ),
    Notes(
      Uuid.v4(),
      '',
      '恭喜您，已完成所有复盘！',
      math.Random().nextInt(100).toString(),
      DateTime.now().toUtc(),
      DateTime.now().toUtc(),
      DateTime.utc(1970, 1, 1),
      DateTime.utc(1970, 1, 1),
      DateTime.utc(1970, 1, 1),
      DateTime.utc(1970, 1, 1),
    ),
    Notes(
      Uuid.v4(),
      '',
      '恭喜您，已完成所有复盘！',
      math.Random().nextInt(100).toString(),
      DateTime.now().toUtc(),
      DateTime.now().toUtc(),
      DateTime.utc(1970, 1, 1),
      DateTime.utc(1970, 1, 1),
      DateTime.utc(1970, 1, 1),
      DateTime.utc(1970, 1, 1),
    ),
    Notes(
      Uuid.v4(),
      '',
      '恭喜您，已完成所有复盘！',
      math.Random().nextInt(100).toString(),
      DateTime.now().toUtc(),
      DateTime.now().toUtc(),
      DateTime.utc(1970, 1, 1),
      DateTime.utc(1970, 1, 1),
      DateTime.utc(1970, 1, 1),
      DateTime.utc(1970, 1, 1),
    )
  ];
  List<Notes> blankListToday = [
    Notes(
      Uuid.v4(),
      '',
      '恭喜您，已完成今日复盘！',
      math.Random().nextInt(100).toString(),
      DateTime.now().toUtc(),
      DateTime.now().toUtc(),
      DateTime.utc(1970, 1, 1),
      DateTime.utc(1970, 1, 1),
      DateTime.utc(1970, 1, 1),
      DateTime.utc(1970, 1, 1),
    ),
    Notes(
      Uuid.v4(),
      '',
      '恭喜您，已完成今日复盘！',
      math.Random().nextInt(100).toString(),
      DateTime.now().toUtc(),
      DateTime.now().toUtc(),
      DateTime.utc(1970, 1, 1),
      DateTime.utc(1970, 1, 1),
      DateTime.utc(1970, 1, 1),
      DateTime.utc(1970, 1, 1),
    ),
    Notes(
      Uuid.v4(),
      '',
      '恭喜您，已完成今日复盘！',
      math.Random().nextInt(100).toString(),
      DateTime.now().toUtc(),
      DateTime.now().toUtc(),
      DateTime.utc(1970, 1, 1),
      DateTime.utc(1970, 1, 1),
      DateTime.utc(1970, 1, 1),
      DateTime.utc(1970, 1, 1),
    ),
    Notes(
      Uuid.v4(),
      '',
      '恭喜您，已完成今日复盘！',
      math.Random().nextInt(100).toString(),
      DateTime.now().toUtc(),
      DateTime.now().toUtc(),
      DateTime.utc(1970, 1, 1),
      DateTime.utc(1970, 1, 1),
      DateTime.utc(1970, 1, 1),
      DateTime.utc(1970, 1, 1),
    ),
    Notes(
      Uuid.v4(),
      '',
      '恭喜您，已完成今日复盘！',
      math.Random().nextInt(100).toString(),
      DateTime.now().toUtc(),
      DateTime.now().toUtc(),
      DateTime.utc(1970, 1, 1),
      DateTime.utc(1970, 1, 1),
      DateTime.utc(1970, 1, 1),
      DateTime.utc(1970, 1, 1),
    ),
    Notes(
      Uuid.v4(),
      '',
      '恭喜您，已完成今日复盘！',
      math.Random().nextInt(100).toString(),
      DateTime.now().toUtc(),
      DateTime.now().toUtc(),
      DateTime.utc(1970, 1, 1),
      DateTime.utc(1970, 1, 1),
      DateTime.utc(1970, 1, 1),
      DateTime.utc(1970, 1, 1),
    ),
  ];
  @override
  void initState() {
    super.initState();
    now = DateTime.now().toUtc();
    todayMoring = DateTime(now.year, now.month, now.day);
    _controller = SwipableStackController()..addListener(_listenController);
  }

  @override
  void dispose() {
    super.dispose();
    _controller
      ..removeListener(_listenController)
      ..dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (isToday) {
      reviewList = realm.query<Notes>(
              "noteIsDeleted != true AND noteIsReviewed == false AND noteCreateDate > \$0 SORT(noteCreateDate ASC)",
              [todayMoring]).toList() +
          blankListToday;
    } else {
      reviewList = realm
              .query<Notes>(
                  "noteIsDeleted != true AND noteIsReviewed == false SORT(noteCreateDate ASC)")
              .toList() +
          blankList;
    }
    return Scaffold(
      appBar: AppBar(
        title: Text(isToday == true ? "今日复盘" : "所有复盘"),
        actions: [
          TextButton(
              onPressed: () {
                setState(() {
                  isToday = !isToday;
                  blankTip =
                      (isToday == true ? '恭喜您，已完成今日复盘！' : '恭喜您，已完成所有复盘！');
                });
              },
              child: Text(isToday != true ? "前往今日复盘" : "前往所有复盘"))
        ],
      ),
      body: Stack(
        children: [
          Positioned.fill(
            child: Padding(
              padding: const EdgeInsets.all(8),
              child: SwipableStack(
                detectableSwipeDirections: const {
                  SwipeDirection.right,
                  SwipeDirection.left,
                  SwipeDirection.up,
                  SwipeDirection.down
                },
                // overlayBuilder: (context, properties) {
                //   final opacity = min(properties.swipeProgress, 1.0);
                //   final isRight = properties.direction == SwipeDirection.right;
                //   return Opacity(
                //     opacity: isRight ? opacity : 0,
                //     child: CardLabel.right(),
                //   );
                // },
                //可以控制最上面一层在不同方向滑动时的叠加的东西
                controller: _controller,
                swipeAnchor: SwipeAnchor.bottom,
                stackClipBehaviour: Clip.none,
                onSwipeCompleted: (index, direction) {
                  if ((direction == SwipeDirection.right ||
                          direction == SwipeDirection.up) &&
                      reviewList[index].noteTitle != blankTip) {
                    realm.write(() {
                      reviewList[index].noteIsReviewed = true;
                      reviewList[index].noteUpdateDate = DateTime.now().toUtc();
                    });
                  }
                  if ((direction == SwipeDirection.left ||
                          direction == SwipeDirection.down) &&
                      reviewList[index].noteTitle != blankTip) {
                    realm.write(() {
                      reviewList[index].noteIsReviewed = false;
                      reviewList[index].noteUpdateDate = DateTime.now().toUtc();
                    });
                  }
                  if (reviewList[index].noteTitle == blankTip) {
                    reviewList.add(Notes(
                      Uuid.v4(),
                      '',
                      blankTip,
                      math.Random().nextInt(100).toString(),
                      DateTime.now().toUtc(),
                      DateTime.now().toUtc(),
                      DateTime.utc(1970, 1, 1),
                      DateTime.utc(1970, 1, 1),
                      DateTime.utc(1970, 1, 1),
                      DateTime.utc(1970, 1, 1),
                    ));
                  }
                },

                horizontalSwipeThreshold: 0.8,
                verticalSwipeThreshold: 0.8,
                builder: (context, properties) {
                  return Stack(
                    children: [
                      ReviewCard(note: reviewList[properties.index]),

                      if (properties.stackIndex == 0 &&
                          properties.direction != null)
                        CardOverlay(
                          swipeProgress: properties.swipeProgress,
                          direction: properties.direction!,
                        ),
                      //可以控制最上面一层在不同方向滑动时的叠加的东西，同overlayBuilder
                    ],
                  );
                },
              ),
            ),
          ),
          BottomButtonsRow(
            onSwipe: (direction) {
              _controller.next(swipeDirection: direction);
            },
            onRewindTap: _controller.rewind,
            canRewind: _controller.canRewind,
          ),
        ],
      ),
    );
  }
}

class BottomButtonsRow extends StatelessWidget {
  const BottomButtonsRow({
    required this.onRewindTap,
    required this.onSwipe,
    required this.canRewind,
    super.key,
  });

  final bool canRewind;
  final VoidCallback onRewindTap;
  final ValueChanged<SwipeDirection> onSwipe;

  static const double height = 100;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.bottomCenter,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8),
        child: SizedBox(
          height: height,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _BottomButton(
                color: SwipeDirectionColor.down,
                child: const Icon(Icons.arrow_back),
                onPressed: () {
                  onSwipe(SwipeDirection.left);
                },
              ),
              // _BottomButton(
              //   color: SwipeDirectionColor.up,
              //   onPressed: () {
              //     onSwipe(SwipeDirection.up);
              //   },
              //   child: const Icon(Icons.arrow_upward),
              // ),
              _BottomButton(
                color: canRewind ? Colors.yellow : Colors.grey,
                onPressed: canRewind ? onRewindTap : null,
                child: const Icon(Icons.refresh),
              ),
              _BottomButton(
                color: SwipeDirectionColor.right,
                onPressed: () {
                  onSwipe(SwipeDirection.right);
                },
                child: const Icon(Icons.arrow_forward),
              ),
              // _BottomButton(
              //   color: SwipeDirectionColor.down,
              //   onPressed: () {
              //     onSwipe(SwipeDirection.down);
              //   },
              //   child: const Icon(Icons.arrow_downward),
              // ),
            ],
          ),
        ),
      ),
    );
  }
}

class _BottomButton extends StatelessWidget {
  const _BottomButton({
    required this.onPressed,
    required this.child,
    required this.color,
  });

  final VoidCallback? onPressed;
  final Icon child;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 50,
      width: 100,
      child: ElevatedButton(
        style: ButtonStyle(
          shape: WidgetStateProperty.resolveWith(
            (states) => RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(100),
            ),
          ),
          backgroundColor: WidgetStateProperty.resolveWith(
            (states) => color,
          ),
        ),
        onPressed: onPressed,
        child: child,
      ),
    );
  }
}

class SwipeDirectionColor {
  static const right = Color.fromRGBO(70, 195, 120, 1);
  static const left = Color.fromRGBO(220, 90, 108, 1);
  static const up = Color.fromRGBO(83, 170, 232, 1);
  static const down = Color.fromRGBO(154, 85, 215, 1);
}

extension SwipeDirecionX on SwipeDirection {
  Color get color {
    switch (this) {
      case SwipeDirection.right:
        return const Color.fromRGBO(70, 195, 120, 1);
      case SwipeDirection.left:
        return const Color.fromRGBO(220, 90, 108, 1);
      case SwipeDirection.up:
        return const Color.fromRGBO(83, 170, 232, 1);
      case SwipeDirection.down:
        return const Color.fromRGBO(154, 85, 215, 1);
    }
  }
}

class CardOverlay extends StatelessWidget {
  const CardOverlay({
    required this.direction,
    required this.swipeProgress,
    super.key,
  });
  final SwipeDirection direction;
  final double swipeProgress;

  @override
  Widget build(BuildContext context) {
    final opacity = math.min<double>(swipeProgress, 1);

    final isRight = direction == SwipeDirection.right;
    final isLeft = direction == SwipeDirection.left;
    final isUp = direction == SwipeDirection.up;
    final isDown = direction == SwipeDirection.down;
    return Stack(
      children: [
        Opacity(
          opacity: isRight ? opacity : 0,
          child: CardLabel.right(),
        ),
        Opacity(
          opacity: isLeft ? opacity : 0,
          child: CardLabel.left(),
        ),
        Opacity(
          opacity: isUp ? opacity : 0,
          child: CardLabel.up(),
        ),
        Opacity(
          opacity: isDown ? opacity : 0,
          child: CardLabel.down(),
        ),
      ],
    );
  }
}

class CardLabel extends StatelessWidget {
  const CardLabel._({
    required this.color,
    required this.label,
    required this.angle,
    required this.alignment,
  });

  factory CardLabel.right() {
    return const CardLabel._(
      color: SwipeDirectionColor.right,
      label: '完成',
      angle: -_labelAngle,
      alignment: Alignment.topLeft,
    );
  }

  factory CardLabel.left() {
    return const CardLabel._(
      color: SwipeDirectionColor.down,
      label: '待定',
      angle: _labelAngle,
      alignment: Alignment.topRight,
    );
  }

  factory CardLabel.up() {
    return const CardLabel._(
      color: SwipeDirectionColor.right,
      label: '完成',
      angle: _labelAngle,
      alignment: Alignment(0, 0.5),
    );
  }

  factory CardLabel.down() {
    return const CardLabel._(
      color: SwipeDirectionColor.down,
      label: '待定',
      angle: -_labelAngle,
      alignment: Alignment(0, -0.75),
    );
  }

  final Color color;
  final String label;
  final double angle;
  final Alignment alignment;

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: alignment,
      padding: const EdgeInsets.symmetric(
        vertical: 36,
        horizontal: 36,
      ),
      child: Transform.rotate(
        angle: angle,
        child: Container(
          decoration: BoxDecoration(
            border: Border.all(
              color: color,
              width: 4,
            ),
            color: Colors.white,
            borderRadius: BorderRadius.circular(4),
          ),
          padding: const EdgeInsets.all(6),
          child: Text(
            label,
            style: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.w600,
              letterSpacing: 1.4,
              color: color,
              height: 1,
            ),
          ),
        ),
      ),
    );
  }
}

class ExampleCard extends StatelessWidget {
  const ExampleCard({
    required this.name,
    super.key,
  });

  final int name;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      child: Stack(
        children: [
          const Positioned.fill(
            child: Text(
              '日拱一卒，不期而至！',
              style: TextStyle(
                  fontSize: 16, color: Color.fromARGB(255, 0, 140, 198)),
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              height: 200,
              width: double.infinity,
              decoration: BoxDecoration(
                borderRadius: const BorderRadius.vertical(
                  bottom: Radius.circular(14),
                ),
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: <Color>[
                    Colors.black12.withOpacity(0),
                    Colors.black12.withOpacity(.4),
                    Colors.black12.withOpacity(.82),
                  ],
                ),
              ),
            ),
          ),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 12),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '日拱一卒，不期而至！',
                  style: TextStyle(
                      fontSize: 16, color: Color.fromARGB(255, 0, 140, 198)),
                ),
                SizedBox(height: BottomButtonsRow.height)
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class ReviewCard extends StatefulWidget {
  final Notes note;
  const ReviewCard({super.key, required this.note});

  @override
  State<ReviewCard> createState() => _ReviewCardState();
}

class _ReviewCardState extends State<ReviewCard> {
  List<String> typeList = ['新建', '清空'];
  List<String> folderList = ['新建', '清空'];
  List<String> projectList = ['新建', '清空'];
  List<String> finishStateList = [
    '未完',
    '已完',
  ];
  @override
  void initState() {
    super.initState();

    List<Notes> typeDistinctList = realm
        .query<Notes>(
            "noteType !='' DISTINCT(noteType) SORT(noteCreateDate DESC)")
        .toList();

    for (int i = 0; i < typeDistinctList.length; i++) {
      typeList.add(typeDistinctList[i].noteType);
    }
    List<Notes> folderDistinctList = realm
        .query<Notes>(
            "noteFolder !='' DISTINCT(noteFolder) SORT(noteCreateDate DESC)")
        .toList();

    for (int i = 0; i < folderDistinctList.length; i++) {
      folderList.add(folderDistinctList[i].noteFolder);
    }
    List<Notes> projectDistinctList = realm
        .query<Notes>(
            "noteProject !='' DISTINCT(noteProject) SORT(noteCreateDate DESC)")
        .toList();

    for (int i = 0; i < projectDistinctList.length; i++) {
      projectList.add(projectDistinctList[i].noteProject);
    }
    List<Notes> finishStateDistinctList = realm
        .query<Notes>("noteFinishState !='' DISTINCT(noteFinishState)")
        .toList();

    for (int i = 0; i < finishStateDistinctList.length; i++) {
      if ((finishStateDistinctList[i].noteFinishState != '未完') &&
          (finishStateDistinctList[i].noteFinishState != '已完')) {
        finishStateList.add(finishStateDistinctList[i].noteFinishState);
      }
    }
    finishStateList.add('新建');
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      child: Card(
        margin: const EdgeInsets.all(20),
        color: Colors.white,
        child: Card(
          margin: const EdgeInsets.all(0),
          elevation: 0,
          shadowColor: Colors.grey,
          color: const Color.fromARGB(20, 0, 140, 198),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.max,
              children: [
                Text(
                  widget.note.noteTitle,
                  maxLines: 4,
                  textAlign: TextAlign.start,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w600,
                      color: Color.fromARGB(255, 0, 140, 198)),
                ),
                const SizedBox(
                  height: 5,
                ),
                Align(
                  alignment: Alignment.center,
                  child: Wrap(
                    direction: Axis.horizontal,
                    alignment: WrapAlignment.spaceBetween,
                    runAlignment: WrapAlignment.spaceBetween,
                    spacing: 8.0,
                    runSpacing: 8.0,
                    children: [
                      MenuAnchor(
                        builder: (context, controller, child) {
                          return FilledButton.tonal(
                            style: selectButtonStyle,
                            onPressed: () {
                              if (controller.isOpen) {
                                controller.close();
                              } else {
                                controller.open();
                              }
                            },
                            child: Text(
                              widget.note.noteType == ''
                                  ? '类型'
                                  : widget.note.noteType,
                              style: widget.note.noteType == ''
                                  ? const TextStyle(color: Colors.grey)
                                  : const TextStyle(
                                      color: Color.fromARGB(255, 56, 128, 186)),
                            ),
                          );
                        },
                        menuChildren: typeList.map((type) {
                          return MenuItemButton(
                            style: menuChildrenButtonStyle,
                            child: Text(type),
                            onPressed: () {
                              switch (type) {
                                case '清空':
                                  setState(() {
                                    realm.write(() {
                                      widget.note.noteType = '';
                                      widget.note.noteUpdateDate =
                                          DateTime.now().toUtc();
                                    });
                                  });
                                  break;
                                case '新建':
                                  showDialog(
                                    context: context,
                                    builder: (ctx) {
                                      return InputAlertDialog(
                                        onSubmitted: (text) {
                                          setState(() {
                                            if (!text.startsWith('.')) {
                                              text = '.$text';
                                            }
                                            typeList.add(text);
                                            realm.write(() {
                                              widget.note.noteType = text;
                                              widget.note.noteUpdateDate =
                                                  DateTime.now().toUtc();
                                            });
                                          });
                                        },
                                      );
                                    },
                                  );
                                  break;
                                default:
                                  setState(() {
                                    realm.write(() {
                                      widget.note.noteType = type;
                                      widget.note.noteUpdateDate =
                                          DateTime.now().toUtc();
                                    });
                                  });
                              }
                            },
                          );
                        }).toList(),
                      ),
                      MenuAnchor(
                        builder: (context, controller, child) {
                          return FilledButton.tonal(
                            style: selectButtonStyle,
                            onPressed: () {
                              if (controller.isOpen) {
                                controller.close();
                              } else {
                                controller.open();
                              }
                            },
                            child: Text(
                              widget.note.noteProject == ''
                                  ? '项目'
                                  : widget.note.noteProject,
                              style: widget.note.noteProject == ''
                                  ? const TextStyle(color: Colors.grey)
                                  : const TextStyle(
                                      color: Color.fromARGB(255, 215, 55, 55)),
                            ),
                          );
                        },
                        menuChildren: projectList.map((project) {
                          return MenuItemButton(
                            style: menuChildrenButtonStyle,
                            child: Text(project),
                            onPressed: () {
                              switch (project) {
                                case '清空':
                                  setState(() {
                                    realm.write(() {
                                      widget.note.noteProject = '';
                                      widget.note.noteUpdateDate =
                                          DateTime.now().toUtc();
                                    });
                                  });
                                  break;
                                case '新建':
                                  showDialog(
                                    context: context,
                                    builder: (ctx) {
                                      return InputAlertDialog(
                                        onSubmitted: (text) {
                                          setState(() {
                                            if (!text.startsWith('~')) {
                                              text = '~$text';
                                            }
                                            projectList.add(text);
                                            realm.write(() {
                                              widget.note.noteProject = text;
                                              widget.note.noteUpdateDate =
                                                  DateTime.now().toUtc();
                                            });
                                          });
                                        },
                                      );
                                    },
                                  );
                                  break;
                                default:
                                  setState(() {
                                    realm.write(() {
                                      widget.note.noteProject = project;
                                      widget.note.noteUpdateDate =
                                          DateTime.now().toUtc();
                                    });
                                  });
                              }
                            },
                          );
                        }).toList(),
                      ),
                      MenuAnchor(
                        builder: (context, controller, child) {
                          return FilledButton.tonal(
                            style: selectButtonStyle,
                            onPressed: () {
                              if (controller.isOpen) {
                                controller.close();
                              } else {
                                controller.open();
                              }
                            },
                            child: Text(
                              widget.note.noteFolder == ''
                                  ? '路径'
                                  : widget.note.noteFolder,
                              style: widget.note.noteFolder == ''
                                  ? const TextStyle(color: Colors.grey)
                                  : const TextStyle(
                                      color: Color.fromARGB(255, 4, 123, 60)),
                            ),
                          );
                        },
                        menuChildren: folderList.map((folder) {
                          return MenuItemButton(
                            style: menuChildrenButtonStyle,
                            child: Text(folder),
                            onPressed: () {
                              switch (folder) {
                                case '清空':
                                  setState(() {
                                    realm.write(() {
                                      widget.note.noteFolder = '';
                                      widget.note.noteUpdateDate =
                                          DateTime.now().toUtc();
                                    });
                                  });
                                  break;
                                case '新建':
                                  showDialog(
                                    context: context,
                                    builder: (ctx) {
                                      return InputAlertDialog(
                                        onSubmitted: (text) {
                                          setState(() {
                                            if (!text.startsWith('/')) {
                                              text = '/$text';
                                            }
                                            folderList.add(text);
                                            realm.write(() {
                                              widget.note.noteFolder = text;
                                              widget.note.noteUpdateDate =
                                                  DateTime.now().toUtc();
                                            });
                                          });
                                        },
                                      );
                                    },
                                  );
                                  break;
                                default:
                                  setState(() {
                                    realm.write(() {
                                      widget.note.noteFolder = folder;
                                      widget.note.noteUpdateDate =
                                          DateTime.now().toUtc();
                                    });
                                  });
                              }
                            },
                          );
                        }).toList(),
                      ),
                      Visibility(
                        visible: widget.note.noteType == ".todo",
                        child: MenuAnchor(
                          builder: (context, controller, child) {
                            return FilledButton.tonal(
                              style: selectButtonStyle,
                              onPressed: () {
                                if (controller.isOpen) {
                                  controller.close();
                                } else {
                                  controller.open();
                                }
                              },
                              child: Text(
                                widget.note.noteFinishState == ''
                                    ? '未完'
                                    : widget.note.noteFinishState,
                                style: const TextStyle(
                                    color: Color.fromARGB(255, 180, 68, 255)),
                              ),
                            );
                          },
                          menuChildren: finishStateList.map((finishState) {
                            return MenuItemButton(
                              style: menuChildrenButtonStyle,
                              child: Text(finishState),
                              onPressed: () {
                                switch (finishState) {
                                  case '新建':
                                    showDialog(
                                      context: context,
                                      builder: (ctx) {
                                        return InputAlertDialog(
                                          onSubmitted: (text) {
                                            setState(() {
                                              finishStateList.add(text);
                                              realm.write(() {
                                                widget.note.noteFinishState =
                                                    text;
                                                widget.note.noteUpdateDate =
                                                    DateTime.now().toUtc();
                                              });
                                            });
                                          },
                                        );
                                      },
                                    );
                                    break;
                                  default:
                                    setState(() {
                                      realm.write(() {
                                        widget.note.noteFinishState =
                                            finishState;
                                        widget.note.noteUpdateDate =
                                            DateTime.now().toUtc();
                                      });
                                    });
                                }
                              },
                            );
                          }).toList(),
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Text(
                    widget.note.noteContext.replaceAll(RegExp('\n|/n'), '  '),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 40,
                    style: const TextStyle(
                      fontSize: 16,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ChangePage(
              onPageClosed: () {
                setState(() {});
              },
              note: widget.note,
              mod: 1,
            ),
          ),
        );
      },
      onLongPress: () {
        showModalBottomSheet(
          context: context,
          builder: (context) {
            return BottomPopSheet(
              note: widget.note,
              onDialogClosed: () {
                setState(() {});
              },
            );
          },
        );
      },
    );
  }
}
