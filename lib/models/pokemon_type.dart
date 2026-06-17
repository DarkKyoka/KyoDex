

class PokemonType{
  final int id;
  final String name;
  final String colorHex;

  const PokemonType({
    required this.id,
    required this.name,
    required this.colorHex,

  });

  //from Db row (MAP) to Class Object
  factory PokemonType.fromMap(Map<String, dynamic> map){
    return  PokemonType(
        id: map['id'] as int,
        name: map['name'] as String,
        colorHex: map['color_hex'] as String,
    );
  }

  //from classObject to DB row (MAP)
  Map<String, dynamic> toMap(){
    return{
      'id': id,
      'name': name,
      'color_hex': colorHex
    };
  }
}