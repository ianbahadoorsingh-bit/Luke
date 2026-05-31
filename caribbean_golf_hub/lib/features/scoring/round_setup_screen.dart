import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../../core/constants/app_colors.dart';
import '../../shared/models/course_model.dart';
import '../../shared/models/scorecard_model.dart';
import '../../shared/services/data_store.dart';
import 'active_round_screen.dart';

class RoundSetupScreen extends StatefulWidget {
  final bool isTournament;

  const RoundSetupScreen({super.key, this.isTournament = false});

  @override
  State<RoundSetupScreen> createState() => _RoundSetupScreenState();
}

class _RoundSetupScreenState extends State<RoundSetupScreen> {
  final _formKey = GlobalKey<FormState>();

  // Players
  final List<TextEditingController> _playerControllers = [
    TextEditingController(text: 'Player 1'),
  ];

  // Course
  GolfCourse? _selectedCourse;
  int _holes = 18;

  @override
  void initState() {
    super.initState();
    final courses = DataStore.instance.courses;
    if (courses.isNotEmpty) _selectedCourse = courses.first;
  }

  @override
  void dispose() {
    for (final c in _playerControllers) {
      c.dispose();
    }
    super.dispose();
  }

  void _addPlayer() {
    if (_playerControllers.length >= 8) return;
    setState(() {
      _playerControllers.add(TextEditingController(
          text: 'Player ${_playerControllers.length + 1}'));
    });
  }

  void _removePlayer(int index) {
    if (_playerControllers.length <= 1) return;
    setState(() {
      _playerControllers[index].dispose();
      _playerControllers.removeAt(index);
    });
  }

  void _startRound() {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedCourse == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a course')),
      );
      return;
    }

    final playerNames = _playerControllers
        .map((c) => c.text.trim())
        .where((n) => n.isNotEmpty)
        .toList();

    if (playerNames.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Add at least one player')),
      );
      return;
    }

    final pars = ScorecardRound.defaultPars(_holes);
    final holeScores = List.generate(
      _holes,
      (_) => Map<String, int?>.fromEntries(
        playerNames.map((p) => MapEntry(p, null)),
      ),
    );

    final round = ScorecardRound(
      id: const Uuid().v4(),
      courseId: _selectedCourse!.id,
      courseName: _selectedCourse!.name,
      date: DateTime.now(),
      totalHoles: _holes,
      playerNames: playerNames,
      holeScores: holeScores,
      pars: pars,
    );

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => ActiveRoundScreen(round: round),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final courses = DataStore.instance.courses;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.primaryGreen,
        title: Text(
            widget.isTournament
                ? 'Tournament Score Card'
                : 'New Round Setup',
            style: const TextStyle(color: Colors.white)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            // Players section
            _SectionHeader(
              icon: Icons.people,
              title: 'Players (${_playerControllers.length}/8)',
            ),
            const SizedBox(height: 12),
            ..._playerControllers.asMap().entries.map((entry) {
              final idx = entry.key;
              final ctrl = entry.value;
              return Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: ctrl,
                        decoration: InputDecoration(
                          labelText: 'Player ${idx + 1}',
                          prefixIcon: const Icon(Icons.person_outline),
                        ),
                        validator: (v) =>
                            (v == null || v.trim().isEmpty)
                                ? 'Enter a name'
                                : null,
                      ),
                    ),
                    if (_playerControllers.length > 1)
                      IconButton(
                        icon: const Icon(Icons.remove_circle_outline,
                            color: AppColors.error),
                        onPressed: () => _removePlayer(idx),
                        tooltip: 'Remove player',
                      ),
                  ],
                ),
              );
            }),
            if (_playerControllers.length < 8)
              TextButton.icon(
                icon: const Icon(Icons.add, color: AppColors.primaryGreen),
                label: const Text('Add Player',
                    style: TextStyle(color: AppColors.primaryGreen)),
                onPressed: _addPlayer,
              ),

            const SizedBox(height: 24),

            // Course section
            _SectionHeader(icon: Icons.golf_course, title: 'Course'),
            const SizedBox(height: 12),
            if (courses.isEmpty)
              const Text('No courses available. Add courses in Admin.',
                  style: TextStyle(color: AppColors.mediumGray))
            else
              DropdownButtonFormField<GolfCourse>(
                value: _selectedCourse,
                decoration: const InputDecoration(
                  labelText: 'Select Course',
                  prefixIcon: Icon(Icons.location_on_outlined),
                ),
                items: courses
                    .map((c) => DropdownMenuItem(
                        value: c,
                        child: Text(c.name,
                            overflow: TextOverflow.ellipsis)))
                    .toList(),
                onChanged: (c) => setState(() => _selectedCourse = c),
              ),

            const SizedBox(height: 20),

            // Holes
            _SectionHeader(icon: Icons.format_list_numbered, title: 'Holes'),
            const SizedBox(height: 12),
            SegmentedButton<int>(
              segments: const [
                ButtonSegment(value: 9, label: Text('9 Holes')),
                ButtonSegment(value: 18, label: Text('18 Holes')),
              ],
              selected: {_holes},
              onSelectionChanged: (s) =>
                  setState(() => _holes = s.first),
              style: SegmentedButton.styleFrom(
                selectedBackgroundColor: AppColors.primaryGreen,
                selectedForegroundColor: Colors.white,
              ),
            ),

            const SizedBox(height: 36),

            SizedBox(
              height: 50,
              child: ElevatedButton.icon(
                icon: const Icon(Icons.play_arrow),
                label: const Text('Start Round',
                    style: TextStyle(fontSize: 16)),
                onPressed: _startRound,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final IconData icon;
  final String title;

  const _SectionHeader({required this.icon, required this.title});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: AppColors.primaryGreen, size: 20),
        const SizedBox(width: 8),
        Text(
          title,
          style: const TextStyle(
            fontWeight: FontWeight.w700,
            fontSize: 16,
            color: AppColors.charcoal,
          ),
        ),
      ],
    );
  }
}
