import '../entities/staff_entity.dart';
import '../repositories/staff_repository.dart';

class GetStaffUseCase {
  final StaffRepository repo;
  const GetStaffUseCase(this.repo);

  Stream<List<StaffEntity>> call() => repo.getStaff();
}
