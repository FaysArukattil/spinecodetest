import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../core/constants/firestore_keys.dart';
import '../../domain/entities/staff_entity.dart';

class StaffModel extends StaffEntity {
  const StaffModel({
    required super.id,
    required super.name,
    required super.phone,
    required super.role,
    required super.permissions,
    required super.status,
    required super.createdAt,
  });

  factory StaffModel.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final d = doc.data() ?? {};
    final rawPerms = d['permissions'];
    final perms = rawPerms is List ? rawPerms.map((e) => e.toString()).toList() : <String>[];
    return StaffModel(
      id: doc.id,
      name: (d[FirestoreKeys.name] ?? '') as String,
      phone: (d[FirestoreKeys.phone] ?? '') as String,
      role: (d['role'] ?? 'Staff') as String,
      permissions: perms,
      status: (d[FirestoreKeys.status] ?? 'Active') as String,
      createdAt: (d[FirestoreKeys.createdAt] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  factory StaffModel.fromEntity(StaffEntity e) => StaffModel(
        id: e.id,
        name: e.name,
        phone: e.phone,
        role: e.role,
        permissions: e.permissions,
        status: e.status,
        createdAt: e.createdAt,
      );

  Map<String, dynamic> toMap() => {
        FirestoreKeys.name: name,
        FirestoreKeys.phone: phone,
        'role': role,
        'permissions': permissions,
        FirestoreKeys.status: status,
        FirestoreKeys.createdAt: Timestamp.fromDate(createdAt),
      };
}
