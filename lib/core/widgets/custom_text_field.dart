import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class CustomTextField extends StatefulWidget {
  final TextEditingController controller;
  final String label;
  final String? hint;
  final String? Function(String?)? validator;
  final TextInputType keyboardType;
  final bool isPassword;
  final int maxLines;
  final List<TextInputFormatter>? inputFormatters;
  final bool enabled;

  const CustomTextField({
    super.key,
    required this.controller,
    required this.label,
    this.hint,
    this.validator,
    this.keyboardType = TextInputType.text,
    this.isPassword = false,
    this.maxLines = 1,
    this.inputFormatters,
    this.enabled = true,
  });

  @override
  State<CustomTextField> createState() => _CustomTextFieldState();
}

class _CustomTextFieldState extends State<CustomTextField> {
  bool _obscure = true;

  @override
  Widget build(BuildContext context) => TextFormField(
    controller: widget.controller,
    validator: widget.validator,
    keyboardType: widget.keyboardType,
    obscureText: widget.isPassword && _obscure,
    maxLines: widget.isPassword ? 1 : widget.maxLines,
    inputFormatters: widget.inputFormatters,
    enabled: widget.enabled,
    decoration: InputDecoration(
      labelText: widget.label,
      hintText: widget.hint,
      suffixIcon: widget.isPassword
          ? IconButton(
              icon: Icon(_obscure ? Icons.visibility_off : Icons.visibility),
              onPressed: () => setState(() => _obscure = !_obscure),
            )
          : null,
    ),
  );
}
