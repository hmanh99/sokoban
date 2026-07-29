import 'package:flutter_test/flutter_test.dart';
import 'package:sokoban/models/level.dart';
import 'package:sokoban/models/position.dart';
import 'package:sokoban/models/tile.dart';

/// Tests for [Level] parsing from standard Sokoban notation.
void main() {
  group('Level.fromLines', () {
    test('parses a simple level correctly', () {
      final level = Level.fromLines(
        id: 1,
        name: 'Test',
        lines: [
          '#####',
          '#@\$.#',
          '#####',
        ],
      );

      expect(level.id, 1);
      expect(level.name, 'Test');
      expect(level.rows, 3);
      expect(level.cols, 5);
      expect(level.playerStart, Position(1, 1));
      expect(level.initialBoxPositions, {Position(1, 2)});
      expect(level.goalPositions, {Position(1, 3)});
    });

    test('base grid stores floor under player and box', () {
      final level = Level.fromLines(
        id: 1,
        name: 'Test',
        lines: [
          '#####',
          '#@\$.#',
          '#####',
        ],
      );

      // Player position should be floor in baseGrid
      expect(level.baseGrid[1][1], Tile.floor);
      // Box position should be floor in baseGrid
      expect(level.baseGrid[1][2], Tile.floor);
      // Goal should remain goal in baseGrid
      expect(level.baseGrid[1][3], Tile.goal);
    });

    test('parses box-on-goal correctly', () {
      final level = Level.fromLines(
        id: 1,
        name: 'Test',
        lines: [
          '#####',
          '#@* #',
          '#####',
        ],
      );

      // Box-on-goal: box at that position AND goal at that position
      expect(level.initialBoxPositions, {Position(1, 2)});
      expect(level.goalPositions, {Position(1, 2)});
      expect(level.baseGrid[1][2], Tile.goal);
    });

    test('parses player-on-goal correctly', () {
      final level = Level.fromLines(
        id: 1,
        name: 'Test',
        lines: [
          '####',
          '#+\$#',
          '####',
        ],
      );

      expect(level.playerStart, Position(1, 1));
      expect(level.goalPositions.contains(Position(1, 1)), true);
      expect(level.baseGrid[1][1], Tile.goal);
    });

    test('throws on missing player', () {
      expect(
        () => Level.fromLines(
          id: 1,
          name: 'Test',
          lines: [
            '#####',
            '# \$.#',
            '#####',
          ],
        ),
        throwsArgumentError,
      );
    });

    test('throws on mismatched goals and boxes', () {
      expect(
        () => Level.fromLines(
          id: 1,
          name: 'Test',
          lines: [
            '#####',
            '#@\$ #',
            '#####',
          ],
        ),
        throwsArgumentError,
      );
    });

    test('pads lines to rectangular grid', () {
      final level = Level.fromLines(
        id: 1,
        name: 'Test',
        lines: [
          '###',
          '#@\$.#',
          '###',
        ],
      );

      // Should be padded to 5 columns (max line length).
      expect(level.cols, 5);
    });
  });

  group('Tile.fromChar', () {
    test('parses all standard notation characters', () {
      expect(Tile.fromChar('#'), Tile.wall);
      expect(Tile.fromChar(' '), Tile.floor);
      expect(Tile.fromChar('.'), Tile.goal);
      expect(Tile.fromChar('@'), Tile.player);
      expect(Tile.fromChar('+'), Tile.playerOnGoal);
      expect(Tile.fromChar('\$'), Tile.box);
      expect(Tile.fromChar('*'), Tile.boxOnGoal);
    });
  });
}
