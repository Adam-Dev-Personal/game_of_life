import 'package:flutter_test/flutter_test.dart';
import 'package:game_of_life/data/services/game_engine.dart';
import 'package:game_of_life/data/models/game_grid.dart';
import 'package:game_of_life/data/models/cell.dart';
import 'package:game_of_life/data/models/position.dart';

void main() {
  group('GameEngine', () {
    late GameEngine gameEngine;

    setUp(() {
      gameEngine = const GameEngine();
    });

    group('nextGeneration', () {
      test('should kill live cell with less than 2 neighbors', () {
        final grid = GameGrid.empty(width: 3, height: 3);
        final gridWithSingleCell = grid.setCellAt(
          Position(x: 1, y: 1), 
          Cell.alive(Position(x: 1, y: 1))
        );

        final nextGen = gameEngine.nextGeneration(gridWithSingleCell);
        final centerCell = nextGen.getCellAt(Position(x: 1, y: 1));

        expect(centerCell!.isDead, isTrue);
      });

      test('should keep live cell with 2 neighbors', () {
        final grid = GameGrid.empty(width: 3, height: 3);
        final gridWithThreeCells = grid
            .setCellAt(Position(x: 0, y: 0), Cell.alive(Position(x: 0, y: 0)))
            .setCellAt(Position(x: 1, y: 1), Cell.alive(Position(x: 1, y: 1)))
            .setCellAt(Position(x: 2, y: 2), Cell.alive(Position(x: 2, y: 2)));

        final nextGen = gameEngine.nextGeneration(gridWithThreeCells);
        final centerCell = nextGen.getCellAt(Position(x: 1, y: 1));

        expect(centerCell!.isAlive, isTrue);
      });

      test('should keep live cell with 3 neighbors', () {
        final grid = GameGrid.empty(width: 3, height: 3);
        final gridWithFourCells = grid
            .setCellAt(Position(x: 0, y: 0), Cell.alive(Position(x: 0, y: 0)))
            .setCellAt(Position(x: 0, y: 1), Cell.alive(Position(x: 0, y: 1)))
            .setCellAt(Position(x: 1, y: 0), Cell.alive(Position(x: 1, y: 0)))
            .setCellAt(Position(x: 1, y: 1), Cell.alive(Position(x: 1, y: 1)));

        final nextGen = gameEngine.nextGeneration(gridWithFourCells);
        final centerCell = nextGen.getCellAt(Position(x: 1, y: 1));

        expect(centerCell!.isAlive, isTrue);
      });

      test('should kill live cell with more than 3 neighbors', () {
        final grid = GameGrid.empty(width: 3, height: 3);
        final gridWithFiveCells = grid
            .setCellAt(Position(x: 0, y: 0), Cell.alive(Position(x: 0, y: 0)))
            .setCellAt(Position(x: 0, y: 1), Cell.alive(Position(x: 0, y: 1)))
            .setCellAt(Position(x: 0, y: 2), Cell.alive(Position(x: 0, y: 2)))
            .setCellAt(Position(x: 1, y: 0), Cell.alive(Position(x: 1, y: 0)))
            .setCellAt(Position(x: 1, y: 1), Cell.alive(Position(x: 1, y: 1)));

        final nextGen = gameEngine.nextGeneration(gridWithFiveCells);
        final centerCell = nextGen.getCellAt(Position(x: 1, y: 1));

        expect(centerCell!.isDead, isTrue);
      });

      test('should birth dead cell with exactly 3 neighbors', () {
        final grid = GameGrid.empty(width: 3, height: 3);
        final gridWithThreeCells = grid
            .setCellAt(Position(x: 0, y: 0), Cell.alive(Position(x: 0, y: 0)))
            .setCellAt(Position(x: 0, y: 1), Cell.alive(Position(x: 0, y: 1)))
            .setCellAt(Position(x: 1, y: 0), Cell.alive(Position(x: 1, y: 0)));

        final nextGen = gameEngine.nextGeneration(gridWithThreeCells);
        final centerCell = nextGen.getCellAt(Position(x: 1, y: 1));

        expect(centerCell!.isAlive, isTrue);
      });

      test('should not birth dead cell with 2 neighbors', () {
        final grid = GameGrid.empty(width: 3, height: 3);
        final gridWithTwoCells = grid
            .setCellAt(Position(x: 0, y: 0), Cell.alive(Position(x: 0, y: 0)))
            .setCellAt(Position(x: 0, y: 1), Cell.alive(Position(x: 0, y: 1)));

        final nextGen = gameEngine.nextGeneration(gridWithTwoCells);
        final centerCell = nextGen.getCellAt(Position(x: 1, y: 1));

        expect(centerCell!.isDead, isTrue);
      });

      test('should not birth dead cell with 4 neighbors', () {
        final grid = GameGrid.empty(width: 3, height: 3);
        final gridWithFourCells = grid
            .setCellAt(Position(x: 0, y: 0), Cell.alive(Position(x: 0, y: 0)))
            .setCellAt(Position(x: 0, y: 1), Cell.alive(Position(x: 0, y: 1)))
            .setCellAt(Position(x: 0, y: 2), Cell.alive(Position(x: 0, y: 2)))
            .setCellAt(Position(x: 1, y: 0), Cell.alive(Position(x: 1, y: 0)));

        final nextGen = gameEngine.nextGeneration(gridWithFourCells);
        final centerCell = nextGen.getCellAt(Position(x: 1, y: 1));

        expect(centerCell!.isDead, isTrue);
      });
    });

    group('isStableState', () {
      test('should return true for identical grids', () {
        final grid1 = GameGrid.empty(width: 3, height: 3);
        final grid2 = GameGrid.empty(width: 3, height: 3);

        expect(gameEngine.isStableState(grid1, grid2), isTrue);
      });

      test('should return false for different grids', () {
        final grid1 = GameGrid.empty(width: 3, height: 3);
        final grid2 = grid1.setCellAt(
          Position(x: 1, y: 1), 
          Cell.alive(Position(x: 1, y: 1))
        );

        expect(gameEngine.isStableState(grid1, grid2), isFalse);
      });

      test('should return false for different sized grids', () {
        final grid1 = GameGrid.empty(width: 3, height: 3);
        final grid2 = GameGrid.empty(width: 4, height: 4);

        expect(gameEngine.isStableState(grid1, grid2), isFalse);
      });
    });

    group('isEmpty', () {
      test('should return true for empty grid', () {
        final grid = GameGrid.empty(width: 3, height: 3);
        expect(gameEngine.isEmpty(grid), isTrue);
      });

      test('should return false for grid with alive cells', () {
        final grid = GameGrid.empty(width: 3, height: 3);
        final gridWithCell = grid.setCellAt(
          Position(x: 1, y: 1), 
          Cell.alive(Position(x: 1, y: 1))
        );
        expect(gameEngine.isEmpty(gridWithCell), isFalse);
      });
    });

    group('detectOscillation', () {
      test('should return null for insufficient history', () {
        final history = [
          GameGrid.empty(width: 3, height: 3),
        ];

        expect(gameEngine.detectOscillation(history), isNull);
      });

      test('should detect period-2 oscillator', () {
        final grid1 = GameGrid.empty(width: 3, height: 3);
        final grid2 = grid1.setCellAt(
          Position(x: 1, y: 1), 
          Cell.alive(Position(x: 1, y: 1))
        );
        final history = [grid1, grid2, grid1];

        expect(gameEngine.detectOscillation(history), equals(2));
      });

      test('should detect period-3 oscillator', () {
        final grid1 = GameGrid.empty(width: 3, height: 3);
        final grid2 = grid1.setCellAt(
          Position(x: 1, y: 1), 
          Cell.alive(Position(x: 1, y: 1))
        );
        final grid3 = grid2.setCellAt(
          Position(x: 2, y: 2), 
          Cell.alive(Position(x: 2, y: 2))
        );
        final history = [grid1, grid2, grid3, grid1];

        expect(gameEngine.detectOscillation(history), equals(3));
      });
    });

    group('getGridStats', () {
      test('should return correct stats for empty grid', () {
        final grid = GameGrid.empty(width: 3, height: 3);
        final stats = gameEngine.getGridStats(grid);

        expect(stats.totalCells, equals(9));
        expect(stats.aliveCells, equals(0));
        expect(stats.deadCells, equals(9));
        expect(stats.alivePercentage, equals(0.0));
      });

      test('should return correct stats for grid with alive cells', () {
        final grid = GameGrid.empty(width: 2, height: 2);
        final gridWithCells = grid
            .setCellAt(Position(x: 0, y: 0), Cell.alive(Position(x: 0, y: 0)))
            .setCellAt(Position(x: 1, y: 1), Cell.alive(Position(x: 1, y: 1)));
        final stats = gameEngine.getGridStats(gridWithCells);

        expect(stats.totalCells, equals(4));
        expect(stats.aliveCells, equals(2));
        expect(stats.deadCells, equals(2));
        expect(stats.alivePercentage, equals(50.0));
      });
    });
  });
} 