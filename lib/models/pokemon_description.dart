

class PokemonDescription {

  final int id;
  final int pokemonId;
  final String version;
  final String description;


  const PokemonDescription({
    required this.id,
    required this.pokemonId,
    required this.version,
    required this.description,
  });

  factory PokemonDescription.fromMap(Map<String, dynamic> map){
    return PokemonDescription(
      id: map['id'] as int,
      pokemonId: map['pokemon_id'] as int,
      version: map['version'] as String,
      description: map['description'] as String
    );

  }

  Map<String, dynamic> toMap(){
    return{
      'id': id,
      'pokemon_id': pokemonId,
      'version': version,
      'description': description
    };
  }


}