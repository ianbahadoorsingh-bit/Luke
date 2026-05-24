import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';

class AmenityChip extends StatelessWidget {
  final String label;
  final bool gold;

  const AmenityChip({super.key, required this.label, this.gold = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: gold
            ? AppColors.accentGold.withOpacity(0.15)
            : AppColors.lightGreen.withOpacity(0.12),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: gold
              ? AppColors.accentGold.withOpacity(0.4)
              : AppColors.lightGreen.withOpacity(0.3),
        ),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w500,
          color: gold ? AppColors.charcoal : AppColors.primaryGreen,
        ),
      ),
    );
  }
}

class AmenityChipList extends StatelessWidget {
  final List<String> amenities;
  final bool gold;

  const AmenityChipList({
    super.key,
    required this.amenities,
    this.gold = false,
  });

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: amenities.map((a) => AmenityChip(label: a, gold: gold)).toList(),
    );
  }
}
