import '../models/attendance.dart';

class AttendanceService {
  static final List<Attendance> _records = [];

  static void markAttendance() {
    _records.add(Attendance(time: DateTime.now()));
  }

  static List<Attendance> getRecords() {
    return _records;
  }
}
