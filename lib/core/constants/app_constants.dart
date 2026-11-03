class AppConstants {
  AppConstants._();
  static const appName = 'Vegetable Ordering';
  static const roleStore = 'store';
  static const roleShop = 'shop';

  static const unitKg = 'Kg';
  static const unitPiece = 'Piece';
  static const units = [unitKg, unitPiece];

  static const vegAvailable = 'Available';
  static const vegOutOfStock = 'Out of Stock';

  static const shopActive = 'Active';
  static const shopBlocked = 'Blocked';

  static const orderPending = 'Pending';
  static const orderApproved = 'Approved';
  static const orderRejected = 'Rejected';
  static const orderCancelled = 'Cancelled';
  static const orderStatuses = [
    orderPending,
    orderApproved,
    orderRejected,
    orderCancelled,
  ];
}
