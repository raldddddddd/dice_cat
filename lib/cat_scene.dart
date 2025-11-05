import 'dart:math';
import 'package:flame/components.dart';
import 'package:flame/events.dart';
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

    final viewportSize = game.camera.viewport.size;
    size = viewportSize;

    // --- BACKGROUND ---
    bg = SpriteComponent(
      sprite: await Sprite.load('bg.png'),
      size: viewportSize,
      position: Vector2.zero(),
      anchor: Anchor.topLeft,
      priority: -1,
    );
    add(bg);

    // --- CAT SPRITE SETUP ---
    final original = game.catIdle.srcSize;

    // Scale to fit height or width (whichever is smaller)
    final scaleFactor = min(
      viewportSize.x * 0.8 / original.x, // 80% width fit
      viewportSize.y * 0.9 / original.y, // 90% height fit
    );

    final targetSize = Vector2(original.x * scaleFactor, original.y * scaleFactor);

    // Idle animation (default)
    final idleAnimation = SpriteAnimation.spriteList(
      [game.catIdle],
      stepTime: 1.0,
      loop: true,
    );

    // Position centered horizontally with the bottom edge at the screen bottom
    catSprite = SpriteAnimationComponent(
      animation: idleAnimation,
      size: targetSize,
      // **FIX 1: Anchor the sprite from its bottom-center point**
      anchor: Anchor.bottomCenter, 
      position: Vector2(
        viewportSize.x / 2, // Center horizontally
        // **FIX 2: Place the bottom-center point (the anchor) at the screen's bottom edge**
        viewportSize.y
      ), 
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
        catSprite.animation = game.catBlink;
        catSprite.animationTicker?.reset();
      }

      _scheduleBlink();
    });
  }

  @override
  void update(double dt) {
    super.update(dt);

    // After blink → back to idle
    if (!isRolling &&
        catSprite.animation == game.catBlink &&
        catSprite.animationTicker?.done() == true) {
      catSprite.animation = SpriteAnimation.spriteList(
        [game.catIdle],
        stepTime: 1.0,
        loop: true,
      );
      catSprite.animationTicker?.reset();
    }

    // After roll → go idle + show result
    if (isRolling && catSprite.animation == game.catRoll) {
      final ticker = catSprite.animationTicker;
      if (ticker?.done() == true) {
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
    if (isRolling) return;

    isRolling = true;
    catSprite.animation = game.catRoll;
    catSprite.animationTicker?.reset();
  }
}