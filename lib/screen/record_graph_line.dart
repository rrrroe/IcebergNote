import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class LineChartSample extends StatefulWidget {
  const LineChartSample(
      {super.key,
      required this.fontColor,
      required this.dataList,
      required this.currentReportDurationType,
      required this.title,
      required this.unit,
      required this.length});
  final Color fontColor;
  final List<num> dataList;
  final String currentReportDurationType;
  final String title;
  final String unit;
  final int length;
  @override
  State<LineChartSample> createState() => _LineChartSampleState();
}

class _LineChartSampleState extends State<LineChartSample> {
  List<Color> gradientColors = [];
  List<FlSpot> spotList = [];
  int maxX = 6;
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

  bool showAvg = false;

  @override
  Widget build(BuildContext context) {
    spotList = [];
    maxX = 6;
    minX = 0;
    maxY = 5;
    minY = 0;
    scaleYList = [];
    for (int i = 0; i < widget.length; i++) {
      spotList.add(FlSpot(
          i.toDouble(), double.parse(widget.dataList[i].toStringAsFixed(2))));
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

    maxX = widget.length - 1;

    return Container(
      margin: const EdgeInsets.only(left: 0, right: 25, top: 25, bottom: 0),
      child: AspectRatio(
        aspectRatio: 1.70,
        child: Padding(
          padding: const EdgeInsets.only(
            right: 18,
            left: 12,
            top: 24,
            bottom: 12,
          ),
          child: LineChart(
            mainData(),
          ),
        ),
      ),
    );
  }

  Widget bottomTitleWidgets(double value, TitleMeta meta) {
    const style = TextStyle(
      // fontWeight: FontWeight.bold,
      fontSize: 14,
    );
    String text;
    switch (widget.currentReportDurationType) {
      case '周报':
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
        break;
      case '月报':
        switch (value.toInt()) {
          case 0:
          case 4:
          case 9:
          case 14:
          case 19:
          case 24:
          case 29:
            text = (value.toInt() + 1).toString();
            break;
          default:
            text = '';
            break;
        }
        break;
      case '年报':
        text = (value.toInt() + 1).toString();
        break;
      default:
        text = value.toInt().toString();
        break;
    }

    return SideTitleWidget(
      axisSide: meta.axisSide,
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

  Widget rightTitleWidgets(double value, TitleMeta meta) {
    return const SizedBox();
  }

  LineChartData mainData() {
    return LineChartData(
      lineTouchData: const LineTouchData(
        enabled: true,
        touchTooltipData:
            LineTouchTooltipData(tooltipBgColor: Color.fromARGB(0, 0, 0, 0)),
      ),
      gridData: FlGridData(
        show: true,
        drawVerticalLine: true,
        getDrawingHorizontalLine: (value) {
          return FlLine(
            color: Colors.grey.withOpacity(0.5),
            strokeWidth: 0.5,
          );
        },
        getDrawingVerticalLine: (value) {
          return const FlLine(
            color: Colors.grey,
            strokeWidth: 0.5,
          );
        },
      ),
      titlesData: FlTitlesData(
        show: true,
        rightTitles: const AxisTitles(
          sideTitles: SideTitles(showTitles: false),
        ),
        topTitles: const AxisTitles(
          sideTitles: SideTitles(showTitles: false),
        ),
        bottomTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            reservedSize: 30,
            interval: 1,
            getTitlesWidget: bottomTitleWidgets,
          ),
        ),
        leftTitles: const AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            // getTitlesWidget: leftTitleWidgets,
            reservedSize: 40,
          ),
        ),
      ),
      borderData: FlBorderData(
        show: true,
        border: Border.all(color: widget.fontColor),
      ),
      minX: 0,
      maxX: maxX.toDouble(),
      minY: minY.toDouble(),
      maxY: maxY.toDouble(),
      lineBarsData: [
        LineChartBarData(
          spots: spotList,
          isCurved: true,
          gradient: LinearGradient(
            colors: gradientColors,
          ),
          barWidth: 5,
          isStrokeCapRound: true,
          dotData: const FlDotData(
            show: false,
          ),
          belowBarData: BarAreaData(
            show: true,
            gradient: LinearGradient(
              colors: gradientColors
                  .map((color) => color.withOpacity(0.3))
                  .toList(),
            ),
          ),
        ),
      ],
    );
  }
}
