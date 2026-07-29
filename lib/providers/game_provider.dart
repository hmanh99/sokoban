import 'dart:async';
import 'package:flutter/foundation.dart';
import '../logic/game_engine.dart';
import '../models/level.dart';
import '../models/position.dart';
import '../models/tile.dart';
import 'progress_provider.dart';

/// Callback types for UI feedback events.
typedef MoveCallback = void Function();
typedef BoxOnGoalCallback = void Function(Position goalPos);
typedef InvalidMoveCallback = void Function();

/// ChangeNotifier wrapping the [GameEngine] for use with Provider.
///
/// Acts as the bridge between the pure-Dart game logic and Flutter widgets.
/// On level completion, automatically records progress via [ProgressProvider].
/// Tracks a live timer, provides callbacks for invalid moves and box-on-goal events.
class GameProvider extends ChangeNotifier {
  final GameEngine _engine = GameEngine();
  final ProgressProvider _progressProvider;
  bool _hasWon = false;

  // Timer state
  Timer? _timer;
  int _elapsedSeconds = 0;
  bool _timerStarted = false;

  // Event callbacks for UI feedback
  InvalidMoveCallback? onInvalidMove;
  BoxOnGoalCallback? onBoxLandedOnGoal;

  // Track which boxes were on goals before a move to detect new placements
  Set<Position> _boxesOnGoalBefore = {};

  GameProvider(this._progressProvider);

  // --- Delegated getters ---

  Level get currentLevel => _engine.level;
  Position get playerPos => _engine.playerPos;
  Set<Position> get boxPositions => _engine.boxPositions;
  int get moveCount => _engine.moveCount;
  int get pushCount => _engine.pushCount;
  bool get canUndo => _engine.canUndo;
  bool get isWon => _hasWon;
  List<List<Tile>> get renderGrid => _engine.renderGrid;
  int get elapsedSeconds => _elapsedSeconds;

  int get gridRows => _engine.level.rows;
  int get gridCols => _engine.level.cols;

  String get timerDisplay {
    final mins = (_elapsedSeconds ~/ 60).toString().padLeft(2, '0');
    final secs = (_elapsedSeconds % 60).toString().padLeft(2, '0');
    return '$mins:$secs';
  }

  /// Load a level and reset game state.
  void loadLevel(Level level) {
    _engine.loadLevel(level);
    _hasWon = false;
    _stopTimer();
    _elapsedSeconds = 0;
    _timerStarted = false;
    _boxesOnGoalBefore = {};
    notifyListeners();
  }

  /// Attempt to move in the given direction.
  void move(Direction direction) {
    if (_hasWon) return;

    // Snapshot which boxes are on goals before moving.
    _boxesOnGoalBefore = _engine.boxPositions
        .where((b) => _engine.level.goalPositions.contains(b))
        .toSet();

    final success = _engine.tryMove(direction);
    if (success) {
      // Start timer on first successful move.
      if (!_timerStarted) {
        _timerStarted = true;
        _startTimer();
      }

      // Detect new boxes that just landed on goals.
      for (final box in _engine.boxPositions) {
        if (_engine.level.goalPositions.contains(box) &&
            !_boxesOnGoalBefore.contains(box)) {
          onBoxLandedOnGoal?.call(box);
        }
      }

      if (_engine.isWon) {
        _hasWon = true;
        _stopTimer();
        _progressProvider.completeLevel(
          _engine.level.id,
          _engine.moveCount,
        );
      }
      notifyListeners();
    } else {
      // Invalid move — fire callback for shake/haptic feedback.
      onInvalidMove?.call();
    }
  }

  /// Undo the last move.
  void undo() {
    if (_hasWon) return;
    if (_engine.undo()) {
      notifyListeners();
    }
  }

  /// Restart the current level.
  void restart() {
    _engine.restart();
    _hasWon = false;
    _stopTimer();
    _elapsedSeconds = 0;
    _timerStarted = false;
    _boxesOnGoalBefore = {};
    notifyListeners();
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      _elapsedSeconds++;
      notifyListeners();
    });
  }

  void _stopTimer() {
    _timer?.cancel();
    _timer = null;
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}
