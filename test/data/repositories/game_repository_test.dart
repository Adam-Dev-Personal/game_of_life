import 'package:flutter_test/flutter_test.dart';
import 'package:game_of_life/data/repositories/game_repository.dart';
import 'package:game_of_life/data/services/game_engine.dart';
import 'package:game_of_life/data/services/grid_generator.dart';
import 'package:game_of_life/data/models/game_state.dart';
import 'package:game_of_life/data/models/position.dart';

void main() {
  group('GameRepository', () {
    late GameRepository repository;
    late GameEngine mockGameEngine;
    late GridGenerator mockGridGenerator;

    setUp(() {
      mockGameEngine = const GameEngine();
      mockGridGenerator = GridGenerator();
      repository = GameRepository(
        gameEngine: mockGameEngine,
        gridGenerator: mockGridGenerator,
      );
    });

    group('initialization', () {
      test('should initialize with default state', () {
        expect(repository.currentState.grid.width, equals(40));
        expect(repository.currentState.grid.height, equals(40));
        expect(repository.currentState.status, equals(GameStatus.initial));
      });

      test('should initialize game with custom configuration', () {
        repository.initializeGame(width: 10, height: 15, generationDurationMs: 1000);

        expect(repository.currentState.grid.width, equals(10));
        expect(repository.currentState.grid.height, equals(15));
        expect(repository.currentState.generationDurationMs, equals(1000));
        expect(repository.currentState.status, equals(GameStatus.initial));
      });
    });

    group('game state management', () {
      test('should start game', () {
        repository.initializeGame(width: 3, height: 3);
        repository.startGame();

        expect(repository.currentState.status, equals(GameStatus.running));
      });

      test('should pause game', () {
        repository.initializeGame(width: 3, height: 3);
        repository.startGame();
        repository.pauseGame();

        expect(repository.currentState.status, equals(GameStatus.paused));
      });

      test('should stop game', () {
        repository.initializeGame(width: 3, height: 3);
        repository.startGame();
        repository.stopGame();

        expect(repository.currentState.status, equals(GameStatus.stopped));
      });

      test('should reset game', () {
        repository.initializeGame(width: 3, height: 3);
        repository.startGame();
        repository.resetGame();

        expect(repository.currentState.status, equals(GameStatus.initial));
        expect(repository.currentState.generation, equals(0));
      });
    });

    group('cell operations', () {
      test('should toggle cell when game is not running', () {
        repository.initializeGame(width: 3, height: 3);
        final position = Position(x: 1, y: 1);

        repository.toggleCell(position);

        expect(repository.currentState.grid.getCellAt(position)!.isAlive, isTrue);
      });

      test('should not toggle cell when game is running', () {
        repository.initializeGame(width: 3, height: 3);
        repository.startGame();
        final position = Position(x: 1, y: 1);

        repository.toggleCell(position);

        expect(repository.currentState.grid.getCellAt(position)!.isDead, isTrue);
      });

      test('should clear grid', () {
        repository.initializeGame(width: 3, height: 3);
        repository.toggleCell(Position(x: 1, y: 1));
        repository.clearGrid();

        expect(repository.currentState.grid.aliveCount, equals(0));
      });
    });

    group('generation management', () {
      test('should advance generation manually', () {
        repository.initializeGame(width: 3, height: 3);
        final initialGeneration = repository.currentState.generation;

        repository.nextGeneration();

        expect(repository.currentState.generation, equals(initialGeneration + 1));
      });

      test('should set generation duration', () {
        repository.initializeGame(width: 3, height: 3);
        repository.setGenerationDuration(2000);

        expect(repository.currentState.generationDurationMs, equals(2000));
      });
    });

    group('grid generation', () {
      test('should generate random grid', () {
        repository.initializeGame(width: 3, height: 3);
        repository.generateRandomGrid(aliveProbability: 0.5);

        expect(repository.currentState.grid.aliveCount, greaterThan(0));
      });

      test('should not generate random grid when game is running', () {
        repository.initializeGame(width: 3, height: 3);
        repository.startGame();
        final originalGrid = repository.currentState.grid;

        repository.generateRandomGrid();

        expect(repository.currentState.grid, equals(originalGrid));
      });
    });

    group('game statistics', () {
      test('should get grid stats', () {
        repository.initializeGame(width: 2, height: 2);
        repository.toggleCell(Position(x: 0, y: 0));
        repository.toggleCell(Position(x: 1, y: 1));

        final stats = repository.getGridStats();

        expect(stats.totalCells, equals(4));
        expect(stats.aliveCells, equals(2));
        expect(stats.deadCells, equals(2));
        expect(stats.alivePercentage, equals(50.0));
      });

      test('should check if grid is empty', () {
        repository.initializeGame(width: 3, height: 3);
        expect(repository.isEmpty(), isTrue);

        repository.toggleCell(Position(x: 1, y: 1));
        expect(repository.isEmpty(), isFalse);
      });

      test('should check if state is stable', () {
        repository.initializeGame(width: 3, height: 3);
        expect(repository.isStableState(), isFalse); // No history yet

        repository.nextGeneration(); // Add to history
        expect(repository.isStableState(), isTrue); // Now has history to compare

        repository.toggleCell(Position(x: 1, y: 1));
        expect(repository.isStableState(), isFalse); // Different from history
      });

      test('should detect oscillation', () {
        repository.initializeGame(width: 3, height: 3);
        expect(repository.detectOscillation(), isNull);
      });
    });

    group('history management', () {
      test('should maintain generation history', () {
        repository.initializeGame(width: 3, height: 3);
        repository.nextGeneration();
        repository.nextGeneration();

        expect(repository.history.length, equals(2));
      });

      test('should limit history size', () {
        repository.initializeGame(width: 3, height: 3);
        
        for (int i = 0; i < 15; i++) {
          repository.nextGeneration();
        }

        expect(repository.history.length, lessThanOrEqualTo(15));
      });
    });

    group('stream management', () {
      test('should emit state changes', () async {
        repository.initializeGame(width: 3, height: 3);
        
        final states = <GameState>[];
        final subscription = repository.gameStateStream.listen(states.add);

        repository.startGame();
        await Future.delayed(const Duration(milliseconds: 10));

        expect(states.length, greaterThan(0));
        expect(states.last.status, equals(GameStatus.running));

        subscription.cancel();
      });
    });

    group('disposal', () {
      test('should dispose resources', () {
        repository.initializeGame(width: 3, height: 3);
        repository.startGame();
        
        expect(() => repository.dispose(), returnsNormally);
      });
    });
  });
} 