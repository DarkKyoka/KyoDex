import 'package:kyodex/core/database/database_helper.dart';
import 'package:kyodex/models/pokemon.dart';
import 'package:kyodex/models/pokemon_forms.dart';
import 'package:kyodex/models/pokemon_type.dart';
import 'package:kyodex/models/pokemon_description.dart';
//import 'package:kyodex/models/pokemon_form.dart';
import 'package:kyodex/models/evolution.dart';

class DetailRepository {
  DetailRepository._();
  static final DetailRepository instance = DetailRepository._();

  Future<Pokemon> getPokemon(int id) async {
    final db = await DatabaseHelper.instance.database;

    // Main pokemon row
    final rows = await db.query(
      'pokemon',
      where: 'id = ?',
      whereArgs: [id],
    );
    if (rows.isEmpty) throw Exception('Pokemon $id not found');

    final row = Map<String, dynamic>.from(rows.first);

    // Types
    final typeRows = await db.rawQuery('''
      SELECT t.id, t.name, t.color_hex
      FROM types t
      INNER JOIN pokemon_types pt ON pt.type_id = t.id
      WHERE pt.pokemon_id = ?
      ORDER BY pt.slot ASC
    ''', [id]);

    final List<PokemonType> types = typeRows
        .map<PokemonType>((r) => PokemonType.fromMap(Map<String, dynamic>.from(r)))
        .toList();

    // Descriptions
    final descRows = await db.query(
      'pokemon_descriptions',
      where: 'pokemon_id = ?',
      whereArgs: [id],
    );

    final List<PokemonDescription> descriptions = descRows
        .map<PokemonDescription>((r) => PokemonDescription.fromMap(Map<String, dynamic>.from(r)))
        .toList();

    return Pokemon.fromMap(row).copyWith(
      types: types,
      descriptions: descriptions,
    );
  }

  Future<List<PokemonForms>> getForms(int pokemonId) async {
    final db = await DatabaseHelper.instance.database;
    final all = await db.query('pokemon_forms', where: 'pokemon_id = ?', whereArgs: [pokemonId]);
    print('ALL FORMS FOR $pokemonId: ${all.map((r) => r['form_name']).toList()}');

    final rows = await db.query(
      'pokemon_forms',
      where: 'pokemon_id = ? AND form_name NOT LIKE ? AND form_name NOT LIKE ?',
      whereArgs: [pokemonId, '%-mega%', '%-gmax%'],
    );
    print('FILTERED FORMS: ${rows.map((r) => r['form_name']).toList()}');
    return rows.map<PokemonForms>((r) => PokemonForms.fromMap(Map<String, dynamic>.from(r))).toList();
  }

  Future<List<PokemonForms>> getFormsWithTypes(int pokemonId) async {
    final db = await DatabaseHelper.instance.database;

    final formRows = await db.query(
      'pokemon_forms',
      where: 'pokemon_id = ? AND form_name NOT LIKE ? AND form_name NOT LIKE ?',
      whereArgs: [pokemonId, '%-mega%', '%-gmax%'],
    );

    final List<PokemonForms> result = [];
    for (final row in formRows) {
      final formName = row['form_name'] as String;

      final typeRows = await db.rawQuery('''
      SELECT t.id, t.name, t.color_hex
      FROM types t
      INNER JOIN pokemon_form_types pft ON pft.type_id = t.id
      WHERE pft.form_name = ? AND pft.pokemon_id = ?
      ORDER BY pft.slot ASC
    ''', [formName, pokemonId]);

      final List<PokemonType> types = typeRows
          .map<PokemonType>((r) => PokemonType.fromMap(Map<String, dynamic>.from(r)))
          .toList();

      result.add(
        PokemonForms.fromMap(Map<String, dynamic>.from(row))
            .copyWith(types: types.isNotEmpty ? types : null),
      );
    }
    return result;
  }

  Future<List<PokemonForms>> getMegaForms(int pokemonId) async {
    final db = await DatabaseHelper.instance.database;
    final rows = await db.query(
      'pokemon_forms',
      where: 'pokemon_id = ? AND (form_name LIKE ? OR form_name LIKE ?)',
      whereArgs: [pokemonId, '%-mega%', '%-gmax%'],
    );
    print('MEGA FORMS FOR $pokemonId: ${rows.map((r) => r['form_name']).toList()}');
    return rows.map<PokemonForms>((r) => PokemonForms.fromMap(Map<String, dynamic>.from(r))).toList();
  }

  Future<List<Evolution>> getEvolutionChain(int pokemonId) async {
    final db = await DatabaseHelper.instance.database;

    final chainRows = await db.rawQuery('''
    SELECT DISTINCT chain_id FROM evolutions
    WHERE from_id = ? OR to_id = ?
  ''', [pokemonId, pokemonId]);

    print('CHAIN ROWS for $pokemonId: $chainRows');

    if (chainRows.isEmpty) return [];

    final chainId = chainRows.first['chain_id'] as int;
    print('CHAIN ID: $chainId');

    final rows = await db.query(
      'evolutions',
      where: 'chain_id = ?',
      whereArgs: [chainId],
    );

    print('EVOLUTION ROWS: ${rows.length}');

    return rows
        .map<Evolution>((r) => Evolution.fromMap(Map<String, dynamic>.from(r)))
        .toList();
  }
}