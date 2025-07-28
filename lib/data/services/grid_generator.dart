import 'dart:math';
import '../models/cell.dart';
import '../models/game_grid.dart';
import '../models/position.dart';

class GridGenerator {
  GridGenerator({Random? random}) : _random = random ?? Random();

  final Random _random;

  GameGrid generateRandom({
    required int width,
    required int height,
    double aliveProbability = 0.3,
  }) {
    final List<List<Cell>> cells = [];

    for (int y = 0; y < height; y++) {
      final row = <Cell>[];
      for (int x = 0; x < width; x++) {
        final position = Position(x: x, y: y);
        final isAlive = _random.nextDouble() < aliveProbability;
        
        row.add(isAlive
            ? Cell.alive(position)
            : Cell.dead(position));
      }
      cells.add(row);
    }

    return GameGrid(
      width: width,
      height: height,
      cells: cells,
    );
  }

  GameGrid generateFromPositions({
    required int width,
    required int height,
    required List<Position> alivePositions,
  }) {
    GameGrid grid = GameGrid.empty(width: width, height: height);

    for (final position in alivePositions) {
      if (grid.isValidPosition(position)) {
        grid = grid.setCellAt(position, Cell.alive(position));
      }
    }

    return grid;
  }

  GameGrid generateSmartAutofill({
    required int width,
    required int height,
  }) {
    GameGrid grid = GameGrid.empty(width: width, height: height);
    
    final clusterCount = 3 + _random.nextInt(3);
    
    for (int i = 0; i < clusterCount; i++) {
      grid = _addInterestingPattern(grid);
    }
    
    if (_random.nextBool()) {
      grid = _addSingleCells(grid, 1 + _random.nextInt(2));
    }
    
    return grid;
  }

  GameGrid _addInterestingPattern(GameGrid grid) {
    final margin = 5;
    final centerX = margin + _random.nextInt(grid.width - 2 * margin);
    final centerY = margin + _random.nextInt(grid.height - 2 * margin);
    
    final patterns = [
      [
        Position(x: 0, y: 0),
        Position(x: 1, y: 0),
        Position(x: 2, y: 0),
      ],
      
      [
        Position(x: 0, y: 0),
        Position(x: 0, y: 1),
        Position(x: 1, y: 0),
        Position(x: 1, y: 1),
      ],
      
      [
        Position(x: 0, y: 1),
        Position(x: 1, y: 1),
        Position(x: 2, y: 1),
        Position(x: 1, y: 0),
        Position(x: 2, y: 0),
        Position(x: 3, y: 0),
      ],
      
      [
        Position(x: 0, y: 0),
        Position(x: 0, y: 1),
        Position(x: 1, y: 0),
        Position(x: 2, y: 3),
        Position(x: 3, y: 2),
        Position(x: 3, y: 3),
      ],
      
      [
        Position(x: 0, y: 1),
        Position(x: 1, y: 2),
        Position(x: 2, y: 0),
        Position(x: 2, y: 1),
        Position(x: 2, y: 2),
      ],
      
      [
        Position(x: 0, y: 1),
        Position(x: 0, y: 2),
        Position(x: 1, y: 0),
        Position(x: 1, y: 1),
        Position(x: 2, y: 1),
      ],
      
      [
        Position(x: 0, y: 0),
        Position(x: 0, y: 1),
        Position(x: 1, y: 0),
      ],
      
      [
        Position(x: 0, y: 1),
        Position(x: 1, y: 0),
        Position(x: 1, y: 1),
        Position(x: 1, y: 2),
      ],
    ];
    
    final patternIndex = _random.nextInt(patterns.length);
    final pattern = patterns[patternIndex];
    
    final rotation = _random.nextInt(4);
    
    for (final offset in pattern) {
      final rotatedOffset = _rotatePosition(offset, rotation);
      final position = Position(
        x: centerX + rotatedOffset.x,
        y: centerY + rotatedOffset.y,
      );
      
      if (grid.isValidPosition(position)) {
        grid = grid.setCellAt(position, Cell.alive(position));
      }
    }
    
    return grid;
  }

  GameGrid _addSingleCells(GameGrid grid, int count) {
    for (int i = 0; i < count; i++) {
      final x = _random.nextInt(grid.width);
      final y = _random.nextInt(grid.height);
      final position = Position(x: x, y: y);
      
      final cell = grid.getCellAt(position);
      if (cell != null && cell.isDead && grid.getAliveNeighborCount(position) <= 1) {
        grid = grid.setCellAt(position, Cell.alive(position));
      }
    }
    
    return grid;
  }

  Position _rotatePosition(Position pos, int steps) {
    var x = pos.x;
    var y = pos.y;
    
    for (int i = 0; i < steps % 4; i++) {
      final temp = x;
      x = -y;
      y = temp;
    }
    
    return Position(x: x, y: y);
  }
}