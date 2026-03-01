import 'package:flutter/material.dart';

class FsPriceText extends StatelessWidget {
  final int priceCents;
  final TextStyle? style;

  const FsPriceText({super.key, required this.priceCents, this.style});

  @override
  Widget build(BuildContext context) {
    final euros = (priceCents / 100).toStringAsFixed(2).replaceAll('.', ',');
    final defaultStyle = Theme.of(context).textTheme.bodyMedium?.copyWith(
          fontWeight: FontWeight.w400,
          letterSpacing: 0.3,
        );
    return Text('$euros \u20ac', style: style ?? defaultStyle);
  }
}
