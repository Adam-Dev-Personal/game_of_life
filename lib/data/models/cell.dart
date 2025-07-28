import 'package:equatable/equatable.dart';
import 'position.dart';

/// Represents the state of a cell in Conway's Game of Life
enum CellState { alive, dead }

/// Represents a cell in the game grid
class Cell extends Equatable {
  const Cell({
    required this.position,
    required this.state,
  });

  final Position position;
  final CellState state;

  /// Creates a dead cell at the given position
  factory Cell.dead(Position position) {
    return Cell(position: position, state: CellState.dead);
  }

  /// Creates an alive cell at the given position
  factory Cell.alive(Position position) {
    return Cell(position: position, state: CellState.alive);
  }

  /// Returns true if the cell is alive
  bool get isAlive => state == CellState.alive;

  /// Returns true if the cell is dead
  bool get isDead => state == CellState.dead;

  /// Creates a copy of this cell with optionally updated values
  Cell copyWith({
    Position? position,
    CellState? state,
  }) {
    return Cell(
      position: position ?? this.position,
      state: state ?? this.state,
    );
  }

  /// Toggles the cell state between alive and dead
  Cell toggle() {
    return copyWith(
      state: isAlive ? CellState.dead : CellState.alive,
    );
  }

  @override
  List<Object?> get props => [position, state];

  @override
  String toString() => 'Cell(position: $position, state: $state)';
} 