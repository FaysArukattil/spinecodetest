import '../../../../core/constants/firestore_keys.dart';
import '../../domain/entities/user_entity.dart';

class UserModel extends UserEntity {
  const UserModel({
    required super.id,
    required super.email,
    required super.role,
    required super.name,
  });

  factory UserModel.fromMap(String id, Map<String, dynamic> map) => UserModel(
    id: id,
    email: (map[FirestoreKeys.email] ?? '') as String,
    role: (map[FirestoreKeys.role] ?? '') as String,
    name: (map[FirestoreKeys.name] ?? '') as String,
  );
}
