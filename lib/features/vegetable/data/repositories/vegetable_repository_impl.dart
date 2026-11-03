import '../../domain/entities/vegetable_entity.dart';
import '../../domain/repositories/vegetable_repository.dart';
import '../datasources/vegetable_remote_datasource.dart';
import '../models/vegetable_model.dart';

class VegetableRepositoryImpl implements VegetableRepository {
  final VegetableRemoteDataSource remote;
  const VegetableRepositoryImpl(this.remote);

  @override
  Stream<List<VegetableEntity>> watchVegetables() => remote.watchAll();

  @override
  Future<void> addVegetable(VegetableEntity v) =>
      remote.add(VegetableModel.fromEntity(v));

  @override
  Future<void> updateVegetable(VegetableEntity v) =>
      remote.update(VegetableModel.fromEntity(v));

  @override
  Future<void> deleteVegetable(String id) => remote.delete(id);
}
