import 'package:flutter/material.dart';

class DaysInYearHeatmap extends StatelessWidget {
  const DaysInYearHeatmap(
      {super.key,
      required this.data,
      required this.color,
      required this.level,
      required this.firstWeekday,
      required this.today});
  final List<num> data;
  final List<num> level;
  final Color color;
  final int firstWeekday;
  final int today;

  @override
  Widget build(BuildContext context) {
    final List<Color> colorList = [];
    final List<int> dataList = [];
    for (int i = 0; i < level.length + 1; i++) {
      print('$i/${level.length + 1}');
      colorList.add(color.withOpacity(i / (level.length + 1)));
    }
    for (int i = 0; i < data.length; i++) {
      dataList.add(getLevelIndex(data[i], level));
    }
    final List<int> dataList1 = [];
    final List<int> dataList2 = [];
    for (int i = 0; i < firstWeekday - 1; i++) {
      dataList1.add(-1);
    }
    dataList1.addAll(dataList.sublist(0, 189 - firstWeekday + 1));
    dataList2.addAll(dataList.sublist(189 - firstWeekday + 1));
    for (int i = 0; dataList2.length < 189; i++) {
      dataList2.add(-1);
    }
    int weekNum1 = dataList1.length ~/ 7;
    int weekNum2 = dataList2.length ~/ 7;
    print(level);
    print(dataList);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // Container(
        //   margin: const EdgeInsets.only(top: 10),
        //   padding: const EdgeInsets.only(left: 10, right: 10),
        //   height: 320,
        //   child: Wrap(
        //     direction: Axis.vertical,
        //     spacing: 3,
        //     runSpacing: 3,
        //     children: List.generate(
        //       data.length,
        //       (index) => Container(
        //         color: Colors.grey[200],
        //         child: Container(
        //           height: 12,
        //           width: 12,
        //           decoration: BoxDecoration(
        //             borderRadius: BorderRadius.circular(4),
        //             // border: Border.all(color: Colors.grey, width: 1),
        //             color: colorList[dataList[index]],
        //           ),
        //           alignment: Alignment.center,
        //           child: Text(dataList[index].toString(),
        //               style: const TextStyle(fontSize: 10)),
        //         ),
        //       ),
        //     ),
        //   ),
        // ),
        Container(
          margin: const EdgeInsets.fromLTRB(0, 10, 0, 0),
          padding: const EdgeInsets.fromLTRB(10, 0, 10, 0),
          child: Row(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(
              27,
              (index) => Container(
                height: 12,
                width: 12,
                margin: const EdgeInsets.all(0),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(0),
                  color: Colors.white,
                ),
                alignment: Alignment.center,
                child: Text(
                  ((index + 1) % 4 == 0) ||
                          index == (today + firstWeekday - 2) ~/ 7
                      ? (index + 1).toString()
                      : '',
                  overflow: TextOverflow.visible,
                  style: TextStyle(
                    fontSize: 9,
                    fontWeight: FontWeight.bold,
                    color: index == (today + firstWeekday - 2) ~/ 7
                        ? color
                        : Colors.black,
                  ),
                ),
              ),
            ),
          ),
        ),
        Container(
          margin: const EdgeInsets.fromLTRB(0, 2, 0, 5),
          padding: const EdgeInsets.fromLTRB(10, 0, 10, 0),
          child: Row(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(
                weekNum1,
                (weekno) => Column(
                      children: List.generate(
                        7,
                        (day) => Container(
                          margin: const EdgeInsets.all(1),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(2),
                            color: Colors.grey[200],
                          ),
                          child: Container(
                            height: 10,
                            width: 10,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(2),
                              color: dataList1[weekno * 7 + day] == -1
                                  ? Colors.white
                                  : colorList[dataList1[weekno * 7 + day]],
                              border: Border.all(
                                  color: weekno * 7 + day !=
                                          today + firstWeekday - 2
                                      ? const Color.fromARGB(0, 0, 0, 0)
                                      : Colors.black,
                                  width: 1.5),
                            ),
                          ),
                        ),
                      ),
                    )),
          ),
        ),
        Container(
          margin: const EdgeInsets.fromLTRB(0, 5, 0, 2),
          padding: const EdgeInsets.fromLTRB(10, 0, 10, 0),
          child: Row(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(
                weekNum2,
                (weekno) => Column(
                      children: List.generate(
                        7,
                        (day) => Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(2),
                            color: Colors.grey[200],
                          ),
                          margin: const EdgeInsets.all(1),
                          child: Container(
                            height: 10,
                            width: 10,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(2),
                              color: dataList2[weekno * 7 + day] == -1
                                  ? Colors.white
                                  : colorList[dataList2[weekno * 7 + day]],
                              border: Border.all(
                                  color: weekno * 7 + day + 189 !=
                                          today + firstWeekday - 2
                                      ? const Color.fromARGB(0, 0, 0, 0)
                                      : Colors.black,
                                  width: 1.5),
                            ),
                            // alignment: Alignment.center,
                            // child: Text(dataList2[weekno * 7 + day].toString(),
                            //     style: const TextStyle(fontSize: 10)),
                          ),
                        ),
                      ),
                    )),
          ),
        ),
        Container(
          margin: const EdgeInsets.fromLTRB(0, 0, 0, 10),
          padding: const EdgeInsets.fromLTRB(10, 0, 10, 0),
          child: Row(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(
              27,
              (index) => Container(
                height: 12,
                width: 12,
                margin: const EdgeInsets.all(0),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(0),
                  color: Colors.white,
                ),
                alignment: Alignment.center,
                child: Text(
                  ((index + 28) % 4 == 0) ||
                          index + 27 == (today + firstWeekday - 2) ~/ 7
                      ? (index + 28).toString()
                      : '',
                  overflow: TextOverflow.visible,
                  style: TextStyle(
                    fontSize: 9,
                    fontWeight: FontWeight.bold,
                    color: index + 27 == (today + firstWeekday - 2) ~/ 7
                        ? color
                        : Colors.black,
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

int getLevelIndex(num number, List<num> levels) {
  if (levels.length == 1) {
    if (number < levels[0]) {
      return 0;
    } else {
      return 1;
    }
  } else {
    for (int i = 0; i < levels.length - 1; i++) {
      if (i == 0) {
        if (number < levels[i]) {
          return 0;
        }
      }
      if (i == levels.length - 2) {
        if (number >= levels[i + 1]) {
          return i + 2;
        }
      }
      if (number >= levels[i] && number < levels[i + 1]) {
        return i + 1;
      }
    }
  }
  return levels.length - 1;
}
