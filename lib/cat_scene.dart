import 'dart:math';
import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flutter/foundation.dart';
import 'game.dart';

class CatComponent extends PositionComponent
    with HasGameReference<DiceRollerGame>, TapCallbacks {
  late SpriteAnimationComponent catSprite;
  late SpriteComponent bg;
  bool isRolling = false;
  bool blinkScheduled = false;

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    size = game.size;

    // --- BACKGROUND ---
    bg = SpriteComponent(
      sprite: await Sprite.load('bg.png'),
      size: size,
      position: Vector2.zero(),
      anchor: Anchor.topLeft,
      priority: -1, // ensures background is always behind cat
    );
    add(bg);

    // --- CAT SETUP ---
    final original = game.catIdle.srcSize;
    final targetWidth = size.x * 0.80;
    final scale = targetWidth / original.x;
    final targetSize = Vector2(original.x * scale, original.y * scale);

    final idleAnimation = SpriteAnimation.spriteList(
      [game.catIdle],
      stepTime: 1.0,
      loop: true,
    );

    catSprite = SpriteAnimationComponent(
      animation: idleAnimation,
      size: targetSize,
      anchor: Anchor.bottomCenter,
      position: Vector2(size.x / 2, size.y),
    );
    add(catSprite);

    _scheduleBlink();
  }

  void _scheduleBlink() {
    if (blinkScheduled) return;
    blinkScheduled = true;

    Future.delayed(Duration(seconds: 5 + Random().nextInt(2)), () {
      if (!isMounted) return;
      blinkScheduled = false;

      if (!isRolling) {
        // Play blink animation
        catSprite.animation = game.catBlink;
        catSprite.animationTicker?.reset();
      }

      _scheduleBlink();
    });
  }

  @override
  void update(double dt) {
    super.update(dt);

    // After blink, go back to idle
    if (!isRolling &&
        catSprite.animation == game.catBlink &&
        catSprite.animationTicker?.done() == true) {
      debugPrint('😊 Blink complete, returning to idle');
      catSprite.animation = SpriteAnimation.spriteList(
        [game.catIdle],
        stepTime: 1.0,
        loop: true,
      );
      catSprite.animationTicker?.reset();
    }

    // After roll animation, show result overlay
    if (isRolling && catSprite.animation == game.catRoll) {
      final ticker = catSprite.animationTicker;
      if (ticker?.done() == true) {
        debugPrint('✅ Roll animation COMPLETE! Showing overlay...');
        isRolling = false;
        catSprite.animation = SpriteAnimation.spriteList(
          [game.catIdle],
          stepTime: 1.0,
          loop: true,
        );
        catSprite.animationTicker?.reset();

        Future.delayed(const Duration(milliseconds: 100), () {
          if (isMounted) game.onCatRollComplete();
        });
      }
    }
  }

  @override
  void onTapDown(TapDownEvent event) {
    debugPrint('🐱 CAT TAPPED!');
    if (isRolling) {
      debugPrint('⚠️ Already rolling, ignoring tap');
      return;
    }

    debugPrint('🎲 Starting roll animation...');
    isRolling = true;
    catSprite.animation = game.catRoll;
    catSprite.animationTicker?.reset();
  }
}
