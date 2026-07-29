import 'package:flutter_test/flutter_test.dart';
import 'package:sokoban/logic/game_engine.dart';
import 'package:sokoban/models/level.dart';
import 'package:sokoban/models/position.dart';
import 'package:sokoban/models/tile.dart';

/// Unit tests for [GameEngine] — the pure-Dart Sokoban game logic.
///
/// Tests cover movement, pushing, wall collisions, win detection,
/// undo, and restart.
void main() {
  late GameEngine engine;

  /// Helper: creates a small test level from notation lines.
  Level makeLevel(List<String> lines) {
    return Level.fromLines(
      id: 99,
      name: 'Test',
      lines: lines,
    );
  }

  setUp(() {
    engine = GameEngine();
  });

  group('Basic movement', () {
    test('moving onto empty floor succeeds', () {
      // Layout: player surrounded by floor, one goal, one box elsewhere
      //  #####
      //  #@$.#
      //  #####
      final level = makeLevel([
        '#####',
        '#@\$.#',
        '#####',
      ]);
      engine.loadLevel(level);

      // Player at (1,1), move right — but there's a box at (1,2).
      // Move down should fail (wall). Move left should fail (wall).
      // Let's test with a bigger level:
      final level2 = makeLevel([
        '#####',
        '#  .#',
        '# \$ #',
        '#@  #',
        '#####',
      ]);
      engine.loadLevel(level2);

      // Player at (3,1). Move up to (2,1) — empty floor.
      final success = engine.tryMove(Direction.up);
      expect(success, true);
      expect(engine.playerPos, Position(2, 1));
      expect(engine.moveCount, 1);
      expect(engine.pushCount, 0);
    });

    test('moving into a wall fails and does not change state', () {
      final level = makeLevel([
        '#####',
        '#@  #',
        '#####',
      ]);
      engine.loadLevel(level);

      // Player at (1,1). Move up → wall at (0,1).
      final success = engine.tryMove(Direction.up);
      expect(success, false);
      expect(engine.playerPos, Position(1, 1));
      expect(engine.moveCount, 0);
    });
  });

  group('Pushing boxes', () {
    test('pushing a box onto empty floor succeeds', () {
      final level = makeLevel([
        '#####',
        '#   #',
        '#@\$.#',
        '#   #',
        '#####',
      ]);
      engine.loadLevel(level);

      // Player (2,1), box (2,2), goal (2,3).
      final success = engine.tryMove(Direction.right);
      expect(success, true);
      expect(engine.playerPos, Position(2, 2));
      expect(engine.boxPositions.contains(Position(2, 3)), true);
      expect(engine.moveCount, 1);
      expect(engine.pushCount, 1);
    });

    test('pushing a box into a wall fails', () {
      final level = makeLevel([
        '#####',
        '# @\$#',
        '#  .#',
        '#####',
      ]);
      engine.loadLevel(level);

      // Player (1,2), box (1,3), wall (1,4).
      final success = engine.tryMove(Direction.right);
      expect(success, false);
      expect(engine.moveCount, 0);
      expect(engine.pushCount, 0);
    });

    test('pushing a box into another box fails', () {
      final level = makeLevel([
        '######',
        '#@\$\$.#',
        '#  . #',
        '######',
      ]);
      engine.loadLevel(level);

      // Player (1,1), boxes at (1,2) and (1,3).
      // Push right: box at (1,2) would go to (1,3) which has another box.
      final success = engine.tryMove(Direction.right);
      expect(success, false);
    });

    test('pushing a box onto a goal marks it as box-on-goal in render', () {
      final level = makeLevel([
        '#####',
        '#   #',
        '#@\$.#',
        '#   #',
        '#####',
      ]);
      engine.loadLevel(level);

      // Push box right onto goal.
      engine.tryMove(Direction.right);
      final grid = engine.renderGrid;
      expect(grid[2][3], Tile.boxOnGoal);
    });
  });

  group('Win detection', () {
    test('all goals filled → isWon is true', () {
      final level = makeLevel([
        '#####',
        '#   #',
        '#@\$.#',
        '#   #',
        '#####',
      ]);
      engine.loadLevel(level);

      expect(engine.isWon, false);
      engine.tryMove(Direction.right); // pushes box onto goal
      expect(engine.isWon, true);
    });

    test('not all goals filled → isWon is false', () {
      final level = makeLevel([
        '######',
        '#@\$\$ #',
        '#..  #',
        '######',
      ]);
      engine.loadLevel(level);

      // Push one box down, but two goals need filling.
      engine.tryMove(Direction.right); // pushes box (1,2) to (1,3)
      expect(engine.isWon, false);
    });
  });

  group('Undo', () {
    test('undo restores player position and decrements move count', () {
      final level = makeLevel([
        '#####',
        '#@   #',
        '#####',
      ]);
      engine.loadLevel(level);

      engine.tryMove(Direction.right);
      expect(engine.playerPos, Position(1, 2));
      expect(engine.moveCount, 1);

      final undone = engine.undo();
      expect(undone, true);
      expect(engine.playerPos, Position(1, 1));
      expect(engine.moveCount, 0);
    });

    test('undo restores box position after a push', () {
      final level = makeLevel([
        '#####',
        '#   #',
        '#@\$.#',
        '#   #',
        '#####',
      ]);
      engine.loadLevel(level);

      engine.tryMove(Direction.right); // push box
      expect(engine.boxPositions.contains(Position(2, 3)), true);
      expect(engine.pushCount, 1);

      engine.undo();
      expect(engine.boxPositions.contains(Position(2, 2)), true);
      expect(engine.boxPositions.contains(Position(2, 3)), false);
      expect(engine.pushCount, 0);
    });

    test('undo on empty history returns false', () {
      final level = makeLevel([
        '#####',
        '#@  #',
        '#####',
      ]);
      engine.loadLevel(level);

      expect(engine.undo(), false);
    });
  });

  group('Restart', () {
    test('restart resets to initial state', () {
      final level = makeLevel([
        '#####',
        '#   #',
        '#@\$.#',
        '#   #',
        '#####',
      ]);
      engine.loadLevel(level);

      engine.tryMove(Direction.right); // push box
      engine.tryMove(Direction.up); // move up
      expect(engine.moveCount, 2);

      engine.restart();
      expect(engine.playerPos, Position(2, 1));
      expect(engine.boxPositions, {Position(2, 2)});
      expect(engine.moveCount, 0);
      expect(engine.pushCount, 0);
      expect(engine.canUndo, false);
    });
  });
}
