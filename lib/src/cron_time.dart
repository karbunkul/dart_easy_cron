import 'package:easy_cron/easy_cron.dart';

class CronTime {
  final DateTime time;
  final CronSchedule schedule;

  CronTime({required this.time, required this.schedule});
}
