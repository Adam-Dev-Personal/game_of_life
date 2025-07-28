import 'package:flutter_test/flutter_test.dart';
import 'package:game_of_life/data/models/game_grid.dart';
import 'package:game_of_life/data/models/cell.dart';
import 'package:game_of_life/data/models/position.dart';

void main() {
  group('GameGrid', () {
    test('should create empty grid', () {
      final grid = GameGrid.empty(width: 3, height: 4);

      expect(grid.width, equals(3));
      expect(grid.height, equals(4));
      expect(grid.totalCells, equals(12));
      expect(grid.aliveCount, equals(0));
      expect(grid.aliveCells, isEmpty);
    });

    test('should get cell at valid position', () {
      final grid = GameGrid.empty(width: 3, height: 3);
      final position = Position(x: 1, y: 1);
      final cell = grid.getCellAt(position);

      expect(cell, isNotNull);
      expect(cell!.position, equals(position));
      expect(cell.isDead, isTrue);
    });

    test('should return null for invalid position', () {
      final grid = GameGrid.empty(width: 3, height: 3);
      final invalidPosition = Position(x: 5, y: 5);
      final cell = grid.getCellAt(invalidPosition);

      expect(cell, isNull);
    });

    test('should set cell at valid position', () {
      final grid = GameGrid.empty(width: 3, height: 3);
      final position = Position(x: 1, y: 1);
      final aliveCell = Cell.alive(position);
      final newGrid = grid.setCellAt(position, aliveCell);

      expect(newGrid.getCellAt(position)!.isAlive, isTrue);
      expect(newGrid.aliveCount, equals(1));
      expect(newGrid.aliveCells.length, equals(1));
    });

    test('should not set cell at invalid position', () {
      final grid = GameGrid.empty(width: 3, height: 3);
      final invalidPosition = Position(x: 5, y: 5);
      final aliveCell = Cell.alive(invalidPosition);
      final newGrid = grid.setCellAt(invalidPosition, aliveCell);

      expect(newGrid, equals(grid));
      expect(newGrid.aliveCount, equals(0));
    });

    test('should toggle cell state', () {
      final grid = GameGrid.empty(width: 3, height: 3);
      final position = Position(x: 1, y: 1);
      
      final gridWithAliveCell = grid.toggleCellAt(position);
      expect(gridWithAliveCell.getCellAt(position)!.isAlive, isTrue);
      expect(gridWithAliveCell.aliveCount, equals(1));

      final gridWithDeadCell = gridWithAliveCell.toggleCellAt(position);
      expect(gridWithDeadCell.getCellAt(position)!.isDead, isTrue);
      expect(gridWithDeadCell.aliveCount, equals(0));
    });

    test('should validate position correctly', () {
      final grid = GameGrid.empty(width: 3, height: 3);

      expect(grid.isValidPosition(Position(x: 0, y: 0)), isTrue);
      expect(grid.isValidPosition(Position(x: 2, y: 2)), isTrue);
      expect(grid.isValidPosition(Position(x: -1, y: 0)), isFalse);
      expect(grid.isValidPosition(Position(x: 0, y: -1)), isFalse);
      expect(grid.isValidPosition(Position(x: 3, y: 0)), isFalse);
      expect(grid.isValidPosition(Position(x: 0, y: 3)), isFalse);
    });

    test('should get alive cells', () {
      final grid = GameGrid.empty(width: 3, height: 3);
      final position1 = Position(x: 0, y: 0);
      final position2 = Position(x: 1, y: 1);
      
      final gridWithCells = grid
          .setCellAt(position1, Cell.alive(position1))
          .setCellAt(position2, Cell.alive(position2));

      final aliveCells = gridWithCells.aliveCells;
      expect(aliveCells.length, equals(2));
      expect(aliveCells.any((cell) => cell.position == position1), isTrue);
      expect(aliveCells.any((cell) => cell.position == position2), isTrue);
    });

    test('should get dead cells', () {
      final grid = GameGrid.empty(width: 2, height: 2);
      final position = Position(x: 0, y: 0);
      final gridWithOneAlive = grid.setCellAt(position, Cell.alive(position));

      final deadCells = gridWithOneAlive.deadCells;
      expect(deadCells.length, equals(3));
      expect(deadCells.every((cell) => cell.isDead), isTrue);
    });

    test('should count alive neighbors correctly', () {
      final grid = GameGrid.empty(width: 3, height: 3);
      final centerPosition = Position(x: 1, y: 1);
      
      final gridWithNeighbors = grid
          .setCellAt(Position(x: 0, y: 0), Cell.alive(Position(x: 0, y: 0)))
          .setCellAt(Position(x: 1, y: 0), Cell.alive(Position(x: 1, y: 0)))
          .setCellAt(Position(x: 2, y: 0), Cell.alive(Position(x: 2, y: 0)));

      final neighborCount = gridWithNeighbors.getAliveNeighborCount(centerPosition);
      expect(neighborCount, equals(3));
    });

    test('should get alive neighbor positions', () {
      final grid = GameGrid.empty(width: 3, height: 3);
      final centerPosition = Position(x: 1, y: 1);
      
      final gridWithNeighbors = grid
          .setCellAt(Position(x: 0, y: 0), Cell.alive(Position(x: 0, y: 0)))
          .setCellAt(Position(x: 1, y: 0), Cell.alive(Position(x: 1, y: 0)))
          .setCellAt(Position(x: 2, y: 0), Cell.alive(Position(x: 2, y: 0)));

      final aliveNeighbors = gridWithNeighbors.getAliveNeighborPositions(centerPosition);
      expect(aliveNeighbors.length, equals(3));
      expect(aliveNeighbors, contains(Position(x: 0, y: 0)));
      expect(aliveNeighbors, contains(Position(x: 1, y: 0)));
      expect(aliveNeighbors, contains(Position(x: 2, y: 0)));
    });

    test('should track changes between grids', () {
      final grid1 = GameGrid.empty(width: 3, height: 3);
      final grid2 = grid1
          .setCellAt(Position(x: 1, y: 1), Cell.alive(Position(x: 1, y: 1)))
          .setCellAt(Position(x: 2, y: 2), Cell.alive(Position(x: 2, y: 2)));

      final changes = grid2.getChanges(grid1);
      expect(changes.length, equals(2));
      expect(changes, contains(Position(x: 1, y: 1)));
      expect(changes, contains(Position(x: 2, y: 2)));
    });

    test('should detect no changes between identical grids', () {
      final grid1 = GameGrid.empty(width: 3, height: 3);
      final grid2 = GameGrid.empty(width: 3, height: 3);

      final changes = grid2.getChanges(grid1);
      expect(changes, isEmpty);
    });

    test('should copy grid correctly', () {
      final originalGrid = GameGrid.empty(width: 3, height: 3);
      final gridWithCell = originalGrid.setCellAt(
        Position(x: 1, y: 1), 
        Cell.alive(Position(x: 1, y: 1))
      );
      final copiedGrid = gridWithCell.copy();

      expect(copiedGrid.width, equals(gridWithCell.width));
      expect(copiedGrid.height, equals(gridWithCell.height));
      expect(copiedGrid.aliveCount, equals(gridWithCell.aliveCount));
      expect(copiedGrid.getCellAt(Position(x: 1, y: 1))!.isAlive, isTrue);
    });

    test('should have correct string representation', () {
      final grid = GameGrid.empty(width: 3, height: 4);
      final gridWithCells = grid
          .setCellAt(Position(x: 1, y: 1), Cell.alive(Position(x: 1, y: 1)))
          .setCellAt(Position(x: 2, y: 2), Cell.alive(Position(x: 2, y: 2)));

      final stringRep = gridWithCells.toString();
      expect(stringRep, contains('3x4'));
      expect(stringRep, contains('alive: 2'));
    });
  });
} 