import 'package:flutter/material.dart';

import '../../theme/app_theme.dart';
import '../app_shell.dart';

class OperatorMenuBar extends StatelessWidget {
  const OperatorMenuBar({
    super.key,
    required this.items,
    required this.currentLocation,
    required this.onTap,
  });

  final List<AppNavItem> items;
  final String currentLocation;
  final ValueChanged<String> onTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.card,
        border: Border(
          bottom: BorderSide(color: Colors.grey.shade200),
        ),
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        child: Row(
          children: [
            for (final item in items) ...[
              _MenuTab(
                label: item.label,
                selected: currentLocation.startsWith(item.location),
                onTap: () => onTap(item.location),
              ),
              const SizedBox(width: 4),
            ],
          ],
        ),
      ),
    );
  }
}

class _MenuTab extends StatelessWidget {
  const _MenuTab({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: onTap,
      style: TextButton.styleFrom(
        foregroundColor: selected ? AppColors.primary : Colors.grey.shade700,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontWeight: selected ? FontWeight.bold : FontWeight.normal,
          decoration: selected ? TextDecoration.underline : null,
          decorationColor: AppColors.primary,
        ),
      ),
    );
  }
}
