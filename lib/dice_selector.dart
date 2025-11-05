import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'game.dart';
import 'dice_type.dart';

class DiceSelector extends PositionComponent 
    with HasGameReference<DiceRollerGame>, TapCallbacks {
  DiceType selected = DiceType.d6;
  late SpriteComponent diceIcon;
  late SpriteComponent numberIcon;

  @override
  Future<void> onLoad() async {
    final viewportSize = game.camera.viewport.size;
    size = Vector2(80, 80);
    position = Vector2(viewportSize.x - size.x - 12, viewportSize.y - size.y - 12);

    diceIcon = SpriteComponent(
      sprite: game.diceSprites[selected],
      size: Vector2(120, 120),
      anchor: Anchor.center,
      position: size / 2,
    );
    add(diceIcon);

    final num = game.maxRoll(selected);
    numberIcon = SpriteComponent(
      sprite: game.numberSprites[num],
      size: Vector2(40, 40),
      anchor: Anchor.center,
      position: size / 2,
    );
    add(numberIcon);
  }

  @override
  void onTapDown(TapDownEvent event) {
    game.showDiceSelectOverlay((DiceType type) {
      selected = type;
      game.selectedDice = type;
      diceIcon.sprite = game.diceSprites[type];
      numberIcon.sprite = game.numberSprites[game.maxRoll(type)];
    });
  }
}