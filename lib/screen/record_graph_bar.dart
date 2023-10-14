import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import '/extensions/color_extensions.dart';

class BarChartSample3 extends StatefulWidget {
  const BarChartSample3(
      {super.key,
      required this.fontColor,
      required this.dataList,
      required this.currentReportDurationType,
      required this.title,
      required this.unit});
  final Color fontColor;
  final List<num> dataList;
  final String currentReportDurationType;
  final String title;
  final String unit;
  @override
  State<StatefulWidget> createState() => BarChartSample3State();
}

class BarChartSample3State extends State<BarChartSample3> {
  List<Color> gradientColors = [];
  List<BarChartGroupData> spotList = [];
  int maxX = 20;
  int minX = 0;
  int maxY = 5;
  int minY = 0;
  List<int> scaleYList = [];
  @override
  void initState() {
    super.initState();
    gradientColors = [
      widget.fontColor,
      widget.fontColor,
    ];
  }

  @override
  Widget build(BuildContext context) {
    spotList = [];
    maxX = 20;
    minX = 0;
    maxY = 5;
    minY = 0;
    scaleYList = [];
    for (int i = 0; i < widget.dataList.length; i++) {
      spotList.add(
        BarChartGroupData(
          x: i,
          barsSpace: 2,
          barRods: [
            BarChartRodData(
              toY: double.parse(widget.dataList[i].toStringAsFixed(2)),
              gradient: _barsGradient,
              width: 15,
            )
          ],
          showingTooltipIndicators: [0],
        ),
      );
      while (maxY < widget.dataList[i]) {
        maxY = maxY + 5;
      }
      while (minY > widget.dataList[i]) {
        minY = minY - 5;
      }
    }
    scaleYList = [
      (maxY - minY) * 1 ~/ 5 + minY,
      (maxY - minY) * 2 ~/ 5 + minY,
      (maxY - minY) * 3 ~/ 5 + minY,
      (maxY - minY) * 4 ~/ 5 + minY,
      minY,
      maxY,
      0
    ];
    switch (widget.currentReportDurationType) {
      case '周报':
        maxX = 6;
    }
    return AspectRatio(
      aspectRatio: 1.6,
      child: BarChart(
        BarChartData(
          barTouchData: barTouchData,
          titlesData: titlesData,
          borderData: borderData,
          barGroups: spotList,
          gridData: const FlGridData(show: false),
          alignment: BarChartAlignment.spaceAround,
          maxY: maxY.toDouble(),
        ),
      ),
    );
  }

  BarTouchData get barTouchData => BarTouchData(
        enabled: false,
        touchTooltipData: BarTouchTooltipData(
          tooltipBgColor: Colors.transparent,
          tooltipPadding: EdgeInsets.zero,
          tooltipMargin: 8,
          getTooltipItem: (
            BarChartGroupData group,
            int groupIndex,
            BarChartRodData rod,
            int rodIndex,
          ) {
            if (rod.toY != 0.0) {
              return BarTooltipItem(
                rod.toY.round().toString(),
                TextStyle(
                  color: widget.fontColor,
                  fontWeight: FontWeight.bold,
                ),
              );
            } else {
              return BarTooltipItem(
                '',
                TextStyle(
                  color: widget.fontColor,
                  fontWeight: FontWeight.bold,
                ),
              );
            }
          },
        ),
      );

  Widget bottomTitleWidgets(double value, TitleMeta meta) {
    const style = TextStyle(
      color: Colors.black,
      fontWeight: FontWeight.bold,
      fontSize: 14,
    );
    String text;
    switch (value.toInt()) {
      case 0:
        text = '周一';
        break;
      case 1:
        text = '周二';
        break;
      case 2:
        text = '周三';
        break;
      case 3:
        text = '周四';
        break;
      case 4:
        text = '周五';
        break;
      case 5:
        text = '周六';
        break;
      case 6:
        text = '周日';
        break;
      default:
        text = '';
        break;
    }
    return SideTitleWidget(
      axisSide: meta.axisSide,
      space: 4,
      child: Text(text, style: style),
    );
  }

  Widget leftTitleWidgets(double value, TitleMeta meta) {
    const style = TextStyle(
      fontWeight: FontWeight.bold,
      fontSize: 15,
    );

    String text;
    if (scaleYList.contains(value.toInt())) {
      text = value.toInt().toString();
    } else {
      text = '';
    }

    return Text(text, style: style, textAlign: TextAlign.center);
  }

  FlTitlesData get titlesData => FlTitlesData(
        show: true,
        bottomTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            reservedSize: 30,
            getTitlesWidget: bottomTitleWidgets,
          ),
        ),
        leftTitles: const AxisTitles(
          sideTitles: SideTitles(showTitles: false),
        ),
        // leftTitles: AxisTitles(
        //   sideTitles: SideTitles(
        //     showTitles: true,
        //     reservedSize: 25,
        //     getTitlesWidget: leftTitleWidgets,
        //   ),
        // ),
        topTitles: const AxisTitles(
          sideTitles: SideTitles(showTitles: false),
        ),
        rightTitles: const AxisTitles(
          sideTitles: SideTitles(showTitles: false),
        ),
      );

  FlBorderData get borderData => FlBorderData(
        show: false,
      );

  LinearGradient get _barsGradient => LinearGradient(
        colors: [
          widget.fontColor.darken(40),
          widget.fontColor.lighten(40),
        ],
        begin: Alignment.bottomCenter,
        end: Alignment.topCenter,
      );
}
