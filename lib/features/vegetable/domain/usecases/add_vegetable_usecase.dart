import '../entities/vegetable_entity.dart';
import '../repositories/vegetable_repository.dart';

class AddVegetableUseCase {
  final VegetableRepository repository;
  const AddVegetableUseCase(this.repository);
  Future<void> call(VegetableEntity v) => repository.addVegetable(v);
}
