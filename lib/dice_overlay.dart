import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flame/events.dart';
import 'package:flutter/material.dart' hide Image, PointerMoveEvent;
import 'game.dart';
import 'dice_type.dart';

class DiceButton extends PositionComponent {
  final DiceType diceType;
  late final SpriteComponent diceSprite;
  late final SpriteComponent numberSprite;

  DiceButton({
    required this.diceType,
    required Sprite dice,
    required Sprite number,
    required Vector2 position,
  }) : super(
          position: position,
          anchor: Anchor.center,
          size: Vector2(80, 80),
        ) {
    diceSprite = SpriteComponent(
      sprite: dice,
      size: Vector2(120, 120),
      anchor: Anchor.center,
      position: Vector2(size.x / 2, size.y / 2),
    );
    numberSprite = SpriteComponent(
      sprite: number,
      size: Vector2(40, 40),
      anchor: Anchor.center,
      position: Vector2(size.x / 2, size.y / 2),
    );
    add(diceSprite);
    add(numberSprite);
  }
}

class DiceSelectOverlay extends PositionComponent
    with
        HasGameReference<DiceRollerGame>,
        TapCallbacks,
        PointerMoveCallbacks,
        DragCallbacks {
  final void Function(DiceType dice) onDiceSelected;
  final List<DiceButton> diceComponents = [];
  late SpriteComponent pawCursor;
  late RectangleComponent backgroundRect;
  late RectangleComponent whiteRect;

  DiceSelectOverlay({required this.onDiceSelected});

  @override
  Future<void> onLoad() async {
    final viewportSize = game.camera.viewport.size;
    size = viewportSize;
    anchor = Anchor.topLeft;
    priority = 100;

    backgroundRect = RectangleComponent(
      size: size,
      paint: Paint()..color = const Color(0xAA000000),
    );
    add(backgroundRect);

    final boxHeight = 280.0;
    whiteRect = RectangleComponent(
      size: Vector2(viewportSize.x, boxHeight),
      position: Vector2(0, viewportSize.y / 2 - boxHeight / 2),
      paint: Paint()..color = const Color(0x00E4A672),
    );
    add(whiteRect);

    whiteRect.add(
      OpacityEffect.to(
        0.4,
        EffectController(duration: 0.3),
      ),
    );

    const columns = 3;
    const rows = 2;
    const spacingX = 120.0;
    const spacingY = 120.0;

    final totalWidth = (columns - 1) * spacingX;
    final totalHeight = (rows - 1) * spacingY;
    final startX = viewportSize.x / 2 - totalWidth / 2;
    final startY = viewportSize.y / 2 - totalHeight / 2;

    for (int i = 0; i < DiceType.values.length; i++) {
      final dice = DiceType.values[i];
      final diceSprite = game.diceSprites[dice]!;
      final numberSprite = game.numberSprites[game.maxRoll(dice)]!;

      final col = i % columns;
      final row = i ~/ columns;

      final x = startX + col * spacingX;
      final y = startY + row * spacingY;

      final button = DiceButton(
        diceType: dice,
        dice: diceSprite,
        number: numberSprite,
        position: Vector2(x, y),
      );
      diceComponents.add(button);
      add(button);
    }

    final pawSprite = await Sprite.load('paw.png');
    pawCursor = SpriteComponent(
      sprite: pawSprite,
      size: Vector2(180, 360),
      anchor: Anchor(0.5, 0.25),
      position: Vector2(viewportSize.x / 2, viewportSize.y / 2 + boxHeight / 2 - 20),
    );
    add(pawCursor);
  }

  @override
  void onPointerMove(PointerMoveEvent event) {
    pawCursor.position = event.localPosition;
  }

  @override
  void onDragUpdate(DragUpdateEvent event) {
    pawCursor.position = event.localStartPosition + event.localDelta;
  }

  @override
  void onTapDown(TapDownEvent event) {
    final local = event.localPosition;
    for (final button in diceComponents) {
      if (button.containsPoint(local)) {
        whiteRect.add(
          OpacityEffect.to(
            0.0,
            EffectController(duration: 0.2),
            onComplete: () => removeFromParent(),
          ),
        );
        onDiceSelected(button.diceType);
        return;
      }
    }
  }
}

class DiceRollOverlay extends PositionComponent
    with HasGameReference<DiceRollerGame>, TapCallbacks {
  final DiceType dice;
  final int result;
  late RectangleComponent backgroundRect;
  late RectangleComponent whiteRect;

  DiceRollOverlay({required this.dice, required this.result});

  @override
  Future<void> onLoad() async {
    debugPrint('🎯 DiceRollOverlay loading...');
    final viewportSize = game.camera.viewport.size;
    size = viewportSize;
    priority = 100;

    backgroundRect = RectangleComponent(
      size: size,
      paint: Paint()..color = const Color(0xAA000000),
    );
    add(backgroundRect);

    final boxHeight = 280.0;
    whiteRect = RectangleComponent(
      size: Vector2(viewportSize.x, boxHeight),
      position: Vector2(0, viewportSize.y / 2 - boxHeight / 2),
      paint: Paint()..color = const Color(0x00E4A672),
    );
    add(whiteRect);

    whiteRect.add(
      OpacityEffect.to(
        0.4,
        EffectController(duration: 0.3),
      ),
    );

    final diceSprite = SpriteComponent(
      sprite: game.diceSprites[dice]!,
      size: Vector2(160, 160),
      anchor: Anchor.center,
      position: Vector2(viewportSize.x / 2, viewportSize.y / 2),
    );
    add(diceSprite);

    final numberSprite = game.numberSprites[result]!;
    final numberIcon = SpriteComponent(
      sprite: numberSprite,
      size: Vector2(64, 64),
      anchor: Anchor.center,
      position: diceSprite.position,
    );
    add(numberIcon);
    
    debugPrint('✅ DiceRollOverlay loaded!');
  }

  @override
  void onTapDown(TapDownEvent event) {
    debugPrint('👆 Overlay tapped');
    whiteRect.add(
      OpacityEffect.to(
        0.0,
        EffectController(duration: 0.2),
        onComplete: () => removeFromParent(),
      ),
    );
  }
}