import '../entities/staff_entity.dart';
import '../repositories/staff_repository.dart';

class AddStaffUseCase {
  final StaffRepository repo;
  const AddStaffUseCase(this.repo);

  Future<void> call(StaffEntity staff) => repo.addStaff(staff);
}
