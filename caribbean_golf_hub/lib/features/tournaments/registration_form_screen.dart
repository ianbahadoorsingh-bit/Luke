import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_strings.dart';
import '../../shared/models/tournament_model.dart';
import '../../shared/models/registration_model.dart';
import '../../shared/services/firestore_service.dart';

class RegistrationFormScreen extends StatefulWidget {
  final Tournament tournament;

  const RegistrationFormScreen({super.key, required this.tournament});

  @override
  State<RegistrationFormScreen> createState() => _RegistrationFormScreenState();
}

class _RegistrationFormScreenState extends State<RegistrationFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _clubCtrl = TextEditingController();
  final _hcpCtrl = TextEditingController();
  bool _submitting = false;
  bool _submitted = false;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _phoneCtrl.dispose();
    _clubCtrl.dispose();
    _hcpCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _submitting = true);

    try {
      final reg = TournamentRegistration(
        id: '',
        tournamentId: widget.tournament.id,
        tournamentName: widget.tournament.name,
        fullName: _nameCtrl.text.trim(),
        email: _emailCtrl.text.trim().toLowerCase(),
        phone: _phoneCtrl.text.trim(),
        homeClub: _clubCtrl.text.trim(),
        handicapIndex: double.tryParse(_hcpCtrl.text.trim()) ?? 0,
        submittedAt: DateTime.now(),
      );

      await FirestoreService.instance.submitRegistration(reg);
      if (mounted) setState(() => _submitted = true);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Submission failed: ${e.toString()}'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.registerTitle),
        backgroundColor: AppColors.primaryGreen,
        foregroundColor: AppColors.white,
      ),
      body: _submitted ? _SuccessView(tournament: widget.tournament) : _FormView(
        tournament: widget.tournament,
        formKey: _formKey,
        nameCtrl: _nameCtrl,
        emailCtrl: _emailCtrl,
        phoneCtrl: _phoneCtrl,
        clubCtrl: _clubCtrl,
        hcpCtrl: _hcpCtrl,
        submitting: _submitting,
        onSubmit: _submit,
      ),
    );
  }
}

class _FormView extends StatelessWidget {
  final Tournament tournament;
  final GlobalKey<FormState> formKey;
  final TextEditingController nameCtrl;
  final TextEditingController emailCtrl;
  final TextEditingController phoneCtrl;
  final TextEditingController clubCtrl;
  final TextEditingController hcpCtrl;
  final bool submitting;
  final VoidCallback onSubmit;

  const _FormView({
    required this.tournament,
    required this.formKey,
    required this.nameCtrl,
    required this.emailCtrl,
    required this.phoneCtrl,
    required this.clubCtrl,
    required this.hcpCtrl,
    required this.submitting,
    required this.onSubmit,
  });

