import '../entities/staff_entity.dart';

abstract class StaffRepository {
  Stream<List<StaffEntity>> getStaff();
  Future<void> addStaff(StaffEntity staff);
  Future<void> updateStaff(StaffEntity staff);
  Future<void> deleteStaff(String id);
}
