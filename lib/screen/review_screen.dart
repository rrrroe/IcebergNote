import 'package:flutter/material.dart';
import 'package:icebergnote/main.dart';
import 'package:realm/realm.dart';
import 'package:swipable_stack/swipable_stack.dart';
import 'dart:math' as math;

import '../notes.dart';
import 'input_screen.dart';
import 'noteslist_screen.dart';

const _labelAngle = math.pi / 2 * 0.2;
String blankTip = '恭喜您，已完成所有复盘！';
List<Notes> blankList = [
  Notes(ObjectId(), '', blankTip, math.Random().nextInt(100).toString()),
  Notes(ObjectId(), '', blankTip, math.Random().nextInt(100).toString()),
  Notes(ObjectId(), '', blankTip, math.Random().nextInt(100).toString()),
  Notes(ObjectId(), '', blankTip, math.Random().nextInt(100).toString()),
  Notes(ObjectId(), '', blankTip, math.Random().nextInt(100).toString()),
  Notes(ObjectId(), '', blankTip, math.Random().nextInt(100).toString())
];

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

  @override
  void initState() {
    super.initState();
    _controller = SwipableStackController()..addListener(_listenController);
    reviewList = realm
            .query<Notes>(
                "noteIsDeleted != true AND noteIsReviewed == false AND noteIsReviewed == false SORT(id ASC)")
            .toList() +
        blankList;
    print(reviewList.length);
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
    return Scaffold(
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
                stackClipBehaviour: Clip.none,
                onSwipeCompleted: (index, direction) {
                  print('$index, $direction');
                  if ((direction == SwipeDirection.right ||
                          direction == SwipeDirection.up) &&
                      reviewList[index].noteTitle != blankTip) {
                    realm.write(() => reviewList[index].noteIsReviewed = true);
                  }
                  if ((direction == SwipeDirection.left ||
                          direction == SwipeDirection.down) &&
                      reviewList[index].noteTitle != blankTip) {
                    realm.write(() => reviewList[index].noteIsReviewed = false);
                  }
                  if (reviewList[index].noteTitle == blankTip) {
                    reviewList.add(Notes(ObjectId(), '', blankTip,
                        math.Random().nextInt(100).toString()));
                  }
                  print(reviewList[index].noteIsReviewed);
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

  static const double height = 50;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.bottomCenter,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8),
        child: SizedBox(
          height: height,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _BottomButton(
                color: canRewind ? Colors.amberAccent : Colors.grey,
                onPressed: canRewind ? onRewindTap : null,
                child: const Icon(Icons.refresh),
              ),
              _BottomButton(
                color: SwipeDirectionColor.left,
                child: const Icon(Icons.arrow_back),
                onPressed: () {
                  onSwipe(SwipeDirection.left);
                },
              ),
              _BottomButton(
                color: SwipeDirectionColor.up,
                onPressed: () {
                  onSwipe(SwipeDirection.up);
                },
                child: const Icon(Icons.arrow_upward),
              ),
              _BottomButton(
                color: SwipeDirectionColor.right,
                onPressed: () {
                  onSwipe(SwipeDirection.right);
                },
                child: const Icon(Icons.arrow_forward),
              ),
              _BottomButton(
                color: SwipeDirectionColor.down,
                onPressed: () {
                  onSwipe(SwipeDirection.down);
                },
                child: const Icon(Icons.arrow_downward),
              ),
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
      height: 64,
      width: 64,
      child: ElevatedButton(
        style: ButtonStyle(
          shape: MaterialStateProperty.resolveWith(
            (states) => RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(100),
            ),
          ),
          backgroundColor: MaterialStateProperty.resolveWith(
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
  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      child: GestureDetector(
        child: Card(
          margin: const EdgeInsets.fromLTRB(15, 0, 15, 10),
          elevation: 0,
          shadowColor: Colors.grey,
          color: const Color.fromARGB(20, 0, 140, 198),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Visibility(
                  visible: widget.note.noteTitle != "",
                  child: SizedBox(
                    child: Text(
                      widget.note.noteTitle,
                      maxLines: 2,
                      textAlign: TextAlign.start,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                          color: Color.fromARGB(255, 0, 140, 198)),
                    ),
                  ),
                ),
                Visibility(
                  visible: widget.note.noteTitle != "",
                  child: const SizedBox(
                    height: 5,
                  ),
                ),
                Visibility(
                  visible: widget.note.noteContext != "",
                  child: Text(
                    widget.note.noteContext.replaceAll(RegExp('\n|/n'), '  '),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 5,
                    style: const TextStyle(
                      fontSize: 16,
                    ),
                  ),
                ),
                // Text(
                //   '${note.noteContext.length + note.noteTitle.length}${note.noteCreatTime.length > 19 ? '${note.noteCreatTime.substring(0, 19)}创建       ' : note.noteCreatTime}${note.noteUpdateTime.length > 19 ? '${note.noteUpdateTime.substring(0, 19)}修改' : note.noteUpdateTime}',
                //   maxLines: 1,
                //   style: const TextStyle(
                //     fontSize: 10,
                //   ),
                // ),
                Visibility(
                  visible: widget.note.noteType +
                          widget.note.noteProject +
                          widget.note.noteFolder !=
                      "",
                  child: Row(
                    children: [
                      Container(
                        width: 70,
                        padding: const EdgeInsets.all(0),
                        alignment: Alignment.centerLeft,
                        child: Text(
                          widget.note.noteType,
                          style: const TextStyle(
                            fontSize: 10,
                            color: Color.fromARGB(255, 56, 128, 186),
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.all(0),
                        alignment: Alignment.centerLeft,
                        width: 79,
                        child: Text(
                          widget.note.noteProject,
                          style: const TextStyle(
                            fontSize: 10,
                            color: Color.fromARGB(255, 215, 55, 55),
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.all(0),
                        alignment: Alignment.centerLeft,
                        width: 150,
                        child: Text(
                          widget.note.noteFolder,
                          style: const TextStyle(
                            fontSize: 10,
                            color: Color.fromARGB(255, 4, 123, 60),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
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
      ),
    );
  }
}
