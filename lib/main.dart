import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'game.dart';

void main() {
  final game = DiceRollerGame();

  runApp(
    MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        body: GameWidget(
          game: game,
          loadingBuilder: (_) =>
              const Center(child: CircularProgressIndicator()),
        ),
      ),
    ),
  );
}