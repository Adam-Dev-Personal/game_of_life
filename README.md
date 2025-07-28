# Conway's Game of Life

A Flutter-based app on Conway’s Game of Life. It supports large grids, smooth animations, and interactive editing. Built with performance and usability in mind.

<br/><br/>

## Features

### 🧬 Core Simulation
- Implements the classic Game of Life rules
- Smoothly animates cell generations
- Works well with large grids
- Manual step mode or auto-play with pause/resume
- Reset simulation at any time

### 🎨 Grid Interaction
- Tap to toggle cells in edit mode
- Random fill feature
- Adjustable grid size
- Zoom and pan support for easier navigation

### ⚙️ Under the Hood
- Efficient rendering with `CustomPainter`
- Only updates changed cells for better performance
- Detects stable and oscillating states
- Displays live stats (cell count, generation number, etc.)
- Runs on mobile, desktop, and web

### 💡 UI & UX
- Clean, simple interface
- Glass effect style widgets
- Responsive layout for all screen sizes

<br/><br/>

## Tech Stack

### Framework & Language
- **Flutter**
- **Dart**

### Architecture
- MVVM structure (Model-View-ViewModel)
- `Provider` for state management
- Reactive updates via `ChangeNotifier`

### Rendering & Performance
- `CustomPainter` + `InteractiveViewer` for grid
- Central `AnimationController` for transitions
- 2D array for fast cell lookups and updates

### Testing
- 80+ unit tests
- Covers logic, edge cases, and performance
- Written with Flutter's built-in test framework

<br/><br/>

## Getting Started

### Prerequisites
- Flutter SDK (3.0+)
- Dart SDK
- IDE of your choice (Android Studio, VS Code)

### Setup

```bash
# Clone the repo
git clone https://github.com/Adam-Dev-Personal/game-of-life.git
cd game-of-life

# Install dependencies
flutter pub get

# Run the app
flutter run
```

### Running Tests

```bash
flutter test             # Run all tests
flutter test --coverage # With coverage report
flutter test test/data/models/cell_test.dart # Single test file
```

<br/><br/>

## Screenshots

<img width="200" height="434" alt="Image" src="https://github.com/user-attachments/assets/6d81cb58-afd3-4cb4-ab2d-2d25dc5105ad" />
<img width="200" height="434" alt="Image" src="https://github.com/user-attachments/assets/7fa9c7ba-0549-44aa-a96a-7a290555591d" />
<img width="200" height="434" alt="Image" src="https://github.com/user-attachments/assets/3824d1f6-7f90-4ac4-ae4a-bdbc9bb28307" />
<img width="200" height="434" alt="Image" src="https://github.com/user-attachments/assets/44b6786d-525d-4fb6-838e-d7f21d381aa1" />

<br/><br/>

## Testing Overview

This project includes tests for:

- Data models: `Cell`, `Position`, `GameGrid`, etc.
- Core logic: Simulation engine (Conway’s rules)
- Edge cases: Boundary handling, invalid input
- Performance: Change tracking, animation sync

**All tests passing ✅**

<br/><br/>

## Game Rules

The simulation follows the standard Conway's Game of Life rules:

1. **Alive** – A live cell with 2 or 3 neighbors stays alive  
2. **From Dead to Alive** – A dead cell with exactly 3 neighbors becomes alive  
3. **From Alive to Dead** – An alive cell with less than 2 or more than 3 neighbors becomes dead
4. **Dead** – A dead cell, stays dead until 3 neighbors are alive

<br/><br/>

## Performance Details

### Rendering
- Uses `CustomPainter` for direct canvas drawing
- Tracks changes to only repaint updated cells
- Shared `AnimationController` for smoother transitions

### Data
- 2D array instead of `Map` for fast access
- Grid updates are batched for efficiency
