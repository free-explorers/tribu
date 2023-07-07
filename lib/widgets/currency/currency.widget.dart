import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class CurrencyViewer extends StatelessWidget {
  const CurrencyViewer(this.value,
      {required this.currencyName, super.key, this.style,});
  final double value;
  final String currencyName;
  final TextStyle? style;

  @override
  Widget build(BuildContext context) {
    final formatter = NumberFormat.simpleCurrency(name: currencyName);

    return Text(formatter.format(value), style: style);
  }
}
