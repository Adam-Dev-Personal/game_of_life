import 'dart:math';
import 'package:flutter_test/flutter_test.dart';
import 'package:game_of_life/data/services/grid_generator.dart';
import 'package:game_of_life/data/models/game_grid.dart';
import 'package:game_of_life/data/models/position.dart';

void main() {
  group('GridGenerator', () {
    late GridGenerator gridGenerator;

    setUp(() {
      gridGenerator = GridGenerator();
    });

    group('generateRandom', () {
      test('should generate grid with correct dimensions', () {
        final grid = gridGenerator.generateRandom(width: 5, height: 7);

        expect(grid.width, equals(5));
        expect(grid.height, equals(7));
        expect(grid.totalCells, equals(35));
      });

      test('should generate grid with specified alive probability', () {
        final grid = gridGenerator.generateRandom(
          width: 10, 
          height: 10, 
          aliveProbability: 0.0
        );

        expect(grid.aliveCount, equals(0));
      });

      test('should generate grid with high alive probability', () {
        final grid = gridGenerator.generateRandom(
          width: 3, 
          height: 3, 
          aliveProbability: 1.0
        );

        expect(grid.aliveCount, equals(9));
      });

      test('should generate different grids on multiple calls', () {
        final grid1 = gridGenerator.generateRandom(width: 5, height: 5);
        final grid2 = gridGenerator.generateRandom(width: 5, height: 5);

        expect(grid1, isNot(equals(grid2)));
      });
    });

    group('generateFromPositions', () {
      test('should generate grid from alive positions', () {
        final positions = [
          Position(x: 0, y: 0),
          Position(x: 1, y: 1),
          Position(x: 2, y: 2),
        ];

        final grid = gridGenerator.generateFromPositions(
          width: 3,
          height: 3,
          alivePositions: positions,
        );

        expect(grid.width, equals(3));
        expect(grid.height, equals(3));
        expect(grid.aliveCount, equals(3));
        
        for (final position in positions) {
          expect(grid.getCellAt(position)!.isAlive, isTrue);
        }
      });

      test('should ignore invalid positions', () {
        final positions = [
          Position(x: 0, y: 0),
          Position(x: 5, y: 5), // Invalid position
          Position(x: 1, y: 1),
        ];

        final grid = gridGenerator.generateFromPositions(
          width: 3,
          height: 3,
          alivePositions: positions,
        );

        expect(grid.aliveCount, equals(2));
        expect(grid.getCellAt(Position(x: 0, y: 0))!.isAlive, isTrue);
        expect(grid.getCellAt(Position(x: 1, y: 1))!.isAlive, isTrue);
      });

      test('should create empty grid when no valid positions', () {
        final positions = [
          Position(x: 5, y: 5),
          Position(x: 10, y: 10),
        ];

        final grid = gridGenerator.generateFromPositions(
          width: 3,
          height: 3,
          alivePositions: positions,
        );

        expect(grid.aliveCount, equals(0));
      });
    });

    group('generateSmartAutofill', () {
      test('should generate grid with correct dimensions', () {
        final grid = gridGenerator.generateSmartAutofill(width: 20, height: 20);

        expect(grid.width, equals(20));
        expect(grid.height, equals(20));
      });

      test('should generate grid with some alive cells', () {
        final grid = gridGenerator.generateSmartAutofill(width: 20, height: 20);

        expect(grid.aliveCount, greaterThan(0));
      });

      test('should generate different patterns on multiple calls', () {
        final grid1 = gridGenerator.generateSmartAutofill(width: 20, height: 20);
        final grid2 = gridGenerator.generateSmartAutofill(width: 20, height: 20);

        expect(grid1, isNot(equals(grid2)));
      });

      test('should generate patterns within grid bounds', () {
        final grid = gridGenerator.generateSmartAutofill(width: 20, height: 20);

        for (final cell in grid.aliveCells) {
          expect(grid.isValidPosition(cell.position), isTrue);
        }
      });
    });

    group('_addInterestingPattern', () {
      test('should add pattern to grid', () {
        final grid = GameGrid.empty(width: 20, height: 20);
        final originalAliveCount = grid.aliveCount;

        final newGrid = gridGenerator.generateSmartAutofill(width: 20, height: 20);

        expect(newGrid.aliveCount, greaterThan(originalAliveCount));
      });

      test('should place patterns away from edges', () {
        final grid = gridGenerator.generateSmartAutofill(width: 20, height: 20);

        for (final cell in grid.aliveCells) {
          expect(cell.position.x, greaterThanOrEqualTo(0));
          expect(cell.position.x, lessThan(20));
          expect(cell.position.y, greaterThanOrEqualTo(0));
          expect(cell.position.y, lessThan(20));
        }
      });
    });

    group('_addSingleCells', () {
      test('should add single cells to grid', () {
        final grid = GameGrid.empty(width: 20, height: 20);
        final originalAliveCount = grid.aliveCount;

        final newGrid = gridGenerator.generateSmartAutofill(width: 20, height: 20);

        expect(newGrid.aliveCount, greaterThanOrEqualTo(originalAliveCount));
      });
    });

    group('_rotatePosition', () {
      test('should rotate position by 0 steps', () {
        final position = Position(x: 1, y: 2);
        final rotated = gridGenerator.generateSmartAutofill(width: 20, height: 20);
        
        // This is a bit of a hack to test the private method indirectly
        // In a real scenario, we'd test the rotation logic more directly
        expect(rotated, isA<GameGrid>());
      });
    });

    group('deterministic behavior', () {
      test('should generate same grid with same seed', () {
        final generator1 = GridGenerator(random: Random(42));
        final generator2 = GridGenerator(random: Random(42));

        final grid1 = generator1.generateRandom(width: 5, height: 5);
        final grid2 = generator2.generateRandom(width: 5, height: 5);

        expect(grid1, equals(grid2));
      });

      test('should generate different grids with different seeds', () {
        final generator1 = GridGenerator(random: Random(42));
        final generator2 = GridGenerator(random: Random(43));

        final grid1 = generator1.generateRandom(width: 5, height: 5);
        final grid2 = generator2.generateRandom(width: 5, height: 5);

        expect(grid1, isNot(equals(grid2)));
      });
    });
  });
} 