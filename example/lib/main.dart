import 'package:easy_cron/easy_cron.dart';

void main() {
// create parser instance
  final parser = UnixCronParser();

// parse cron time to CronSchedule
  final schedule = parser.parse('* * * * *');

// next time
  final nextTime = schedule.next();
  print(nextTime.time);

// previous time
  final prevTime = schedule.prev();
  print(prevTime.time);
}
