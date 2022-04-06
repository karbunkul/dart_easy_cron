Parse cron string to schedule and generate previous or next schedule item

## Parsers ##

**UnixCronParser** - implementation unix cron, see [https://www.ibm.com/docs/en/db2/11.1?topic=task-unix-cron-format](https://www.ibm.com/docs/en/db2/11.1?topic=task-unix-cron-format)

## Usage: ##

```dart

// import library
import 'package:easy_cron/easy_cron.dart';

// create parser instance
final parser = UnixCronParser();

// parse cron time to CronSchedule
final schedule = parser.parse('* * * * *');

// next time
final nextTime = schedule.next();

// previous time
final prevTime = schedule.prev();
```
