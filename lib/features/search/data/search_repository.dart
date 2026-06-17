import 'package:kyodex/core/database/database_helper.dart';
import 'package:kyodex/core/constants/app_constants.dart';
import 'package:kyodex/models/list_item.dart';
import 'package:kyodex/models/pokemon_type.dart';

class SearchRepository {
  SearchRepository._();
  static final SearchRepository instance = SearchRepository._();

  int _levenshtein(String a, String b) {
    final m = a.length, n = b.length;
    final dp = List.generate(m + 1, (i) => List.filled(n + 1, 0));
    for (int i = 0; i <= m; i++) dp[i][0] = i;
    for (int j = 0; j <= n; j++) dp[0][j] = j;
    for (int i = 1; i <= m; i++) {
      for (int j = 1; j <= n; j++) {
        if (a[i - 1] == b[j - 1]) {
          dp[i][j] = dp[i - 1][j - 1];
        } else {
          dp[i][j] = 1 + [dp[i-1][j], dp[i][j-1], dp[i-1][j-1]]
              .reduce((a, b) => a < b ? a : b);
        }
      }
    }
    return dp[m][n];
  }

  Future<List<ListItem>> searchPokemon({
    String? name,
    int? nationalDex,
    String? type,
    int? generation,
  }) async {
    final db = await DatabaseHelper.instance.database;

    final query = name?.toLowerCase().trim() ?? '';

    // Number search
    final asNumber = int.tryParse(query);
    if (asNumber != null) {
      final rows = await db.query(
        'pokemon',
        where: 'national_dex = ?',
        whereArgs: [asNumber],
      );
      return _buildItems(db, rows, includeforms: true);
    }

    // Region/generation mapping
    final genFromRegion = AppConstants.region_To_Generation[query];
    final effectiveGeneration = generation ?? genFromRegion;

    // Type check
    final typeNames = AppConstants.typeColors.keys.toSet();
    final isType = typeNames.contains(query);

    final conditions = <String>[];
    final args = <dynamic>[];
    String joinClause = '';

    if (isType) {
      joinClause = '''
        INNER JOIN pokemon_types pt ON pt.pokemon_id = p.id
        INNER JOIN types t ON t.id = pt.type_id
      ''';
      conditions.add('t.name = ?');
      args.add(query);
    } else if (effectiveGeneration != null) {
      conditions.add('p.generation = ?');
      args.add(effectiveGeneration);
    } else if (query.isNotEmpty) {
      conditions.add('(p.name LIKE ? OR p.category LIKE ?)');
      args.add('%$query%');
      args.add('%$query%');
    }

    if (type != null && !isType) {
      joinClause = '''
        INNER JOIN pokemon_types pt ON pt.pokemon_id = p.id
        INNER JOIN types t ON t.id = pt.type_id
      ''';
      conditions.add('t.name = ?');
      args.add(type);
    }

    if (generation != null && genFromRegion == null) {
      conditions.add('p.generation = ?');
      args.add(generation);
    }

    final where = conditions.isEmpty ? '' : 'WHERE ${conditions.join(' AND ')}';

    final sql = '''
      SELECT DISTINCT p.*
      FROM pokemon p
      $joinClause
      $where
      ORDER BY p.national_dex ASC
    ''';

    final rows = await db.rawQuery(sql, args);

    if (rows.isEmpty && query.isNotEmpty && asNumber == null && !isType && effectiveGeneration == null) {
      return _fuzzySearch(db, query);
    }

    return _buildItems(db, rows, includeforms: true);
  }

  Future<List<ListItem>> getItemsByIds(List<int> ids, {bool includeForms = false}) async {
    if (ids.isEmpty) return [];
    final db = await DatabaseHelper.instance.database;
    final rows = await db.query(
      'pokemon',
      where: 'id IN (${ids.join(',')})',
      orderBy: 'national_dex ASC',
    );
    return _buildItems(db, rows, includeforms: includeForms);
  }

  Future<List<ListItem>> _buildItems(
      dynamic db,
      List<Map<Object?, Object?>> rows, {
        bool includeforms = false,
      }) async {
    if (rows.isEmpty) return [];

    final ids = rows.map((r) => r['id'] as int).toList();

    // Bulk type fetch for base pokemon
    final allTypeRows = await db.rawQuery('''
      SELECT pt.pokemon_id, t.id, t.name, t.color_hex
      FROM types t
      INNER JOIN pokemon_types pt ON pt.type_id = t.id
      WHERE pt.pokemon_id IN (${ids.join(',')})
      ORDER BY pt.pokemon_id, pt.slot ASC
    ''');

    final typeMap = <int, List<PokemonType>>{};
    for (final row in allTypeRows) {
      final pid = row['pokemon_id'] as int;
      typeMap.putIfAbsent(pid, () => <PokemonType>[]);
      typeMap[pid]!.add(PokemonType.fromMap(Map<String, dynamic>.from(row)));
    }

    final List<ListItem> items = [];

    for (final row in rows) {
      final id = row['id'] as int;
      final nationalDex = row['national_dex'] as int;
      final name = row['name'] as String;
      final spriteUrl = row['sprite_url'] as String;
      final types = typeMap[id] ?? <PokemonType>[];

      // Add base pokemon
      items.add(ListItem(
        nationalDex: nationalDex,
        name: name[0].toUpperCase() + name.substring(1),
        spriteUrl: spriteUrl,
        types: types,
        pokemonId: id,
      ));

      if (!includeforms) continue;

      // Add forms but exclude shiny
      final formRows = await db.query(
        'pokemon_forms',
        where: 'pokemon_id = ? AND form_name != ?',
        whereArgs: [id, 'shiny'],
      );

      for (final formRow in formRows) {
        final formName = formRow['form_name'] as String;
        final formSprite = formRow['sprite_url'] as String;

        // Get form types
        final formTypeRows = await db.rawQuery('''
          SELECT t.id, t.name, t.color_hex
          FROM types t
          INNER JOIN pokemon_form_types pft ON pft.type_id = t.id
          WHERE pft.form_name = ? AND pft.pokemon_id = ?
          ORDER BY pft.slot ASC
        ''', [formName, id]);

        final List<PokemonType> formTypes = formTypeRows.isNotEmpty
            ? formTypeRows.map<PokemonType>((r) => PokemonType.fromMap(Map<String, dynamic>.from(r))).toList()
            : types; // fallback to base types

        final displayName = formName
            .split('-')
            .map((w) => w[0].toUpperCase() + w.substring(1))
            .join(' ');

        items.add(ListItem(
          nationalDex: nationalDex,
          name: displayName,
          spriteUrl: formSprite,
          types: formTypes,
          pokemonId: id,
          isForm: true,
          formName: formName,
        ));
      }
    }

    return items;
  }

  Future<List<ListItem>> _fuzzySearch(dynamic db, String query) async {
    final rows = await db.query('pokemon', orderBy: 'national_dex ASC');
    final threshold = (query.length / 4).ceil().clamp(2, 5);
    final matches = <Map<Object?, Object?>>[];

    for (final row in rows) {
      final pokemonName = (row['name'] as String).toLowerCase();
      if (_levenshtein(query, pokemonName) <= threshold) {
        matches.add(row);
      }
    }

    matches.sort((a, b) {
      final da = _levenshtein(query, (a['name'] as String).toLowerCase());
      final db2 = _levenshtein(query, (b['name'] as String).toLowerCase());
      return da.compareTo(db2);
    });

    return _buildItems(db, matches, includeforms: false);
  }
}