import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';
import '../../../core/constants/app_colors.dart';
import '../../../shared/models/special_model.dart';
import '../../../shared/services/data_store.dart';
import '../admin_shared_widgets.dart';

class AdminSpecialsTab extends StatelessWidget {
  const AdminSpecialsTab({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<GolfSpecial>>(
      initialData: DataStore.instance.specials,
      stream: DataStore.instance.watchSpecials(),
      builder: (context, snap) {
        final list = snap.data ?? [];
        return Column(
          children: [
            AdminActionBar(
              count: list.length,
              label: 'specials',
              onAdd: () => _openForm(context, null),
            ),
            Expanded(
              child: ListView.separated(
                itemCount: list.length,
                separatorBuilder: (_, __) => const Divider(height: 1),
                itemBuilder: (context, i) {
                  final s = list[i];
                  return ListTile(
                    leading: CircleAvatar(
                      backgroundColor: AppColors.paleGold,
                      child: const Icon(Icons.local_offer,
                          color: AppColors.accentGold, size: 20),
                    ),
                    title: Text(s.title,
                        style: const TextStyle(
                            fontWeight: FontWeight.w600)),
                    subtitle: Text(
                        '${s.courseName} · ${s.currency} ${s.price.toStringAsFixed(0)}'),
                    trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: s.isActive
                                  ? AppColors.success
                                  : AppColors.mediumGray,
                              borderRadius:
                                  BorderRadius.circular(8),
                            ),
                            child: Text(
                                s.isActive ? 'Active' : 'Inactive',
                                style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 11)),
                          ),
                          AdminRowActions(
                            onEdit: () => _openForm(context, s),
                            onDelete: () =>
                                _confirmDelete(context, s),
                          ),
                        ]),
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }

  void _openForm(BuildContext context, GolfSpecial? s) =>
      showDialog(
          context: context,
          barrierDismissible: false,
          builder: (_) => _SpecialDialog(special: s));

  Future<void> _confirmDelete(
      BuildContext context, GolfSpecial s) async {
    final ok = await showDialog<bool>(
        context: context,
        builder: (_) => AdminDeleteDialog(name: s.title));
    if (ok == true) await DataStore.instance.deleteSpecial(s.id);
  }
}

class _SpecialDialog extends StatefulWidget {
  final GolfSpecial? special;
  const _SpecialDialog({this.special});

  @override
  State<_SpecialDialog> createState() => _SpecialDialogState();
}

class _SpecialDialogState extends State<_SpecialDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _title,
      _courseName,
      _courseId,
      _price,
      _origPrice,
      _desc,
      _tags;
  late String _currency;
  late bool _active;
  late DateTime _from, _to;

  static const _currencies = ['TTD', 'USD', 'BBD', 'JMD'];

  @override
  void initState() {
    super.initState();
    final s = widget.special;
    _title = TextEditingController(text: s?.title ?? '');
    _courseName =
        TextEditingController(text: s?.courseName ?? '');
    _courseId = TextEditingController(text: s?.courseId ?? '');
    _price = TextEditingController(
        text: s?.price.toStringAsFixed(0) ?? '');
    _origPrice = TextEditingController(
        text: s?.originalPrice?.toStringAsFixed(0) ?? '');
    _desc = TextEditingController(text: s?.description ?? '');
    _tags =
        TextEditingController(text: s?.tags.join(', ') ?? '');
    _currency = s?.currency ?? 'TTD';
    _active = s?.isActive ?? true;
    _from = s?.validFrom ?? DateTime.now();
    _to = s?.validTo ??
        DateTime.now().add(const Duration(days: 30));
  }

  @override
  void dispose() {
    for (final c in [
      _title,
      _courseName,
      _courseId,
      _price,
      _origPrice,
      _desc,
      _tags
    ]) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _pickDate(
      DateTime initial, ValueChanged<DateTime> onPicked) async {
    final d = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );
    if (d != null) setState(() => onPicked(d));
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    await DataStore.instance.saveSpecial(GolfSpecial(
      id: widget.special?.id ?? const Uuid().v4(),
      courseId: _courseId.text.trim().isEmpty
          ? _courseName.text
              .trim()
              .toLowerCase()
              .replaceAll(' ', '_')
          : _courseId.text.trim(),
      courseName: _courseName.text.trim(),
      title: _title.text.trim(),
      description: _desc.text.trim(),
      validFrom: _from,
      validTo: _to,
      price: double.tryParse(_price.text) ?? 0,
      originalPrice: double.tryParse(_origPrice.text),
      currency: _currency,
      tags: _tags.text
          .split(',')
          .map((e) => e.trim())
          .where((e) => e.isNotEmpty)
          .toList(),
      isActive: _active,
      publishedAt: widget.special?.publishedAt ?? DateTime.now(),
    ));
    if (mounted) Navigator.pop(context);
  }

  final _df = DateFormat('d MMM yyyy');

  @override
  Widget build(BuildContext context) {
    return AdminFormDialog(
      title: widget.special == null ? 'Add Special' : 'Edit Special',
      saveLabel: widget.special == null
          ? 'Publish Special'
          : 'Save Changes',
      onSave: _save,
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _tf('Title *', _title, required: true),
            _tf('Course Name *', _courseName, required: true),
            _tf('Description', _desc, maxLines: 3),
            Row(children: [
              Expanded(
                  child:
                      _tf('Price *', _price, required: true)),
              const SizedBox(width: 8),
              Expanded(child: _tf('Original Price', _origPrice)),
              const SizedBox(width: 8),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: DropdownButtonFormField<String>(
                    value: _currency,
                    decoration: const InputDecoration(
                        labelText: 'Currency'),
                    items: _currencies
                        .map((e) => DropdownMenuItem(
                            value: e, child: Text(e)))
                        .toList(),
                    onChanged: (v) =>
                        setState(() => _currency = v!),
                  ),
                ),
              ),
            ]),
            Row(children: [
              Expanded(
                  child: _datePicker(
                      'Valid From', _from, (d) => _from = d)),
              const SizedBox(width: 8),
              Expanded(
                  child: _datePicker(
                      'Valid Until', _to, (d) => _to = d)),
            ]),
            _tf('Tags (comma-separated)', _tags),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Active'),
              value: _active,
              onChanged: (v) => setState(() => _active = v),
              activeColor: AppColors.primaryGreen,
            ),
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

  Widget _datePicker(String label, DateTime date,
          ValueChanged<DateTime> onPicked) =>
      Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: InkWell(
          onTap: () => _pickDate(date, onPicked),
          child: InputDecorator(
            decoration: InputDecoration(
              labelText: label,
              suffixIcon:
                  const Icon(Icons.calendar_today, size: 18),
            ),
            child: Text(_df.format(date)),
          ),
        ),
      );
}
