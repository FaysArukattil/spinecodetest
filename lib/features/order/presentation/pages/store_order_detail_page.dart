import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/date_formatter.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/utils/snackbar_helper.dart';
import '../../../../core/widgets/confirm_dialog.dart';
import '../../../../core/widgets/custom_button.dart';
import '../../../../core/widgets/empty_state.dart';
import '../../domain/entities/order_entity.dart';
import '../../domain/entities/order_item_entity.dart';
import '../providers/order_provider.dart';
import '../widgets/order_detail_body.dart';

class StoreOrderDetailPage extends StatelessWidget {
  final String orderId;
  const StoreOrderDetailPage({super.key, required this.orderId});

  static const _verbs = {
    AppConstants.orderApproved: 'Approve',
    AppConstants.orderRejected: 'Reject',
    AppConstants.orderCompleted: 'Complete',
  };

  Future<void> _update(BuildContext context, OrderEntity o, String status) async {
    final p = context.read<OrderProvider>();
    final verb = _verbs[status] ?? 'Update';
    final color = status == AppConstants.orderRejected
        ? AppColors.error
        : status == AppConstants.orderApproved
            ? AppColors.success
            : AppColors.primary;

    final yes = await ConfirmDialog.show(
      context,
      title: '$verb Order',
      message: 'Are you sure you want to ${verb.toLowerCase()} order ${o.displayId}?',
      confirmLabel: 'Yes, $verb',
      color: color,
    );
    if (!yes || !context.mounted) return;

    final err = await p.updateStatus(o.id, status);
    if (!context.mounted) return;
    err == null
        ? SnackbarHelper.success(context, 'Order ${status.toLowerCase()}')
        : SnackbarHelper.error(context, err);
  }

  @override
  Widget build(BuildContext context) {
    final p = context.watch<OrderProvider>();
    final order = p.findById(orderId);

    return Scaffold(
      appBar: AppBar(title: const Text('Order Details', style: TextStyle(fontSize: 16))),
      body: order == null
          ? const EmptyState(message: 'Order not found', icon: Icons.receipt_long_outlined)
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [OrderDetailBody(order: order)],
            ),
      bottomNavigationBar: order == null ? null : _actions(context, order, p.isBusy),
    );
  }

  Widget? _actions(BuildContext context, OrderEntity o, bool busy) {
    Widget? child;
    if (o.status == AppConstants.orderPending) {
      child = Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(children: [
            Expanded(
              child: OutlinedButton.icon(
                icon: const Icon(Icons.edit_outlined, size: 16),
                label: const Text('Edit Order'),
                onPressed: busy ? null : () => _editOrderQuantities(context, o),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: OutlinedButton(
                onPressed: busy ? null : () => _update(context, o, AppConstants.orderRejected),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.error,
                  side: const BorderSide(color: AppColors.error),
                ),
                child: const Text('Reject Order'),
              ),
            ),
          ]),
          const SizedBox(height: 8),
          CustomButton(
            label: 'Approve',
            isLoading: busy,
            onPressed: () => _update(context, o, AppConstants.orderApproved),
          ),
        ],
      );
    } else if (o.status == AppConstants.orderApproved) {
      child = CustomButton(
        label: 'Mark as Completed',
        isLoading: busy,
        onPressed: () => _update(context, o, AppConstants.orderCompleted),
      );
    } else if (o.status == AppConstants.orderCompleted) {
      child = OutlinedButton.icon(
        icon: const Icon(Icons.print_outlined, size: 18),
        label: const Text('Print Invoice'),
        onPressed: () => _printInvoice(context, o),
      );
    }
    if (child == null) return null;
    return SafeArea(
      child: Padding(padding: const EdgeInsets.fromLTRB(16, 8, 16, 12), child: child),
    );
  }

  void _printInvoice(BuildContext context, OrderEntity o) {
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.receipt_long, color: AppColors.primary),
            SizedBox(width: 8),
            Text('Invoice Preview', style: TextStyle(fontSize: 16)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Order ID: ${o.displayId}',
                style: const TextStyle(fontWeight: FontWeight.w700)),
            Text('Shop: ${o.shopName}'),
            Text('Date: ${DateFormatter.compact(o.createdAt)}'),
            const Divider(height: 16),
            for (final i in o.items)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 2),
                child: Row(
                  children: [
                    Expanded(child: Text(i.name, style: const TextStyle(fontSize: 12))),
                    Text(
                        '${Formatters.qty(i.quantity)} ${i.unit} - ${Formatters.money(i.lineTotal)}',
                        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                  ],
                ),
              ),
            const Divider(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Total Amount', style: TextStyle(fontWeight: FontWeight.w700)),
                Text(Formatters.money(o.totalAmount),
                    style: const TextStyle(fontWeight: FontWeight.w700, color: AppColors.primary)),
              ],
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Close'),
          ),
          ElevatedButton.icon(
            icon: const Icon(Icons.print, size: 16),
            label: const Text('Print'),
            onPressed: () {
              Navigator.pop(ctx);
              SnackbarHelper.success(context, 'Invoice printed successfully');
            },
          ),
        ],
      ),
    );
  }

  void _editOrderQuantities(BuildContext context, OrderEntity o) {
    final quantities = {for (final item in o.items) item.vegetableId: item.quantity};

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (sheetCtx) => StatefulBuilder(
        builder: (ctx, setModalState) {
          return Padding(
            padding: EdgeInsets.only(
              left: 16,
              right: 16,
              top: 16,
              bottom: MediaQuery.of(ctx).viewInsets.bottom + 16,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Edit Order Quantities',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.pop(ctx),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                for (final item in o.items)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 6),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(item.name,
                                  style: const TextStyle(
                                      fontSize: 13, fontWeight: FontWeight.w600)),
                              Text(
                                '${Formatters.money(item.price)} / ${item.unit}',
                                style: const TextStyle(
                                    fontSize: 11, color: AppColors.textSecondary),
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.remove_circle_outline, size: 20),
                          onPressed: (quantities[item.vegetableId] ?? 0) <= 0
                              ? null
                              : () {
                                  setModalState(() {
                                    final current = quantities[item.vegetableId] ?? 0;
                                    quantities[item.vegetableId] =
                                        (current - 1).clamp(0, 9999);
                                  });
                                },
                        ),
                        Text(
                          '${Formatters.qty(quantities[item.vegetableId] ?? 0)} ${item.unit}',
                          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
                        ),
                        IconButton(
                          icon: const Icon(Icons.add_circle_outline, size: 20),
                          onPressed: () {
                            setModalState(() {
                              final current = quantities[item.vegetableId] ?? 0;
                              quantities[item.vegetableId] = current + 1;
                            });
                          },
                        ),
                      ],
                    ),
                  ),
                const SizedBox(height: 16),
                CustomButton(
                  label: 'Save Changes',
                  onPressed: () async {
                    final updated = o.items.map((i) {
                      final newQty = quantities[i.vegetableId] ?? i.quantity;
                      return OrderItemEntity(
                        vegetableId: i.vegetableId,
                        name: i.name,
                        unit: i.unit,
                        price: i.price,
                        quantity: newQty,
                      );
                    }).toList();

                    Navigator.pop(ctx);
                    final err = await context
                        .read<OrderProvider>()
                        .updateOrderItems(o.id, updated);
                    if (context.mounted) {
                      err == null
                          ? SnackbarHelper.success(context, 'Order updated successfully')
                          : SnackbarHelper.error(context, err);
                    }
                  },
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
