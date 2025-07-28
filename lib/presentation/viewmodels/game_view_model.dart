import 'dart:async';
import 'package:flutter/material.dart';
import '../../data/models/game_state.dart';
import '../../data/models/game_grid.dart';
import '../../data/models/position.dart';

import '../../data/repositories/game_repository.dart';
import '../../data/services/grid_generator.dart';

/// Represents the different game modes for UI control
enum GameMode {
  configuration, // Initial configuration (board size, game mode selection)
  edit,         // User can manually set up cells
  play,         // Game is running/paused but not editable
}



/// Represents board size options
enum BoardSize {
  small,   // 30x30
  normal,  // 50x50  
  large,   // 70x70
}

/// ViewModel that manages the Game of Life state and UI interactions
class GameViewModel extends ChangeNotifier {
  GameViewModel({
    GameRepository? gameRepository,
    GridGenerator? gridGenerator,
  }) : _gameRepository = gameRepository ?? GameRepository(),
       _gridGenerator = gridGenerator ?? GridGenerator() {
    _initializeGame();
  }

  final GameRepository _gameRepository;
  final GridGenerator _gridGenerator;
  StreamSubscription<GameState>? _gameStateSubscription;

  // State
  GameState _gameState = GameState.initial(gridWidth: 50, gridHeight: 50);
  GameMode _gameMode = GameMode.configuration;
  BoardSize _boardSize = BoardSize.small; // Start with small as default
  bool _isAutofillLoading = false;
  bool _isAutoMode = true; // true = auto generation, false = manual stepping
  int _totalAliveCellsEver = 0; // Track total cells that have ever been alive
  bool _isAnimating = false; // Track if animations are in progress
  bool _isPauseQueued = false; // Track if pause action is queued during animations
  
  // Grid transformation management
  final TransformationController _transformationController = TransformationController();
  bool _hasInitializedTransformation = false;
  
  // Classic mode timers
  Timer? _classicGenerationTimer;

  // Getters
  GameState get gameState => _gameState;
  GameMode get gameMode => _gameMode;
  BoardSize get boardSize => _boardSize;
  bool get isAutofillLoading => _isAutofillLoading;
  bool get isAutoMode => _isAutoMode;
  int get totalAliveCellsEver => _totalAliveCellsEver;
  int get currentAliveCells => _gameState.grid.aliveCells.length;
  TransformationController get transformationController => _transformationController;
  
  // Computed properties
  bool get isConfigurationMode => _gameMode == GameMode.configuration;
  bool get isEditMode => _gameMode == GameMode.edit;
  bool get isPlayMode => _gameMode == GameMode.play;
  bool get canStartGame => _hasValidStartingCells();
  bool get isGameRunning => _gameState.isRunning;
  bool get isGamePaused => _gameState.isPaused;
  bool get isAnimating => _isAnimating;
  bool get isPauseQueued => _isPauseQueued;
  VoidCallback? get onAnimationsComplete => _isAnimating ? _handleAnimationsComplete : null;

  // Board size dimensions
  Map<BoardSize, Map<String, int>> get boardSizeDimensions => {
    BoardSize.small: {'width': 30, 'height': 30},
    BoardSize.normal: {'width': 50, 'height': 50},
    BoardSize.large: {'width': 70, 'height': 70},
  };

  String getBoardSizeDescription(BoardSize size) {
    final dimensions = boardSizeDimensions[size]!;
    final width = dimensions['width']!;
    final height = dimensions['height']!;
    
    switch (size) {
      case BoardSize.small:
        return 'Small sized board ($width x $height)';
      case BoardSize.normal:
        return 'Normal sized board ($width x $height)';
      case BoardSize.large:
        return 'Large sized board ($width x $height)';
    }
  }

  /// Set the board size and reinitialize the game
  void setBoardSize(BoardSize size) {
    _boardSize = size;
    _hasInitializedTransformation = false; // Reset transformation for new size
    _initializeGame();
    notifyListeners();
  }

