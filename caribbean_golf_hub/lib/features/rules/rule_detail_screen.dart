import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../core/constants/app_colors.dart';
import '../../shared/models/rule_model.dart';
import '../../shared/widgets/amenity_chip.dart';

class RuleDetailScreen extends StatelessWidget {
  final GolfRule rule;

  const RuleDetailScreen({super.key, required this.rule});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.primaryGreen,
        foregroundColor: AppColors.white,
        title: Text('Rule ${rule.ruleNumber}'),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Center(
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.accentGold,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  rule.category,
                  style: const TextStyle(
                    color: AppColors.charcoal,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title
            Text(rule.title, style: Theme.of(context).textTheme.displayMedium),
            const SizedBox(height: 12),
            // Summary card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppColors.surfaceGreen,
                borderRadius: BorderRadius.circular(10),
                border: const Border(
                  left: BorderSide(color: AppColors.accentGold, width: 4),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Quick Summary',
                    style: Theme.of(context).textTheme.labelMedium?.copyWith(
                          color: AppColors.primaryGreen,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.5,
                        ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    rule.summary,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppColors.primaryGreen,
                          fontWeight: FontWeight.w500,
                        ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            // Rule number + section marker
            _SectionHeader(label: 'Rule Detail'),
            const SizedBox(height: 12),
            // Rule content (formatted text)
            _RuleContent(content: rule.content),
            // Diagrams / images
            if (rule.imageUrls.isNotEmpty) ...[
              const SizedBox(height: 24),
              _SectionHeader(label: 'Diagrams'),
              const SizedBox(height: 12),
              _DiagramGallery(imageUrls: rule.imageUrls),
            ],
            // Tags
            if (rule.tags.isNotEmpty) ...[
              const SizedBox(height: 24),
              AmenityChipList(amenities: rule.tags),
            ],
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String label;

  const _SectionHeader({required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 4,
          height: 18,
          decoration: BoxDecoration(
            color: AppColors.accentGold,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 8),
        Text(label, style: Theme.of(context).textTheme.headlineSmall),
      ],
    );
  }
}

/// Renders rule content with basic markdown-like structure.
/// Paragraphs are split on double newlines; bullet lines start with "- ".
class _RuleContent extends StatelessWidget {
  final String content;

  const _RuleContent({required this.content});

  @override
  Widget build(BuildContext context) {
    final paragraphs = content.split('\n\n');
    final bodyStyle = Theme.of(context).textTheme.bodyLarge;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: paragraphs.map((para) {
        final trimmed = para.trim();
        if (trimmed.startsWith('- ')) {
          // Bullet list
          final lines = trimmed.split('\n');
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: lines.map((line) {
                final text = line.startsWith('- ')
                    ? line.substring(2)
                    : line;
                return Padding(
                  padding: const EdgeInsets.only(bottom: 6),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Padding(
                        padding: EdgeInsets.only(top: 8, right: 8),
                        child: Icon(Icons.circle,
                            size: 6, color: AppColors.accentGold),
                      ),
                      Expanded(child: Text(text, style: bodyStyle)),
                    ],
                  ),
                );
              }).toList(),
            ),
          );
        }
        if (trimmed.startsWith('**') && trimmed.endsWith('**')) {
          // Bold heading
          return Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Text(
              trimmed.replaceAll('**', ''),
              style: Theme.of(context).textTheme.headlineSmall,
            ),
          );
        }
        // Normal paragraph
        return Padding(
          padding: const EdgeInsets.only(bottom: 14),
          child: Text(trimmed, style: bodyStyle),
        );
      }).toList(),
    );
  }
}

class _DiagramGallery extends StatelessWidget {
  final List<String> imageUrls;

  const _DiagramGallery({required this.imageUrls});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: imageUrls
          .map((url) => Padding(
                padding: const EdgeInsets.only(bottom: 14),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: CachedNetworkImage(
                    imageUrl: url,
                    width: double.infinity,
                    fit: BoxFit.contain,
                    placeholder: (_, __) => Container(
                      height: 200,
                      color: AppColors.surfaceGreen,
                      child: const Center(
                        child: CircularProgressIndicator(
                          color: AppColors.primaryGreen,
                        ),
                      ),
                    ),
                    errorWidget: (_, __, ___) => Container(
                      height: 150,
                      color: AppColors.lightGray,
                      child: const Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.image_not_supported,
                                color: AppColors.mediumGray, size: 32),
                            SizedBox(height: 8),
                            Text('Diagram placeholder',
                                style: TextStyle(color: AppColors.mediumGray)),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ))
          .toList(),
    );
  }
}
