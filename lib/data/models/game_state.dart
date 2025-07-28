import 'package:equatable/equatable.dart';
import 'game_grid.dart';

/// Represents the different states the game can be in
enum GameStatus {
  initial,      // Game not started yet
  running,      // Game is running automatically
  paused,       // Game is paused
  stopped,      // Game is stopped
}

/// Represents the complete state of the Game of Life
class GameState extends Equatable {
  const GameState({
    required this.grid,
    required this.generation,
    required this.status,
    this.generationDurationMs = 500,
  });

  final GameGrid grid;
  final int generation;
  final GameStatus status;
  final int generationDurationMs; // Duration between generations in milliseconds

  /// Creates initial game state with empty grid
  factory GameState.initial({
    required int gridWidth,
    required int gridHeight,
    int generationDurationMs = 500,
  }) {
    return GameState(
      grid: GameGrid.empty(width: gridWidth, height: gridHeight),
      generation: 0,
      status: GameStatus.initial,
      generationDurationMs: generationDurationMs,
    );
  }

  /// Creates a copy of this state with optionally updated values
  GameState copyWith({
    GameGrid? grid,
    int? generation,
    GameStatus? status,
    int? generationDurationMs,
  }) {
    return GameState(
      grid: grid ?? this.grid,
      generation: generation ?? this.generation,
      status: status ?? this.status,
      generationDurationMs: generationDurationMs ?? this.generationDurationMs,
    );
  }

  /// Returns true if the game is running
  bool get isRunning => status == GameStatus.running;

  /// Returns true if the game is paused
  bool get isPaused => status == GameStatus.paused;

  /// Returns true if the game is stopped
  bool get isStopped => status == GameStatus.stopped;

  /// Returns true if the game is in initial state
  bool get isInitial => status == GameStatus.initial;

  /// Returns true if the game can be started/resumed
  bool get canStart => status == GameStatus.initial || status == GameStatus.paused || status == GameStatus.stopped;

  /// Returns true if the game can be paused
  bool get canPause => status == GameStatus.running;

  /// Returns true if the game can be stopped
  bool get canStop => status == GameStatus.running || status == GameStatus.paused;

  /// Returns true if the game can be reset
  bool get canReset => status != GameStatus.initial;

  @override
  List<Object?> get props => [grid, generation, status, generationDurationMs];

  @override
  String toString() => 'GameState(gen: $generation, status: $status, alive: ${grid.aliveCount})';
} 