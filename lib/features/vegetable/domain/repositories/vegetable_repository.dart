import '../entities/vegetable_entity.dart';

abstract class VegetableRepository {
  Stream<List<VegetableEntity>> watchVegetables();
  Future<void> addVegetable(VegetableEntity v);
  Future<void> updateVegetable(VegetableEntity v);
  Future<void> deleteVegetable(String id);
}
