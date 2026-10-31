class DinoCharacter {
  const DinoCharacter(
    this.id,
    this.name,
    this.species,
    this.price,
    this.asset,
    this.description,
  );
  final String id, name, species, asset, description;
  final int price;

  String get animationAsset => 'assets/runtime/$id-run.png';

  // Measured opaque foot baselines in the original 443.5px atlas cells.
  // Airborne frame 6 uses the running baseline so tucked feet stay lifted.
  List<double> get footBaselines => switch (id) {
    'bramble' => [420, 420, 421, 420, 387, 387, 420, 388],
    'sunny' => [406, 410, 407, 410, 406, 403, 406, 406],
    'nova' => [417, 417, 417, 417, 389, 390, 417, 389],
    _ => [418, 412, 417, 417, 403, 403, 418, 403],
  };
}

const dinoCatalog = [
  DinoCharacter(
    'sprout',
    'Sprout',
    'Little T. rex',
    0,
    'assets/runtime/dino.png',
    'Your cheerful green friend. Ready for every adventure!',
  ),
  DinoCharacter(
    'bramble',
    'Bramble',
    'Baby triceratops',
    1000,
    'assets/runtime/bramble.png',
    'A gentle explorer with a bright frill and three little horns.',
  ),
  DinoCharacter(
    'sunny',
    'Sunny',
    'Baby stegosaurus',
    10000,
    'assets/runtime/sunny.png',
    'A sunny trailblazer with a rainbow of warm back plates.',
  ),
  DinoCharacter(
    'nova',
    'Nova',
    'Baby spinosaurus',
    25000,
    'assets/runtime/nova.png',
    'A curious purple adventurer with a magnificent starry sail.',
  ),
];

DinoCharacter characterById(String id) => dinoCatalog.firstWhere(
  (character) => character.id == id,
  orElse: () => dinoCatalog.first,
);

enum PurchaseResult {
  purchased,
  alreadyOwned,
  insufficientCoins,
  unknownCharacter,
}
