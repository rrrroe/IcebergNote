String printWeekday(DateTime t) {
  int w = t.weekday;
  switch (w) {
    case 1:
      return '周一';
    case 2:
      return '周二';
    case 3:
      return '周三';
    case 4:
      return '周四';
    case 5:
      return '周五';
    case 6:
      return '周六';
    case 7:
      return '周日';
    default:
      return '';
  }
}

//获取一年中的第几周
int weekNumber(DateTime date) {
  // 获取年份的第一天
  DateTime firstDayOfYear = DateTime(date.year, 1, 1);
  // 获取第一天是星期几
  int firstWeekday = firstDayOfYear.weekday;
  // 计算当前日期是本年度的第几天
  int dayOfYear = date.difference(firstDayOfYear).inDays + 1;
  // 计算第几周
  int weekNumber = ((dayOfYear + firstWeekday - 1) / 7).ceil() +
      offsetWeekYear(firstDayOfYear);
  return weekNumber;
}

//获取一年中的第几周
int week7Number(DateTime date) {
  int n = weekNumber(date);
  return ((n - 1) ~/ 7) + 1;
}

int offsetWeekYear(DateTime today) {
  DateTime thu = today.add(Duration(days: -today.weekday + 4));
  return thu.year - today.year;
}
