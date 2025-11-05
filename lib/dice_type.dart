enum DiceType { d4, d6, d8, d10, d12, d20 }

extension DiceTypeValues on DiceType {
  int get maxValue {
    switch (this) {
      case DiceType.d4:
        return 4;
      case DiceType.d6:
        return 6;
      case DiceType.d8:
        return 8;
      case DiceType.d10:
        return 10;
      case DiceType.d12:
        return 12;
      case DiceType.d20:
        return 20;
    }
  }
}
