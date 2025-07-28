import 'dart:async';
import '../models/game_state.dart';
import '../models/game_grid.dart';
import '../models/position.dart';
import '../services/game_engine.dart';
import '../services/grid_generator.dart';

class GameRepository {
  GameRepository({
    GameEngine? gameEngine,
    GridGenerator? gridGenerator,
  }) : _gameEngine = gameEngine ?? const GameEngine(),
       _gridGenerator = gridGenerator ?? GridGenerator();

  final GameEngine _gameEngine;
  final GridGenerator _gridGenerator;

  GameState _currentState = GameState.initial(
    gridWidth: 40,
    gridHeight: 40,
  );

  Timer? _gameTimer;
  final List<GameGrid> _history = [];

  final StreamController<GameState> _stateController = StreamController<GameState>.broadcast();

  Stream<GameState> get gameStateStream => _stateController.stream;

  GameState get currentState => _currentState;

  void initializeGame({
    required int width,
    required int height,
    int generationDurationMs = 500,
  }) {
    _stopGame();
    _history.clear();
    
    _currentState = GameState.initial(
      gridWidth: width,
      gridHeight: height,
      generationDurationMs: generationDurationMs,
    );
    
    _emitState();
  }

  void startGame() {
    if (!_currentState.canStart) return;

    _currentState = _currentState.copyWith(status: GameStatus.running);
    _emitState();
  }

  void pauseGame() {
    if (!_currentState.canPause) return;

    _currentState = _currentState.copyWith(status: GameStatus.paused);
    _stopTimer();
    _emitState();
  }

  void stopGame() {
    if (!_currentState.canStop) return;

    _currentState = _currentState.copyWith(status: GameStatus.stopped);
    _stopTimer();
    _emitState();
  }

  void resetGame() {
    if (!_currentState.canReset) return;

    _stopGame();
    _history.clear();
    
    _currentState = GameState.initial(
      gridWidth: _currentState.grid.width,
      gridHeight: _currentState.grid.height,
      generationDurationMs: _currentState.generationDurationMs,
    );
    
    _emitState();
  }

  void nextGeneration() {
    _advanceGeneration();
  }

  void toggleCell(Position position) {
    // Only allow cell editing when game is not running
    if (_currentState.isRunning) return;

    final newGrid = _currentState.grid.toggleCellAt(position);
    _currentState = _currentState.copyWith(grid: newGrid);
    _emitState();
  }

  void generateRandomGrid({double aliveProbability = 0.3}) {
    if (_currentState.isRunning) return;

    final newGrid = _gridGenerator.generateRandom(
      width: _currentState.grid.width,
      height: _currentState.grid.height,
      aliveProbability: aliveProbability,
    );

    _currentState = _currentState.copyWith(grid: newGrid);
    _emitState();
  }

  void setGenerationDuration(int durationMs) {
    _currentState = _currentState.copyWith(generationDurationMs: durationMs);
    
    // Restart timer if game is running
    if (_currentState.isRunning) {
      _startTimer();
    }
    
    _emitState();
  }

  void clearGrid() {
    if (_currentState.isRunning) return;

    final newGrid = GameGrid.empty(
      width: _currentState.grid.width,
      height: _currentState.grid.height,
    );

    _currentState = _currentState.copyWith(grid: newGrid);
    _emitState();
  }

  GameGridStats getGridStats() {
    return _gameEngine.getGridStats(_currentState.grid);
  }

  bool isStableState() {
    if (_history.isEmpty) return false;
    return _gameEngine.isStableState(_currentState.grid, _history.last);
  }

  bool isEmpty() {
    return _gameEngine.isEmpty(_currentState.grid);
  }

  int? detectOscillation() {
    return _gameEngine.detectOscillation(_history);
  }

  List<GameGrid> get history => List.unmodifiable(_history);

  void _startTimer() {
    _stopTimer();
    _gameTimer = Timer.periodic(
      Duration(milliseconds: _currentState.generationDurationMs),
      (_) => _advanceGeneration(),
    );
  }

  void _stopTimer() {
    _gameTimer?.cancel();
    _gameTimer = null;
  }

  void _advanceGeneration() {
    // Save current state to history
    _history.add(_currentState.grid);
    
    // Limit history size to prevent memory issues
    if (_history.length > 100) {
      _history.removeAt(0);
    }

    // Calculate next generation
    final nextGrid = _gameEngine.nextGeneration(_currentState.grid);
    
    _currentState = _currentState.copyWith(
      grid: nextGrid,
      generation: _currentState.generation + 1,
    );

    // Check for end conditions
    if (_gameEngine.isEmpty(nextGrid)) {
      // All cells died - stop the game
      _stopGame();
    } else if (_history.isNotEmpty && _gameEngine.isStableState(nextGrid, _history.last)) {
      // Reached stable state - stop the game
      _stopGame();
    }

    _emitState();
  }

  void _stopGame() {
    _stopTimer();
    if (_currentState.isRunning || _currentState.isPaused) {
      _currentState = _currentState.copyWith(status: GameStatus.stopped);
    }
  }

  void _emitState() {
    _stateController.add(_currentState);
  }

  void dispose() {
    _stopTimer();
    _stateController.close();
  }
} 