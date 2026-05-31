import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';
import '../../../core/constants/app_colors.dart';
import '../../../shared/models/tournament_model.dart';
import '../../../shared/services/data_store.dart';
import '../admin_shared_widgets.dart';

class AdminTournamentsTab extends StatelessWidget {
  const AdminTournamentsTab({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<Tournament>>(
      initialData: DataStore.instance.tournaments,
      stream: DataStore.instance.watchTournaments(),
      builder: (context, snap) {
        final list = snap.data ?? [];
        return Column(
          children: [
            AdminActionBar(
              count: list.length,
              label: 'tournaments',
              onAdd: () => _openForm(context, null),
            ),
            Expanded(
              child: ListView.separated(
                itemCount: list.length,
                separatorBuilder: (_, __) => const Divider(height: 1),
                itemBuilder: (context, i) {
                  final t = list[i];
                  return ListTile(
                    leading: CircleAvatar(
                      backgroundColor: AppColors.paleGold,
                      child: const Icon(Icons.emoji_events,
                          color: AppColors.accentGold, size: 20),
                    ),
                    title: Text(t.name,
                        style: const TextStyle(
                            fontWeight: FontWeight.w600)),
                    subtitle: Text(
                        '${t.courseName} · ${DateFormat('d MMM yyyy').format(t.startDate)}'),
                    trailing: AdminRowActions(
                      onEdit: () => _openForm(context, t),
                      onDelete: () => _confirmDelete(context, t),
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

  void _openForm(BuildContext context, Tournament? t) => showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => _TournamentDialog(tournament: t));

  Future<void> _confirmDelete(
      BuildContext context, Tournament t) async {
    final ok = await showDialog<bool>(
        context: context,
        builder: (_) => AdminDeleteDialog(name: t.name));
    if (ok == true) await DataStore.instance.deleteTournament(t.id);
  }
}

class _TournamentDialog extends StatefulWidget {
  final Tournament? tournament;
  const _TournamentDialog({this.tournament});

  @override
  State<_TournamentDialog> createState() => _TournamentDialogState();
}

class _TournamentDialogState extends State<_TournamentDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _name,
      _courseName,
      _courseId,
      _maxP,
      _fee,
      _desc,
      _tags;
  late String _country, _format, _currency;
  late bool _regOpen;
  late DateTime _start, _end, _deadline;

  static const _formats = [
    'Strokeplay',
    'Stableford',
    'Match Play',
    'Pro-Am',
    'Scramble',
    'Texas Scramble'
  ];
  static const _currencies = ['TTD', 'USD', 'BBD', 'JMD'];
  static const _countries = ['TT', 'BB', 'JM', 'BS', 'GY', 'LC', 'AG'];

  @override
  void initState() {
    super.initState();
    final t = widget.tournament;
    _name = TextEditingController(text: t?.name ?? '');
    _courseName = TextEditingController(text: t?.courseName ?? '');
    _courseId = TextEditingController(text: t?.courseId ?? '');
    _maxP = TextEditingController(
        text: t?.maxParticipants.toString() ?? '80');
    _fee = TextEditingController(
        text: t?.entryFee.toStringAsFixed(0) ?? '');
    _desc = TextEditingController(text: t?.description ?? '');
    _tags =
        TextEditingController(text: t?.tags.join(', ') ?? '');
    _country = t?.country ?? 'TT';
    _format = t?.format ?? 'Strokeplay';
    _currency = t?.feeCurrency ?? 'TTD';
    _regOpen = t?.registrationOpen ?? true;
    _start = t?.startDate ??
        DateTime.now().add(const Duration(days: 30));
    _end = t?.endDate ??
        DateTime.now().add(const Duration(days: 32));
    _deadline = t?.registrationDeadline ??
        DateTime.now().add(const Duration(days: 21));
  }

  @override
  void dispose() {
    for (final c in [
      _name,
      _courseName,
      _courseId,
      _maxP,
      _fee,
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
    await DataStore.instance.saveTournament(Tournament(
      id: widget.tournament?.id ?? const Uuid().v4(),
      name: _name.text.trim(),
      description: _desc.text.trim(),
      courseId: _courseId.text.trim().isEmpty
          ? _courseName.text
              .trim()
              .toLowerCase()
              .replaceAll(' ', '_')
          : _courseId.text.trim(),
      courseName: _courseName.text.trim(),
      startDate: _start,
      endDate: _end,
      registrationDeadline: _deadline,
      format: _format,
      maxParticipants: int.tryParse(_maxP.text) ?? 80,
      entryFee: double.tryParse(_fee.text) ?? 0,
      feeCurrency: _currency,
      registrationOpen: _regOpen,
      country: _country,
      tags: _tags.text
          .split(',')
          .map((e) => e.trim())
          .where((e) => e.isNotEmpty)
          .toList(),
    ));
    if (mounted) Navigator.pop(context);
  }

  final _df = DateFormat('d MMM yyyy');

  @override
  Widget build(BuildContext context) {
    return AdminFormDialog(
      title: widget.tournament == null
          ? 'Add Tournament'
          : 'Edit Tournament',
      saveLabel: widget.tournament == null
          ? 'Add Tournament'
          : 'Save Changes',
      onSave: _save,
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _tf('Tournament Name *', _name, required: true),
            _tf('Course Name *', _courseName, required: true),
            _tf('Description', _desc, maxLines: 3),
            const SizedBox(height: 4),
            Row(children: [
              Expanded(
                  child: _dropdown('Format', _formats, _format,
                      (v) => setState(() => _format = v!))),
              const SizedBox(width: 8),
              Expanded(
                  child: _dropdown(
                      'Country', _countries, _country,
                      (v) => setState(() => _country = v!))),
            ]),
            const SizedBox(height: 12),
            Row(children: [
              Expanded(
                  child: _datePicker(
                      'Start', _start, (d) => _start = d)),
              const SizedBox(width: 8),
              Expanded(
                  child:
                      _datePicker('End', _end, (d) => _end = d)),
            ]),
            const SizedBox(height: 8),
            _datePicker('Registration Deadline', _deadline,
                (d) => _deadline = d),
            const SizedBox(height: 12),
            Row(children: [
              Expanded(child: _tf('Max Players', _maxP)),
              const SizedBox(width: 8),
              Expanded(child: _tf('Entry Fee', _fee)),
              const SizedBox(width: 8),
              Expanded(
                  child: _dropdown(
                      'Currency', _currencies, _currency,
                      (v) => setState(() => _currency = v!))),
            ]),
            _tf('Tags (comma-separated)', _tags),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Registration Open'),
              value: _regOpen,
              onChanged: (v) => setState(() => _regOpen = v),
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

  Widget _dropdown<T>(String label, List<T> items, T value,
          ValueChanged<T?> onChanged) =>
      Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: DropdownButtonFormField<T>(
          value: value,
          decoration: InputDecoration(labelText: label),
          items: items
              .map((e) => DropdownMenuItem(
                  value: e, child: Text(e.toString())))
              .toList(),
          onChanged: onChanged,
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
