import 'package:flutter_test/flutter_test.dart';
import 'package:game_of_life/data/models/position.dart';

void main() {
  group('Position', () {
    test('should create position with x and y coordinates', () {
      final position = Position(x: 3, y: 5);

      expect(position.x, equals(3));
      expect(position.y, equals(5));
    });

    test('should be equal when same coordinates', () {
      final position1 = Position(x: 1, y: 2);
      final position2 = Position(x: 1, y: 2);

      expect(position1, equals(position2));
    });

    test('should not be equal when different coordinates', () {
      final position1 = Position(x: 1, y: 2);
      final position2 = Position(x: 2, y: 1);

      expect(position1, isNot(equals(position2)));
    });

    test('should have correct string representation', () {
      final position = Position(x: 3, y: 7);

      expect(position.toString(), equals('Position(x: 3, y: 7)'));
    });

    test('should get all 8 neighbors', () {
      final position = Position(x: 1, y: 1);
      final neighbors = position.getNeighbors();

      expect(neighbors.length, equals(8));
      expect(neighbors, contains(Position(x: 0, y: 0)));
      expect(neighbors, contains(Position(x: 0, y: 1)));
      expect(neighbors, contains(Position(x: 0, y: 2)));
      expect(neighbors, contains(Position(x: 1, y: 0)));
      expect(neighbors, contains(Position(x: 1, y: 2)));
      expect(neighbors, contains(Position(x: 2, y: 0)));
      expect(neighbors, contains(Position(x: 2, y: 1)));
      expect(neighbors, contains(Position(x: 2, y: 2)));
    });

    test('should get neighbors for corner position', () {
      final position = Position(x: 0, y: 0);
      final neighbors = position.getNeighbors();

      expect(neighbors.length, equals(8));
      expect(neighbors, contains(Position(x: -1, y: -1)));
      expect(neighbors, contains(Position(x: -1, y: 0)));
      expect(neighbors, contains(Position(x: -1, y: 1)));
      expect(neighbors, contains(Position(x: 0, y: -1)));
      expect(neighbors, contains(Position(x: 0, y: 1)));
      expect(neighbors, contains(Position(x: 1, y: -1)));
      expect(neighbors, contains(Position(x: 1, y: 0)));
      expect(neighbors, contains(Position(x: 1, y: 1)));
    });

    test('should get neighbors for edge position', () {
      final position = Position(x: 0, y: 5);
      final neighbors = position.getNeighbors();

      expect(neighbors.length, equals(8));
      expect(neighbors, contains(Position(x: -1, y: 4)));
      expect(neighbors, contains(Position(x: -1, y: 5)));
      expect(neighbors, contains(Position(x: -1, y: 6)));
      expect(neighbors, contains(Position(x: 0, y: 4)));
      expect(neighbors, contains(Position(x: 0, y: 6)));
      expect(neighbors, contains(Position(x: 1, y: 4)));
      expect(neighbors, contains(Position(x: 1, y: 5)));
      expect(neighbors, contains(Position(x: 1, y: 6)));
    });

    test('should handle negative coordinates', () {
      final position = Position(x: -2, y: -3);
      final neighbors = position.getNeighbors();

      expect(neighbors.length, equals(8));
      expect(neighbors, contains(Position(x: -3, y: -4)));
      expect(neighbors, contains(Position(x: -3, y: -3)));
      expect(neighbors, contains(Position(x: -3, y: -2)));
      expect(neighbors, contains(Position(x: -2, y: -4)));
      expect(neighbors, contains(Position(x: -2, y: -2)));
      expect(neighbors, contains(Position(x: -1, y: -4)));
      expect(neighbors, contains(Position(x: -1, y: -3)));
      expect(neighbors, contains(Position(x: -1, y: -2)));
    });
  });
} 