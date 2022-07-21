enum AcornType { Pure, Roman }

class Acorn {
  final String name;
  final int cost;
  final double speed;
  final int spriteId;
  final String assetPath;
  final int level;

  const Acorn(
      {required this.name,
      required this.cost,
      required this.speed,
      required this.spriteId,
      required this.assetPath,
      required this.level});

  static Acorn getAcornByType(AcornType acornType){
    return acorns[acornType] ?? acorns.entries.first.value;
  }

  static const Map<AcornType, Acorn> acorns = {
    AcornType.Pure: Acorn(
      name: 'Pure',
      cost: 0,
      speed: 250,
      spriteId: 0,
      assetPath: 'assets/images/acorn.png',
      level: 1,
    ),
    AcornType.Roman: Acorn(
      name: 'Roman',
      cost: 100,
      speed: 400,
      spriteId: 1,
      assetPath: "assets/images/acorn_roman.png",
      level: 2,
    )
  };
}
