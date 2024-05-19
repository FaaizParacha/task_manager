import 'package:matcher/matcher.dart';
import 'package:task_manager/models/task_model.dart';

class TaskMatcher extends Matcher {
  final Task expected;

  TaskMatcher(this.expected);

  @override
  Description describe(Description description) {
    return description.add('matches task $expected');
  }

  @override
  bool matches(item, Map matchState) {
    if (item is! Task) return false;
    return item.id == expected.id &&
        item.todo == expected.todo &&
        item.completed == expected.completed &&
        item.userId == expected.userId;
  }
}

Matcher equalsTask(Task task) => TaskMatcher(task);