  /// Initialize grid transformation for configuration mode
  void initializeGridTransformation(Size screenSize, double cellSize) {
    if (_hasInitializedTransformation) return;
    
    final dimensions = boardSizeDimensions[_boardSize]!;
    final gridWidth = dimensions['width']!;
    final gridHeight = dimensions['height']!;
    
    // Calculate grid dimensions in pixels
    final gridPixelWidth = gridWidth * (cellSize + 1.0);
    final gridPixelHeight = gridHeight * (cellSize + 1.0);
    
    // Determine if screen is portrait or landscape
    final isPortrait = screenSize.height > screenSize.width;
    
    double scale;
    double translateX = 0;
    double translateY = 0;
    
    if (isPortrait) {
      // Portrait: fill height, center horizontally
      scale = screenSize.height / gridPixelHeight;
      translateX = (screenSize.width - (gridPixelWidth * scale)) / 2;
    } else {
      // Landscape: fill width, center vertically
      scale = screenSize.width / gridPixelWidth;
      translateY = (screenSize.height - (gridPixelHeight * scale)) / 2;
    }
    
    // Apply transformation
    final matrix = Matrix4.identity()
      ..translate(translateX, translateY)
      ..scale(scale);
    
    _transformationController.value = matrix;
    _hasInitializedTransformation = true;
  }



  /// Continue from configuration to edit mode
  void continueToEditMode() {
    _gameMode = GameMode.edit;
    // Transformation is preserved from configuration mode
    notifyListeners();
  }

  /// Initialize the game with current board size
  void _initializeGame() {
    final dimensions = boardSizeDimensions[_boardSize]!;
    final width = dimensions['width']!;
    final height = dimensions['height']!;
    
    _gameRepository.initializeGame(
      width: width,
      height: height,
      generationDurationMs: 1000, // 1 second for classic mode
    );
    
    _subscribeToGameState();
  }

  /// Subscribe to game state changes
  void _subscribeToGameState() {
    _gameStateSubscription = _gameRepository.gameStateStream.listen((state) {
      final previousState = _gameState;
      _gameState = state;
      
      // Check if any cells changed state (for animations)
      _checkForStateChanges(previousState, state);
      
      // Track newly alive cells for total count and auto-death feature
      _trackNewlyAliveCells(previousState, state);
      
      notifyListeners();
    });
  }

  /// Toggle a cell state (for edit mode)
  void toggleCell(Position position) {
    if (!isEditMode) return;
    
    _gameRepository.toggleCell(position);
  }

  /// Auto fill the grid with random alive cells
  Future<void> autofillGrid() async {
    _isAutofillLoading = true;
    notifyListeners();

    // Simulate loading delay for better UX
    await Future.delayed(const Duration(milliseconds: 300));

    final autofilledGrid = _generateSmartAutofill();
    _setGridInRepository(autofilledGrid);
    
    _isAutofillLoading = false;
    notifyListeners();
  }

  /// Start the game
  void startGame() {
    if (!canStartGame) return;
    
    _gameMode = GameMode.play;
    // Transformation is preserved from edit mode
    
    _startClassicMode();
    
    notifyListeners();
  }

  /// Start Classic mode (traditional Game of Life)
  void _startClassicMode() {
    _gameRepository.startGame();
    
    if (_isAutoMode) {
      _startClassicTimer();
    } else {
      // In manual mode, just advance one generation
      stepGeneration();
    }
  }



  /// Pause the game
  void pauseGame() {
    // If animations are in progress and we're in auto mode, queue the pause
    if (_isAnimating && _isAutoMode && _gameState.isRunning) {
      _isPauseQueued = true;
      notifyListeners();
      return;
    }
    
    // Otherwise, pause immediately
    _gameRepository.pauseGame();
    _stopAllTimers();
    _isPauseQueued = false; // Clear any queued pause
    notifyListeners();
  }

  /// Reset the game to edit mode (Reset Board)
  void resetToEditMode() {
    _gameRepository.resetGame();
    _gameMode = GameMode.edit;
    _totalAliveCellsEver = 0;
    _stopAllTimers();
    _isPauseQueued = false; // Clear any queued pause
    // Transformation is preserved
    notifyListeners();
  }

  /// Leave game and return to configuration mode
  void leaveGame() {
    _gameRepository.resetGame();
    _gameMode = GameMode.configuration;
    _totalAliveCellsEver = 0;
    _stopAllTimers();
    _isPauseQueued = false; // Clear any queued pause
    _hasInitializedTransformation = false; // Reset transformation for new configuration
    notifyListeners();
  }

