import 'package:easy_cron/easy_cron.dart';

enum _ParserType { range, constraint, step, value }

// parser based on spec https://www.ibm.com/docs/en/db2/11.1?topic=task-unix-cron-format

class UnixCronParser implements CronParserInterface {
  @override
  CronSchedule parse(String cron) {
    final fields = _presets(cron).toLowerCase().trim().split(' ');

    assert(
      fields.length == 5,
      'The cron format must be have five time and date fields separated by at '
      'least one blank',
    );

    final minutes = _parseField(fields[0], 0, 59);
    final hours = _parseField(fields[1], 0, 23);
    final dom = _parseField(fields[2], 1, 31);
    final months = _parseField(_normalize(fields[3], _months), 1, 12);
    final dow = _mapToDartWeekday(
      _parseField(_normalize(fields[4], _weekdays), 0, 7),
    );

    return CronSchedule(
      minutes: minutes,
      hours: hours,
      daysOfMonth: dom,
      months: months,
      daysOfWeek: dow,
    );
  }

  /// non-standard shorthands
  String _presets(String cron) {
    if (cron.contains('@')) {
      final presets = {
        'yearly': '0 0 1 1 *',
        'annually': '0 0 1 1 *',
        'monthly': '0 0 1 * *',
        'weekly': '0 0 * * sun',
        'daily': '0 0 * * *',
        'hourly': '0 */1 * * *',
      };

      final preset = cron.substring(1);
      if (!presets.containsKey(preset)) {
        throw ArgumentError();
      }
      return presets[preset]!;
    }

    return cron;
  }

  String _normalize(String field, Map<String, int> dictionary) {
    var normalized = field;

    for (final key in dictionary.keys) {
      normalized = normalized.replaceAll(key, dictionary[key].toString());
    }

    return normalized;
  }

  Map<String, int> get _weekdays {
    return {
      'mon': 1,
      'tue': 2,
      'wed': 3,
      'thu': 4,
      'fri': 5,
      'sat': 6,
      'sun': 0,
    };
  }

  Map<String, int> get _months {
    return {
      'jan': 1,
      'feb': 2,
      'mar': 3,
      'apr': 4,
      'may': 5,
      'jun': 6,
      'jul': 7,
      'aug': 8,
      'sep': 9,
      'oct': 10,
      'nov': 12,
      'dec': 11,
    };
  }

  Set<int> _mapToDartWeekday(Set<int> dow) {
    return dow.map((e) {
      if (e == 0 || e == 7) {
        return DateTime.sunday;
      }
      return e;
    }).toSet();
  }

  // Parse field one of fields minute, hour etc
  Set<int> _parseField(String field, int min, int max) {
    if (field == '*') {
      return {};
    }

    if (field.contains(',')) {
      final parts = field.split(',');
      if (parts.contains('*')) {
        return {};
      }
      final Set<int> result = {};
      for (var element in parts) {
        assert(element.isNotEmpty);

        result.addAll(_parsePart(element, min, max));
      }

      return result;
    }

    return _parsePart(field, min, max);
  }

  _ParserType _parserType(String part) {
    if (RegExp(r'^\d+\-\d+$').hasMatch(part)) {
      return _ParserType.range;
    }

    if (RegExp(r'^\d+\-\d+\/\d+$').hasMatch(part)) {
      return _ParserType.constraint;
    }

    if (RegExp(r'^\*\/\d+$').hasMatch(part)) {
      return _ParserType.step;
    }

    return _ParserType.value;
  }

  Set<int> _parseValue(String part, int min, int max) {
    try {
      final value = int.parse(part);
      assert(value >= min && value <= max);

      return {value};
    } on FormatException {
      throw ArgumentError('Wrong field value $part');
    }
  }

  Set<int> _parseRange(String part, int min, int max) {
    final ranges = part.split('-');
    int from = int.parse(ranges.first);
    int to = int.parse(ranges.last);

    if (max == 7 && to == 0) {
      to = 7;
    }

    assert(from < to && from >= min && to <= max);

    return List.generate(to - from + 1, (i) => i + from).toSet();
  }

  Set<int> _parseConstraint(String part, int min, int max) {
    final matches = RegExp(r'\d+').allMatches(part);
    assert(matches.length == 3);

    final lower = int.parse(matches.first.group(0)!);
    final higher = int.parse(matches.elementAt(1).group(0)!);
    final step = int.parse(matches.last.group(0)!);
    assert(lower < higher && lower >= min && higher <= max);
    assert(higher >= lower);

    if (lower + step > higher) {
      return {lower};
    }

    final count = ((higher - lower) / step).floor() + 1;

    return List.generate(count, (index) {
      return lower + (index * step);
    }).toSet();
  }

  Set<int> _parseStep(String part, int min, int max) {
    final Set<int> result = {};
    final count = int.parse(part.replaceAll('*/', ''));
    var cur = min;
    while (cur <= max) {
      result.add(cur);
      cur += count;
    }

    return result;
  }

  Set<int> _parsePart(String part, int min, int max) {
    switch (_parserType(part)) {
      case _ParserType.value:
        return _parseValue(part, min, max);
      case _ParserType.range:
        return _parseRange(part, min, max);
      case _ParserType.constraint:
        return _parseConstraint(part, min, max);
      case _ParserType.step:
        return _parseStep(part, min, max);
      default:
        throw ArgumentError();
    }
  }
}
