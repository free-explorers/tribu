import 'package:flutter/material.dart';

class TribuCardButton extends StatelessWidget {
  const TribuCardButton({
    required this.label,
    required this.icon,
    super.key,
    this.label2,
    this.onTap,
    this.disabled = false,
    this.readOnly = false,
    this.style,
  });
  final Widget label;
  final Widget? label2;
  final Icon icon;
  final void Function()? onTap;
  final bool disabled;
  final bool readOnly;
  final ButtonStyle? style;

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: disabled ? 0.5 : 1,
      child: Card(
        color: readOnly
            ? Colors.transparent
            : style?.backgroundColor?.resolve({MaterialState.selected}) ??
                Theme.of(context).colorScheme.tertiaryContainer,
        child: InkWell(
          onTap: disabled || readOnly ? null : onTap,
          child: Container(
            height: 48,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconTheme.merge(
                  data: IconThemeData(
                    color: style?.foregroundColor
                            ?.resolve({MaterialState.selected}) ??
                        Theme.of(context).colorScheme.primary,
                  ),
                  child: icon,
                ),
                const SizedBox(width: 16),
                DefaultTextStyle.merge(
                  style: Theme.of(context).textTheme.labelLarge?.copyWith(
                        color: style?.foregroundColor
                                ?.resolve({MaterialState.selected}) ??
                            Theme.of(context).colorScheme.primary,
                      ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      label,
                      if (label2 != null) label2!,
                    ],
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
