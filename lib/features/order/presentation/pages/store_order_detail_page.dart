import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/snackbar_helper.dart';
import '../../../../core/widgets/confirm_dialog.dart';
import '../../../../core/widgets/custom_button.dart';
import '../../../../core/widgets/empty_state.dart';
import '../../domain/entities/order_entity.dart';
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
      child = Row(children: [
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
        const SizedBox(width: 12),
        Expanded(
          child: OutlinedButton(
            onPressed: busy ? null : () => _update(context, o, AppConstants.orderApproved),
            child: const Text('Approve'),
          ),
        ),
      ]);
    } else if (o.status == AppConstants.orderApproved) {
      child = CustomButton(
        label: 'Mark as Completed',
        isLoading: busy,
        onPressed: () => _update(context, o, AppConstants.orderCompleted),
      );
    }
    if (child == null) return null;
    return SafeArea(
      child: Padding(padding: const EdgeInsets.fromLTRB(16, 8, 16, 12), child: child),
    );
  }
}
