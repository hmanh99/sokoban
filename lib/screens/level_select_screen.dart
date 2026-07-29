import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../data/level_repository.dart';
import '../providers/progress_provider.dart';
import '../providers/game_provider.dart';
import '../widgets/level_card.dart';
import 'game_screen.dart';

/// Grid of level cards showing completion status and best moves.
class LevelSelectScreen extends StatelessWidget {
  const LevelSelectScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final levels = LevelRepository.getAllLevels();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Select Level'),
        centerTitle: true,
      ),
      body: Consumer<ProgressProvider>(
        builder: (context, progress, _) {
          return LayoutBuilder(
            builder: (context, constraints) {
              // Responsive columns: 3 on phone, more on wider screens.
              final crossAxisCount = constraints.maxWidth > 900
                  ? 6
                  : constraints.maxWidth > 600
                      ? 4
                      : 3;

              return GridView.builder(
                padding: const EdgeInsets.all(12),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: crossAxisCount,
                  mainAxisSpacing: 8,
                  crossAxisSpacing: 8,
                  childAspectRatio: 0.85,
                ),
                itemCount: levels.length,
                itemBuilder: (context, index) {
                  final level = levels[index];
                  return LevelCard(
                    level: level,
                    isCompleted: progress.isCompleted(level.id),
                    bestMoves: progress.bestMoves(level.id),
                    onTap: () {
                      final gameProvider = context.read<GameProvider>();
                      gameProvider.loadLevel(level);
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const GameScreen(),
                        ),
                      );
                    },
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
