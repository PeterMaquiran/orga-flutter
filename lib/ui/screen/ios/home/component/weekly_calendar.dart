import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class InfiniteWeeklyCalendar extends StatelessWidget {
  const InfiniteWeeklyCalendar({super.key});

  static const int _virtualCenter = 10000;

  List<DateTime> _getWeekForIndex(int index, DateTime today) {
    final int weekOffset = index - _virtualCenter;
    final DateTime firstDayOfWeek = today.subtract(Duration(days: today.weekday - 1));
    final DateTime startOfTargetWeek = firstDayOfWeek.add(Duration(days: weekOffset * 7));
    return List.generate(7, (i) => startOfTargetWeek.add(Duration(days: i)));
  }

  @override
  Widget build(BuildContext context) {
    final DateTime today = DateTime.now();
    final PageController controller = PageController(initialPage: _virtualCenter);
    final ValueNotifier<DateTime> focusedDate = ValueNotifier(_getWeekForIndex(_virtualCenter, today).last);
    final Color iconColor = CupertinoColors.secondaryLabel.resolveFrom(context);
    final days = ["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"];

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 5),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: CupertinoColors.systemBackground.resolveFrom(context),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: const Color(0xFF3C3C43).withValues(alpha: 0.12),
                    width: 1,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.06),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: CupertinoButton(
                  padding: EdgeInsets.zero,
                  onPressed: () {},
                  child: Icon(
                    CupertinoIcons.chart_bar_alt_fill,
                    size: 22,
                    color: iconColor,
                  ),
                ),
              ),
              ValueListenableBuilder<DateTime>(
                valueListenable: focusedDate,
                builder: (context, date, _) {
                  final String yearStr = date.year != today.year ? ', ${date.year}' : '';
                  final String month = [
                    'Jan',
                    'Feb',
                    'Mar',
                    'Apr',
                    'May',
                    'Jun',
                    'Jul',
                    'Aug',
                    'Sep',
                    'Oct',
                    'Nov',
                    'Dec',
                  ][date.month - 1];
                  return Text(
                    '$month ${date.day}$yearStr',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 17,
                      letterSpacing: -0.41,
                      color: CupertinoColors.label.resolveFrom(context),
                    ),
                  );
                },
              ),
              Container(
                width: 100,
                decoration: BoxDecoration(
                  color: CupertinoColors.systemBackground.resolveFrom(context),
                  borderRadius: BorderRadius.circular(22),
                  border: Border.all(
                    color: const Color(0xFF3C3C43).withValues(alpha: 0.12),
                    width: 1,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.06),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    SizedBox(
                      width: 44,
                      height: 44,
                      child: CupertinoButton(
                        padding: EdgeInsets.zero,
                        onPressed: () {},
                        child: Icon(
                          CupertinoIcons.add,
                          size: 22,
                          color: iconColor,
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    SizedBox(
                      width: 44,
                      height: 44,
                      child: CupertinoButton(
                        padding: EdgeInsets.zero,
                        onPressed: () {},
                        child: Icon(
                          CupertinoIcons.slider_horizontal_3,
                          size: 22,
                          color: iconColor,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        SizedBox(
          height: 40,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: days.map((day) {
              final isSunday = day == "Sun";

              return SizedBox(
                width: 35,
                child: Text(
                  day,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.06,
                    color: isSunday
                        ? CupertinoColors.activeBlue.resolveFrom(context)
                        : CupertinoColors.tertiaryLabel.resolveFrom(context),
                  ),
                ),
              );
            }).toList(),
          ),
        ),
        SizedBox(
          height: 35,
          child: PageView.builder(
            controller: controller,
            onPageChanged: (i) => focusedDate.value = _getWeekForIndex(i, today).last,
            itemBuilder: (context, index) {
              final week = _getWeekForIndex(index, today);
              return Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: week.map((date) {
                  final isToday =
                      date.day == today.day && date.month == today.month && date.year == today.year;
                  return _buildDayCard(context, date, isToday);
                }).toList(),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildDayCard(
      BuildContext context,
      DateTime date,
      bool isToday, {
        double completion = 0.75,
      }) {
    final active = CupertinoColors.activeBlue.resolveFrom(context);
    final labelColor = CupertinoColors.label.resolveFrom(context);

    return SizedBox(
      width: 35,
      height: 35,
      child: CustomPaint(
        painter: _DayProgressPainter(
          progress: completion,
          color: active,
        ),
        child: Container(
          margin: const EdgeInsets.all(3),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isToday
                ? active.withValues(alpha: 0.05)
                : CupertinoColors.systemBackground.resolveFrom(context),
          ),
          alignment: Alignment.center,
          child: Text(
            date.day.toString(),
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              letterSpacing: -0.08,
              color: isToday ? active : labelColor,
            ),
          ),
        ),
      ),
    );
  }

}



class _DayProgressPainter extends CustomPainter {
  final double progress;
  final Color color;

  _DayProgressPainter({
    required this.progress,
    required this.color,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final strokeWidth = 2.5;

    final rect = Offset.zero & size;

    final backgroundPaint = Paint()
      ..color = const Color(0xFF3C3C43).withValues(alpha: 0.12)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth;

    final progressPaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    // background track
    canvas.drawArc(
      rect.deflate(1),
      0,
      2 * 3.1416,
      false,
      backgroundPaint,
    );

    // progress arc
    canvas.drawArc(
      rect.deflate(1),
      -3.1416 / 2,
      2 * 3.1416 * progress,
      false,
      progressPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}