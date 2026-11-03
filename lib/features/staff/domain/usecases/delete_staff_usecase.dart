import '../repositories/staff_repository.dart';

class DeleteStaffUseCase {
  final StaffRepository repo;
  const DeleteStaffUseCase(this.repo);

  Future<void> call(String id) => repo.deleteStaff(id);
}
