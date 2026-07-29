import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../data/level_repository.dart';
import '../models/position.dart';
import '../providers/game_provider.dart';
import '../widgets/game_board.dart';
import '../widgets/d_pad.dart';
import '../widgets/win_dialog.dart';

/// Main gameplay screen with the grid, HUD, controls, and win detection.
class GameScreen extends StatefulWidget {
  const GameScreen({super.key});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  final FocusNode _focusNode = FocusNode();
  bool _winDialogShown = false;

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Request keyboard focus for arrow/WASD support.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _focusNode.requestFocus();
    });

    return KeyboardListener(
      focusNode: _focusNode,
      autofocus: true,
      onKeyEvent: _handleKeyEvent,
      child: Consumer<GameProvider>(
        builder: (context, game, _) {
          // Show win dialog when game is won (only once per win).
          if (game.isWon && !_winDialogShown) {
            _winDialogShown = true;
            WidgetsBinding.instance.addPostFrameCallback((_) {
              _showWinDialog(context, game);
            });
          }

          return Scaffold(
            appBar: AppBar(
              title: Text('Level ${game.currentLevel.id}: ${game.currentLevel.name}'),
              centerTitle: true,
              actions: [
                // Undo button
                IconButton(
                  onPressed: game.canUndo ? () => game.undo() : null,
                  icon: const Icon(Icons.undo),
                  tooltip: 'Undo',
                ),
                // Restart button
                IconButton(
                  onPressed: () {
                    _winDialogShown = false;
                    game.restart();
                  },
                  icon: const Icon(Icons.refresh),
                  tooltip: 'Restart',
                ),
              ],
            ),
            body: SafeArea(
              child: Column(
                children: [
                  // HUD — move count and push count
                  _buildHud(context, game),

                  // Game grid — takes remaining space
                  Expanded(
                    child: GestureDetector(
                      onVerticalDragEnd: (details) =>
                          _handleSwipe(game, details, Axis.vertical),
                      onHorizontalDragEnd: (details) =>
                          _handleSwipe(game, details, Axis.horizontal),
                      child: Padding(
                        padding: const EdgeInsets.all(8),
                        child: GameBoard(
                          grid: game.renderGrid,
                          rows: game.gridRows,
                          cols: game.gridCols,
                        ),
                      ),
                    ),
                  ),

                  // D-pad controls
                  Padding(
                    padding: const EdgeInsets.only(bottom: 16, top: 8),
                    child: DPad(
                      onDirection: (dir) => game.move(dir),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildHud(BuildContext context, GameProvider game) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _hudItem(context, Icons.directions_walk, 'Moves', game.moveCount),
          _hudItem(context, Icons.push_pin, 'Pushes', game.pushCount),
        ],
      ),
    );
  }

  Widget _hudItem(BuildContext context, IconData icon, String label, int value) {
    final colorScheme = Theme.of(context).colorScheme;
    return Row(
      children: [
        Icon(icon, size: 18, color: colorScheme.primary),
        const SizedBox(width: 4),
        Text('$label: ', style: Theme.of(context).textTheme.bodyMedium),
        Text(
          '$value',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
      ],
    );
  }

  /// Handle keyboard arrow keys and WASD.
  void _handleKeyEvent(KeyEvent event) {
    if (event is! KeyDownEvent && event is! KeyRepeatEvent) return;

    final game = context.read<GameProvider>();
    final direction = switch (event.logicalKey) {
      LogicalKeyboardKey.arrowUp || LogicalKeyboardKey.keyW => Direction.up,
      LogicalKeyboardKey.arrowDown || LogicalKeyboardKey.keyS => Direction.down,
      LogicalKeyboardKey.arrowLeft || LogicalKeyboardKey.keyA => Direction.left,
      LogicalKeyboardKey.arrowRight || LogicalKeyboardKey.keyD => Direction.right,
      LogicalKeyboardKey.keyZ => null, // handled below as undo
      LogicalKeyboardKey.keyR => null, // handled below as restart
      _ => null,
    };

    if (direction != null) {
      game.move(direction);
    } else if (event.logicalKey == LogicalKeyboardKey.keyZ) {
      game.undo();
    } else if (event.logicalKey == LogicalKeyboardKey.keyR) {
      _winDialogShown = false;
      game.restart();
    }
  }

  /// Handle swipe gestures.
  void _handleSwipe(GameProvider game, DragEndDetails details, Axis axis) {
    const minVelocity = 100.0;
    final velocity = details.primaryVelocity ?? 0;
    if (velocity.abs() < minVelocity) return;

    final direction = axis == Axis.vertical
        ? (velocity < 0 ? Direction.up : Direction.down)
        : (velocity < 0 ? Direction.left : Direction.right);

    game.move(direction);
  }

  /// Show the win dialog.
  void _showWinDialog(BuildContext context, GameProvider game) {
    final levels = LevelRepository.getAllLevels();
    final currentId = game.currentLevel.id;
    final hasNext = levels.any((l) => l.id == currentId + 1);

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => WinDialog(
        levelId: currentId,
        levelName: game.currentLevel.name,
        moveCount: game.moveCount,
        pushCount: game.pushCount,
        hasNextLevel: hasNext,
        onNextLevel: () {
          Navigator.pop(context); // close dialog
          _winDialogShown = false;
          final nextLevel = LevelRepository.getLevel(currentId + 1);
          game.loadLevel(nextLevel);
        },
        onLevelSelect: () {
          Navigator.pop(context); // close dialog
          Navigator.pop(context); // back to level select
        },
      ),
    );
  }
}
