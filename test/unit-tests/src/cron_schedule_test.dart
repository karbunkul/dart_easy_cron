import 'package:easy_cron/easy_cron.dart';
import 'package:test/test.dart';

String report(DateTime date) {
  final year = date.year;
  final month = date.month.toString().padLeft(2, '0');
  final day = date.day.toString().padLeft(2, '0');
  final minute = date.minute.toString().padLeft(2, '0');
  final second = date.second.toString().padLeft(2, '0');
  final hour = date.hour.toString().padLeft(2, '0');

  return '$year-$month-$day $hour:$minute:$second';
}

CronSchedule schedule(String cron) {
  return UnixCronParser().parse(cron);
}

String next(String cron) {
  final startAt = DateTime(2022, 4, 4).toUtc().add(Duration(hours: 5));
  return report(schedule(cron).next(startAt).time);
}

String prev(String cron) {
  final startAt = DateTime(2022, 4, 4).toUtc().add(Duration(hours: 5));
  return report(schedule(cron).prev(startAt).time);
}

void complex(String cron) {
  final startAt = DateTime(2022, 4, 4);
  final next = schedule(cron).next(startAt);
  final prev = next.schedule.prev(next.time);
  final nextAtPrev = prev.schedule.next(prev.time);
  expect(report(next.time), equals(report(nextAtPrev.time)));
}

void main() {
  test('next method', () {
    expect(next('* * * * *'), equals('2022-04-04 00:01:00'));
    expect(next('0 0 * * 1'), equals('2022-04-11 00:00:00'));
    expect(next('0 0 1,15 * 3'), equals('2022-06-01 00:00:00'));
    expect(next('5 0 * 8 *'), equals('2022-08-01 00:05:00'));
    expect(next('0 22 * * 1-5'), equals('2022-04-05 22:00:00'));
    expect(next('23 0-20/2 * * *'), equals('2022-04-04 00:23:00'));
  });

  test('prev method', () {
    expect(prev('* * * * *'), equals('2022-04-03 23:59:00'));
    expect(prev('0 0 * * 1'), equals('2022-03-28 00:00:00'));
    expect(prev('0 0 1,15 * 3'), equals('2021-12-15 00:00:00'));
    expect(prev('5 0 * 8 *'), equals('2021-08-31 00:05:00'));
    expect(prev('0 22 * * 1-5'), equals('2022-04-01 22:00:00'));
    expect(prev('23 0-20/2 * * *'), equals('2022-04-03 20:23:00'));
  });

  test('complex test', () {
    complex('* * * * *');
    complex('0 0 * * 1');
    complex('0 0 1,15 * 3');
    complex('5 0 * AUG *');
    complex('1 * * * *');
    complex('* 1 * * *');
    complex('* * 1 * *');
    complex('* * * jan *');
    complex('* * * * MON');
    complex('0 22 * * 1-5');
    complex('23 0-20/2 * * *');
    complex('0 0,12 1 */2 *');
    complex('0 4 8-14 * *');
    complex('0 0 1,15 * 3');
    complex('15 14 1 * *');
    complex('0 22 * * 1-5');
    complex('23 0-20/2 * * *');
    complex('5 4 * * Sun');
    complex('0 0,12 1 */2 *');
    complex('0 4 8-14 * *');
    complex('0 0 1,15 * 3');
    complex('0 0 1,15 * *');
    complex('0 0 * * 1-5');
    complex('32 18 17,21,29 11 mon-wed');
    complex('0-5,22 0-3,5 7,2-5 1,11,7-9 1-3,5-6');
  });
}
