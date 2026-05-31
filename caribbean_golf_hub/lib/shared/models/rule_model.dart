class GolfRule {
  final String id;
  final String category;
  final String title;
  final String ruleNumber;
  final String summary;
  final String content;
  final List<String> imageUrls;
  final int order;
  final List<String> tags;

  const GolfRule({
    required this.id,
    required this.category,
    required this.title,
    required this.ruleNumber,
    required this.summary,
    required this.content,
    this.imageUrls = const [],
    required this.order,
    this.tags = const [],
  });

  factory GolfRule.fromFirestore(Map<String, dynamic> data, String id) =>
      GolfRule(
        id: id,
        category: data['category'] as String? ?? '',
        title: data['title'] as String? ?? '',
        ruleNumber: data['ruleNumber'] as String? ?? '',
        summary: data['summary'] as String? ?? '',
        content: data['content'] as String? ?? '',
        imageUrls: List<String>.from(data['imageUrls'] as List? ?? []),
        order: data['order'] as int? ?? 0,
        tags: List<String>.from(data['tags'] as List? ?? []),
      );

  Map<String, dynamic> toFirestore() => {
        'category': category,
        'title': title,
        'ruleNumber': ruleNumber,
        'summary': summary,
        'content': content,
        'imageUrls': imageUrls,
        'order': order,
        'tags': tags,
      };

  factory GolfRule.fromJson(Map<String, dynamic> map) => GolfRule(
        id: map['id'] as String? ?? '',
        category: map['category'] as String? ?? '',
        title: map['title'] as String? ?? '',
        ruleNumber: map['ruleNumber'] as String? ?? '',
        summary: map['summary'] as String? ?? '',
        content: map['content'] as String? ?? '',
        imageUrls: List<String>.from(map['imageUrls'] as List? ?? []),
        order: map['order'] as int? ?? 0,
        tags: List<String>.from(map['tags'] as List? ?? []),
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'category': category,
        'title': title,
        'ruleNumber': ruleNumber,
        'summary': summary,
        'content': content,
        'imageUrls': imageUrls,
        'order': order,
        'tags': tags,
      };
}

/// Predefined rule categories with icons
class RuleCategory {
  final String name;
  final String icon;

  const RuleCategory({required this.name, required this.icon});

  static const List<RuleCategory> all = [
    RuleCategory(name: 'Out of Bounds', icon: '🚫'),
    RuleCategory(name: 'Penalty Areas', icon: '🔴'),
    RuleCategory(name: 'Unplayable Ball', icon: '⚠️'),
    RuleCategory(name: 'Bunkers', icon: '🏖'),
    RuleCategory(name: 'Putting Green', icon: '⛳'),
    RuleCategory(name: 'Loose Impediments', icon: '🍂'),
    RuleCategory(name: 'Abnormal Course Conditions', icon: '🌧'),
    RuleCategory(name: 'Scorecard Etiquette', icon: '📋'),
    RuleCategory(name: 'Pace of Play', icon: '⏱'),
    RuleCategory(name: 'Local Rules', icon: '🌴'),
  ];
}