  @override
  Widget build(BuildContext context) {
    final df = DateFormat('d MMMM yyyy');

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Form(
        key: formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Tournament summary card
            _TournamentSummaryCard(tournament: tournament, df: df),
            const SizedBox(height: 24),
            Text(
              'Your Details',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 16),
            // Full Name
            _FieldLabel(label: AppStrings.fullName),
            TextFormField(
              controller: nameCtrl,
              textCapitalization: TextCapitalization.words,
              decoration: const InputDecoration(
                hintText: 'e.g. Marcus James',
                prefixIcon: Icon(Icons.person_outline),
              ),
              validator: (v) =>
                  (v == null || v.trim().length < 2) ? 'Enter your full name' : null,
            ),
            const SizedBox(height: 14),
            // Email
            _FieldLabel(label: AppStrings.emailAddress),
            TextFormField(
              controller: emailCtrl,
              keyboardType: TextInputType.emailAddress,
              autocorrect: false,
              decoration: const InputDecoration(
                hintText: 'e.g. marcus@example.com',
                prefixIcon: Icon(Icons.email_outlined),
              ),
              validator: (v) {
                if (v == null || v.trim().isEmpty) return 'Enter your email';
                final emailRx = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');
                if (!emailRx.hasMatch(v.trim())) return 'Enter a valid email';
                return null;
              },
            ),
            const SizedBox(height: 14),
            // Phone
            _FieldLabel(label: AppStrings.phoneNumber),
            TextFormField(
              controller: phoneCtrl,
              keyboardType: TextInputType.phone,
              inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[0-9+\-\s()]'))],
              decoration: const InputDecoration(
                hintText: '+1-868-000-0000',
                prefixIcon: Icon(Icons.phone_outlined),
              ),
              validator: (v) =>
                  (v == null || v.trim().length < 7) ? 'Enter a valid phone number' : null,
            ),
            const SizedBox(height: 14),
            // Home Club
            _FieldLabel(label: AppStrings.homeClub),
            TextFormField(
              controller: clubCtrl,
              textCapitalization: TextCapitalization.words,
              decoration: const InputDecoration(
                hintText: 'e.g. St. Andrews Golf Club',
                prefixIcon: Icon(Icons.sports_golf_outlined),
              ),
              validator: (v) =>
                  (v == null || v.trim().isEmpty) ? 'Enter your home club' : null,
            ),
            const SizedBox(height: 14),
            // Handicap Index
            _FieldLabel(label: AppStrings.handicapIndex),
            TextFormField(
              controller: hcpCtrl,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'^\d{0,2}\.?\d{0,1}')),
              ],
              decoration: const InputDecoration(
                hintText: 'e.g. 14.2',
                prefixIcon: Icon(Icons.bar_chart_outlined),
                suffixText: 'HCP',
              ),
              validator: (v) {
                if (v == null || v.trim().isEmpty) return 'Enter your handicap index';
                final hcp = double.tryParse(v.trim());
                if (hcp == null || hcp < 0 || hcp > 54) {
                  return 'Enter a valid handicap (0.0 – 54.0)';
                }
                return null;
              },
            ),
            const SizedBox(height: 28),
            // Disclaimer
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.surfaceGreen,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.info_outline,
                      color: AppColors.primaryGreen, size: 16),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Your registration is subject to confirmation by the tournament '
                      'organiser. You will receive a follow-up email within 48 hours.',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppColors.primaryGreen,
                          ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: submitting ? null : onSubmit,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: submitting
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: AppColors.white,
                        ),
                      )
                    : const Text(AppStrings.submitRegistration),
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}

class _TournamentSummaryCard extends StatelessWidget {
  final Tournament tournament;
  final DateFormat df;

  const _TournamentSummaryCard({required this.tournament, required this.df});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: AppColors.greenGradient,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            tournament.name,
            style: const TextStyle(
              color: AppColors.white,
              fontSize: 18,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          Row(children: [
            const Icon(Icons.calendar_today, color: Colors.white70, size: 14),
            const SizedBox(width: 6),
            Text(
              df.format(tournament.startDate),
              style: const TextStyle(color: Colors.white70, fontSize: 13),
            ),
          ]),
          const SizedBox(height: 4),
          Row(children: [
            const Icon(Icons.golf_course, color: Colors.white70, size: 14),
            const SizedBox(width: 6),
            Text(
              tournament.courseName,
              style: const TextStyle(color: Colors.white70, fontSize: 13),
            ),
          ]),
          const SizedBox(height: 4),
          Row(children: [
            const Icon(Icons.payments_outlined, color: AppColors.accentGold, size: 14),
            const SizedBox(width: 6),
            Text(
              '${tournament.feeCurrency} ${tournament.entryFee.toStringAsFixed(0)} entry fee',
              style: const TextStyle(
                  color: AppColors.accentGold,
                  fontSize: 13,
                  fontWeight: FontWeight.w600),
            ),
          ]),
        ],
      ),
    );
  }
}

class _FieldLabel extends StatelessWidget {
  final String label;

  const _FieldLabel({required this.label});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Text(
        label,
        style: Theme.of(context).textTheme.labelMedium?.copyWith(
              color: AppColors.charcoal,
              fontWeight: FontWeight.w600,
            ),
      ),
    );
  }
}

class _SuccessView extends StatelessWidget {
  final Tournament tournament;

  const _SuccessView({required this.tournament});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: AppColors.success.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.check_circle,
                  color: AppColors.success, size: 48),
            ),
            const SizedBox(height: 20),
            Text(
              'You\'re Registered!',
              style: Theme.of(context).textTheme.displayMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              AppStrings.registrationSuccess,
              style: Theme.of(context).textTheme.bodyLarge,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Tournament: ${tournament.name}',
              style: Theme.of(context)
                  .textTheme
                  .bodyMedium
                  ?.copyWith(fontWeight: FontWeight.w600),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            OutlinedButton.icon(
              onPressed: () =>
                  Navigator.of(context).popUntil((r) => r.isFirst),
              icon: const Icon(Icons.home_outlined),
              label: const Text('Back to Tournaments'),
            ),
          ],
        ),
      ),
    );
  }
}
