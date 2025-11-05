import 'package:flutter/material.dart';
import 'package:flame/game.dart';
import 'game.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    GameWidget(
      game: DiceRollerGame(),
      backgroundBuilder: (context) => const ColoredBox(color: Colors.black),
    ),
  );
}
