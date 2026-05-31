import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../../../core/constants/app_colors.dart';
import '../../../shared/models/course_model.dart';
import '../../../shared/services/data_store.dart';
import '../admin_shared_widgets.dart';

class AdminCoursesTab extends StatelessWidget {
  const AdminCoursesTab({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<GolfCourse>>(
      initialData: DataStore.instance.courses,
      stream: DataStore.instance.watchCourses(),
      builder: (context, snap) {
        final courses = snap.data ?? [];
        return Column(
          children: [
            AdminActionBar(
              count: courses.length,
              label: 'courses',
              onAdd: () => _openForm(context, null),
            ),
            Expanded(
              child: ListView.separated(
                itemCount: courses.length,
                separatorBuilder: (_, __) => const Divider(height: 1),
                itemBuilder: (context, i) {
                  final c = courses[i];
                  return ListTile(
                    leading: CircleAvatar(
                      backgroundColor: AppColors.surfaceGreen,
                      child: const Icon(Icons.golf_course,
                          color: AppColors.primaryGreen, size: 20),
                    ),
                    title: Text(c.name,
                        style:
                            const TextStyle(fontWeight: FontWeight.w600)),
                    subtitle: Text(c.location),
                    trailing: AdminRowActions(
                      onEdit: () => _openForm(context, c),
                      onDelete: () => _confirmDelete(context, c),
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

  void _openForm(BuildContext context, GolfCourse? course) => showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => _CourseDialog(course: course));

  Future<void> _confirmDelete(BuildContext context, GolfCourse c) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AdminDeleteDialog(name: c.name),
    );
    if (ok == true) await DataStore.instance.deleteCourse(c.id);
  }
}

class _CourseDialog extends StatefulWidget {
  final GolfCourse? course;
  const _CourseDialog({this.course});

  @override
  State<_CourseDialog> createState() => _CourseDialogState();
}

class _CourseDialogState extends State<_CourseDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _name,
      _location,
      _contact,
      _whatsapp,
      _desc,
      _amenities,
      _lWD,
      _lWE,
      _lTW,
      _tWD,
      _tWE,
      _tTW,
      _notes;

  @override
  void initState() {
    super.initState();
    final c = widget.course;
    _name = TextEditingController(text: c?.name ?? '');
    _location = TextEditingController(text: c?.location ?? '');
    _contact = TextEditingController(text: c?.contactNumber ?? '');
    _whatsapp = TextEditingController(text: c?.whatsappNumber ?? '');
    _desc = TextEditingController(text: c?.description ?? '');
    _amenities =
        TextEditingController(text: c?.amenities.join(', ') ?? '');
    _lWD = TextEditingController(
        text: c?.rates.local.weekday?.toStringAsFixed(0) ?? '');
    _lWE = TextEditingController(
        text: c?.rates.local.weekend?.toStringAsFixed(0) ?? '');
    _lTW = TextEditingController(
        text: c?.rates.local.twilight?.toStringAsFixed(0) ?? '');
    _tWD = TextEditingController(
        text: c?.rates.tourist.weekday?.toStringAsFixed(0) ?? '');
    _tWE = TextEditingController(
        text: c?.rates.tourist.weekend?.toStringAsFixed(0) ?? '');
    _tTW = TextEditingController(
        text: c?.rates.tourist.twilight?.toStringAsFixed(0) ?? '');
    _notes = TextEditingController(text: c?.rates.notes ?? '');
  }

  @override
  void dispose() {
    for (final c in [
      _name,
      _location,
      _contact,
      _whatsapp,
      _desc,
      _amenities,
      _lWD,
      _lWE,
      _lTW,
      _tWD,
      _tWE,
      _tTW,
      _notes
    ]) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    await DataStore.instance.saveCourse(GolfCourse(
      id: widget.course?.id ?? const Uuid().v4(),
      name: _name.text.trim(),
      location: _location.text.trim(),
      contactNumber: _contact.text.trim(),
      whatsappNumber:
          _whatsapp.text.trim().replaceAll(RegExp(r'[^0-9]'), ''),
      description: _desc.text.trim(),
      amenities: _amenities.text
          .split(',')
          .map((e) => e.trim())
          .where((e) => e.isNotEmpty)
          .toList(),
      rates: CourseRates(
        local: RateTier(
          weekday: double.tryParse(_lWD.text),
          weekend: double.tryParse(_lWE.text),
          twilight: double.tryParse(_lTW.text),
        ),
        tourist: RateTier(
          weekday: double.tryParse(_tWD.text),
          weekend: double.tryParse(_tWE.text),
          twilight: double.tryParse(_tTW.text),
        ),
        notes:
            _notes.text.trim().isEmpty ? null : _notes.text.trim(),
      ),
    ));
    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return AdminFormDialog(
      title: widget.course == null ? 'Add Course' : 'Edit Course',
      saveLabel:
          widget.course == null ? 'Add Course' : 'Save Changes',
      onSave: _save,
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _tf('Course Name *', _name, required: true),
            _tf('Location *', _location, required: true),
            _tf('Contact Number', _contact),
            _tf('WhatsApp (digits only)', _whatsapp),
            _tf('Description', _desc, maxLines: 3),
            _tf('Amenities (comma-separated)', _amenities),
            const SizedBox(height: 16),
            const Text('Local Green Fees (TTD)',
                style: TextStyle(fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            Row(children: [
              Expanded(child: _numField('Weekday', _lWD)),
              const SizedBox(width: 8),
              Expanded(child: _numField('Weekend', _lWE)),
              const SizedBox(width: 8),
              Expanded(child: _numField('Twilight', _lTW)),
            ]),
            const SizedBox(height: 16),
            const Text('Tourist Green Fees (USD)',
                style: TextStyle(fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            Row(children: [
              Expanded(child: _numField('Weekday', _tWD)),
              const SizedBox(width: 8),
              Expanded(child: _numField('Weekend', _tWE)),
              const SizedBox(width: 8),
              Expanded(child: _numField('Twilight', _tTW)),
            ]),
            _tf('Rate Notes', _notes),
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

  Widget _numField(String label, TextEditingController c) =>
      TextFormField(
        controller: c,
        keyboardType:
            const TextInputType.numberWithOptions(decimal: true),
        decoration: InputDecoration(labelText: label),
      );
}
