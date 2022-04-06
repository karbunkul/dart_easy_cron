import 'cron_schedule.dart';

abstract class CronParserInterface {
  CronSchedule parse(String cron);
}
