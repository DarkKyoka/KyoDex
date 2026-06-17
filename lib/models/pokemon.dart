import 'package:kyodex/models/pokemon_description.dart';
import 'package:kyodex/models/pokemon_type.dart';

class Pokemon {
  final int id;
  final int nationalDex;
  final String name;
  final String category;
  final String spriteUrl;
  final double height;
  final double weight;
  final int generation;

  final List<PokemonType> types;
  final List<PokemonDescription> descriptions;

  const Pokemon({
    required this.id,
    required this.nationalDex,
    required this.name,
    required this.category,
    required this.spriteUrl,
    required this.height,
    required this.weight,
    required this.generation,

    required this.types,
    required this.descriptions,
  });

  factory Pokemon.fromMap(Map<String, dynamic> map) {
    return Pokemon(
      id: map['id'] as int,
      nationalDex: map['national_dex'] as int,
      name: map['name'] as String,
      category: map['category'] as String,
      spriteUrl: map['sprite_url'] as String,
      height: (map['height'] as num).toDouble(),
      weight: (map['weight'] as num).toDouble(),
      generation: map['generation'] as int,

      types: [],
      descriptions: [],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'category': category,
      'sprite_url': spriteUrl,
      'height': height,
      'weight': weight,
      'generation': generation,
    };
  }

  Pokemon copyWith({
    List<PokemonType>? types,
    List<PokemonDescription>? descriptions,
  }) {
    return Pokemon(
      id: id,
      nationalDex: nationalDex,
      name: name,
      category: category,
      spriteUrl: spriteUrl,
      height: height,
      weight: weight,
      generation: generation,
      types: types ?? this.types,
      descriptions: descriptions ?? this.descriptions,
    );
  }
}
