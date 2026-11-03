import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/utils/snackbar_helper.dart';
import '../../../../core/utils/validators.dart';
import '../../../../core/widgets/custom_button.dart';
import '../../../../core/widgets/custom_text_field.dart';
import '../../domain/entities/shop_entity.dart';
import '../providers/shop_provider.dart';

class AddEditShopPage extends StatefulWidget {
  final ShopEntity? shop; // null => add
  const AddEditShopPage({super.key, this.shop});

  @override
  State<AddEditShopPage> createState() => _AddEditShopPageState();
}

class _AddEditShopPageState extends State<AddEditShopPage> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _name;
  late final TextEditingController _owner;
  late final TextEditingController _phone;
  late final TextEditingController _email;
  late final TextEditingController _password;
  late final TextEditingController _address;

  bool get _isEdit => widget.shop != null;

  @override
  void initState() {
    super.initState();
    final s = widget.shop;
    _name = TextEditingController(text: s?.shopName ?? '');
    _owner = TextEditingController(text: s?.ownerName ?? '');
    _phone = TextEditingController(text: s?.phone ?? '');
    _email = TextEditingController(text: s?.email ?? '');
    _password = TextEditingController();
    _address = TextEditingController(text: s?.address ?? '');
  }

  @override
  void dispose() {
    for (final c in [_name, _owner, _phone, _email, _password, _address]) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    FocusScope.of(context).unfocus();
    final provider = context.read<ShopProvider>();
    final old = widget.shop;

    final shop = ShopEntity(
      id: old?.id ?? '',
      shopName: _name.text.trim(),
      ownerName: _owner.text.trim(),
      email: _email.text.trim(),
      phone: _phone.text.trim(),
      address: _address.text.trim(),
      status: old?.status ?? AppConstants.shopActive,
      createdAt: old?.createdAt ?? DateTime.now(),
    );

    final err = await provider.save(shop, password: _password.text);
    if (!mounted) return;
    if (err != null) {
      SnackbarHelper.error(context, err);
      return;
    }
    SnackbarHelper.success(context, _isEdit ? 'Shop updated' : 'Shop added');
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final saving = context.select<ShopProvider, bool>((p) => p.isSaving);

    return Scaffold(
      appBar: AppBar(
        title: Text(_isEdit ? 'Edit Store' : 'Add New Shop',
            style: const TextStyle(fontSize: 16)),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
          children: [
            CustomTextField(
              controller: _name,
              label: 'Store Name *',
              hint: 'Enter shop name',
              validator: (v) => Validators.name(v, 'Store name'),
            ),
            const SizedBox(height: 14),
            CustomTextField(
              controller: _owner,
              label: 'Contact Person Name *',
              hint: 'Enter contact person name',
              validator: (v) => Validators.name(v, 'Contact person name'),
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
            const SizedBox(height: 14),
            CustomTextField(
              controller: _email,
              label: 'Email (used to log in) *',
              hint: 'Enter email',
              keyboardType: TextInputType.emailAddress,
              enabled: !_isEdit, // login email can't change after creation
              validator: Validators.email,
            ),
            if (!_isEdit) ...[
              const SizedBox(height: 14),
              CustomTextField(
                controller: _password,
                label: 'Password *',
                hint: 'Min 6 characters',
                isPassword: true,
                validator: Validators.password,
              ),
            ],
            const SizedBox(height: 14),
            CustomTextField(
              controller: _address,
              label: 'Location / Address *',
              hint: 'Enter Location',
              maxLines: 4,
              validator: (v) => Validators.required(v, 'Location'),
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
              child: CustomButton(
                label: _isEdit ? 'Save Store' : 'Submit',
                isLoading: saving,
                onPressed: _submit,
              ),
            ),
          ]),
        ),
      ),
    );
  }
}
