import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_strings.dart';
import '../../shared/models/rule_model.dart';
import '../../shared/services/firestore_service.dart';
import '../../shared/widgets/caribbean_app_bar.dart';
import '../../shared/widgets/loading_shimmer.dart';
import '../../shared/widgets/empty_state.dart';
import 'rule_detail_screen.dart';

class RulesScreen extends StatefulWidget {
  const RulesScreen({super.key});

  @override
  State<RulesScreen> createState() => _RulesScreenState();
}

class _RulesScreenState extends State<RulesScreen> {
  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CaribbeanAppBar(
        title: AppStrings.rulesTitle,
        subtitle: AppStrings.rulesSubtitle,
      ),
      body: Column(
        children: [
          _SearchHeader(onChanged: (q) => setState(() => _searchQuery = q.toLowerCase())),
          Expanded(
            child: StreamBuilder<List<GolfRule>>(
              stream: FirestoreService.instance.watchAllRules(),
              builder: (context, snap) {
                if (snap.connectionState == ConnectionState.waiting) {
                  return const ShimmerList(count: 5, cardHeight: 72);
                }
                if (snap.hasError) {
                  return const EmptyState(
                    emoji: '⚠️',
                    title: 'Unable to load rules',
                    subtitle: 'Please check your connection',
                  );
                }

                final allRules = snap.data ?? [];
                final filtered = _searchQuery.isEmpty
                    ? allRules
                    : allRules
                        .where((r) =>
                            r.title.toLowerCase().contains(_searchQuery) ||
                            r.category.toLowerCase().contains(_searchQuery) ||
                            r.summary.toLowerCase().contains(_searchQuery) ||
                            r.ruleNumber.contains(_searchQuery))
                        .toList();

                if (filtered.isEmpty) {
                  return const EmptyState(
                    emoji: '📖',
                    title: 'No rules found',
                    subtitle: 'Try a different search term',
                  );
                }

                // Group by category
                final grouped = <String, List<GolfRule>>{};
                for (final rule in filtered) {
                  grouped.putIfAbsent(rule.category, () => []).add(rule);
                }

                return ListView.builder(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  itemCount: grouped.length,
                  itemBuilder: (context, i) {
                    final category = grouped.keys.elementAt(i);
                    final rules = grouped[category]!;
                    return _CategorySection(
                      category: category,
                      rules: rules,
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _SearchHeader extends StatelessWidget {
  final ValueChanged<String> onChanged;

  const _SearchHeader({required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.primaryGreen,
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 14),
      child: TextField(
        onChanged: onChanged,
        style: const TextStyle(color: AppColors.white),
        decoration: InputDecoration(
          hintText: 'Search rules...',
          hintStyle: TextStyle(color: AppColors.white.withOpacity(0.6)),
          prefixIcon: Icon(Icons.search, color: AppColors.white.withOpacity(0.8)),
          filled: true,
          fillColor: AppColors.mediumGreen,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide.none,
          ),
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        ),
      ),
    );
  }
}

class _CategorySection extends StatefulWidget {
  final String category;
  final List<GolfRule> rules;

  const _CategorySection({required this.category, required this.rules});

  @override
  State<_CategorySection> createState() => _CategorySectionState();
}

class _CategorySectionState extends State<_CategorySection> {
  bool _expanded = true;

  String get _emoji {
    final match = RuleCategory.all
        .where((c) => c.name == widget.category)
        .toList();
    return match.isEmpty ? '📋' : match.first.icon;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Category header
        InkWell(
          onTap: () => setState(() => _expanded = !_expanded),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                Text(_emoji, style: const TextStyle(fontSize: 20)),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    widget.category,
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          color: AppColors.primaryGreen,
                        ),
                  ),
                ),
                Text(
                  '${widget.rules.length} rule${widget.rules.length == 1 ? '' : 's'}',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                const SizedBox(width: 6),
                AnimatedRotation(
                  turns: _expanded ? 0 : -0.25,
                  duration: const Duration(milliseconds: 200),
                  child: const Icon(Icons.expand_more,
                      color: AppColors.mediumGray),
                ),
              ],
            ),
          ),
        ),
        if (_expanded)
          ...widget.rules.map((rule) => _RuleTile(rule: rule)),
        const Divider(height: 1),
      ],
    );
  }
}

class _RuleTile extends StatelessWidget {
  final GolfRule rule;

  const _RuleTile({required this.rule});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: AppColors.surfaceGreen,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Center(
          child: Text(
            rule.ruleNumber,
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: AppColors.primaryGreen,
            ),
            textAlign: TextAlign.center,
          ),
        ),
      ),
      title: Text(
        rule.title,
        style: Theme.of(context)
            .textTheme
            .bodyMedium
            ?.copyWith(fontWeight: FontWeight.w600),
      ),
      subtitle: Text(
        rule.summary,
        style: Theme.of(context).textTheme.bodySmall,
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
      ),
      trailing: const Icon(Icons.chevron_right, color: AppColors.mediumGray),
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => RuleDetailScreen(rule: rule)),
      ),
    );
  }
}
