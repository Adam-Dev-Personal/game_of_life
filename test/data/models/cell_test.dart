import 'package:flutter_test/flutter_test.dart';
import 'package:game_of_life/data/models/cell.dart';
import 'package:game_of_life/data/models/position.dart';

void main() {
  group('Cell', () {
    test('should create alive cell', () {
      final position = Position(x: 1, y: 2);
      final cell = Cell.alive(position);

      expect(cell.position, equals(position));
      expect(cell.state, equals(CellState.alive));
      expect(cell.isAlive, isTrue);
      expect(cell.isDead, isFalse);
    });

    test('should create dead cell', () {
      final position = Position(x: 3, y: 4);
      final cell = Cell.dead(position);

      expect(cell.position, equals(position));
      expect(cell.state, equals(CellState.dead));
      expect(cell.isAlive, isFalse);
      expect(cell.isDead, isTrue);
    });

    test('should create cell with custom state', () {
      final position = Position(x: 0, y: 0);
      final cell = Cell(position: position, state: CellState.alive);

      expect(cell.position, equals(position));
      expect(cell.state, equals(CellState.alive));
    });

    test('should toggle alive cell to dead', () {
      final position = Position(x: 1, y: 1);
      final aliveCell = Cell.alive(position);
      final deadCell = aliveCell.toggle();

      expect(deadCell.position, equals(position));
      expect(deadCell.state, equals(CellState.dead));
      expect(deadCell.isDead, isTrue);
    });

    test('should toggle dead cell to alive', () {
      final position = Position(x: 2, y: 2);
      final deadCell = Cell.dead(position);
      final aliveCell = deadCell.toggle();

      expect(aliveCell.position, equals(position));
      expect(aliveCell.state, equals(CellState.alive));
      expect(aliveCell.isAlive, isTrue);
    });

    test('should be equal when same position and state', () {
      final position1 = Position(x: 1, y: 1);
      final position2 = Position(x: 1, y: 1);
      final cell1 = Cell.alive(position1);
      final cell2 = Cell.alive(position2);

      expect(cell1, equals(cell2));
    });

    test('should not be equal when different states', () {
      final position = Position(x: 1, y: 1);
      final aliveCell = Cell.alive(position);
      final deadCell = Cell.dead(position);

      expect(aliveCell, isNot(equals(deadCell)));
    });

    test('should not be equal when different positions', () {
      final position1 = Position(x: 1, y: 1);
      final position2 = Position(x: 2, y: 2);
      final cell1 = Cell.alive(position1);
      final cell2 = Cell.alive(position2);

      expect(cell1, isNot(equals(cell2)));
    });

    test('should have correct string representation', () {
      final position = Position(x: 1, y: 2);
      final aliveCell = Cell.alive(position);
      final deadCell = Cell.dead(position);

      expect(aliveCell.toString(), contains('alive'));
      expect(deadCell.toString(), contains('dead'));
      expect(aliveCell.toString(), contains('Position(x: 1, y: 2)'));
      expect(deadCell.toString(), contains('Position(x: 1, y: 2)'));
    });
  });
} 