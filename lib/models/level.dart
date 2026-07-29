import 'tile.dart';
import 'position.dart';

/// Difficulty tier for a level.
enum Difficulty { beginner, intermediate, advanced, expert }

/// Represents a Sokoban level parsed from standard notation.
class Level {
  final int id;
  final String name;

  /// The static grid (walls, floors, goals — no dynamic objects).
  /// Dynamic objects (player, boxes) are tracked separately.
  final List<List<Tile>> baseGrid;

  /// Starting player position.
  final Position playerStart;

  /// Set of goal tile positions.
  final Set<Position> goalPositions;

  /// Set of initial box positions.
  final Set<Position> initialBoxPositions;

  /// Grid dimensions.
  int get rows => baseGrid.length;
  int get cols => baseGrid.isEmpty ? 0 : baseGrid.map((r) => r.length).reduce((a, b) => a > b ? a : b);

  Level({
    required this.id,
    required this.name,
    required this.baseGrid,
    required this.playerStart,
    required this.goalPositions,
    required this.initialBoxPositions,
  });

  /// Parse a level from standard Sokoban notation lines.
  ///
  /// Characters: # wall, (space) floor, . goal, @ player,
  /// + player-on-goal, $ box, * box-on-goal
  factory Level.fromLines({
    required int id,
    required String name,
    required List<String> lines,
  }) {
    Position? playerStart;
    final goals = <Position>{};
    final boxes = <Position>{};

    // First pass: find the max width for padding.
    final maxWidth = lines.fold<int>(0, (m, l) => l.length > m ? l.length : m);

    final baseGrid = <List<Tile>>[];

    for (int r = 0; r < lines.length; r++) {
      final row = <Tile>[];
      // Pad each line to max width so the grid is rectangular.
      final line = lines[r].padRight(maxWidth);

      for (int c = 0; c < line.length; c++) {
        final ch = line[c];
        final tile = Tile.fromChar(ch);

        // Extract dynamic objects and store base tile.
        if (tile == Tile.player) {
          playerStart = Position(r, c);
          row.add(Tile.floor);
        } else if (tile == Tile.playerOnGoal) {
          playerStart = Position(r, c);
          goals.add(Position(r, c));
          row.add(Tile.goal);
        } else if (tile == Tile.box) {
          boxes.add(Position(r, c));
          row.add(Tile.floor);
        } else if (tile == Tile.boxOnGoal) {
          boxes.add(Position(r, c));
          goals.add(Position(r, c));
          row.add(Tile.goal);
        } else if (tile == Tile.goal) {
          goals.add(Position(r, c));
          row.add(Tile.goal);
        } else {
          row.add(tile);
        }
      }
      baseGrid.add(row);
    }

    if (playerStart == null) {
      throw ArgumentError('Level $id ("$name") has no player start position (@).');
    }

    if (goals.length != boxes.length) {
      throw ArgumentError(
        'Level $id ("$name"): mismatch — ${goals.length} goals vs ${boxes.length} boxes.',
      );
    }

    return Level(
      id: id,
      name: name,
      baseGrid: baseGrid,
      playerStart: playerStart,
      goalPositions: goals,
      initialBoxPositions: boxes,
    );
  }
}
