import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class BalanceAmount extends StatelessWidget {
  const BalanceAmount(
    this.value, {
    required this.currencyName,
    super.key,
    this.style,
  });
  final double value;
  final String currencyName;
  final TextStyle? style;

  @override
  Widget build(BuildContext context) {
    final formatter = NumberFormat.simpleCurrency(name: currencyName);
    final positive = value >= 0;
    final style = this.style ?? Theme.of(context).textTheme.titleSmall!;
    return Text(
      '${positive ? '+' : '-'} ${formatter.format(value.abs())}',
      style: style.copyWith(
        color: positive ? Colors.green : Theme.of(context).colorScheme.error,
      ),
    );
  }
}
