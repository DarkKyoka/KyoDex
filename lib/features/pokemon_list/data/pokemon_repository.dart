import 'package:kyodex/core/database/database_helper.dart';
import 'package:kyodex/models/pokemon.dart';
import 'package:kyodex/models/pokemon_type.dart';
import 'package:kyodex/models/pokemon_description.dart';

class PokemonRepository {
  PokemonRepository._();
  static final PokemonRepository instance = PokemonRepository._();

  Future<List<Pokemon>> getAllPokemon() async {
    final db = await DatabaseHelper.instance.database;
    final rows = await db.query('pokemon', orderBy: 'national_dex ASC');
    print('POKEMON ROWS IN DB: ${rows.length}');

    // Fetch ALL types in one query
    final allTypeRows = await db.rawQuery('''
      SELECT pt.pokemon_id, t.id, t.name, t.color_hex
      FROM types t
      INNER JOIN pokemon_types pt ON pt.type_id = t.id
      ORDER BY pt.pokemon_id, pt.slot ASC
    ''');

    // Group by pokemon_id
    final typeMap = <int, List<PokemonType>>{};
    for (final row in allTypeRows) {
      final pid = row['pokemon_id'] as int;
      typeMap.putIfAbsent(pid, () => []);
      typeMap[pid]!.add(PokemonType.fromMap(Map<String, dynamic>.from(row)));
    }

    // Fetch ALL descriptions in one query
    final allDescRows = await db.query(
      'pokemon_descriptions',
      orderBy: 'pokemon_id ASC',
    );

    final descMap = <int, List<PokemonDescription>>{};
    for (final row in allDescRows) {
      final pid = row['pokemon_id'] as int;
      descMap.putIfAbsent(pid, () => []);
      descMap[pid]!.add(PokemonDescription.fromMap(Map<String, dynamic>.from(row)));
    }

    // Build result
    final List<Pokemon> result = [];
    for (final row in rows) {
      final id = row['id'] as int;
      result.add(
        Pokemon.fromMap(Map<String, dynamic>.from(row)).copyWith(
          types: typeMap[id] ?? [],
          descriptions: descMap[id] ?? [],
        ),
      );
    }

    return result;
  }
}