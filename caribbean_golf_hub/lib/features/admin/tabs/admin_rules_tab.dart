import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../../../core/constants/app_colors.dart';
import '../../../shared/models/rule_model.dart';
import '../../../shared/services/data_store.dart';
import '../admin_shared_widgets.dart';

class AdminRulesTab extends StatelessWidget {
  const AdminRulesTab({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<GolfRule>>(
      initialData: DataStore.instance.rules,
      stream: DataStore.instance.watchRules(),
      builder: (context, snap) {
        final list = snap.data ?? [];
        return Column(
          children: [
            AdminActionBar(
              count: list.length,
              label: 'rules',
              onAdd: () => _openForm(context, null),
            ),
            Expanded(
              child: ListView.separated(
                itemCount: list.length,
                separatorBuilder: (_, __) => const Divider(height: 1),
                itemBuilder: (context, i) {
                  final r = list[i];
                  return ListTile(
                    leading: CircleAvatar(
                      backgroundColor: AppColors.surfaceGreen,
                      child: Text(r.ruleNumber,
                          style: const TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                              color: AppColors.primaryGreen)),
                    ),
                    title: Text(r.title,
                        style: const TextStyle(
                            fontWeight: FontWeight.w600)),
                    subtitle: Text(r.category),
                    trailing: AdminRowActions(
                      onEdit: () => _openForm(context, r),
                      onDelete: () => _confirmDelete(context, r),
                    ),
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }

  void _openForm(BuildContext context, GolfRule? r) => showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => _RuleDialog(rule: r));

  Future<void> _confirmDelete(
      BuildContext context, GolfRule r) async {
    final ok = await showDialog<bool>(
        context: context,
        builder: (_) => AdminDeleteDialog(name: r.title));
    if (ok == true) await DataStore.instance.deleteRule(r.id);
  }
}

class _RuleDialog extends StatefulWidget {
  final GolfRule? rule;
  const _RuleDialog({this.rule});

  @override
  State<_RuleDialog> createState() => _RuleDialogState();
}

class _RuleDialogState extends State<_RuleDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _title,
      _ruleNum,
      _summary,
      _content,
      _tags,
      _order;
  late String _category;

  @override
  void initState() {
    super.initState();
    final r = widget.rule;
    _category = r?.category ?? RuleCategory.all.first.name;
    _title = TextEditingController(text: r?.title ?? '');
    _ruleNum = TextEditingController(text: r?.ruleNumber ?? '');
    _summary = TextEditingController(text: r?.summary ?? '');
    _content = TextEditingController(text: r?.content ?? '');
    _tags =
        TextEditingController(text: r?.tags.join(', ') ?? '');
    _order =
        TextEditingController(text: r?.order.toString() ?? '0');
  }

  @override
  void dispose() {
    for (final c in [
      _title,
      _ruleNum,
      _summary,
      _content,
      _tags,
      _order
    ]) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    await DataStore.instance.saveRule(GolfRule(
      id: widget.rule?.id ?? const Uuid().v4(),
      category: _category,
      title: _title.text.trim(),
      ruleNumber: _ruleNum.text.trim(),
      summary: _summary.text.trim(),
      content: _content.text.trim(),
      order: int.tryParse(_order.text) ?? 0,
      tags: _tags.text
          .split(',')
          .map((e) => e.trim())
          .where((e) => e.isNotEmpty)
          .toList(),
    ));
    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return AdminFormDialog(
      title: widget.rule == null ? 'Add Rule' : 'Edit Rule',
      saveLabel:
          widget.rule == null ? 'Add Rule' : 'Save Changes',
      onSave: _save,
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: DropdownButtonFormField<String>(
                value: _category,
                decoration:
                    const InputDecoration(labelText: 'Category'),
                items: RuleCategory.all
                    .map((c) => DropdownMenuItem(
                        value: c.name,
                        child: Text('${c.icon}  ${c.name}')))
                    .toList(),
                onChanged: (v) =>
                    setState(() => _category = v!),
              ),
            ),
            _tf('Title *', _title, required: true),
            _tf('Rule Number (e.g. 18.2 or Local)', _ruleNum),
            _tf('Summary *', _summary, required: true),
            _tf(
                'Full Content (supports **bold** and line breaks)',
                _content,
                maxLines: 8),
            _tf('Tags (comma-separated)', _tags),
            _tf('Display Order', _order),
          ],
        ),
      ),
    );
  }

  Widget _tf(String label, TextEditingController c,
          {bool required = false, int maxLines = 1}) =>
      Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: TextFormField(
          controller: c,
          maxLines: maxLines,
          decoration: InputDecoration(labelText: label),
          validator: required
              ? (v) =>
                  (v == null || v.isEmpty) ? 'Required' : null
              : null,
        ),
      );
}
