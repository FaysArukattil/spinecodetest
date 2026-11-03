class StaffEntity {
  final String id;
  final String name;
  final String phone;
  final String role; // e.g. Manager, Staff, Delivery
  final List<String> permissions; // e.g. ['Vegetables', 'Orders', 'Shops', 'Reports']
  final String status; // 'Active' | 'Inactive'
  final DateTime createdAt;

  const StaffEntity({
    required this.id,
    required this.name,
    required this.phone,
    required this.role,
    required this.permissions,
    required this.status,
    required this.createdAt,
  });

  bool get isActive => status == 'Active';

  StaffEntity copyWith({
    String? name,
    String? phone,
    String? role,
    List<String>? permissions,
    String? status,
  }) =>
      StaffEntity(
        id: id,
        name: name ?? this.name,
        phone: phone ?? this.phone,
        role: role ?? this.role,
        permissions: permissions ?? this.permissions,
        status: status ?? this.status,
        createdAt: createdAt,
      );
}
