import '../entities/vegetable_entity.dart';
import '../repositories/vegetable_repository.dart';

class UpdateVegetableUseCase {
  final VegetableRepository repository;
  const UpdateVegetableUseCase(this.repository);
  Future<void> call(VegetableEntity v) => repository.updateVegetable(v);
}
