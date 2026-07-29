import 'package:flutter/material.dart';
import '../models/tile.dart';

/// CustomPainter-based renderer for the Sokoban grid.
///
/// Calculates tile size from available space to maintain square tiles.
/// Draws walls, floor, goals, player, boxes, and boxes-on-goals with
/// distinct visual styling for playability.
class GameBoard extends StatelessWidget {
  final List<List<Tile>> grid;
  final int rows;
  final int cols;

  const GameBoard({
    super.key,
    required this.grid,
    required this.rows,
    required this.cols,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // Calculate tile size to fit within available space while keeping square.
        final availableWidth = constraints.maxWidth;
        final availableHeight = constraints.maxHeight;
        final tileSize = _calculateTileSize(availableWidth, availableHeight);
        final gridWidth = tileSize * cols;
        final gridHeight = tileSize * rows;

        return Center(
          child: SizedBox(
            width: gridWidth,
            height: gridHeight,
            child: CustomPaint(
              painter: _SokobanGridPainter(
                grid: grid,
                rows: rows,
                cols: cols,
                tileSize: tileSize,
              ),
              size: Size(gridWidth, gridHeight),
            ),
          ),
        );
      },
    );
  }

  double _calculateTileSize(double width, double height) {
    if (cols == 0 || rows == 0) return 0;
    final tileSizeByWidth = width / cols;
    final tileSizeByHeight = height / rows;
    // Use the smaller dimension to ensure the grid fits, with a max cap.
    final tileSize =
        tileSizeByWidth < tileSizeByHeight ? tileSizeByWidth : tileSizeByHeight;
    return tileSize.clamp(16.0, 72.0);
  }
}

class _SokobanGridPainter extends CustomPainter {
  final List<List<Tile>> grid;
  final int rows;
  final int cols;
  final double tileSize;

  // Pre-built paints for performance.
  static final _wallPaint = Paint()..color = const Color(0xFF37474F); // Blue Grey 800
  static final _floorPaint = Paint()..color = const Color(0xFFE8E0D4); // Warm beige
  static final _goalPaint = Paint()..color = const Color(0xFFE8E0D4);
  static final _boxPaint = Paint()..color = const Color(0xFFFF8F00); // Amber 800
  static final _boxOnGoalPaint = Paint()..color = const Color(0xFF2E7D32); // Green 800
  static final _playerPaint = Paint()..color = const Color(0xFF1565C0); // Blue 800
  static final _goalMarkerPaint = Paint()
    ..color = const Color(0xFFEF5350) // Red 400
    ..style = PaintingStyle.fill;
  static final _tileBorderPaint = Paint()
    ..color = const Color(0x22000000)
    ..style = PaintingStyle.stroke
    ..strokeWidth = 0.5;

  _SokobanGridPainter({
    required this.grid,
    required this.rows,
    required this.cols,
    required this.tileSize,
  });

  @override
  void paint(Canvas canvas, Size size) {
    for (int r = 0; r < rows; r++) {
      for (int c = 0; c < cols; c++) {
        final tile = (r < grid.length && c < grid[r].length)
            ? grid[r][c]
            : Tile.floor;
        _drawTile(canvas, r, c, tile);
      }
    }
  }

  void _drawTile(Canvas canvas, int r, int c, Tile tile) {
    final rect = Rect.fromLTWH(
      c * tileSize,
      r * tileSize,
      tileSize,
      tileSize,
    );
    final center = rect.center;
    final inset = tileSize * 0.1;
    final innerRect = rect.deflate(inset);

    switch (tile) {
      case Tile.wall:
        // Solid dark tile with subtle 3D effect.
        canvas.drawRect(rect, _wallPaint);
        final highlight = Paint()
          ..color = const Color(0x33FFFFFF)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.5;
        canvas.drawLine(rect.topLeft, rect.topRight, highlight);
        canvas.drawLine(rect.topLeft, rect.bottomLeft, highlight);

      case Tile.floor:
        canvas.drawRect(rect, _floorPaint);
        canvas.drawRect(rect, _tileBorderPaint);

      case Tile.goal:
        // Floor with a diamond-shaped goal marker.
        canvas.drawRect(rect, _goalPaint);
        canvas.drawRect(rect, _tileBorderPaint);
        _drawGoalMarker(canvas, center);

      case Tile.player:
      case Tile.playerOnGoal:
        // Draw floor/goal underneath, then the player circle.
        canvas.drawRect(rect, _floorPaint);
        canvas.drawRect(rect, _tileBorderPaint);
        if (tile == Tile.playerOnGoal) {
          _drawGoalMarker(canvas, center);
        }
        // Player as a filled circle with a darker ring.
        final playerRadius = tileSize * 0.35;
        canvas.drawCircle(center, playerRadius, _playerPaint);
        final ringPaint = Paint()
          ..color = const Color(0xFF0D47A1) // Blue 900
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2.0;
        canvas.drawCircle(center, playerRadius, ringPaint);
        // Eyes/face for personality.
        final eyePaint = Paint()..color = Colors.white;
        final eyeRadius = tileSize * 0.06;
        canvas.drawCircle(
          Offset(center.dx - tileSize * 0.1, center.dy - tileSize * 0.05),
          eyeRadius,
          eyePaint,
        );
        canvas.drawCircle(
          Offset(center.dx + tileSize * 0.1, center.dy - tileSize * 0.05),
          eyeRadius,
          eyePaint,
        );

      case Tile.box:
        // Floor underneath, then the box as a rounded rect.
        canvas.drawRect(rect, _floorPaint);
        canvas.drawRect(rect, _tileBorderPaint);
        final rrect = RRect.fromRectAndRadius(innerRect, Radius.circular(tileSize * 0.12));
        canvas.drawRRect(rrect, _boxPaint);
        // Inner cross pattern for crate look.
        final linePaint = Paint()
          ..color = const Color(0x44000000)
          ..strokeWidth = 1.5;
        canvas.drawLine(innerRect.topLeft, innerRect.bottomRight, linePaint);
        canvas.drawLine(innerRect.topRight, innerRect.bottomLeft, linePaint);

      case Tile.boxOnGoal:
        // Visually distinct: green rounded rect with a check mark.
        canvas.drawRect(rect, _floorPaint);
        canvas.drawRect(rect, _tileBorderPaint);
        final rrect = RRect.fromRectAndRadius(innerRect, Radius.circular(tileSize * 0.12));
        canvas.drawRRect(rrect, _boxOnGoalPaint);
        // Checkmark to show box is correctly placed.
        final checkPaint = Paint()
          ..color = Colors.white
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2.5
          ..strokeCap = StrokeCap.round;
        final path = Path();
        path.moveTo(center.dx - tileSize * 0.15, center.dy);
        path.lineTo(center.dx - tileSize * 0.02, center.dy + tileSize * 0.13);
        path.lineTo(center.dx + tileSize * 0.18, center.dy - tileSize * 0.12);
        canvas.drawPath(path, checkPaint);
    }
  }

  /// Draws a small diamond shape as the goal marker.
  void _drawGoalMarker(Canvas canvas, Offset center) {
    final size = tileSize * 0.15;
    final path = Path()
      ..moveTo(center.dx, center.dy - size)
      ..lineTo(center.dx + size, center.dy)
      ..lineTo(center.dx, center.dy + size)
      ..lineTo(center.dx - size, center.dy)
      ..close();
    canvas.drawPath(path, _goalMarkerPaint);
  }

  @override
  bool shouldRepaint(covariant _SokobanGridPainter oldDelegate) {
    // Always repaint since grid contents change frequently.
    return true;
  }
}
