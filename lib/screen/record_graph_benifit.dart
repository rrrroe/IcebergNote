import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class BenifutLineChart extends StatefulWidget {
  const BenifutLineChart(
      {super.key,
      required this.fontColor,
      required this.dataList,
      required this.currentReportDurationType,
      required this.title,
      required this.unit,
      required this.length,
      required this.startDay});
  final Color fontColor;
  final List<Map<String, int>> dataList;
  final String currentReportDurationType;
  final String title;
  final String unit;
  final int length;
  final DateTime startDay;
  @override
  State<StatefulWidget> createState() => BenifutLineChartState();
}

class BenifutLineChartState extends State<BenifutLineChart> {
  late bool isShowingMainData;
  List<FlSpot> assetSpot = [];
  List<int> input = [];
  List<FlSpot> inputSpot = [];
  List<double> rate = [];
  List<FlSpot> rateSpot = [];

  @override
  void initState() {
    super.initState();
    isShowingMainData = true;
  }

  @override
  Widget build(BuildContext context) {
    widget.dataList.sort((a, b) {
      return a['day']!.compareTo(b['day']!);
    });
    if (widget.dataList[0]['asset'] == -1) {
      widget.dataList[0]['asset'] = widget.dataList[1]['asset']!;
    }
    assetSpot = [];
    input = [];
    inputSpot = [];
    rateSpot = [];
    rate = [];

    for (int i = 0; i < widget.dataList.length; i++) {
      double day = widget.dataList[i]['day']!.toDouble();
      if (i == 0) {
        assetSpot.add(FlSpot(day, widget.dataList[i]['asset']!.toDouble()));
        input.add(widget.dataList[i]['asset']!);
        inputSpot.add(FlSpot(day, input[i].toDouble()));
        rate.add(0);
        rateSpot.add(FlSpot(day, 0));
      } else {
        assetSpot.add(FlSpot(day, widget.dataList[i]['asset']!.toDouble()));
        input.add(input[i - 1] + widget.dataList[i]['change']!);
        inputSpot.add(FlSpot(day, input[i].toDouble()));
        rate.add(
            (widget.dataList[i]['asset']! - widget.dataList[i]['change']!) /
                    widget.dataList[i - 1]['asset']! *
                    (rate[i - 1] + 1) -
                1);
        rateSpot.add(FlSpot(day, double.parse(rate[i].toStringAsFixed(4))));
      }
    }
    return AspectRatio(
      aspectRatio: 1.8,
      child: Stack(
        children: <Widget>[
          Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              const SizedBox(
                height: 10,
              ),
              TextButton(
                onPressed: () {
                  setState(() {
                    isShowingMainData = !isShowingMainData;
                  });
                },
                child: isShowingMainData == true
                    ? Text(
                        '资产曲线',
                        style: TextStyle(color: widget.fontColor, fontSize: 20),
                      )
                    : const Text(
                        '收益曲线',
                        style: TextStyle(color: Colors.grey, fontSize: 20),
                      ),
              ),
              const SizedBox(
                height: 10,
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(right: 16, left: 6),
                  child: LineChart(
                    isShowingMainData ? sampleData1 : sampleData2,
                    duration: const Duration(milliseconds: 250),
                  ),
                ),
              ),
              const SizedBox(
                height: 10,
              ),
            ],
          ),
        ],
      ),
    );
  }

  LineChartData get sampleData1 => LineChartData(
        lineTouchData: lineTouchData1,
        gridData: gridData,
        titlesData: titlesData1,
        borderData: borderData,
        lineBarsData: lineBarsData1,
        // minX: 0,
        maxX: 366,
        // maxY: 15000,
        minY: 0,
      );

  LineChartData get sampleData2 => LineChartData(
        lineTouchData: lineTouchData2,
        gridData: gridData,
        titlesData: titlesData2,
        borderData: borderData,
        lineBarsData: lineBarsData2,
        // minX: 0,
        // maxX: 366,
        // maxY: 1,
        // minY: 0,
      );

  LineTouchData get lineTouchData1 => LineTouchData(
        handleBuiltInTouches: true,
        touchTooltipData: LineTouchTooltipData(
            tooltipBgColor: Colors.white,
            getTooltipItems: (List<LineBarSpot> touchedSpots) {
              return touchedSpots.map((LineBarSpot touchedSpot) {
                final textStyle = TextStyle(
                  color: touchedSpot.bar.gradient?.colors.first ??
                      touchedSpot.bar.color ??
                      Colors.blueGrey,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                );
                return LineTooltipItem(
                    touchedSpot.y.toInt().toString(), textStyle);
              }).toList();
            }),
      );

  FlTitlesData get titlesData1 => FlTitlesData(
        bottomTitles: const AxisTitles(
          sideTitles: SideTitles(showTitles: false),
        ),
        rightTitles: const AxisTitles(
          sideTitles: SideTitles(showTitles: false),
        ),
        topTitles: const AxisTitles(
          sideTitles: SideTitles(showTitles: false),
        ),
        leftTitles: AxisTitles(
          sideTitles: leftTitles1(),
        ),
      );

  List<LineChartBarData> get lineBarsData1 => [
        lineChartBarData1_1,
        lineChartBarData1_2,
        // lineChartBarData1_3,
      ];

  LineTouchData get lineTouchData2 => LineTouchData(
        handleBuiltInTouches: true,
        touchTooltipData: LineTouchTooltipData(
            tooltipBgColor: const Color.fromARGB(0, 0, 0, 0),
            getTooltipItems: (List<LineBarSpot> touchedSpots) {
              return touchedSpots.map((LineBarSpot touchedSpot) {
                final textStyle = TextStyle(
                  color: touchedSpot.bar.gradient?.colors.first ??
                      touchedSpot.bar.color ??
                      Colors.blueGrey,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                );
                return LineTooltipItem(
                    '${(touchedSpot.y * 100).toStringAsFixed(2)}%', textStyle);
              }).toList();
            }),
      );

  FlTitlesData get titlesData2 => FlTitlesData(
        bottomTitles: const AxisTitles(
          sideTitles: SideTitles(showTitles: false),
        ),
        rightTitles: const AxisTitles(
          sideTitles: SideTitles(showTitles: false),
        ),
        topTitles: const AxisTitles(
          sideTitles: SideTitles(showTitles: false),
        ),
        leftTitles: AxisTitles(
          sideTitles: leftTitles2(),
        ),
      );

  List<LineChartBarData> get lineBarsData2 => [
        lineChartBarData2_1,
        // lineChartBarData2_2,
        // lineChartBarData2_3,
      ];

  Widget leftTitleWidgets1(double value, TitleMeta meta) {
    if (value == meta.max) {
      return SideTitleWidget(
        axisSide: meta.axisSide,
        child: const Text(
          '',
        ),
      );
    } else {
      return SideTitleWidget(
        axisSide: meta.axisSide,
        child: Text(
          meta.formattedValue,
        ),
      );
    }
  }

  Widget leftTitleWidgets2(double value, TitleMeta meta) {
    const style = TextStyle(
      fontWeight: FontWeight.bold,
      fontSize: 14,
    );
    String text = '';
    if (value != meta.max && value != meta.min) {
      text = '${(value * 100).toInt()}%';
    }

    return Text(text, style: style, textAlign: TextAlign.center);
  }

  SideTitles leftTitles1() => SideTitles(
        getTitlesWidget: leftTitleWidgets1,
        showTitles: true,
        // interval: 1,
        reservedSize: 40,
      );
  SideTitles leftTitles2() => SideTitles(
        getTitlesWidget: leftTitleWidgets2,
        showTitles: true,
        // interval: 1,
        reservedSize: 40,
      );

  Widget bottomTitleWidgets(double value, TitleMeta meta) {
    if (value == 366) {
      return const Text(
        '366',
      );
    } else {
      return const SizedBox();
    }
  }

  SideTitles get bottomTitles => SideTitles(
        showTitles: true,
        reservedSize: 31,
        interval: 30,
        getTitlesWidget: bottomTitleWidgets,
      );

  FlGridData get gridData => const FlGridData(show: false);

  FlBorderData get borderData => FlBorderData(
        show: true,
        border: Border(
          bottom:
              BorderSide(color: widget.fontColor.withOpacity(0.3), width: 3),
          left: BorderSide(color: widget.fontColor.withOpacity(0.3), width: 3),
          right: const BorderSide(color: Colors.transparent),
          top: const BorderSide(color: Colors.transparent),
        ),
      );

  LineChartBarData get lineChartBarData1_1 => LineChartBarData(
        isCurved: true,
        curveSmoothness: 0,
        color: widget.fontColor,
        barWidth: 3,
        isStrokeCapRound: true,
        dotData: const FlDotData(show: false),
        belowBarData: BarAreaData(show: false),
        spots: assetSpot,
      );

  LineChartBarData get lineChartBarData1_2 => LineChartBarData(
        isCurved: true,
        curveSmoothness: 0,
        color: Colors.grey,
        barWidth: 3,
        isStrokeCapRound: true,
        dotData: const FlDotData(show: false),
        belowBarData: BarAreaData(
          show: false,
          color: AppColors.contentColorPink.withOpacity(0),
        ),
        spots: inputSpot,
      );

  LineChartBarData get lineChartBarData1_3 => LineChartBarData(
        isCurved: true,
        color: AppColors.contentColorCyan,
        barWidth: 8,
        isStrokeCapRound: true,
        dotData: const FlDotData(show: false),
        belowBarData: BarAreaData(show: false),
        spots: const [
          FlSpot(1, 2.8),
          FlSpot(3, 1.9),
          FlSpot(6, 3),
          FlSpot(10, 1.3),
          FlSpot(13, 2.5),
        ],
      );

  LineChartBarData get lineChartBarData2_1 => LineChartBarData(
        isCurved: true,
        curveSmoothness: 0,
        color: Colors.red,
        barWidth: 3,
        isStrokeCapRound: true,
        dotData: const FlDotData(show: false),
        belowBarData: BarAreaData(show: false),
        spots: rateSpot,
      );

  LineChartBarData get lineChartBarData2_2 => LineChartBarData(
        isCurved: true,
        color: AppColors.contentColorPink.withOpacity(0.5),
        barWidth: 4,
        isStrokeCapRound: true,
        dotData: const FlDotData(show: false),
        belowBarData: BarAreaData(
          show: true,
          color: AppColors.contentColorPink.withOpacity(0.2),
        ),
        spots: const [
          FlSpot(1, 1),
          FlSpot(3, 2.8),
          FlSpot(7, 1.2),
          FlSpot(10, 2.8),
          FlSpot(12, 2.6),
          FlSpot(13, 3.9),
        ],
      );

  LineChartBarData get lineChartBarData2_3 => LineChartBarData(
        isCurved: true,
        curveSmoothness: 0,
        color: AppColors.contentColorCyan.withOpacity(0.5),
        barWidth: 2,
        isStrokeCapRound: true,
        dotData: const FlDotData(show: true),
        belowBarData: BarAreaData(show: false),
        spots: const [
          FlSpot(1, 3.8),
          FlSpot(3, 1.9),
          FlSpot(6, 5),
          FlSpot(10, 3.3),
          FlSpot(13, 4.5),
        ],
      );
}

class AppColors {
  static const Color primary = contentColorCyan;
  static const Color menuBackground = Color(0xFF090912);
  static const Color itemsBackground = Color(0xFF1B2339);
  static const Color pageBackground = Color(0xFF282E45);
  static const Color mainTextColor1 = Colors.white;
  static const Color mainTextColor2 = Colors.white70;
  static const Color mainTextColor3 = Colors.white38;
  static const Color mainGridLineColor = Colors.white10;
  static const Color borderColor = Colors.white54;
  static const Color gridLinesColor = Color(0x11FFFFFF);

  static const Color contentColorBlack = Colors.black;
  static const Color contentColorWhite = Colors.white;
  static const Color contentColorBlue = Color(0xFF2196F3);
  static const Color contentColorYellow = Color(0xFFFFC300);
  static const Color contentColorOrange = Color(0xFFFF683B);
  static const Color contentColorGreen = Color(0xFF3BFF49);
  static const Color contentColorPurple = Color(0xFF6E1BFF);
  static const Color contentColorPink = Color(0xFFFF3AF2);
  static const Color contentColorRed = Color(0xFFE80054);
  static const Color contentColorCyan = Color(0xFF50E4FF);
}
