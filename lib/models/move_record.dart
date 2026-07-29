import 'position.dart';

/// Records a single move for the undo history.
///
/// Stores the player's previous position and, if a box was pushed,
/// the box's previous and new positions.
class MoveRecord {
  /// Where the player was before this move.
  final Position previousPlayerPos;

  /// If a box was pushed, its position before the push. Null if no push.
  final Position? pushedBoxFrom;

  /// If a box was pushed, its position after the push. Null if no push.
  final Position? pushedBoxTo;

  /// Whether this move involved pushing a box.
  bool get wasPush => pushedBoxFrom != null;

  const MoveRecord({
    required this.previousPlayerPos,
    this.pushedBoxFrom,
    this.pushedBoxTo,
  });
}
