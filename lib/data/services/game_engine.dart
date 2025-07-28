import '../models/cell.dart';
import '../models/game_grid.dart';
import '../models/position.dart';

class GameEngine {
  const GameEngine();

  GameGrid nextGeneration(GameGrid currentGrid) {
    final List<List<Cell>> newCells = [];

    for (int y = 0; y < currentGrid.height; y++) {
      final row = <Cell>[];
      for (int x = 0; x < currentGrid.width; x++) {
        final position = Position(x: x, y: y);
        final currentCell = currentGrid.getCellAt(position)!;
        final aliveNeighborCount = currentGrid.getAliveNeighborCount(position);

        final newCellState = _calculateNewCellState(
          currentCell.state,
          aliveNeighborCount,
        );

        row.add(Cell(
          position: position,
          state: newCellState,
        ));
      }
      newCells.add(row);
    }

    return GameGrid(
      width: currentGrid.width,
      height: currentGrid.height,
      cells: newCells,
    );
  }

  CellState _calculateNewCellState(CellState currentState, int aliveNeighborCount) {
    switch (currentState) {
      case CellState.alive:
        return (aliveNeighborCount == 2 || aliveNeighborCount == 3)
            ? CellState.alive
            : CellState.dead;
            
      case CellState.dead:
        return aliveNeighborCount == 3
            ? CellState.alive
            : CellState.dead;
    }
  }

  bool isStableState(GameGrid current, GameGrid previous) {
    if (current.width != previous.width || current.height != previous.height) {
      return false;
    }

    final changes = current.getChanges(previous);
    return changes.isEmpty;
  }

  bool isEmpty(GameGrid grid) {
    return grid.aliveCount == 0;
  }

  int? detectOscillation(List<GameGrid> history) {
    if (history.length < 3) return null;

    final current = history.last;
    
    if (history.length >= 3) {
      final twoBack = history[history.length - 3];
      if (isStableState(current, twoBack)) {
        return 2;
      }
    }

    if (history.length >= 4) {
      final threeBack = history[history.length - 4];
      if (isStableState(current, threeBack)) {
        return 3;
      }
    }

    return null;
  }

  GameGridStats getGridStats(GameGrid grid) {
    return GameGridStats(
      totalCells: grid.totalCells,
      aliveCells: grid.aliveCount,
      deadCells: grid.totalCells - grid.aliveCount,
      alivePercentage: (grid.aliveCount / grid.totalCells) * 100,
    );
  }
}

class GameGridStats {
  const GameGridStats({
    required this.totalCells,
    required this.aliveCells,
    required this.deadCells,
    required this.alivePercentage,
  });

  final int totalCells;
  final int aliveCells;
  final int deadCells;
  final double alivePercentage;

  @override
  String toString() {
    return 'GridStats(alive: $aliveCells/$totalCells, ${alivePercentage.toStringAsFixed(1)}%)';
  }
} 