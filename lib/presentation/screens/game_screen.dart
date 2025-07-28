import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodels/game_view_model.dart';
import '../widgets/game_grid.dart';

/// Main game screen with three states: Configuration, Edit, and Play modes
class GameScreen extends StatefulWidget {
  const GameScreen({super.key});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> with TickerProviderStateMixin {
  late AnimationController _contentAnimationController;
  late Animation<Offset> _slideAnimation;
  
  // Menu animation controllers
  late AnimationController _menuAnimationController;
  late AnimationController _blurAnimationController;
  late Animation<double> _menuFadeAnimation;
  late Animation<double> _controlsFadeAnimation;
  late Animation<double> _blurAnimation;
  
  bool _isMenuOpen = false;

  @override
  void initState() {
    super.initState();
    _contentAnimationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(1.0, 0.0), // Start from right
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _contentAnimationController,
      curve: Curves.easeInOut,
    ));

    // Menu animations
    _menuAnimationController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _blurAnimationController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );

    _menuFadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _menuAnimationController,
      curve: Curves.easeInOut,
    ));

    _controlsFadeAnimation = Tween<double>(
      begin: 1.0,
      end: 0.0,
    ).animate(CurvedAnimation(
      parent: _menuAnimationController,
      curve: Curves.easeInOut,
    ));

    _blurAnimation = Tween<double>(
      begin: 0.0,
      end: 10.0,
    ).animate(CurvedAnimation(
      parent: _blurAnimationController,
      curve: Curves.easeInOut,
    ));

    // Start slide-in animation
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _contentAnimationController.forward();
    });
  }

  @override
  void dispose() {
    _contentAnimationController.dispose();
    _menuAnimationController.dispose();
    _blurAnimationController.dispose();
    super.dispose();
  }

  Future<void> _toggleMenu() async {
    if (_isMenuOpen) {
      // Close menu: fade out menu and blur simultaneously
      _blurAnimationController.reverse();
      await _menuAnimationController.reverse();
      setState(() {
        _isMenuOpen = false;
      });
    } else {
      // Open menu: fade out controls first, then fade in menu
      setState(() {
        _isMenuOpen = true;
      });
      _blurAnimationController.forward();
      await Future.delayed(const Duration(milliseconds: 100));
      _menuAnimationController.forward();
    }
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => GameViewModel(),
      child: Scaffold(
        body: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Color.fromARGB(255, 142, 112, 211),
                Color(0xFF60A5FA),
              ],
              stops: [0.0, 1.0],
            ),
          ),
          child: SlideTransition(
            position: _slideAnimation,
            child: Consumer<GameViewModel>(
              builder: (context, viewModel, child) {
                return Stack(
                  children: [
                    // Game grid (always present)
                    _buildGameGrid(viewModel),
                    
                    // Animated blur overlay for menu
                    if (viewModel.isPlayMode && _isMenuOpen)
                      AnimatedBuilder(
                        animation: _blurAnimation,
                        builder: (context, child) {
                          return BackdropFilter(
                            filter: ImageFilter.blur(
                              sigmaX: _blurAnimation.value,
                              sigmaY: _blurAnimation.value,
                            ),
                            child: Container(
                              color: Colors.black.withOpacity(_blurAnimation.value * 0.02),
                            ),
                          );
                        },
                      ),
                    
                    // State-specific overlays
                    if (viewModel.isConfigurationMode)
                      _buildConfigurationOverlay(viewModel),
                    if (viewModel.isEditMode)
                      _buildEditModeOverlay(viewModel),
                    if (viewModel.isPlayMode)
                      _buildPlayModeOverlay(viewModel),
                    
                    // Animated menu panel
                    if (viewModel.isPlayMode && _isMenuOpen)
                      _buildAnimatedMenu(viewModel),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildGameGrid(GameViewModel viewModel) {
    return GameGrid(
      grid: viewModel.gameState.grid,
      isEditMode: viewModel.isEditMode,
      isInteractive: !viewModel.isConfigurationMode,
      transformationController: viewModel.transformationController,
      onInitializeTransformation: () {
        // Initialize transformation when grid is first rendered
        if (viewModel.isConfigurationMode) {
          final size = MediaQuery.of(context).size;
          viewModel.initializeGridTransformation(size, 20.0);
        }
      },
      onCellTap: viewModel.toggleCell,
      onAnimationsComplete: viewModel.onAnimationsComplete,
    );
  }

  Widget _buildConfigurationOverlay(GameViewModel viewModel) {
    return Container(
      color: Colors.black.withOpacity(0.3), // Semi-transparent overlay
      child: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 400),
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Board Size Selection
                  _buildBoardSizeSelection(viewModel),
                  
                  const SizedBox(height: 40),
                  
                  // Continue Button
                  _buildContinueButton(viewModel),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }



  Widget _buildBoardSizeSelection(GameViewModel viewModel) {
    return Column(
      children: [
        Text(
          'Board Size',
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 16),
        Column(
          children: BoardSize.values.map((size) {
            final isSelected = viewModel.boardSize == size;
            return Padding(
              padding: const EdgeInsets.only(bottom: 12.0),
              child: GestureDetector(
                onTap: () => viewModel.setBoardSize(size),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12.0),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16.0,
                        vertical: 12.0,
                      ),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? Colors.white.withOpacity(0.2)
                            : Colors.white.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12.0),
                        border: isSelected
                            ? Border.all(color: Colors.white.withOpacity(0.4))
                            : null,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text(
                            size.name.toUpperCase(),
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                              fontSize: 16,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            viewModel.getBoardSizeDescription(size),
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.7),
                              fontSize: 14,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildContinueButton(GameViewModel viewModel) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: viewModel.continueToEditMode,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.white,
          foregroundColor: const Color.fromARGB(255, 142, 112, 211),
          padding: const EdgeInsets.symmetric(vertical: 16.0),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.0),
          ),
        ),
        child: const Text(
          'Continue',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  Widget _buildEditModeOverlay(GameViewModel viewModel) {
    return SafeArea(
      child: Column(
        children: [
          // Top instruction
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              'Tap cells to toggle them on/off',
              style: TextStyle(
                color: Colors.white.withOpacity(0.9),
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          
          const Spacer(),
          
          // Bottom buttons
          Padding(
            padding: const EdgeInsets.all(24.0),
            child: Row(
              children: [
                Expanded(
                  child: _buildActionButton(
                    label: 'Auto Fill',
                    onPressed: viewModel.autofillGrid,
                    isLoading: viewModel.isAutofillLoading,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildActionButton(
                    label: 'Start Game',
                    onPressed: viewModel.canStartGame ? viewModel.startGame : null,
                    isPrimary: true,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlayModeOverlay(GameViewModel viewModel) {
    return SafeArea(
      child: AnimatedBuilder(
        animation: _controlsFadeAnimation,
        builder: (context, child) {
          return Opacity(
            opacity: _controlsFadeAnimation.value,
            child: IgnorePointer(
              ignoring: _isMenuOpen, // Disable interaction when menu is open
              child: Column(
                children: [
                  // Top bar
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Burger menu
                        IconButton(
                          onPressed: _toggleMenu,
                          icon: const Icon(
                            Icons.menu,
                            color: Colors.white,
                            size: 28,
                          ),
                        ),
                        
                        // Auto/Manual switch (smaller)
                        _buildAutoManualSwitch(viewModel),
                      ],
                    ),
                  ),
                  
                  const Spacer(),
                  
                  // Bottom play/pause button
                  Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Center(
                      child: GestureDetector(
                        onTap: () {
                          if (viewModel.isGameRunning) {
                            viewModel.pauseGame();
                          } else {
                            viewModel.resumeGame();
                          }
                        },
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(28.0),
                          child: BackdropFilter(
                            filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
                            child: Container(
                              width: 56.0,
                              height: 56.0,
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(28.0),
                                border: Border.all(
                                  color: Colors.white.withOpacity(0.4),
                                  width: 1.5,
                                ),
                              ),
                              child: viewModel.isAnimating && !viewModel.isPauseQueued
                                  ? SizedBox(
                                      width: 28,
                                      height: 28,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                      ),
                                    )
                                  : Icon(
                                      viewModel.isPauseQueued 
                                          ? Icons.pause_circle_outline 
                                          : (viewModel.isGameRunning ? Icons.pause : Icons.play_arrow),
                                      size: 28,
                                      color: viewModel.isPauseQueued 
                                          ? Colors.orange 
                                          : (viewModel.isGameRunning ? const Color.fromARGB(255, 32, 117, 255) : const Color.fromARGB(255, 0, 255, 47)),
                                    ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildAnimatedMenu(GameViewModel viewModel) {
    return AnimatedBuilder(
      animation: _menuFadeAnimation,
      builder: (context, child) {
        return Opacity(
          opacity: _menuFadeAnimation.value,
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Menu title (outside container)
                Text(
                  'Menu',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 28,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                
                const SizedBox(height: 20),
                
                // Glass container with options
                ClipRRect(
                  borderRadius: BorderRadius.circular(20.0),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
                    child: Container(
                      width: 240,
                      padding: const EdgeInsets.all(20.0),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(20.0),
                        border: Border.all(
                          color: Colors.white.withOpacity(0.2),
                          width: 1,
                        ),
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Reset Board button
                          _buildSimpleMenuButton(
                            icon: Icons.refresh,
                            title: 'Reset Board',
                            onTap: () {
                              _toggleMenu().then((_) {
                                viewModel.resetToEditMode();
                              });
                            },
                          ),
                          
                          const SizedBox(height: 16),
                          
                          // Leave Game button
                          _buildSimpleMenuButton(
                            icon: Icons.exit_to_app,
                            title: 'Leave Game',
                            onTap: () {
                              _toggleMenu().then((_) {
                                viewModel.leaveGame();
                              });
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                
                const SizedBox(height: 20),
                
                // Close button (circular, below container)
                GestureDetector(
                  onTap: _toggleMenu,
                  child: Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: Colors.white.withOpacity(0.3),
                        width: 1,
                      ),
                    ),
                    child: const Icon(
                      Icons.close,
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildSimpleMenuButton({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16.0),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.25),
          borderRadius: BorderRadius.circular(12.0),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: Colors.white,
              size: 24,
            ),
            const SizedBox(width: 12),
            Text(
              title,
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAutoManualSwitch(GameViewModel viewModel) {

    return ClipRRect(
      borderRadius: BorderRadius.circular(12.0),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
        child: Container(
          height: 36.0,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12.0),
          ),
          padding: const EdgeInsets.all(2.0),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              GestureDetector(
                onTap: () {
                  if (!viewModel.isAutoMode) viewModel.togglePlayMode();
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: viewModel.isAutoMode
                        ? Colors.white.withOpacity(0.3)
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                  child: const Text(
                    'Auto',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                ),
              ),
              GestureDetector(
                onTap: () {
                  if (viewModel.isAutoMode) viewModel.togglePlayMode();
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: !viewModel.isAutoMode
                        ? Colors.white.withOpacity(0.3)
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                  child: const Text(
                    'Manual',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActionButton({
    required String label,
    required VoidCallback? onPressed,
    bool isLoading = false,
    bool isPrimary = false,
  }) {
    return GestureDetector(
      onTap: isLoading ? null : onPressed,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12.0),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 16.0),
            decoration: BoxDecoration(
              color: isPrimary 
                  ? Colors.white.withOpacity(0.9)
                  : Colors.white.withOpacity(0.15),
              borderRadius: BorderRadius.circular(12.0),
              border: Border.all(
                color: Colors.white.withOpacity(0.2),
                width: 1,
              ),
            ),
            child: Center(
              child: isLoading
                  ? SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          isPrimary 
                              ? const Color.fromARGB(255, 142, 112, 211)
                              : Colors.white,
                        ),
                      ),
                    )
                  : Text(
                      label,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: isPrimary 
                            ? const Color.fromARGB(255, 142, 112, 211)
                            : Colors.white,
                      ),
                    ),
            ),
          ),
        ),
      ),
    );
  }


}
