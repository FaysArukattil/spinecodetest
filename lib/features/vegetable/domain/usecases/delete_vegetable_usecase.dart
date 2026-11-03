import '../repositories/vegetable_repository.dart';

class DeleteVegetableUseCase {
  final VegetableRepository repository;
  const DeleteVegetableUseCase(this.repository);
  Future<void> call(String id) => repository.deleteVegetable(id);
}
