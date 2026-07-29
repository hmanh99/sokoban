// ignore_for_file: avoid_print
/// BFS Sokoban solver/validator.
///
/// Verifies every level in the embedded level data is solvable by exhaustive
/// breadth-first search over (player_position, box_positions) state space.
///
/// Run with: dart run tool/solve_levels.dart
///
/// Deadlock pruning: states where a box is on a non-goal corner (two
/// adjacent wall neighbours forming a corner) are pruned as dead states.
library;

import 'dart:collection';

// Import the canonical level data from the game.
import '../lib/data/level_data.dart';

class Pos {
  final int r, c;
  const Pos(this.r, this.c);
  Pos move(int dr, int dc) => Pos(r + dr, c + dc);

  @override
  bool operator ==(Object o) => o is Pos && o.r == r && o.c == c;
  @override
  int get hashCode => Object.hash(r, c);
  @override
  String toString() => '($r,$c)';
}

const _dirs = [(0, 1), (0, -1), (1, 0), (-1, 0)];

class SolverLevel {
  final int id;
  final String name;
  final int rows, cols;
  final Set<Pos> walls;
  final Set<Pos> goals;
  final Pos playerStart;
  final Set<Pos> initialBoxes;

  SolverLevel({
    required this.id,
    required this.name,
    required this.rows,
    required this.cols,
    required this.walls,
    required this.goals,
    required this.playerStart,
    required this.initialBoxes,
  });
}

SolverLevel parseLevel(Map<String, dynamic> data) {
  final lines = List<String>.from(data['lines'] as List);
  final id = data['id'] as int;
  final name = data['name'] as String;
  final maxW = lines.fold<int>(0, (m, l) => l.length > m ? l.length : m);

  final walls = <Pos>{};
  final goals = <Pos>{};
  final boxes = <Pos>{};
  Pos? player;

  for (int r = 0; r < lines.length; r++) {
    final line = lines[r].padRight(maxW);
    for (int c = 0; c < maxW; c++) {
      final ch = line[c];
      final pos = Pos(r, c);
      switch (ch) {
        case '#':
          walls.add(pos);
        case '.':
          goals.add(pos);
        case '@':
          player = pos;
        case '+':
          player = pos;
          goals.add(pos);
        case '\$':
          boxes.add(pos);
        case '*':
          boxes.add(pos);
          goals.add(pos);
      }
    }
  }

  if (player == null) throw StateError('No player in level $id');
  if (goals.length != boxes.length) {
    throw StateError('Level $id ("$name"): ${goals.length} goals vs ${boxes.length} boxes');
  }

  return SolverLevel(
    id: id,
    name: name,
    rows: lines.length,
    cols: maxW,
    walls: walls,
    goals: goals,
    playerStart: player,
    initialBoxes: boxes,
  );
}

class State {
  final Pos player;
  final List<Pos> boxes;

  State(this.player, Set<Pos> boxSet)
      : boxes = boxSet.toList()..sort((a, b) => a.r != b.r ? a.r - b.r : a.c - b.c);

  @override
  bool operator ==(Object o) {
    if (o is! State) return false;
    if (player != o.player) return false;
    if (boxes.length != o.boxes.length) return false;
    for (int i = 0; i < boxes.length; i++) {
      if (boxes[i] != o.boxes[i]) return false;
    }
    return true;
  }

  @override
  int get hashCode {
    var h = player.hashCode;
    for (final b in boxes) {
      h = Object.hash(h, b);
    }
    return h;
  }

  Set<Pos> get boxSet => boxes.toSet();
}

bool hasCornerDeadlock(Set<Pos> boxes, Set<Pos> walls, Set<Pos> goals) {
  for (final box in boxes) {
    if (goals.contains(box)) continue;

    final wallUp = walls.contains(Pos(box.r - 1, box.c));
    final wallDown = walls.contains(Pos(box.r + 1, box.c));
    final wallLeft = walls.contains(Pos(box.r, box.c - 1));
    final wallRight = walls.contains(Pos(box.r, box.c + 1));

    if ((wallUp && wallLeft) ||
        (wallUp && wallRight) ||
        (wallDown && wallLeft) ||
        (wallDown && wallRight)) {
      return true;
    }
  }
  return false;
}

(int moves, int explored) solve(SolverLevel level, {int maxStates = 2000000}) {
  final initial = State(level.playerStart, level.initialBoxes);

  if (level.initialBoxes.length == level.goals.length &&
      level.goals.every(level.initialBoxes.contains)) {
    return (0, 1);
  }

  final visited = <State>{initial};
  final queue = Queue<(State, int)>();
  queue.add((initial, 0));

  while (queue.isNotEmpty) {
    if (visited.length > maxStates) return (-1, visited.length);

    final (state, moves) = queue.removeFirst();
    final boxSet = state.boxSet;

    for (final (dr, dc) in _dirs) {
      final target = state.player.move(dr, dc);

      if (level.walls.contains(target)) continue;

      Set<Pos> newBoxes = boxSet;
      bool pushed = false;

      if (boxSet.contains(target)) {
        final behind = target.move(dr, dc);
        if (level.walls.contains(behind) || boxSet.contains(behind)) continue;
        newBoxes = Set<Pos>.from(boxSet)
          ..remove(target)
          ..add(behind);
        pushed = true;
      }

      if (pushed && hasCornerDeadlock(newBoxes, level.walls, level.goals)) {
        continue;
      }

      final newState = State(target, newBoxes);
      if (visited.contains(newState)) continue;
      visited.add(newState);

      if (level.goals.every(newBoxes.contains)) {
        return (moves + 1, visited.length);
      }

      queue.add((newState, moves + 1));
    }
  }

  return (-1, visited.length);
}

void main() {
  print('============================================');
  print('  Sokoban Level Solver / Validator');
  print('============================================');
  print('');

  int passed = 0;
  int failed = 0;
  final failedLevels = <int>[];

  for (final data in rawLevelData) {
    final level = parseLevel(data);
    final stopwatch = Stopwatch()..start();
    final (moves, explored) = solve(level);
    stopwatch.stop();

    if (moves >= 0) {
      print('\u2713 Level ${level.id} (${level.name}): '
          'solvable in $moves moves  '
          '[$explored states, ${stopwatch.elapsedMilliseconds}ms]');
      passed++;
    } else {
      print('\u2717 Level ${level.id} (${level.name}): '
          'UNSOLVABLE or exceeded state limit  '
          '[$explored states, ${stopwatch.elapsedMilliseconds}ms]');
      failed++;
      failedLevels.add(level.id);
    }
  }

  print('');
  print('============================================');
  print('  Results: $passed/${rawLevelData.length} passed, $failed failed');
  print('============================================');

  if (failed > 0) {
    print('\n\u26A0 WARNING: Failed levels: $failedLevels');
  } else {
    print('\n\u2713 All ${rawLevelData.length} levels verified solvable.');
  }
}
