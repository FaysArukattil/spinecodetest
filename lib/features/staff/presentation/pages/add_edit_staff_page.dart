import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/theme/shop_theme.dart';
import '../../../../core/utils/snackbar_helper.dart';
import '../../../../core/utils/validators.dart';
import '../../../../core/widgets/custom_button.dart';
import '../../../../core/widgets/custom_text_field.dart';
import '../../domain/entities/staff_entity.dart';
import '../providers/staff_provider.dart';

class AddEditStaffPage extends StatefulWidget {
  final StaffEntity? staff;
  final bool isShop;
  const AddEditStaffPage({super.key, this.staff, this.isShop = false});

  @override
  State<AddEditStaffPage> createState() => _AddEditStaffPageState();
}

class _AddEditStaffPageState extends State<AddEditStaffPage> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _name;
  late final TextEditingController _phone;
  late String _role;
  late List<String> _permissions;

  bool get _isEdit => widget.staff != null;

  @override
  void initState() {
    super.initState();
    final s = widget.staff;
    _name = TextEditingController(text: s?.name ?? '');
    _phone = TextEditingController(text: s?.phone ?? '');
    _role = s?.role ?? AppConstants.staffRoles.first;
    _permissions = List<String>.from(s?.permissions ?? AppConstants.staffPermissions.take(2));
  }

  @override
  void dispose() {
    _name.dispose();
    _phone.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    FocusScope.of(context).unfocus();
    final p = context.read<StaffProvider>();
    final old = widget.staff;

    final staff = StaffEntity(
      id: old?.id ?? '',
      name: _name.text.trim(),
      phone: _phone.text.trim(),
      role: _role,
      permissions: _permissions,
      status: old?.status ?? 'Active',
      createdAt: old?.createdAt ?? DateTime.now(),
    );

    final err = await p.save(staff);
    if (!mounted) return;
    if (err != null) {
      SnackbarHelper.error(context, err);
      return;
    }

    if (!_isEdit) {
      // Show "Added New Staff" success dialog (Figma)
      await showDialog<void>(
        context: context,
        builder: (ctx) => Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const CircleAvatar(
                  radius: 28,
                  backgroundColor: AppColors.successLight,
                  child: Icon(Icons.check, color: AppColors.success, size: 32),
                ),
                const SizedBox(height: 16),
                Text('Added New Staff', style: AppTextStyles.h2),
                const SizedBox(height: 6),
                Text(
                  '${staff.name} has been successfully added as a ${staff.role}.',
                  textAlign: TextAlign.center,
                  style: AppTextStyles.caption,
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(ctx),
                    child: const Text('Done'),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    } else {
      SnackbarHelper.success(context, 'Staff details updated');
    }

    if (!mounted) return;
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final saving = context.select<StaffProvider, bool>((p) => p.isSaving);

    final scaffold = Scaffold(
      appBar: AppBar(
        title: Text(_isEdit ? 'Edit Staff Details' : 'Add New Staff',
            style: const TextStyle(fontSize: 16)),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            CustomTextField(
              controller: _name,
              label: 'Staff Name *',
              hint: 'Enter full name',
              validator: (v) => Validators.name(v, 'Staff name'),
            ),
            const SizedBox(height: 14),
            CustomTextField(
              controller: _phone,
              label: 'Mobile Number *',
              hint: 'Enter 10-digit mobile number',
              keyboardType: TextInputType.phone,
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
                LengthLimitingTextInputFormatter(10),
              ],
              validator: Validators.phone,
            ),
            const SizedBox(height: 16),
            const Text('Role *', style: TextStyle(fontSize: 12)),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: AppColors.border),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: _role,
                  isExpanded: true,
                  items: AppConstants.staffRoles
                      .map((r) => DropdownMenuItem(value: r, child: Text(r)))
                      .toList(),
                  onChanged: (v) => setState(() => _role = v ?? _role),
                ),
              ),
            ),
            const SizedBox(height: 20),
            const Text('Available Access *', style: TextStyle(fontSize: 12)),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: AppConstants.staffPermissions.map((perm) {
                final selected = _permissions.contains(perm);
                return FilterChip(
                  label: Text(perm),
                  selected: selected,
                  showCheckmark: false,
                  selectedColor: AppColors.primary,
                  backgroundColor: AppColors.surfaceAlt,
                  labelStyle: TextStyle(
                    color: selected ? Colors.white : AppColors.textPrimary,
                    fontSize: 12,
                    fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
                  ),
                  onSelected: (val) {
                    setState(() {
                      if (val) {
                        _permissions.add(perm);
                      } else {
                        _permissions.remove(perm);
                      }
                    });
                  },
                );
              }).toList(),
            ),
          ],
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
          child: Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: saving ? null : () => Navigator.pop(context),
                  child: const Text('Cancel'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: CustomButton(
                  label: _isEdit ? 'Save Staff' : 'Submit',
                  isLoading: saving,
                  onPressed: _submit,
                ),
              ),
            ],
          ),
        ),
      ),
    );
    return widget.isShop ? ShopTheme(child: scaffold) : scaffold;
  }
}
