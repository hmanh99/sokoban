import '../models/tile.dart';
import '../models/position.dart';
import '../models/level.dart';
import '../models/move_record.dart';

/// Pure-Dart game engine implementing all Sokoban rules.
///
/// This class has NO Flutter dependencies and can be unit-tested independently.
/// It tracks the current game state (player position, box positions, move/push
/// counts) and provides movement, undo, restart, and win-detection.
class GameEngine {
  late Level _level;
  late Position _playerPos;
  late Set<Position> _boxPositions;
  int _moveCount = 0;
  int _pushCount = 0;
  final List<MoveRecord> _history = [];

  // --- Public getters ---

  Level get level => _level;
  Position get playerPos => _playerPos;
  Set<Position> get boxPositions => Set.unmodifiable(_boxPositions);
  int get moveCount => _moveCount;
  int get pushCount => _pushCount;
  bool get canUndo => _history.isNotEmpty;

  /// Whether the level is solved: every goal tile has a box on it.
  bool get isWon {
    for (final goal in _level.goalPositions) {
      if (!_boxPositions.contains(goal)) return false;
    }
    return _level.goalPositions.isNotEmpty;
  }

  /// Load a level and initialize game state.
  void loadLevel(Level level) {
    _level = level;
    _playerPos = level.playerStart;
    _boxPositions = Set<Position>.from(level.initialBoxPositions);
    _moveCount = 0;
    _pushCount = 0;
    _history.clear();
  }

  /// Attempt to move the player in [direction].
  ///
  /// Returns true if the move was valid and executed.
  ///
  /// Movement rules:
  /// 1. Target cell must be in bounds and not a wall.
  /// 2. If target has a box, the cell behind the box (in the same direction)
  ///    must be in bounds, not a wall, and not another box.
  /// 3. Player moves; if pushing, the box moves too.
  bool tryMove(Direction direction) {
    final target = _playerPos.move(direction);

    // Check bounds and walls.
    if (!_isInBounds(target) || _isWall(target)) return false;

    if (_hasBox(target)) {
      // There's a box at the target — try to push it.
      final behindBox = target.move(direction);
      if (!_isInBounds(behindBox) || _isWall(behindBox) || _hasBox(behindBox)) {
        return false; // Can't push: wall, another box, or out of bounds behind.
      }

      // Valid push: record, then move box and player.
      _history.add(
        MoveRecord(
          previousPlayerPos: _playerPos,
          pushedBoxFrom: target,
          pushedBoxTo: behindBox,
        ),
      );
      _boxPositions.remove(target);
      _boxPositions.add(behindBox);
      _playerPos = target;
      _moveCount++;
      _pushCount++;
      return true;
    }

    // No box — just move the player onto empty floor or goal.
    _history.add(MoveRecord(previousPlayerPos: _playerPos));
    _playerPos = target;
    _moveCount++;
    return true;
  }

  /// Undo the last move. Returns true if there was a move to undo.
  bool undo() {
    if (_history.isEmpty) return false;

    final record = _history.removeLast();
    _playerPos = record.previousPlayerPos;
    _moveCount--;

    if (record.wasPush) {
      // Reverse the box push.
      _boxPositions.remove(record.pushedBoxTo!);
      _boxPositions.add(record.pushedBoxFrom!);
      _pushCount--;
    }

    return true;
  }

  /// Restart the current level from scratch.
  void restart() {
    _playerPos = _level.playerStart;
    _boxPositions = Set<Position>.from(_level.initialBoxPositions);
    _moveCount = 0;
    _pushCount = 0;
    _history.clear();
  }

  /// Build a 2D grid of [Tile] values representing the current visual state.
  ///
  /// Overlays dynamic objects (player, boxes) onto the static base grid.
  List<List<Tile>> get renderGrid {
    final grid = <List<Tile>>[];
    for (int r = 0; r < _level.rows; r++) {
      final row = <Tile>[];
      for (int c = 0; c < _level.cols; c++) {
        final pos = Position(r, c);
        final base =
            (r < _level.baseGrid.length && c < _level.baseGrid[r].length)
            ? _level.baseGrid[r][c]
            : Tile.floor;

        if (pos == _playerPos) {
          row.add(base == Tile.goal ? Tile.playerOnGoal : Tile.player);
        } else if (_boxPositions.contains(pos)) {
          row.add(base == Tile.goal ? Tile.boxOnGoal : Tile.box);
        } else {
          row.add(base);
        }
      }
      grid.add(row);
    }
    return grid;
  }

  // --- Private helpers ---

  bool _isInBounds(Position pos) {
    return pos.row >= 0 &&
        pos.row < _level.rows &&
        pos.col >= 0 &&
        pos.col < _level.cols;
  }

  bool _isWall(Position pos) {
    if (pos.row >= _level.baseGrid.length) return false;
    if (pos.col >= _level.baseGrid[pos.row].length) return false;
    return _level.baseGrid[pos.row][pos.col] == Tile.wall;
  }

  bool _hasBox(Position pos) => _boxPositions.contains(pos);
}
