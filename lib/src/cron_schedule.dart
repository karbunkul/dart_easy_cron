import 'package:easy_cron/src/cron_time.dart';
import 'package:equatable/equatable.dart';

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

    // print(_date);

    while (true) {
      if (minutes != null && _minutes.contains(_date.minute) == false) {
        _date = _date.subtract(Duration(minutes: 1));
        continue;
      }

      if (hours != null && _hours.contains(_date.hour) == false) {
        _date = _date.subtract(Duration(hours: 1));
        continue;
      }

      if (daysOfMonth != null && _daysOfMonth.contains(_date.day) == false) {
        _date = _date.subtract(Duration(days: 1));
        continue;
      }

      if (daysOfWeek != null && _daysOfWeek.contains(_date.weekday) == false) {
        _date = _date.subtract(Duration(days: 1));
        // _date = DateTime(
        //   _date.year,
        //   _date.month,
        //   _date.day - 1,
        //   _date.hour,
        //   _date.minute,
        //   _date.second,
        // );
        continue;
      }

      if (months != null && _months.contains(_date.month) == false) {
        _date = _date.subtract(Duration(days: 1));
        // _date = DateTime(
        //   _date.year,
        //   _date.month - 1,
        //   _date.day,
        //   _date.hour,
        //   _date.minute,
        //   // _date.second,
        // );
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
      if (months != null && _months.contains(_date.month) == false) {
        _date = DateTime(_date.year, _date.month + 1, 1);
        continue;
      }

      if (daysOfWeek != null && _daysOfWeek.contains(_date.weekday) == false) {
        _date = DateTime(_date.year, _date.month, _date.day + 1);
        continue;
      }

      if (daysOfMonth != null && _daysOfMonth.contains(_date.day) == false) {
        _date = DateTime(
          _date.year,
          _date.month,
          _date.day + 1,
          _date.hour,
          _date.minute,
          _date.second,
        );
        continue;
      }

      if (hours != null && _hours.contains(_date.hour) == false) {
        _date = _date.add(Duration(hours: 1));
        continue;
      }

      if (minutes != null && _minutes.contains(_date.minute) == false) {
        _date = _date.add(Duration(minutes: 1));
        continue;
      }

      return CronTime(time: _date, schedule: this);
    }
  }
}
