import 'package:assignment/view/constants.dart';
import 'package:flutter/material.dart';

class PasswordTextFormField extends StatefulWidget {
  final String? hintText;
  final String labelText;
  final String? Function(String?) validator;
  final TextEditingController passwordEditingController;

  const PasswordTextFormField({
    super.key,
    this.hintText,
    required this.labelText,
    required this.passwordEditingController,
    required this.validator,
  });

  @override
  State<PasswordTextFormField> createState() => _PasswordTextFormFieldState();
}

class _PasswordTextFormFieldState extends State<PasswordTextFormField> {
  bool _isPasswordHide = true;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: widget.passwordEditingController,
      obscureText: _isPasswordHide,
      maxLength: 20,
      decoration: InputDecoration(
        labelText: widget.labelText,
        hintText: widget.hintText,
        prefixIcon: const Icon(Icons.password),
        suffixIcon: IconButton(
          tooltip: 'Visible/Hide password',
          onPressed: () {
            _isPasswordHide = !_isPasswordHide;
            setState(() {});
          },
          icon: Visibility(
            visible: _isPasswordHide,
            replacement: Icon(Icons.visibility),
            child: Icon(Icons.visibility_off),
          ),
        ),
      ),
      validator: widget.validator,
      keyboardType: TextInputType.text,
    );
  }
}
