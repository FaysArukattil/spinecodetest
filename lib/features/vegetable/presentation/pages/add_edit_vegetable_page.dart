import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/snackbar_helper.dart';
import '../../../../core/utils/validators.dart';
import '../../../../core/widgets/custom_button.dart';
import '../../../../core/widgets/custom_text_field.dart';
import '../../domain/entities/vegetable_entity.dart';
import '../providers/vegetable_provider.dart';

class AddEditVegetablePage extends StatefulWidget {
  final VegetableEntity? vegetable; // null => add
  const AddEditVegetablePage({super.key, this.vegetable});

  @override
  State<AddEditVegetablePage> createState() => _AddEditVegetablePageState();
}

class _AddEditVegetablePageState extends State<AddEditVegetablePage> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _sort;
  late final TextEditingController _name;
  late final TextEditingController _price;
  late final TextEditingController _stock;
  late String _unit;

  bool get _isEdit => widget.vegetable != null;

  @override
  void initState() {
    super.initState();
    final v = widget.vegetable;
    var nextSort = 1;
    if (v == null) {
      final items = context.read<VegetableProvider>().items;
      if (items.isNotEmpty) {
        nextSort = items.map((e) => e.sortNumber).reduce((a, b) => a > b ? a : b) + 1;
      }
    }
    _sort = TextEditingController(text: '${v?.sortNumber ?? nextSort}');
    _name = TextEditingController(text: v?.name ?? '');
    _price = TextEditingController(text: v == null ? '' : '${v.price}');
    _stock = TextEditingController(text: v == null ? '' : '${v.stockQuantity}');
    _unit = v?.unit ?? AppConstants.units.first;
  }

  @override
  void dispose() {
    _sort.dispose();
    _name.dispose();
    _price.dispose();
    _stock.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    FocusScope.of(context).unfocus();
    final provider = context.read<VegetableProvider>();
    final old = widget.vegetable;
    final stock = double.parse(_stock.text.trim());

    // Status rules: no stock => Out of Stock; restocking an empty item => Available.
    String status;
    if (stock <= 0) {
      status = AppConstants.vegOutOfStock;
    } else if (old == null || old.stockQuantity <= 0) {
      status = AppConstants.vegAvailable;
    } else {
      status = old.status;
    }

    final veg = VegetableEntity(
      id: old?.id ?? '',
      name: _name.text.trim(),
      sortNumber: int.parse(_sort.text.trim()),
      unit: _unit,
      price: double.parse(_price.text.trim()),
      stockQuantity: stock,
      status: status,
      createdAt: old?.createdAt ?? DateTime.now(),
    );

    final err = await provider.save(veg);
    if (!mounted) return;
    if (err != null) {
      SnackbarHelper.error(context, err);
      return;
    }
    SnackbarHelper.success(context, _isEdit ? 'Vegetable updated' : 'Vegetable added');
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final saving = context.select<VegetableProvider, bool>((p) => p.isSaving);
    final decimal = [FilteringTextInputFormatter.allow(RegExp(r'[0-9.]'))];

    return Scaffold(
      appBar: AppBar(
        title: Text(_isEdit ? 'Edit Vegetable' : 'Add New Vegetable',
            style: const TextStyle(fontSize: 16)),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
          children: [
            Center(
              child: Container(
                width: 100,
                height: 100,
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: AppColors.surfaceAlt,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.border),
                ),
                child: const Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.eco, size: 36, color: AppColors.brandGreen),
                    SizedBox(height: 4),
                    Text(
                      'Photo',
                      style: TextStyle(fontSize: 11, color: AppColors.textSecondary),
                    ),
                  ],
                ),
              ),
            ),
            CustomTextField(
              controller: _sort,
              label: 'Sort Number *',
              hint: 'Enter sort number',
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              validator: Validators.sortNumber,
            ),
            const SizedBox(height: 14),
            CustomTextField(
              controller: _name,
              label: 'Vegetable Name *',
              hint: 'e.g., Tomato',
              validator: (v) => Validators.name(v, 'Vegetable name'),
            ),
            const SizedBox(height: 18),
            const Text('Select Default Unit *', style: TextStyle(fontSize: 12)),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: AppConstants.units
                  .map((u) => ChoiceChip(
                        label: Text(u),
                        selected: _unit == u,
                        showCheckmark: false,
                        selectedColor: AppColors.primary,
                        backgroundColor: Colors.white,
                        labelStyle: TextStyle(
                            color: _unit == u ? Colors.white : AppColors.textPrimary,
                            fontSize: 12),
                        onSelected: (_) => setState(() => _unit = u),
                      ))
                  .toList(),
            ),
            const SizedBox(height: 18),
            CustomTextField(
              controller: _price,
              label: 'Price (per $_unit) *',
              hint: 'Enter price',
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              inputFormatters: decimal,
              validator: Validators.price,
            ),
            const SizedBox(height: 14),
            CustomTextField(
              controller: _stock,
              label: 'Stock Quantity *',
              hint: 'Enter stock quantity',
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              inputFormatters: decimal,
              validator: (v) => Validators.stock(v) ??
                  (_unit == 'Kg' ? null : Validators.wholeNumber(v)),
            ),
          ],
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
          child: Row(children: [
            Expanded(
              child: OutlinedButton(
                onPressed: saving ? null : () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: CustomButton(label: 'Submit', isLoading: saving, onPressed: _submit),
            ),
          ]),
        ),
      ),
    );
  }
}
