import '../../models/man_hour/man_hour.dart';

abstract class ManHourRepository {
  Future<bool> setManHour(List<ManHour> manHourList);
  Future<List<ManHour>> getManHourList();
  Future<bool> updateManHour(ManHour manHour);
  Future<bool> deleteManHour(List<ManHour> manHourList);
}
