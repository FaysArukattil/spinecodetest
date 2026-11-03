class UserEntity {
  final String id;
  final String email;
  final String role; // 'store' | 'shop'
  final String name;

  const UserEntity({
    required this.id,
    required this.email,
    required this.role,
    required this.name,
  });

  bool get isStore => role == 'store';
  bool get isShop => role == 'shop';
}
