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

    return Stack(
      children: <Widget>[
        AspectRatio(
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
      ],
    );
  }

  Widget bottomTitleWidgets(double value, TitleMeta meta) {
    const style = TextStyle(
      fontWeight: FontWeight.bold,
      fontSize: 14,
    );
    String text;
    print(widget.currentReportDurationType);
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
          case 4:
          case 9:
          case 14:
          case 19:
          case 24:
            text = (value.toInt() + 1).toString();
            break;
          default:
            text = '';
            break;
        }
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
        horizontalInterval: 1,
        verticalInterval: 1,
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
        leftTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            interval: 1,
            getTitlesWidget: leftTitleWidgets,
            reservedSize: 30,
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

  LineChartData avgData() {
    return LineChartData(
      lineTouchData: const LineTouchData(enabled: false),
      gridData: FlGridData(
        show: true,
        drawHorizontalLine: true,
        verticalInterval: 1,
        horizontalInterval: 1,
        getDrawingVerticalLine: (value) {
          return const FlLine(
            color: Color(0xff37434d),
            strokeWidth: 1,
          );
        },
        getDrawingHorizontalLine: (value) {
          return const FlLine(
            color: Color(0xff37434d),
            strokeWidth: 1,
          );
        },
      ),
      titlesData: FlTitlesData(
        show: true,
        bottomTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            reservedSize: 30,
            getTitlesWidget: bottomTitleWidgets,
            interval: 1,
          ),
        ),
        leftTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            getTitlesWidget: leftTitleWidgets,
            reservedSize: 42,
            interval: 1,
          ),
        ),
        topTitles: const AxisTitles(
          sideTitles: SideTitles(showTitles: false),
        ),
        rightTitles: const AxisTitles(
          sideTitles: SideTitles(showTitles: false),
        ),
      ),
      borderData: FlBorderData(
        show: true,
        border: Border.all(color: const Color(0xff37434d)),
      ),
      minX: 0,
      maxX: 11,
      minY: 0,
      maxY: 6,
      lineBarsData: [
        LineChartBarData(
          spots: const [
            FlSpot(0, 3.44),
            FlSpot(2.6, 3.44),
            FlSpot(4.9, 3.44),
            FlSpot(6.8, 3.44),
            FlSpot(8, 3.44),
            FlSpot(9.5, 3.44),
            FlSpot(11, 3.44),
          ],
          isCurved: true,
          gradient: LinearGradient(
            colors: [
              ColorTween(begin: gradientColors[0], end: gradientColors[1])
                  .lerp(0.2)!,
              ColorTween(begin: gradientColors[0], end: gradientColors[1])
                  .lerp(0.2)!,
            ],
          ),
          barWidth: 5,
          isStrokeCapRound: true,
          dotData: const FlDotData(
            show: false,
          ),
          belowBarData: BarAreaData(
            show: true,
            gradient: LinearGradient(
              colors: [
                ColorTween(begin: gradientColors[0], end: gradientColors[1])
                    .lerp(0.2)!
                    .withOpacity(0.1),
                ColorTween(begin: gradientColors[0], end: gradientColors[1])
                    .lerp(0.2)!
                    .withOpacity(0.1),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
