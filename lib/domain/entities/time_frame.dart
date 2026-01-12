enum TimeFrame {
  m1(1, 'minute', '1m'),
  m5(5, 'minute', '5m'),
  m15(15, 'minute', '15m'),
  h1(1, 'hour', '1H'),
  h4(4, 'hour', '4H'),
  d1(1, 'day', '1D'),
  w1(1, 'week', '1W');

  final int multiplier;
  final String span;
  final String displayName;

  const TimeFrame(this.multiplier, this.span, this.displayName);

  Duration get duration {
    switch (this) {
      case TimeFrame.m1:
        return const Duration(minutes: 1);
      case TimeFrame.m5:
        return const Duration(minutes: 5);
      case TimeFrame.m15:
        return const Duration(minutes: 15);
      case TimeFrame.h1:
        return const Duration(hours: 1);
      case TimeFrame.h4:
        return const Duration(hours: 4);
      case TimeFrame.d1:
        return const Duration(days: 1);
      case TimeFrame.w1:
        return const Duration(days: 7);
    }
  }

  int get defaultLookbackDays {
    switch (this) {
      case TimeFrame.m1:
        return 1;
      case TimeFrame.m5:
        return 5;
      case TimeFrame.m15:
        return 10;
      case TimeFrame.h1:
        return 30;
      case TimeFrame.h4:
        return 60;
      case TimeFrame.d1:
        return 365;
      case TimeFrame.w1:
        return 730;
    }
  }
}
