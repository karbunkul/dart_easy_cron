import 'package:easy_cron/src/cron_time.dart';
import 'package:equatable/equatable.dart';

enum _DateTimeSegment { year, month, day, hour, minute, second }

class CronSchedule extends Equatable {
  final Set<int>? seconds;
  final Set<int>? minutes;
  final Set<int>? hours;
  final Set<int>? daysOfMonth;
  final Set<int>? months;
  final Set<int>? daysOfWeek;
  final Set<int>? years;

  CronSchedule({
    this.seconds,
    this.minutes,
    this.hours,
    this.daysOfMonth,
    this.months,
    this.daysOfWeek,
    this.years,
  });

  @override
  bool get stringify => true;

  @override
  List<Object?> get props {
    return [
      seconds,
      minutes,
      hours,
      daysOfMonth,
      months,
      daysOfWeek,
      years,
    ];
  }

  // default start time
  DateTime _defaultDateTime([DateTime? startAt]) {
    if (startAt != null) {
      return startAt;
    }

    final now = DateTime.now();
    return DateTime(
      now.year,
      now.month,
      now.day,
      now.hour,
      now.minute,
      now.second,
    );
  }

  Set<int> _defaultSet(int min, int max) {
    final set = List.generate(max - min, (index) => min + index + 1).toSet();
    return {min, ...set};
  }

  // ignore: unused_element
  Set<int> get _seconds {
    return seconds?.isNotEmpty == true ? seconds! : _defaultSet(0, 59);
  }

  Set<int> get _minutes {
    return minutes?.isNotEmpty == true ? minutes! : _defaultSet(0, 59);
  }

  Set<int> get _hours {
    return hours?.isNotEmpty == true ? hours! : _defaultSet(0, 23);
  }

  Set<int> get _daysOfMonth {
    return daysOfMonth?.isNotEmpty == true ? daysOfMonth! : _defaultSet(1, 31);
  }

  Set<int> get _months {
    return months?.isNotEmpty == true ? months! : _defaultSet(1, 12);
  }

  Set<int> get _daysOfWeek {
    return daysOfWeek?.isNotEmpty == true ? daysOfWeek! : _defaultSet(1, 7);
  }

  CronTime prev([DateTime? startAt]) {
    var _date = _defaultDateTime(startAt);

    if (seconds?.isNotEmpty == true) {
      _date = _date.subtract(Duration(seconds: 1));
    } else {
      _date = _date.subtract(Duration(minutes: 1));
    }

    while (true) {
      if (minutes?.isNotEmpty == true &&
          _minutes.contains(_date.minute) == false) {
        _date = _dec(_date, _DateTimeSegment.minute);
        continue;
      }

      if (hours?.isNotEmpty == true && _hours.contains(_date.hour) == false) {
        _date = _dec(_date, _DateTimeSegment.hour);
        continue;
      }

      if (daysOfMonth?.isNotEmpty == true &&
          _daysOfMonth.contains(_date.day) == false) {
        _date = _dec(_date, _DateTimeSegment.day);
        continue;
      }

      if (daysOfWeek?.isNotEmpty == true &&
          _daysOfWeek.contains(_date.weekday) == false) {
        _date = _dec(_date, _DateTimeSegment.day);
        continue;
      }

      if (months?.isNotEmpty == true &&
          _months.contains(_date.month) == false) {
        _date = _dec(_date, _DateTimeSegment.day);
        continue;
      }

      return CronTime(time: _date, schedule: this);
    }
  }

  CronTime next([DateTime? startAt]) {
    var _date = _defaultDateTime(startAt);

    if (seconds?.isNotEmpty == true) {
      _date = _date.add(Duration(seconds: 1));
    } else {
      _date = _date.add(Duration(minutes: 1));
    }

    while (true) {
      if (months?.isNotEmpty == true &&
          _months.contains(_date.month) == false) {
        _date = _inc(_date, _DateTimeSegment.month);
        continue;
      }

      if (daysOfWeek?.isNotEmpty == true &&
          _daysOfWeek.contains(_date.weekday) == false) {
        _date = _inc(_date, _DateTimeSegment.day);
        continue;
      }

      if (daysOfMonth?.isNotEmpty == true &&
          _daysOfMonth.contains(_date.day) == false) {
        _date = _inc(_date, _DateTimeSegment.day);
        continue;
      }

      if (hours?.isNotEmpty == true && _hours.contains(_date.hour) == false) {
        _date = _inc(_date, _DateTimeSegment.hour);
        continue;
      }

      if (minutes?.isNotEmpty == true &&
          _minutes.contains(_date.minute) == false) {
        _date = _inc(_date, _DateTimeSegment.minute);
        continue;
      }

      return CronTime(time: _date, schedule: this);
    }
  }

  DateTime _inc(DateTime date, _DateTimeSegment segment) {
    switch (segment) {
      case _DateTimeSegment.year:
        return DateTime(date.year + 1);
      case _DateTimeSegment.month:
        return DateTime(date.year, date.month + 1);
      case _DateTimeSegment.day:
        return DateTime(
          date.year,
          date.month,
          date.day + 1,
        );
      case _DateTimeSegment.hour:
        return DateTime(
          date.year,
          date.month,
          date.day,
          date.hour + 1,
        );
      case _DateTimeSegment.minute:
        return DateTime(
          date.year,
          date.month,
          date.day,
          date.hour,
          date.minute + 1,
        );
      case _DateTimeSegment.second:
        return DateTime(
          date.year,
          date.month,
          date.day,
          date.hour,
          date.minute,
          date.second + 1,
        );
    }
  }

  DateTime _dec(DateTime date, _DateTimeSegment segment) {
    switch (segment) {
      case _DateTimeSegment.year:
        return DateTime(date.year - 1);
      case _DateTimeSegment.month:
        return date.subtract(Duration(days: 1));
      case _DateTimeSegment.day:
        return date.subtract(Duration(days: 1));
      case _DateTimeSegment.hour:
        return date.subtract(Duration(hours: 1));
      case _DateTimeSegment.minute:
        return date.subtract(Duration(minutes: 1));
      case _DateTimeSegment.second:
        return date.subtract(Duration(seconds: 1));
    }
  }
}
