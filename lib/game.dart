import 'dart:math';
import 'package:flame/camera.dart';
import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart' hide Image;

import 'cat_scene.dart';
import 'dice_overlay.dart';
import 'dice_selector.dart';
import 'dice_type.dart';

class DiceRollerGame extends FlameGame {
  late final CatComponent cat;
  late final DiceSelector diceSelector;

  late final Sprite catIdle;
  late final SpriteAnimation catBlink;
  late final SpriteAnimation catRoll;
  late final Map<DiceType, Sprite> diceSprites;
  late final Map<int, Sprite> numberSprites;

  DiceType selectedDice = DiceType.d6;

  @override
  Color backgroundColor() => const Color(0xFFE4A672);

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    camera.viewport = FixedResolutionViewport(resolution: Vector2(360, 640));

    catIdle = await Sprite.load('cat.png');

    final catBlinkImages = await images.loadAll([
      'cat_blink_0.png',
      'cat_blink_1.png',
      'cat_blink_2.png',
      'cat_blink_3.png',
      'cat_blink_4.png',
      'cat_blink_5.png',
      'cat_blink_6.png',
    ]);
    catBlink = SpriteAnimation.spriteList(
      catBlinkImages.map((img) => Sprite(img)).toList(),
      stepTime: 0.1,
      loop: false,
    );

    final catRollImages = await images.loadAll([
      'cat_roll_0.png',
      'cat_roll_1.png',
      'cat_roll_2.png',
      'cat_roll_3.png',
      'cat_roll_4.png',
      'cat_roll_5.png',
    ]);
    catRoll = SpriteAnimation.spriteList(
      catRollImages.map((img) => Sprite(img)).toList(),
      stepTime: 0.12,
      loop: false,
    );

    diceSprites = {
      DiceType.d4: await Sprite.load('d4.png'),
      DiceType.d6: await Sprite.load('d6.png'),
      DiceType.d8: await Sprite.load('d8.png'),
      DiceType.d10: await Sprite.load('d10.png'),
      DiceType.d12: await Sprite.load('d12.png'),
      DiceType.d20: await Sprite.load('d20.png'),
    };

    numberSprites = {};
    for (int i = 1; i <= 20; i++) {
      numberSprites[i] = await Sprite.load('$i.png');
    }

    cat = CatComponent();
    add(cat);

    diceSelector = DiceSelector();
    add(diceSelector);
  }

  void showDiceSelectOverlay(void Function(DiceType) onDiceSelected) {
    final overlay = DiceSelectOverlay(
      onDiceSelected: (dice) {
        selectedDice = dice;
        onDiceSelected(dice);
      },
    );
    add(overlay);
  }

  void showRollOverlay(int result) {
    debugPrint('📊 Showing roll overlay: $result');
    final overlay = DiceRollOverlay(dice: selectedDice, result: result);
    add(overlay);
  }

  void onCatRollComplete() {
    debugPrint('🎲 Cat roll complete!');
    final result = Random().nextInt(selectedDice.maxValue) + 1;
    showRollOverlay(result);
  }

  int maxRoll(DiceType type) => type.maxValue;
}