import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/shop_theme.dart';
import '../../../../core/utils/invoice_printer.dart';
import '../../../../core/utils/snackbar_helper.dart';
import '../../../../core/widgets/confirm_dialog.dart';
import '../../../../core/widgets/empty_state.dart';
import '../../domain/entities/order_entity.dart';
import '../providers/order_provider.dart';
import '../widgets/order_detail_body.dart';

class ShopOrderDetailPage extends StatelessWidget {
  final String orderId;
  const ShopOrderDetailPage({super.key, required this.orderId});

  Future<void> _cancel(BuildContext context, OrderEntity o) async {
    final p = context.read<OrderProvider>();
    final yes = await ConfirmDialog.show(
      context,
      title: 'Cancel Order',
      message: 'Are you sure you want to cancel this order?',
      confirmLabel: 'Yes, Cancel',
      cancelLabel: 'No',
    );
    if (!yes || !context.mounted) return;

    // The data layer re-checks the status, so a cancel is refused if the store
    // approved or rejected the order in the meantime.
    final err = await p.cancelOrder(o.id);
    if (!context.mounted) return;
    err == null
        ? SnackbarHelper.success(context, 'Order cancelled')
        : SnackbarHelper.error(context, err);
  }

  @override
  Widget build(BuildContext context) {
    final p = context.watch<OrderProvider>();
    final order = p.findById(orderId);

    return ShopTheme(
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Order Details', style: TextStyle(fontSize: 16)),
          actions: [
            if (order != null)
              IconButton(
                icon: const Icon(Icons.print_outlined),
                tooltip: 'Print Invoice',
                onPressed: () => InvoicePrinter.printInvoice(order),
              ),
          ],
        ),
        body: order == null
            ? const EmptyState(
                message: 'Order not found', icon: Icons.receipt_long_outlined)
            : ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  OrderDetailBody(order: order),
                  const SizedBox(height: 16),
                  _StatusNote(order.status),
                ],
              ),
        bottomNavigationBar: (order == null || !order.canCancel)
            ? null
            : SafeArea(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
                  child: OutlinedButton(
                    onPressed: p.isBusy ? null : () => _cancel(context, order),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.error,
                      side: const BorderSide(color: AppColors.error),
                    ),
                    child: p.isBusy
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Text('Cancel Order'),
                  ),
                ),
              ),
      ),
    );
  }
}

class _StatusNote extends StatelessWidget {
  final String status;
  const _StatusNote(this.status);

  @override
  Widget build(BuildContext context) {
    late final String text;
    late final Color color;
    switch (status) {
      case AppConstants.orderApproved:
        text = 'Your order has been approved. It can no longer be cancelled.';
        color = AppColors.accent;
      case AppConstants.orderRejected:
        text = 'Your order was rejected by the store.';
        color = AppColors.error;
      case AppConstants.orderCompleted:
        text = 'Your order has been completed.';
        color = AppColors.success;
      case AppConstants.orderCancelled:
        text = 'You cancelled this order.';
        color = AppColors.textSecondary;
      default:
        text = 'Your order is pending. The store will process it soon.';
        color = const Color(0xFFB7791F);
    }
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(text,
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 12, color: color)),
    );
  }
}
