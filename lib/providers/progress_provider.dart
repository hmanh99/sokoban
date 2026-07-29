import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Manages player progress persistence via shared_preferences.
///
/// Tracks which levels are completed and the best (lowest) move count
/// for each completed level. Data is loaded on app start and saved
/// immediately on each completion.
class ProgressProvider extends ChangeNotifier {
  static const String _completedPrefix = 'completed_';
  static const String _bestMovesPrefix = 'best_moves_';

  SharedPreferences? _prefs;
  final Map<int, int> _bestMoves = {};
  final Set<int> _completedLevels = {};

  bool _isLoaded = false;
  bool get isLoaded => _isLoaded;

  /// Load saved progress from disk. Must be called before accessing data.
  Future<void> loadProgress() async {
    _prefs = await SharedPreferences.getInstance();

    // Scan all keys for completed levels and best moves.
    for (final key in _prefs!.getKeys()) {
      if (key.startsWith(_completedPrefix)) {
        final id = int.tryParse(key.substring(_completedPrefix.length));
        if (id != null && _prefs!.getBool(key) == true) {
          _completedLevels.add(id);
        }
      } else if (key.startsWith(_bestMovesPrefix)) {
        final id = int.tryParse(key.substring(_bestMovesPrefix.length));
        if (id != null) {
          _bestMoves[id] = _prefs!.getInt(key) ?? 0;
        }
      }
    }

    _isLoaded = true;
    notifyListeners();
  }

  /// Record a level completion. Saves the best (lowest) move count.
  Future<void> completeLevel(int levelId, int moves) async {
    _completedLevels.add(levelId);
    final existing = _bestMoves[levelId];
    if (existing == null || moves < existing) {
      _bestMoves[levelId] = moves;
    }

    await _prefs?.setBool('$_completedPrefix$levelId', true);
    await _prefs?.setInt('$_bestMovesPrefix$levelId', _bestMoves[levelId]!);
    notifyListeners();
  }

  /// Whether a level has been completed.
  bool isCompleted(int levelId) => _completedLevels.contains(levelId);

  /// Whether a level is unlocked for play.
  /// Level 1 is always unlocked. Level N is unlocked if level N-1 is completed.
  bool isLevelUnlocked(int levelId) {
    if (levelId <= 1) return true;
    return _completedLevels.contains(levelId - 1);
  }

  /// Best move count for a completed level, or null if not completed.
  int? bestMoves(int levelId) => _bestMoves[levelId];

  /// Total number of completed levels.
  int get completedCount => _completedLevels.length;

  /// Returns the first uncompleted level id (1-based), or 1 if all completed.
  int nextUncompletedLevel(int totalLevels) {
    for (int i = 1; i <= totalLevels; i++) {
      if (!_completedLevels.contains(i)) return i;
    }
    return 1;
  }
}
