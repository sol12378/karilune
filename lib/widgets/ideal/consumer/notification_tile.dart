import 'package:flutter/material.dart';

import '../../../theme/app_theme.dart';
import '../ideal_theme.dart';

class NotificationTile extends StatelessWidget {
  const NotificationTile({
    super.key,
    required this.title,
    required this.body,
    required this.timeLabel,
    required this.isRead,
    this.onTap,
    this.showChevron = false,
  });

  final String title;
  final String body;
  final String timeLabel;
  final bool isRead;
  final VoidCallback? onTap;
  final bool showChevron;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(IdealRadii.card),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: IdealShadows.card,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(IdealRadii.card),
          child: Padding(
            padding: const EdgeInsets.all(IdealSpacing.md),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CircleAvatar(
                  radius: IdealRadii.avatar,
                  backgroundColor: isRead
                      ? Colors.grey.shade200
                      : Theme.of(context).colorScheme.primaryContainer,
                  child: Icon(
                    isRead
                        ? Icons.notifications_outlined
                        : Icons.notifications_active_outlined,
                    size: 20,
                  ),
                ),
                const SizedBox(width: IdealSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                              fontWeight:
                                  isRead ? FontWeight.normal : FontWeight.bold,
                            ),
                      ),
                      const SizedBox(height: IdealSpacing.xs),
                      Text(
                        body,
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                      const SizedBox(height: IdealSpacing.xs),
                      Text(
                        timeLabel,
                        style: Theme.of(context).textTheme.labelSmall,
                      ),
                    ],
                  ),
                ),
                if (showChevron)
                  Icon(Icons.chevron_right, color: Colors.grey.shade500),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
