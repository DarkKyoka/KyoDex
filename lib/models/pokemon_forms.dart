import 'package:kyodex/models/pokemon_type.dart';

class PokemonForms {
  final int id;
  final int pokemonId;
  final String formName;
  final String spriteUrl;
  final List<PokemonType> types; // ← add this

  const PokemonForms({
    required this.id,
    required this.pokemonId,
    required this.formName,
    required this.spriteUrl,
    this.types = const [], // ← default empty
  });

  factory PokemonForms.fromMap(Map<String, dynamic> map) {
    return PokemonForms(
      id: map['id'] as int,
      pokemonId: map['pokemon_id'] as int,
      formName: map['form_name'] as String,
      spriteUrl: map['sprite_url'] as String,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'pokemon_id': pokemonId,
      'form_name': formName,
      'sprite_url': spriteUrl,
    };
  }

  bool get isShiny => formName == 'shiny';

  PokemonForms copyWith({List<PokemonType>? types}) {
    return PokemonForms(
      id: id,
      pokemonId: pokemonId,
      formName: formName,
      spriteUrl: spriteUrl,
      types: types ?? this.types,
    );
  }
}