# Game of Life - Unit Tests

This directory contains comprehensive unit tests for the Game of Life application.

## Test Structure

### Data Models
- **`cell_test.dart`** - Tests for the Cell model (cell state, toggling, equality)
- **`position_test.dart`** - Tests for the Position model (coordinates, neighbors, equality)
- **`game_grid_test.dart`** - Tests for the GameGrid model (grid operations, change tracking)

### Services
- **`game_engine_test.dart`** - Tests for Conway's Game of Life rules implementation
- **`grid_generator_test.dart`** - Tests for grid generation patterns and randomization

### Repositories
- **`game_repository_test.dart`** - Tests for game state management and operations

## Running Tests

### Run All Tests
```bash
flutter test
```

### Run Specific Test File
```bash
flutter test test/data/models/cell_test.dart
```

### Run Tests with Coverage
```bash
flutter test --coverage
```

### Run Tests with Verbose Output
```bash
flutter test --verbose
```

## Test Coverage

The tests cover:

### Cell Model
- ✅ Cell creation (alive/dead)
- ✅ Cell state toggling
- ✅ Equality comparisons
- ✅ String representation

### Position Model
- ✅ Position creation and coordinates
- ✅ Neighbor calculation (8 neighbors)
- ✅ Edge and corner cases
- ✅ Negative coordinates

### GameGrid Model
- ✅ Grid creation and dimensions
- ✅ Cell access and modification
- ✅ Position validation
- ✅ Alive/dead cell counting
- ✅ Neighbor counting
- ✅ Change tracking between generations
- ✅ Grid copying

### GameEngine Service
- ✅ Conway's Game of Life rules
- ✅ Cell survival conditions (2-3 neighbors)
- ✅ Cell birth conditions (exactly 3 neighbors)
- ✅ Cell death conditions (underpopulation/overpopulation)
- ✅ Stable state detection
- ✅ Oscillation detection
- ✅ Grid statistics

### GridGenerator Service
- ✅ Random grid generation
- ✅ Grid generation from positions
- ✅ Smart autofill patterns
- ✅ Pattern placement and rotation
- ✅ Deterministic behavior with seeds

### GameRepository
- ✅ Game initialization
- ✅ State management (start/pause/stop/reset)
- ✅ Cell operations
- ✅ Generation advancement
- ✅ Grid generation
- ✅ Statistics and analysis
- ✅ History management
- ✅ Stream management

## Test Patterns

### Setup and Teardown
Each test group uses `setUp()` to initialize test dependencies and ensure clean state.

### Edge Cases
Tests include edge cases like:
- Invalid positions
- Empty grids
- Single cells
- Corner and edge positions
- Boundary conditions

### Conway's Rules Validation
The GameEngine tests specifically validate all four rules of Conway's Game of Life:
1. Any live cell with 2-3 live neighbors survives
2. Any dead cell with exactly 3 live neighbors becomes alive
3. All other live cells die in the next generation
4. All other dead cells stay dead

### Performance Considerations
Tests verify that:
- Change tracking is efficient (only checks relevant cells)
- Grid operations are O(1) where expected
- Memory usage is reasonable

## Adding New Tests

When adding new functionality:

1. **Create test file** in the appropriate directory
2. **Follow naming convention**: `{class_name}_test.dart`
3. **Group related tests** using `group()` blocks
4. **Test edge cases** and error conditions
5. **Use descriptive test names** that explain the expected behavior
6. **Add to `all_tests.dart`** if creating a new test category

## Test Best Practices

- **Arrange-Act-Assert**: Structure tests with clear setup, action, and verification
- **One assertion per test**: Focus each test on a single behavior
- **Descriptive names**: Test names should explain what is being tested
- **Independent tests**: Each test should be able to run in isolation
- **Fast execution**: Tests should complete quickly for efficient development 