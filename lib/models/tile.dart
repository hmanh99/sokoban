/// Represents the type of content at a grid cell.
///
/// Uses standard Sokoban notation for parsing:
///   # = wall, (space) = floor, . = goal,
///   @ = player, + = player on goal,
///   $ = box, * = box on goal
enum Tile {
  wall,
  floor,
  goal,
  player,
  playerOnGoal,
  box,
  boxOnGoal;

  /// Parse a single character from standard Sokoban notation into a [Tile].
  static Tile fromChar(String ch) {
    return switch (ch) {
      '#' => Tile.wall,
      ' ' || '-' => Tile.floor,
      '.' => Tile.goal,
      '@' => Tile.player,
      '+' => Tile.playerOnGoal,
      '\$' => Tile.box,
      '*' => Tile.boxOnGoal,
      _ => Tile.floor, // treat unknown chars as floor
    };
  }

  /// Whether this tile is walkable (floor or goal, but not wall/box).
  bool get isWalkable => this == Tile.floor || this == Tile.goal;

  /// Whether this tile has a box on it.
  bool get hasBox => this == Tile.box || this == Tile.boxOnGoal;

  /// Whether this tile is a goal (with or without a box/player on it).
  bool get isGoal => this == Tile.goal || this == Tile.boxOnGoal || this == Tile.playerOnGoal;

  /// The base tile (what's underneath a box or player).
  /// For box-on-goal or player-on-goal, returns goal; otherwise floor.
  Tile get base {
    if (this == Tile.boxOnGoal || this == Tile.playerOnGoal) return Tile.goal;
    if (this == Tile.box || this == Tile.player) return Tile.floor;
    return this;
  }
}
