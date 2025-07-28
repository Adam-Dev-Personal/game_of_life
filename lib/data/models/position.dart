import 'package:equatable/equatable.dart';

/// Represents a position in the game grid with x and y coordinates
class Position extends Equatable {
  const Position({
    required this.x,
    required this.y,
  });

  final int x;
  final int y;

  /// Creates a copy of this position with optionally updated values
  Position copyWith({
    int? x,
    int? y,
  }) {
    return Position(
      x: x ?? this.x,
      y: y ?? this.y,
    );
  }

  /// Returns all 8 neighboring positions around this position
  List<Position> getNeighbors() {
    return [
      Position(x: x - 1, y: y - 1), // top-left
      Position(x: x, y: y - 1),     // top
      Position(x: x + 1, y: y - 1), // top-right
      Position(x: x - 1, y: y),     // left
      Position(x: x + 1, y: y),     // right
      Position(x: x - 1, y: y + 1), // bottom-left
      Position(x: x, y: y + 1),     // bottom
      Position(x: x + 1, y: y + 1), // bottom-right
    ];
  }

  @override
  List<Object?> get props => [x, y];

  @override
  String toString() => 'Position(x: $x, y: $y)';
} 