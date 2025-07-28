import 'package:flutter/material.dart';

/// Widget that displays game controls at the bottom of the screen
class GameControls extends StatelessWidget {
  const GameControls({
    super.key,
    required this.isEditMode,
    required this.isGameRunning,
    required this.canStartGame,
    required this.isAutoMode,
    this.onStart,
    this.onPlayPause,
    this.onReset,
    this.onModeToggle,
  });

  final bool isEditMode;
  final bool isGameRunning;
  final bool canStartGame;
  final bool isAutoMode;
  final VoidCallback? onStart;
  final VoidCallback? onPlayPause;
  final VoidCallback? onReset;
  final VoidCallback? onModeToggle;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: isEditMode ? _buildEditControls() : _buildPlayControls(),
    );
  }

  Widget _buildEditControls() {
    return Center(
      child: _buildFloatingButton(
        icon: Icons.play_arrow,
        onPressed: canStartGame ? onStart : null,
        foregroundColor: canStartGame
            ? const Color(0xFF10B981)
            : Colors.grey.shade600,
        backgroundColor: canStartGame
            ? Colors.white
            : Colors.white.withOpacity(0.3),
        size: 64.0,
      ),
    );
  }

  Widget _buildPlayControls() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        // Reset Button (Left)
        _buildFloatingButton(
          icon: Icons.refresh,
          onPressed: onReset,
          foregroundColor: const Color(0xFFEF4444),
          size: 40,
          opacity: 0.6,
        ),

        // Play/Pause Button (Center)
        _buildFloatingButton(
          icon: isGameRunning
              ? Icons.pause
              : (isAutoMode ? Icons.play_arrow : Icons.skip_next),
          onPressed: onPlayPause,
          foregroundColor: isGameRunning
              ? const Color.fromARGB(255, 0, 115, 255)
              : const Color(0xFF10B981),
          backgroundColor: Colors.white,
          size: 64.0, // Larger center button
        ),

        // Mode Toggle Button (Right) - shows manual/auto mode
        _buildFloatingButton(
          icon: isAutoMode ? Icons.loop_rounded : Icons.exposure_plus_1,
          onPressed: onModeToggle,
          foregroundColor: isAutoMode
              ? const Color(0xFF059669)
              : const Color(0xFF6366F1),
          size: 40,
          opacity: 0.6,
        ),
      ],
    );
  }

  Widget _buildFloatingButton({
    required IconData icon,
    required VoidCallback? onPressed,
    Color backgroundColor = Colors.white,
    Color foregroundColor = Colors.black,
    double size = 56.0,
    double opacity = 1.0,
  }) {
    return Opacity(
      opacity: opacity,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: backgroundColor,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 16.0,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onPressed,
            borderRadius: BorderRadius.circular(size / 2),
            child: Center(
              child: Icon(
                icon,
                color: foregroundColor,
                size: size == 64.0 ? 32.0 : 24.0,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
