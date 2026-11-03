class AppConstants {
  AppConstants._();
  static const appName = 'Plantlets';
  static const roleStore = 'store';
  static const roleShop = 'shop';

  static const units = ['Kg', 'Piece', 'Box', 'Bag', 'Packet'];

  static const vegAvailable = 'Available';
  static const vegOutOfStock = 'Out of Stock';

  static const shopActive = 'Active';
  static const shopBlocked = 'Blocked';

  static const orderPending = 'Pending';
  static const orderApproved = 'Approved';
  static const orderRejected = 'Rejected';
  static const orderCompleted = 'Completed';
  static const orderCancelled = 'Cancelled';
  static const orderStatuses = [
    orderPending,
    orderApproved,
    orderRejected,
    orderCompleted,
    orderCancelled,
  ];
}
