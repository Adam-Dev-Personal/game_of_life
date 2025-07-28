import 'package:flutter/material.dart';
import '../../data/models/game_grid.dart' as model;
import '../../data/models/position.dart';

class GameGrid extends StatefulWidget {
  const GameGrid({
    super.key,
    required this.grid,
    required this.onCellTap,
    this.isEditMode = false,
    this.cellSize = 20.0,
    this.isInteractive = true,
    this.transformationController,
    this.onInitializeTransformation,
    this.onAnimationsComplete,
  });

  final model.GameGrid grid;
  final Function(Position)? onCellTap;
  final bool isEditMode;
  final double cellSize;
  final bool isInteractive;
  final TransformationController? transformationController;
  final VoidCallback? onInitializeTransformation;
  final VoidCallback? onAnimationsComplete;

  @override
  State<GameGrid> createState() => _GameGridState();
}

class _GameGridState extends State<GameGrid> with TickerProviderStateMixin {
  late AnimationController _globalAnimationController;
  late Animation<double> _globalAnimation;
  model.GameGrid? _previousGrid;
  Set<Position> _changedCells = {};
  bool _isAnimating = false;

  @override
  void initState() {
    super.initState();
    _previousGrid = widget.grid;
    
    _globalAnimationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _globalAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _globalAnimationController,
      curve: Curves.easeInOut,
    ));

    _globalAnimationController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _isAnimating = false;
        widget.onAnimationsComplete?.call();
      }
    });
  }

  @override
  void didUpdateWidget(GameGrid oldWidget) {
    super.didUpdateWidget(oldWidget);
    
    if (oldWidget.grid != widget.grid) {
      _previousGrid = oldWidget.grid;
      _trackChanges();
      if (_changedCells.isNotEmpty) {
        _isAnimating = true;
        _globalAnimationController.forward(from: 0.0);
      }
    }
  }

  void _trackChanges() {
    _changedCells.clear();
    if (_previousGrid == null) return;
    _changedCells = widget.grid.getChanges(_previousGrid!);
  }

  @override
  void dispose() {
    _globalAnimationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      widget.onInitializeTransformation?.call();
    });

    Widget gridWidget = widget.isEditMode 
        ? _buildEditableGrid()
        : _buildOptimizedGrid();

    if (widget.isInteractive && widget.transformationController != null) {
      return SizedBox.expand(
        child: InteractiveViewer(
          transformationController: widget.transformationController,
          boundaryMargin: EdgeInsets.zero,
          minScale: 0.1,
          maxScale: 5.0,
          constrained: false,
          child: gridWidget,
        ),
      );
    } else {
      return SizedBox.expand(
        child: InteractiveViewer(
          transformationController: widget.transformationController,
          panEnabled: false,
          scaleEnabled: false,
          child: gridWidget,
        ),
      );
    }
  }

  Widget _buildOptimizedGrid() {
    return AnimatedBuilder(
      animation: _globalAnimationController,
      builder: (context, child) {
        return CustomPaint(
          size: Size(
            widget.grid.width * (widget.cellSize + 1.0),
            widget.grid.height * (widget.cellSize + 1.0),
          ),
          painter: GameGridPainter(
            grid: widget.grid,
            previousGrid: _previousGrid,
            cellSize: widget.cellSize,
            animationProgress: _globalAnimation.value,
            changedCells: _changedCells,
          ),
        );
      },
    );
  }

  Widget _buildEditableGrid() {
    final totalWidth = widget.grid.width * (widget.cellSize + 1.0);
    final totalHeight = widget.grid.height * (widget.cellSize + 1.0);
    
    return GestureDetector(
      onTapUp: (details) {
        final x = (details.localPosition.dx / (widget.cellSize + 1.0)).floor();
        final y = (details.localPosition.dy / (widget.cellSize + 1.0)).floor();
        
        if (x >= 0 && x < widget.grid.width && y >= 0 && y < widget.grid.height) {
          final position = Position(x: x, y: y);
          widget.onCellTap?.call(position);
        }
      },
      child: SizedBox(
        width: totalWidth,
        height: totalHeight,
        child: CustomPaint(
          painter: GameGridPainter(
            grid: widget.grid,
            previousGrid: _previousGrid,
            cellSize: widget.cellSize,
            animationProgress: 1.0,
            changedCells: {},
            isEditMode: true,
          ),
        ),
      ),
    );
  }
}

class GameGridPainter extends CustomPainter {
  GameGridPainter({
    required this.grid,
    required this.previousGrid,
    required this.cellSize,
    required this.animationProgress,
    required this.changedCells,
    this.isEditMode = false,
  });

  final model.GameGrid grid;
  final model.GameGrid? previousGrid;
  final double cellSize;
  final double animationProgress;
  final Set<Position> changedCells;
  final bool isEditMode;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint();
    
    for (int x = 0; x < grid.width; x++) {
      for (int y = 0; y < grid.height; y++) {
        final position = Position(x: x, y: y);
        final cell = grid.getCellAt(position);
        final isAlive = cell?.isAlive ?? false;
        
        final cellX = x * (cellSize + 1.0) + 0.5;
        final cellY = y * (cellSize + 1.0) + 0.5;
        final rect = Rect.fromLTWH(cellX, cellY, cellSize, cellSize);
        
        paint.color = Colors.white.withOpacity(0.08);
        canvas.drawRRect(
          RRect.fromRectAndRadius(rect, const Radius.circular(4.0)),
          paint,
        );
        
        paint.color = Colors.white.withOpacity(0.15);
        paint.style = PaintingStyle.stroke;
        paint.strokeWidth = 0.5;
        canvas.drawRRect(
          RRect.fromRectAndRadius(rect, const Radius.circular(4.0)),
          paint,
        );
        paint.style = PaintingStyle.fill;
        
        if (isAlive) {
          double opacity = 1.0;
          double scale = 1.0;
          
          if (changedCells.contains(position) && previousGrid != null) {
            final wasAlive = previousGrid!.getCellAt(position)?.isAlive ?? false;
            if (!wasAlive) {
              opacity = animationProgress;
              scale = 0.5 + (0.5 * animationProgress);
            } else {
              opacity = 1.0 - animationProgress;
              scale = 1.0 - (0.5 * animationProgress);
            }
          }
          
          if (opacity > 0) {
            paint.color = Colors.white.withOpacity(opacity);
            
            final scaledRect = Rect.fromCenter(
              center: rect.center,
              width: rect.width * scale,
              height: rect.height * scale,
            );
            
            canvas.drawRRect(
              RRect.fromRectAndRadius(scaledRect, const Radius.circular(4.0)),
              paint,
            );
          }
        }
        
        if (isEditMode && !isAlive) {
          paint.color = Colors.white.withOpacity(0.3);
          final center = rect.center;
          final iconSize = cellSize * 0.25;
          
          paint.strokeWidth = 0.8;
          paint.style = PaintingStyle.stroke;
          canvas.drawLine(
            Offset(center.dx - iconSize / 2, center.dy),
            Offset(center.dx + iconSize / 2, center.dy),
            paint,
          );
          canvas.drawLine(
            Offset(center.dx, center.dy - iconSize / 2),
            Offset(center.dx, center.dy + iconSize / 2),
            paint,
          );
          paint.style = PaintingStyle.fill;
        }
      }
    }
  }

  @override
  bool shouldRepaint(GameGridPainter oldDelegate) {
    return oldDelegate.grid != grid ||
           oldDelegate.previousGrid != previousGrid ||
           oldDelegate.animationProgress != animationProgress ||
           oldDelegate.changedCells != changedCells ||
           oldDelegate.isEditMode != isEditMode;
  }
} 