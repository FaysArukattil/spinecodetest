import '../entities/vegetable_entity.dart';
import '../repositories/vegetable_repository.dart';

class GetVegetablesUseCase {
  final VegetableRepository repository;
  const GetVegetablesUseCase(this.repository);
  Stream<List<VegetableEntity>> call() => repository.watchVegetables();
}
