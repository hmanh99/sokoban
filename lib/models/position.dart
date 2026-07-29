/// Immutable 2D grid position (row, col).
class Position {
  final int row;
  final int col;

  const Position(this.row, this.col);

  /// Returns a new position offset by [dr] rows and [dc] columns.
  Position offset(int dr, int dc) => Position(row + dr, col + dc);

  /// Returns a new position moved one step in [direction].
  Position move(Direction direction) => offset(direction.dr, direction.dc);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Position && other.row == row && other.col == col;

  @override
  int get hashCode => Object.hash(row, col);

  @override
  String toString() => 'Position($row, $col)';
}

/// Cardinal movement directions with row/col deltas.
enum Direction {
  up(-1, 0),
  down(1, 0),
  left(0, -1),
  right(0, 1);

  final int dr;
  final int dc;

  const Direction(this.dr, this.dc);
}
