import 'package:flutter/material.dart';
import 'game_screen.dart';

/// LaunchScreen displays the initial screen with the game title and tap to start
class LaunchScreen extends StatefulWidget {
  const LaunchScreen({super.key});

  @override
  State<LaunchScreen> createState() => _LaunchScreenState();
}

class _LaunchScreenState extends State<LaunchScreen>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late AnimationController _breathingController;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _breathingScaleAnimation;
  late Animation<double> _breathingOpacityAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _slideAnimation = Tween<Offset>(
      begin: Offset.zero,
      end: const Offset(-1.0, 0.0), // Slide out to the left
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));

    // Breathing animation controller
    _breathingController = AnimationController(
      duration: const Duration(milliseconds: 1200), // 1.2 second cycle
      vsync: this,
    );

    // Scale animation (1.0 to 1.1 and back)
    _breathingScaleAnimation = Tween<double>(
      begin: 1.0,
      end: 1.05,
    ).animate(CurvedAnimation(
      parent: _breathingController,
      curve: Curves.easeInOut,
    ));

    // Opacity animation (0.7 to 1.0 and back)
    _breathingOpacityAnimation = Tween<double>(
      begin: 0.7,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _breathingController,
      curve: Curves.easeInOut,
    ));

    // Start the breathing animation and repeat
    _breathingController.repeat(reverse: true);
  }

  @override
  void dispose() {
    _animationController.dispose();
    _breathingController.dispose();
    super.dispose();
  }

  void _navigateToGame() async {
    // Start slide-out animation
    await _animationController.forward();
    
    if (mounted) {
      // Navigate with custom transition that preserves background
      Navigator.of(context).pushReplacement(
        PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) => const GameScreen(),
          transitionDuration: const Duration(milliseconds: 300),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            // Slide in from right
            final slideAnimation = Tween<Offset>(
              begin: const Offset(1.0, 0.0),
              end: Offset.zero,
            ).animate(CurvedAnimation(
              parent: animation,
              curve: Curves.easeInOut,
            ));
            
            return SlideTransition(
              position: slideAnimation,
              child: child,
            );
          },
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GestureDetector(
        onTap: _navigateToGame,
        child: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Color.fromARGB(255, 142, 112, 211), // Match game screen gradient
                Color(0xFF60A5FA), // Blue-400
              ],
              stops: [0.0, 1.0],
            ),
          ),
          child: SafeArea(
            child: SlideTransition(
              position: _slideAnimation,
              child: Column(
                children: [
                  // Top half - Game title
                  Expanded(
                    flex: 1,
                    child: Center(
                      child: Text(
                        'Game of Life',
                        style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 48,
                          letterSpacing: 2.0,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                  // Bottom half - Touch anywhere text
                  Expanded(
                    flex: 1,
                    child: Center(
                      child: AnimatedBuilder(
                        animation: _breathingController,
                        builder: (context, child) {
                          return Transform.scale(
                            scale: _breathingScaleAnimation.value,
                            child: Opacity(
                              opacity: _breathingOpacityAnimation.value * 0.8, // Multiply by 0.8 to maintain the base opacity
                              child: Text(
                                'Touch anywhere to start',
                                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w300,
                                  letterSpacing: 1.0,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
} 