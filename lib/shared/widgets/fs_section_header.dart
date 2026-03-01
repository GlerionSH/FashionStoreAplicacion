import 'package:flutter/material.dart';

class FsSectionHeader extends StatelessWidget {
  final String title;
  final String? actionLabel;
  final VoidCallback? onAction;

  const FsSectionHeader({
    super.key,
    required this.title,
    this.actionLabel,
    this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title.toUpperCase(),
            style: theme.textTheme.titleSmall?.copyWith(
              letterSpacing: 2.0,
              fontWeight: FontWeight.w500,
            ),
          ),
          if (actionLabel != null)
            GestureDetector(
              onTap: onAction,
              child: Text(
                actionLabel!,
                style: theme.textTheme.bodySmall?.copyWith(
                  decoration: TextDecoration.underline,
                  decorationColor: const Color(0xFF616161),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