  /// Start the classic generation timer
  void _startClassicTimer() {
    _stopAllTimers();
    _classicGenerationTimer = Timer.periodic(
      Duration(milliseconds: _gameState.generationDurationMs),
      (_) {
        if (_isAutoMode && _gameState.isRunning && !_isAnimating) {
          _gameRepository.nextGeneration();
        }
      },
    );
  }

  /// Stop all timers (used when pausing/stopping)
  void _stopAllTimers() {
    _classicGenerationTimer?.cancel();
    _classicGenerationTimer = null;
  }



  /// Toggle between auto and manual generation modes
  void togglePlayMode() {
    if (!isPlayMode) return;
    
    _isAutoMode = !_isAutoMode;
    _isPauseQueued = false; // Clear any queued pause when switching modes
    
    if (_gameState.isRunning) {
      if (_isAutoMode) {
        // Switching to auto mode - start timer
        _startClassicTimer();
      } else {
        // Switching to manual mode - stop timer and pause game
        _stopAllTimers();
        _gameRepository.pauseGame();
      }
    }
    
    notifyListeners();
  }

  /// Advance one generation manually
  void stepGeneration() {
    if (!isPlayMode || _isAutoMode || _isAnimating) return;
    
    _gameRepository.nextGeneration();
  }

  /// Resume the game (respects auto/manual mode)
  void resumeGame() {
    // Clear any queued pause when resuming
    _isPauseQueued = false;
    
    if (_isAutoMode) {
      _gameRepository.startGame();
      _startClassicTimer();
    } else {
      stepGeneration();
    }
    
    notifyListeners();
  }

  /// Generate a smart autofill pattern using the enhanced GridGenerator
  GameGrid _generateSmartAutofill() {
    return _gridGenerator.generateSmartAutofill(
      width: _gameState.grid.width,
      height: _gameState.grid.height,
    );
  }

  /// Handle animation completion
  void _handleAnimationsComplete() {
    _isAnimating = false;
    
    // Check if a pause was queued during animations
    if (_isPauseQueued) {
      _isPauseQueued = false;
      _gameRepository.pauseGame();
      _stopAllTimers();
    }
    
    notifyListeners();
    
    // The timer will handle the next generation automatically
    // No need to manually trigger it here
  }

  /// Check for state changes to trigger animations (optimized)
  void _checkForStateChanges(GameState previousState, GameState currentState) {
    // Use the optimized change tracking
    final changes = currentState.grid.getChanges(previousState.grid);
    if (changes.isNotEmpty) {
      _isAnimating = true;
    }
  }

  /// Track cells that become alive for total count (optimized)
  void _trackNewlyAliveCells(GameState previousState, GameState currentState) {
    // Use the optimized change tracking
    final changes = currentState.grid.getChanges(previousState.grid);
    
    for (final position in changes) {
      final previousCell = previousState.grid.getCellAt(position);
      final currentCell = currentState.grid.getCellAt(position);
      
      if (previousCell != null && currentCell != null) {
        // Cell became alive - increment total count
        if (!previousCell.isAlive && currentCell.isAlive) {
          _totalAliveCellsEver++;
        }
      }
    }
  }



  /// Set a custom grid in the repository by clearing and then setting individual cells
  void _setGridInRepository(GameGrid grid) {
    _gameRepository.clearGrid();
    
    // Set each alive cell individually
    final aliveCells = grid.aliveCells;
    for (final cell in aliveCells) {
      _gameRepository.toggleCell(cell.position);
    }
  }

  /// Check if there are valid starting cells (at least 2 neighboring cells)
  bool _hasValidStartingCells() {
    final aliveCells = _gameState.grid.aliveCells;
    if (aliveCells.length < 2) return false;
    
    // Check if at least one cell has at least one alive neighbor
    for (final cell in aliveCells) {
      final neighborCount = _gameState.grid.getAliveNeighborCount(cell.position);
      if (neighborCount > 0) return true;
    }
    
    return false;
  }

  @override
  void dispose() {
    _gameStateSubscription?.cancel();
    _stopAllTimers();
    _transformationController.dispose();
    _gameRepository.dispose();
    super.dispose();
  }
} 