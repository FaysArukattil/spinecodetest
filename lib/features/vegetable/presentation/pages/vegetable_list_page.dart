import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/snackbar_helper.dart';
import '../../../../core/widgets/confirm_dialog.dart';
import '../../../../core/widgets/custom_button.dart';
import '../../../../core/widgets/empty_state.dart';
import '../../../../core/widgets/error_state.dart';
import '../../../../core/widgets/loading_indicator.dart';
import '../../domain/entities/vegetable_entity.dart';
import '../providers/vegetable_provider.dart';
import '../widgets/vegetable_card.dart';
import 'add_edit_vegetable_page.dart';

/// Store > Vegetables tab.
class VegetableListPage extends StatefulWidget {
  const VegetableListPage({super.key});
  @override
  State<VegetableListPage> createState() => _VegetableListPageState();
}

class _VegetableListPageState extends State<VegetableListPage> {
  bool _showAvailable = true;
  String _query = '';

  void _openForm([VegetableEntity? veg]) => Navigator.push(
    context,
    MaterialPageRoute(builder: (_) => AddEditVegetablePage(vegetable: veg)),
  );

  Future<void> _toggle(VegetableEntity v, bool makeAvailable) async {
    final p = context.read<VegetableProvider>();
    if (makeAvailable && v.stockQuantity <= 0) {
      SnackbarHelper.error(
        context,
        'Add stock to "${v.name}" before marking it available',
      );
      return;
    }
    final yes = await ConfirmDialog.show(
      context,
      title: makeAvailable ? 'Mark Available' : 'Mark Out of Stock',
      message:
          'Are you sure "${v.name}" is ${makeAvailable ? 'available' : 'out of stock'}?',
      color: makeAvailable ? AppColors.success : AppColors.error,
    );
    if (!yes || !mounted) return;
    final err = await p.setAvailability(v, makeAvailable);
    if (err != null && mounted) SnackbarHelper.error(context, err);
  }

  Future<void> _delete(VegetableEntity v) async {
    final p = context.read<VegetableProvider>();
    final yes = await ConfirmDialog.show(
      context,
      title: 'Delete Vegetable',
      message: 'Are you sure you want to delete "${v.name}"?',
      confirmLabel: 'Yes, Delete',
    );
    if (!yes || !mounted) return;
    final err = await p.delete(v.id);
    if (!mounted) return;
    err == null
        ? SnackbarHelper.success(context, 'Vegetable deleted')
        : SnackbarHelper.error(context, err);
  }

  @override
  Widget build(BuildContext context) {
    final p = context.watch<VegetableProvider>();
    final q = _query.trim().toLowerCase();
    final baseList = _showAvailable ? p.available : p.unavailable;
    final list = q.isEmpty
        ? baseList
        : baseList.where((v) => v.name.toLowerCase().contains(q)).toList();

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
              child: _Tabs(
                availableCount: p.available.length,
                unavailableCount: p.unavailable.length,
                showAvailable: _showAvailable,
                onChanged: (v) => setState(() => _showAvailable = v),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
              child: TextField(
                onChanged: (v) => setState(() => _query = v),
                decoration: const InputDecoration(
                  hintText: 'Search vegetables...',
                  prefixIcon: Icon(Icons.search, size: 20),
                  isDense: true,
                ),
              ),
            ),
            Expanded(child: _body(p, list)),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
              child: CustomButton(
                label: '+ Add New Vegetable',
                onPressed: () => _openForm(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _body(VegetableProvider p, List<VegetableEntity> list) {
    if (p.isLoading) return const LoadingIndicator();
    if (p.error != null) {
      return ErrorState(message: p.error!, onRetry: () => p.start(force: true));
    }
    if (list.isEmpty) {
      return EmptyState(
        message: _query.isNotEmpty
            ? 'No vegetables match "$_query"'
            : (_showAvailable
                  ? 'No available vegetables'
                  : 'No out of stock vegetables'),
        icon: Icons.eco_outlined,
      );
    }
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: list.length,
      separatorBuilder: (_, _) => const SizedBox(height: 12),
      itemBuilder: (_, i) => VegetableCard(
        veg: list[i],
        onEdit: () => _openForm(list[i]),
        onDelete: () => _delete(list[i]),
        onToggle: (v) => _toggle(list[i], v),
      ),
    );
  }
}

class _Tabs extends StatelessWidget {
  final int availableCount;
  final int unavailableCount;
  final bool showAvailable;
  final ValueChanged<bool> onChanged;

  const _Tabs({
    required this.availableCount,
    required this.unavailableCount,
    required this.showAvailable,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(4),
    decoration: BoxDecoration(
      color: AppColors.primary,
      borderRadius: BorderRadius.circular(10),
    ),
    child: Row(
      children: [
        _tab('Available $availableCount', showAvailable, () => onChanged(true)),
        _tab(
          'Out of Stock $unavailableCount',
          !showAvailable,
          () => onChanged(false),
        ),
      ],
    ),
  );

  Widget _tab(String label, bool selected, VoidCallback onTap) => Expanded(
    child: GestureDetector(
      onTap: onTap,
      child: Container(
        height: 34,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: selected ? Colors.white24 : Colors.transparent,
          border: Border.all(
            color: selected ? Colors.white : Colors.transparent,
          ),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          label,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    ),
  );
}
