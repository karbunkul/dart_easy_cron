import 'package:easy_cron/easy_cron.dart';
import 'package:test/test.dart';

void main() {
  final parser = UnixCronParser();

  test('Failure parse', () {
    // invalid cron time
    expect(() => parser.parse(''), throwsA(isA<AssertionError>()));
    // only 5 fields
    expect(() => parser.parse('* * * *'), throwsA(isA<AssertionError>()));
    expect(() => parser.parse('* * * * * *'), throwsA(isA<AssertionError>()));

    // invalid separator
    expect(() {
      return parser.parse(',2 ,3 ,1 ,1 ,5');
    }, throwsA(isA<AssertionError>()));

    // invalid range, syntax error
    expect(() {
      return parser.parse('*-10 *-4 *-2 *-1 *-3');
    }, throwsA(isA<ArgumentError>()));

    // invalid range, first > last
    expect(() {
      return parser.parse('12-10 4-2 2-1 5-2 3-1');
    }, throwsA(isA<AssertionError>()));
  });

  test('Successful parse', () {
    // every minute
    expect(
      parser.parse('* * * * *'),
      CronSchedule(
        minutes: {},
        hours: {},
        daysOfMonth: {},
        months: {},
        daysOfWeek: {},
      ),
    );

    // parse simple field
    expect(
      parser.parse('0 0 1 1 0'),
      CronSchedule(
        minutes: {0},
        hours: {0},
        daysOfMonth: {1},
        months: {1},
        daysOfWeek: {7},
      ),
    );

    // parse range and separator
    expect(
      parser.parse('0-5 0-3 2-5 9-11 4-5'),
      CronSchedule(
        minutes: {0, 1, 2, 3, 4, 5},
        hours: {0, 1, 2, 3},
        daysOfMonth: {2, 3, 4, 5},
        months: {9, 10, 11},
        daysOfWeek: {4, 5},
      ),
    );

    // parse range and separator
    expect(
      parser.parse('0-5,22 0-3,5 7,2-5 1,11,7-9 1-3,5-7'),
      CronSchedule(
        minutes: {0, 1, 2, 3, 4, 5, 22},
        hours: {0, 1, 2, 3, 5},
        daysOfMonth: {2, 3, 4, 5, 7},
        months: {1, 7, 8, 9, 11},
        daysOfWeek: {1, 2, 3, 5, 6, 7},
      ),
    );

    // parse range and separator
    expect(
      parser.parse('*/15 * */15 * *'),
      CronSchedule(
        minutes: {0, 15, 30, 45},
        hours: {},
        daysOfMonth: {1, 16, 31},
        months: {},
        daysOfWeek: {},
      ),
    );

    // parse range and separator
    expect(
      parser.parse('10-18/3 10-15/1 10-14/15 * 2-4/2'),
      CronSchedule(
        minutes: {10, 13, 16},
        hours: {10, 11, 12, 13, 14, 15},
        daysOfMonth: {10},
        months: {},
        daysOfWeek: {2, 4},
      ),
    );
  });
}
