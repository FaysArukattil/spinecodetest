import '../entities/staff_entity.dart';
import '../repositories/staff_repository.dart';

class UpdateStaffUseCase {
  final StaffRepository repo;
  const UpdateStaffUseCase(this.repo);

  Future<void> call(StaffEntity staff) => repo.updateStaff(staff);
}
