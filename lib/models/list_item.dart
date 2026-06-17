import 'package:kyodex/models/pokemon_type.dart';

class ListItem {
  final int nationalDex;
  final String name;
  final String spriteUrl;
  final List<PokemonType> types;
  final int pokemonId;
  final bool isForm;
  final String? formName;

  const ListItem({
    required this.nationalDex,
    required this.name,
    required this.spriteUrl,
    required this.types,
    required this.pokemonId,
    this.isForm = false,
    this.formName,
  });
}