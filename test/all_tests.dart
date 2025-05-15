
import 'package:flutter_test/flutter_test.dart';
import 'unit/models/employee_test.dart' as employee_test;
import 'unit/models/employee_attendance_test.dart' as employee_attendance_test;
import 'unit/routes/route_test.dart' as route_test;
import 'unit/app/my_app_test.dart' as my_app_test;
import 'widget/connection_screen_test.dart' as connection_screen_test;

void main() {
  group('All Unit Tests', () {
    employee_test.main();
    employee_attendance_test.main();
    route_test.main();
    my_app_test.main();
  });

  group('All Widget Tests', () {
    connection_screen_test.main();
  });
}