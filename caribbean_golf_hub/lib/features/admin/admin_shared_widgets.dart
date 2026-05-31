import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';

/// Common action bar at top of each admin tab
class AdminActionBar extends StatelessWidget {
  final int count;
  final String label;
  final VoidCallback onAdd;

  const AdminActionBar({
    super.key,
    required this.count,
    required this.label,
    required this.onAdd,
  });

  @override
  Widget build(BuildContext context) {
    final singular = label.endsWith('s') ? label.substring(0, label.length - 1) : label;
    final capitalized =
        singular[0].toUpperCase() + singular.substring(1);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text('$count $label',
              style: const TextStyle(color: AppColors.mediumGray, fontSize: 13)),
          ElevatedButton.icon(
            onPressed: onAdd,
            icon: const Icon(Icons.add, size: 18),
            label: Text('Add $capitalized'),
          ),
        ],
      ),
    );
  }
}

/// Edit + Delete icon buttons row
class AdminRowActions extends StatelessWidget {
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const AdminRowActions({
    super.key,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Row(mainAxisSize: MainAxisSize.min, children: [
      IconButton(
        icon: const Icon(Icons.edit_outlined, color: AppColors.primaryGreen),
        onPressed: onEdit,
        tooltip: 'Edit',
      ),
      IconButton(
        icon: const Icon(Icons.delete_outline, color: AppColors.error),
        onPressed: onDelete,
        tooltip: 'Delete',
      ),
    ]);
  }
}

/// Reusable delete confirmation dialog
class AdminDeleteDialog extends StatelessWidget {
  final String name;

  const AdminDeleteDialog({super.key, required this.name});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Confirm Delete'),
      content: Text('Delete "$name"? This cannot be undone.'),
      actions: [
        TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel')),
        ElevatedButton(
          style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
          onPressed: () => Navigator.pop(context, true),
          child: const Text('Delete'),
        ),
      ],
    );
  }
}

/// Reusable form dialog wrapper (scrollable, constrained width)
class AdminFormDialog extends StatelessWidget {
  final String title;
  final String saveLabel;
  final VoidCallback onSave;
  final Widget child;

  const AdminFormDialog({
    super.key,
    required this.title,
    required this.saveLabel,
    required this.onSave,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      insetPadding: const EdgeInsets.all(16),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 640, maxHeight: 680),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(title,
                        style: Theme.of(context).textTheme.headlineMedium),
                  ),
                  IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.pop(context)),
                ],
              ),
              const Divider(),
              Expanded(child: SingleChildScrollView(child: child)),
              const Divider(),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Cancel')),
                  const SizedBox(width: 12),
                  ElevatedButton(onPressed: onSave, child: Text(saveLabel)),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
