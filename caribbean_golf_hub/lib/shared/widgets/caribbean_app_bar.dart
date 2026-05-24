import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';

class CaribbeanAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final String? subtitle;
  final List<Widget>? actions;
  final bool showGoldAccent;

  const CaribbeanAppBar({
    super.key,
    required this.title,
    this.subtitle,
    this.actions,
    this.showGoldAccent = false,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: AppColors.primaryGreen,
      elevation: 0,
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Text(
                title,
                style: const TextStyle(
                  color: AppColors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.2,
                ),
              ),
              if (showGoldAccent) ...[
                const SizedBox(width: 8),
                Container(
                  width: 6,
                  height: 6,
                  decoration: const BoxDecoration(
                    color: AppColors.accentGold,
                    shape: BoxShape.circle,
                  ),
                ),
              ],
            ],
          ),
          if (subtitle != null)
            Text(
              subtitle!,
              style: TextStyle(
                color: AppColors.white.withOpacity(0.7),
                fontSize: 12,
                fontWeight: FontWeight.w400,
              ),
            ),
        ],
      ),
      actions: actions,
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(subtitle != null ? 64 : kToolbarHeight);
}
