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
    size = Vector2(80, 80);
    position = Vector2(game.size.x - size.x - 12, game.size.y - size.y - 12);

    // Dice icon (centered)
    diceIcon = SpriteComponent(
      sprite: game.diceSprites[selected],
      size: Vector2(120, 120),
      anchor: Anchor.center,
      position: size / 2,
    );
    add(diceIcon);

    // Number overlay centered on top of diceIcon
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
    // Open dice selection overlay; when selected, update icon
    game.showDiceSelectOverlay((DiceType type) {
      selected = type;
      game.selectedDice = type;
      diceIcon.sprite = game.diceSprites[type];
      numberIcon.sprite = game.numberSprites[game.maxRoll(type)];
    });
  }
}