import '../models/level.dart';
import 'level_data.dart';

/// Parses raw level data into [Level] objects.
class LevelRepository {
  static List<Level>? _cachedLevels;

  /// Get all levels, parsed and cached.
  static List<Level> getAllLevels() {
    _cachedLevels ??= _parseLevels();
    return _cachedLevels!;
  }

  /// Get a specific level by its 1-based id.
  static Level getLevel(int id) {
    final levels = getAllLevels();
    return levels.firstWhere(
      (l) => l.id == id,
      orElse: () => throw ArgumentError('Level $id not found.'),
    );
  }

  /// Get the total number of levels.
  static int get levelCount => getAllLevels().length;

  static List<Level> _parseLevels() {
    return rawLevelData.map((data) {
      return Level.fromLines(
        id: data['id'] as int,
        name: data['name'] as String,
        lines: List<String>.from(data['lines'] as List),
      );
    }).toList();
  }
}
