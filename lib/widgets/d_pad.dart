import 'package:flutter/material.dart';
import '../models/position.dart';

/// On-screen directional pad for touch input.
///
/// Displays four directional buttons arranged in a cross pattern.
/// Semi-transparent and non-intrusive while remaining easy to tap.
class DPad extends StatelessWidget {
  final void Function(Direction direction) onDirection;

  const DPad({super.key, required this.onDirection});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final buttonColor = colorScheme.primaryContainer;
    final iconColor = colorScheme.onPrimaryContainer;
    const buttonSize = 56.0;

    Widget dirButton(Direction dir, IconData icon) {
      return SizedBox(
        width: buttonSize,
        height: buttonSize,
        child: Material(
          color: buttonColor.withValues(alpha: 0.85),
          shape: const CircleBorder(),
          elevation: 2,
          child: InkWell(
            customBorder: const CircleBorder(),
            onTap: () => onDirection(dir),
            child: Icon(icon, color: iconColor, size: 28),
          ),
        ),
      );
    }

    return SizedBox(
      width: buttonSize * 3 + 8,
      height: buttonSize * 3 + 8,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Up
          Positioned(
            top: 0,
            child: dirButton(Direction.up, Icons.arrow_upward),
          ),
          // Down
          Positioned(
            bottom: 0,
            child: dirButton(Direction.down, Icons.arrow_downward),
          ),
          // Left
          Positioned(
            left: 0,
            child: dirButton(Direction.left, Icons.arrow_back),
          ),
          // Right
          Positioned(
            right: 0,
            child: dirButton(Direction.right, Icons.arrow_forward),
          ),
        ],
      ),
    );
  }
}
