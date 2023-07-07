import 'package:flutter/material.dart';

class TribuTextField extends StatelessWidget {
  const TribuTextField(
      {super.key,
      this.controller,
      this.placeholder,
      this.validator,
      this.enabled,
      this.autofocus,
      this.prefixIcon,
      this.suffixIcon,
      this.label,
      this.focusNode,
      this.initialValue,
      this.floatingLabelBehavior,});
  final TextEditingController? controller;
  final FocusNode? focusNode;
  final String? placeholder;
  final String? Function(String?)? validator;
  final bool? enabled;
  final bool? autofocus;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final Widget? label;
  final String? initialValue;
  final FloatingLabelBehavior? floatingLabelBehavior;

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: Theme.of(context).copyWith(
          colorScheme: Theme.of(context)
              .colorScheme
              .copyWith(primary: Theme.of(context).colorScheme.secondary),),
      child: TextFormField(
        autofocus: autofocus ?? false,
        controller: controller,
        focusNode: focusNode,
        initialValue: initialValue,
        decoration: InputDecoration(
          filled: true,
          focusColor: Theme.of(context).colorScheme.secondary,
          floatingLabelBehavior: floatingLabelBehavior,
          labelText: placeholder,
          prefixIcon: prefixIcon,
          suffixIcon: suffixIcon,
          label: label,
        ),
        validator: validator,
        enabled: enabled,
        textCapitalization: TextCapitalization.sentences,
      ),
    );
  }
}

class TribuTextTheme extends StatelessWidget {
  const TribuTextTheme({required this.child, super.key});
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Theme(
        data: Theme.of(context).copyWith(
            colorScheme: Theme.of(context)
                .colorScheme
                .copyWith(primary: Theme.of(context).colorScheme.secondary),),
        child: child,);
  }
}
