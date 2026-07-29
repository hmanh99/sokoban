import 'package:flutter/material.dart';
import '../models/level.dart';

/// Card widget for the level select grid.
///
/// Shows the level number, difficulty color badge, and completion status.
/// Completed levels show a checkmark and best move count.
class LevelCard extends StatelessWidget {
  final Level level;
  final bool isCompleted;
  final int? bestMoves;
  final VoidCallback onTap;

  const LevelCard({
    super.key,
    required this.level,
    required this.isCompleted,
    this.bestMoves,
    required this.onTap,
  });


  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Card(
      elevation: isCompleted ? 1 : 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: isCompleted
            ? BorderSide(color: colorScheme.primary.withValues(alpha: 0.4), width: 1.5)
            : BorderSide.none,
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Level number with optional checkmark
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    '${level.id}',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: isCompleted
                              ? colorScheme.primary
                              : colorScheme.onSurface,
                        ),
                  ),
                  if (isCompleted) ...[
                    const SizedBox(width: 4),
                    Icon(Icons.check_circle, color: colorScheme.primary, size: 20),
                  ],
                ],
              ),
              const SizedBox(height: 4),

              // Level name
              Text(
                level.name,
                style: Theme.of(context).textTheme.bodySmall,
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 6),

              // Best moves if completed
              if (bestMoves != null) ...[
                const SizedBox(height: 4),
                Text(
                  'Best: $bestMoves moves',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                        fontSize: 10,
                      ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
