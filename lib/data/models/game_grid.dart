import 'package:equatable/equatable.dart';
import 'cell.dart';
import 'position.dart';

/// Represents the game grid containing all cells
class GameGrid extends Equatable {
  const GameGrid({
    required this.width,
    required this.height,
    required this.cells,
  });

  final int width;
  final int height;
  final List<List<Cell>> cells; // Changed from Map to 2D array for better performance

  /// Creates an empty grid with all dead cells
  factory GameGrid.empty({
    required int width,
    required int height,
  }) {
    final List<List<Cell>> cells = [];
    
    for (int y = 0; y < height; y++) {
      final row = <Cell>[];
      for (int x = 0; x < width; x++) {
        final position = Position(x: x, y: y);
        row.add(Cell.dead(position));
      }
      cells.add(row);
    }

    return GameGrid(
      width: width,
      height: height,
      cells: cells,
    );
  }

  /// Gets the cell at the given position, returns null if out of bounds
  Cell? getCellAt(Position position) {
    if (!isValidPosition(position)) return null;
    return cells[position.y][position.x];
  }

  /// Sets the cell at the given position
  GameGrid setCellAt(Position position, Cell cell) {
    if (!isValidPosition(position)) {
      return this;
    }

    final newCells = List<List<Cell>>.generate(
      height,
      (y) => List<Cell>.from(cells[y]),
    );
    newCells[position.y][position.x] = cell;

    return GameGrid(
      width: width,
      height: height,
      cells: newCells,
    );
  }

  /// Toggles the cell state at the given position
  GameGrid toggleCellAt(Position position) {
    final cell = getCellAt(position);
    if (cell == null) return this;

    return setCellAt(position, cell.toggle());
  }

  /// Checks if the position is within grid bounds
  bool isValidPosition(Position position) {
    return position.x >= 0 &&
           position.x < width &&
           position.y >= 0 &&
           position.y < height;
  }

  /// Gets all alive cells in the grid (optimized)
  List<Cell> get aliveCells {
    final alive = <Cell>[];
    for (int y = 0; y < height; y++) {
      for (int x = 0; x < width; x++) {
        final cell = cells[y][x];
        if (cell.isAlive) {
          alive.add(cell);
        }
      }
    }
    return alive;
  }

  /// Gets all dead cells in the grid (optimized)
  List<Cell> get deadCells {
    final dead = <Cell>[];
    for (int y = 0; y < height; y++) {
      for (int x = 0; x < width; x++) {
        final cell = cells[y][x];
        if (cell.isDead) {
          dead.add(cell);
        }
      }
    }
    return dead;
  }

  /// Gets the number of alive neighbors for a given position
  int getAliveNeighborCount(Position position) {
    int count = 0;
    
    for (final neighborPos in position.getNeighbors()) {
      final neighbor = getCellAt(neighborPos);
      if (neighbor != null && neighbor.isAlive) {
        count++;
      }
    }
    
    return count;
  }

  /// Gets all alive neighbor positions for a given position
  List<Position> getAliveNeighborPositions(Position position) {
    final aliveNeighbors = <Position>[];
    
    for (final neighborPos in position.getNeighbors()) {
      final neighbor = getCellAt(neighborPos);
      if (neighbor != null && neighbor.isAlive) {
        aliveNeighbors.add(neighborPos);
      }
    }
    
    return aliveNeighbors;
  }

  /// Returns total number of alive cells
  int get aliveCount => aliveCells.length;

  /// Returns total number of cells
  int get totalCells => width * height;

  /// Efficiently get changes between this grid and another grid
  Set<Position> getChanges(GameGrid other) {
    final changes = <Position>{};
    
    // Only check positions that were alive in either grid
    final allRelevantPositions = <Position>{};
    
    // Add positions from current grid
    for (final cell in aliveCells) {
      allRelevantPositions.add(cell.position);
    }
    
    // Add positions from other grid
    for (final cell in other.aliveCells) {
      allRelevantPositions.add(cell.position);
    }
    
    // Check only relevant positions for changes
    for (final position in allRelevantPositions) {
      final currentCell = getCellAt(position);
      final otherCell = other.getCellAt(position);
      
      if (currentCell != null && otherCell != null) {
        if (currentCell.isAlive != otherCell.isAlive) {
          changes.add(position);
        }
      }
    }
    
    return changes;
  }

  /// Create a copy of this grid
  GameGrid copy() {
    final newCells = List<List<Cell>>.generate(
      height,
      (y) => List<Cell>.from(cells[y]),
    );
    
    return GameGrid(
      width: width,
      height: height,
      cells: newCells,
    );
  }

  @override
  List<Object?> get props => [width, height, cells];

  @override
  String toString() => 'GameGrid(${width}x$height, alive: $aliveCount)';
} 