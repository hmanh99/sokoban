import 'package:flutter/material.dart';

/// Victory dialog shown when a level is completed.
///
/// Displays the move count and push count, with buttons to proceed to the
/// next level or return to the level select screen.
class WinDialog extends StatelessWidget {
  final int levelId;
  final String levelName;
  final int moveCount;
  final int pushCount;
  final bool hasNextLevel;
  final VoidCallback onNextLevel;
  final VoidCallback onLevelSelect;

  const WinDialog({
    super.key,
    required this.levelId,
    required this.levelName,
    required this.moveCount,
    required this.pushCount,
    required this.hasNextLevel,
    required this.onNextLevel,
    required this.onLevelSelect,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: Row(
        children: [
          Icon(Icons.emoji_events, color: colorScheme.primary, size: 32),
          const SizedBox(width: 12),
          const Expanded(child: Text('Level Complete!')),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Level $levelId: $levelName',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 20),
          _StatRow(
            icon: Icons.directions_walk,
            label: 'Moves',
            value: moveCount.toString(),
          ),
          const SizedBox(height: 8),
          _StatRow(
            icon: Icons.push_pin,
            label: 'Pushes',
            value: pushCount.toString(),
          ),
        ],
      ),
      actionsAlignment: MainAxisAlignment.center,
      actions: [
        OutlinedButton.icon(
          onPressed: onLevelSelect,
          icon: const Icon(Icons.grid_view),
          label: const Text('Level Select'),
        ),
        if (hasNextLevel)
          FilledButton.icon(
            onPressed: onNextLevel,
            icon: const Icon(Icons.arrow_forward),
            label: const Text('Next Level'),
          ),
      ],
    );
  }
}

class _StatRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _StatRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(icon, size: 20, color: Theme.of(context).colorScheme.primary),
        const SizedBox(width: 8),
        Text('$label: ', style: Theme.of(context).textTheme.bodyLarge),
        Text(
          value,
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
      ],
    );
  }
}
