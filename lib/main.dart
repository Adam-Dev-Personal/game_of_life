import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'presentation/viewmodels/game_view_model.dart';
import 'presentation/screens/launch_screen.dart';

void main() {
  runApp(const GameOfLifeApp());
}

class GameOfLifeApp extends StatelessWidget {
  const GameOfLifeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => GameViewModel(),
      child: MaterialApp(
        title: 'Game of Life',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(
            seedColor: const Color.fromARGB(255, 142, 112, 211),
            brightness: Brightness.dark,
          ),
          useMaterial3: true,
        ),
        home: const LaunchScreen(),
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}
