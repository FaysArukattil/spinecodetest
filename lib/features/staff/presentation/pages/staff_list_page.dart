import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/theme/shop_theme.dart';
import '../../../../core/utils/snackbar_helper.dart';
import '../../../../core/widgets/confirm_dialog.dart';
import '../../../../core/widgets/custom_button.dart';
import '../../../../core/widgets/empty_state.dart';
import '../../../../core/widgets/error_state.dart';
import '../../../../core/widgets/loading_indicator.dart';
import '../../domain/entities/staff_entity.dart';
import '../providers/staff_provider.dart';
import '../widgets/staff_card.dart';
import 'add_edit_staff_page.dart';

class StaffListPage extends StatefulWidget {
  final bool isShop;
  const StaffListPage({super.key, this.isShop = false});

  @override
  State<StaffListPage> createState() => _StaffListPageState();
}

class _StaffListPageState extends State<StaffListPage> {
  String _query = '';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) context.read<StaffProvider>().start();
    });
  }

  void _openForm([StaffEntity? staff]) => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => AddEditStaffPage(staff: staff, isShop: widget.isShop),
        ),
      );

  Future<void> _delete(StaffEntity staff) async {
    final p = context.read<StaffProvider>();
    final yes = await ConfirmDialog.show(
      context,
      title: 'Delete Staff',
      message: 'Are you sure you want to remove "${staff.name}"?',
      confirmLabel: 'Yes, Delete',
    );
    if (!yes || !mounted) return;
    final err = await p.delete(staff.id);
    if (!mounted) return;
    err == null
        ? SnackbarHelper.success(context, 'Staff removed')
        : SnackbarHelper.error(context, err);
  }

  @override
  Widget build(BuildContext context) {
    final p = context.watch<StaffProvider>();
    final q = _query.trim().toLowerCase();
    final list = q.isEmpty
        ? p.staffList
        : p.staffList
            .where((s) =>
                s.name.toLowerCase().contains(q) ||
                s.phone.contains(q) ||
                s.role.toLowerCase().contains(q))
            .toList();

    final scaffold = Scaffold(
      appBar: AppBar(title: const Text('Staff Management', style: TextStyle(fontSize: 16))),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
            child: TextField(
              onChanged: (v) => setState(() => _query = v),
              decoration: const InputDecoration(
                hintText: 'Search staff by name, phone, role...',
                prefixIcon: Icon(Icons.search, size: 20),
                isDense: true,
              ),
            ),
          ),
          Expanded(child: _body(p, list)),
          SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
              child: CustomButton(
                label: '+ Add New Staff',
                onPressed: () => _openForm(),
              ),
            ),
          ),
        ],
      ),
    );
    return widget.isShop ? ShopTheme(child: scaffold) : scaffold;
  }

  Widget _body(StaffProvider p, List<StaffEntity> list) {
    if (p.isLoading) return const LoadingIndicator();
    if (p.error != null) {
      return ErrorState(message: p.error!, onRetry: () => p.start(force: true));
    }
    if (list.isEmpty) {
      return EmptyState(
        message: _query.isNotEmpty
            ? 'No staff members match "$_query"'
            : 'No staff added yet.',
        icon: Icons.people_outline,
      );
    }
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: list.length,
      separatorBuilder: (_, _) => const SizedBox(height: 12),
      itemBuilder: (_, i) => StaffCard(
        index: i + 1,
        staff: list[i],
        onEdit: () => _openForm(list[i]),
        onDelete: () => _delete(list[i]),
      ),
    );
  }
}
