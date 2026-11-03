import '../../domain/entities/staff_entity.dart';
import '../../domain/repositories/staff_repository.dart';
import '../datasources/staff_remote_datasource.dart';
import '../models/staff_model.dart';

class StaffRepositoryImpl implements StaffRepository {
  final StaffRemoteDataSource remote;
  const StaffRepositoryImpl(this.remote);

  @override
  Stream<List<StaffEntity>> getStaff() => remote.watchAll();

  @override
  Future<void> addStaff(StaffEntity staff) =>
      remote.add(StaffModel.fromEntity(staff));

  @override
  Future<void> updateStaff(StaffEntity staff) =>
      remote.update(StaffModel.fromEntity(staff));

  @override
  Future<void> deleteStaff(String id) => remote.delete(id);
}
