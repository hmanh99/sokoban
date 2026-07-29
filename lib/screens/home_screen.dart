import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../data/level_repository.dart';
import '../providers/progress_provider.dart';
import '../providers/game_provider.dart';
import 'level_select_screen.dart';
import 'game_screen.dart';

/// Home screen with title and navigation buttons.
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              colorScheme.primaryContainer,
              colorScheme.surface,
            ],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Game icon
                  Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      color: colorScheme.primary,
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          color: colorScheme.primary.withValues(alpha: 0.3),
                          blurRadius: 20,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: Icon(
                      Icons.inventory_2_rounded,
                      size: 56,
                      color: colorScheme.onPrimary,
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Title
                  Text(
                    'Sokoban',
                    style: Theme.of(context).textTheme.displayMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: colorScheme.onSurface,
                        ),
                  ),
                  const SizedBox(height: 8),

                  Text(
                    'Push boxes to their goals',
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                  ),
                  const SizedBox(height: 48),

                  // Play button — starts the next uncompleted level
                  SizedBox(
                    width: 220,
                    height: 52,
                    child: FilledButton.icon(
                      onPressed: () => _startPlay(context),
                      icon: const Icon(Icons.play_arrow_rounded, size: 28),
                      label: const Text('Play', style: TextStyle(fontSize: 18)),
                      style: FilledButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Level select button
                  SizedBox(
                    width: 220,
                    height: 52,
                    child: OutlinedButton.icon(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const LevelSelectScreen(),
                          ),
                        );
                      },
                      icon: const Icon(Icons.grid_view_rounded),
                      label: const Text('Level Select', style: TextStyle(fontSize: 16)),
                      style: OutlinedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 40),

                  // Progress indicator
                  Consumer<ProgressProvider>(
                    builder: (context, progress, _) {
                      final total = LevelRepository.levelCount;
                      final done = progress.completedCount;
                      return Column(
                        children: [
                          Text(
                            '$done / $total levels completed',
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                  color: colorScheme.onSurfaceVariant,
                                ),
                          ),
                          const SizedBox(height: 8),
                          SizedBox(
                            width: 180,
                            child: LinearProgressIndicator(
                              value: total > 0 ? done / total : 0,
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _startPlay(BuildContext context) {
    final progress = context.read<ProgressProvider>();
    final totalLevels = LevelRepository.levelCount;
    final nextId = progress.nextUncompletedLevel(totalLevels);
    final level = LevelRepository.getLevel(nextId);

    final gameProvider = context.read<GameProvider>();
    gameProvider.loadLevel(level);

    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const GameScreen()),
    );
  }
}
