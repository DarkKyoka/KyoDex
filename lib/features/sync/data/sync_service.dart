import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:kyodex/core/constants/app_constants.dart';
import 'package:kyodex/core/database/database_helper.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'dart:async';
import 'package:shared_preferences/shared_preferences.dart';

class SyncService {
  SyncService._();
  static final SyncService instance = SyncService._();

  int _idFromUrl(String url) {
    final segments = url.split('/');
    return int.parse(segments[segments.length - 2]);
  }

  Future<Map<String, dynamic>> _fetchJson(String url) async {
    final response = await http.get(Uri.parse(url))
        .timeout(const Duration(seconds: 10)); // ← add this

    if (response.statusCode == 200) {
      return jsonDecode(response.body) as Map<String, dynamic>;
    } else {
      throw Exception('Failed to fetch $url - Status ${response.statusCode}');
    }
  }

  Future<Map<String, dynamic>> _fetchJsonSlow(String url) async {
    final response = await http.get(Uri.parse(url))
        .timeout(const Duration(seconds: 30)); // longer for forms
    if (response.statusCode == 200) {
      return jsonDecode(response.body) as Map<String, dynamic>;
    } else {
      throw Exception('Failed to fetch $url - Status ${response.statusCode}');
    }
  }

  // -- Fetch methods
  Future<Map<String, dynamic>> fetchPokemon(int id) =>
      _fetchJson('${AppConstants.pokemonEndpoint}/$id');

  Future<Map<String, dynamic>> fetchSpecies(int id) =>
      _fetchJson('${AppConstants.speciesEndpoint}/$id');

  Future<Map<String, dynamic>> fetchEvolutionChain(String url) =>
      _fetchJson(url);


  Future<bool> needsFormSync() async {
    final prefs = await SharedPreferences.getInstance();
    return !(prefs.getBool(AppConstants.formsVersionKey) ?? false);
  }

  Future<void> markFormsSynced() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(AppConstants.formsVersionKey, true);
  }

  // -- Insert pokemon
  Future<void> insertPokemon(
    Database db,
    Map<String, dynamic> pokemon,
    Map<String, dynamic> species,

  ) async {
    final int id = pokemon['id'] as int;

    final existing = await db.query(
      'pokemon',
      where: 'id = ?',
      whereArgs: [id],
    );

    if (existing.isEmpty) {
      await db.transaction((txn) async {
        final generationUrl = species['generation']['url'] as String;
        final generation = _idFromUrl(generationUrl);

        final sprites = pokemon['sprites'] as Map<String, dynamic>;
        final otherSprites = sprites['other'] as Map<String, dynamic>?;
        //final homeSprites = otherSprites?['home'] as Map<String, dynamic>?;
        final spriteUrl = sprites['front_default'] as String? ?? '';
        final shinyUrl = sprites['front_shiny'] as String? ?? '';


        final genera = species['genera'] as List<dynamic>;
        final category =
            (genera.firstWhere(
                  (g) => g['language']['name'] == 'en',
                  orElse: () => {'genus': 'Unknown Pokemon'},
                ))['genus']
                as String;

        // Insert types
        final types = pokemon['types'] as List<dynamic>;
        for (final t in types) {
          final typeName = t['type']['name'] as String;
          final typeUrl = t['type']['url'] as String;
          final typeId = _idFromUrl(typeUrl);

          await txn.insert('types', {
            'id': typeId,
            'name': typeName,
            'color_hex': '#000000',
          }, conflictAlgorithm: ConflictAlgorithm.ignore);

          await txn.insert('pokemon_types', {
            'pokemon_id': id,
            'type_id': typeId,
            'slot': t['slot'] as int,
          });
        }

        // Insert main pokemon row
        await txn.insert('pokemon', {
          'id': id,
          'national_dex': pokemon['id'] as int,
          'name': pokemon['name'] as String,
          'category': category,
          'sprite_url': spriteUrl,
          'evolution_chain_url': species['evolution_chain']['url'] as String? ?? '',
          'height': ((pokemon['height'] as int?) ?? 0).toDouble(),
          'weight': ((pokemon['weight'] as int?) ?? 0).toDouble(),
          'generation': generation,
        });

        // Insert descriptions
        final allEntries = (species['flavor_text_entries'] as List<dynamic>)
            .where((e) => e['language']['name'] == 'en')
            .toList();

        // Remove duplicate text entries
        final seen = <String>{};
        for (final entry in allEntries) {
          final text = (entry['flavor_text'] as String)
              .replaceAll('\n', ' ')
              .replaceAll('\f', ' ');

          if (seen.contains(text)) continue;
          seen.add(text);

          final version = entry['version']['name'] as String;

          await txn.insert('pokemon_descriptions', {
            'pokemon_id': id,
            'version': version,
            'description': text,
          });
        }

        // Insert shiny form if exists
        if (shinyUrl.isNotEmpty) {
          await txn.insert('pokemon_forms', {
            'pokemon_id': id,
            'form_name': 'shiny',
            'sprite_url': shinyUrl,
          });
        }
      });
    }
  }

  // -- Sync set up
  Future<void> syncAll({
    required void Function(int current, int total) onProgress,
    void Function(String status)? onStatus, // ← add this
  }) async {
    final db = await DatabaseHelper.instance.database;

    // Pass 1
    const batchSize = 20;
    for (int i = 1; i <= AppConstants.totalPokemon; i += batchSize) {
      final futures = <Future>[];
      for (int id = i; id < i + batchSize && id <= AppConstants.totalPokemon; id++) {
        futures.add(() async {
          try {
            final pokemon = await fetchPokemon(id);
            final species = await fetchSpecies(id);
            await insertPokemon(db, pokemon, species);
          } catch (e) {
            print('Skipping pokemon $id: $e');
          }
          onProgress(id, AppConstants.totalPokemon);
        }());
      }
      await Future.wait(futures);
    }

    // Pass 2
    onStatus?.call('Syncing evolution chains...');
    await _syncEvolutions(db);

    // Pass 3
    onStatus?.call('Syncing alternate forms...');
    await _syncForms(db);
    await markFormsSynced();
  }

  Future<void> syncFormsOnly() async {
    final db = await DatabaseHelper.instance.database;
    await _syncForms(db);
  }

  // -- Evolution sync

  Future<void> _syncEvolutions(Database db) async {
    // Get unique chain URLs directly from DB — no API calls needed
    final chainRows = await db.rawQuery('''
    SELECT DISTINCT evolution_chain_url 
    FROM pokemon 
    WHERE evolution_chain_url != ''
  ''');

    final urls = chainRows
        .map((r) => r['evolution_chain_url'] as String)
        .toList();

    print('UNIQUE CHAINS: ${urls.length}');

    // Process in batches of 10
    const batchSize = 10;
    for (int i = 0; i < urls.length; i += batchSize) {
      final batch = urls.sublist(i, (i + batchSize).clamp(0, urls.length));
      final futures = batch.map((url) async {
        try {
          final chainId = _idFromUrl(url);
          final existing = await db.query(
            'evolutions',
            where: 'chain_id = ?',
            whereArgs: [chainId],
            limit: 1,
          );
          if (existing.isNotEmpty) return;

          final chainData = await fetchEvolutionChain(url);
          await _insertEvolutionChain(db, chainData['chain'], chainId);
        } catch (e) {
          print('Failed chain $url: $e');
        }
      });
      await Future.wait(futures);
    }
  }

  // -- Evolution chain  insert
  Future<void> _insertEvolutionChain(
    Database db,
    Map<String, dynamic> chain,
    int chainId,
  ) async {
    final fromUrl = chain['species']['url'] as String;
    final fromId = _idFromUrl(fromUrl);
    final evolvesTo = chain['evolves_to'] as List<dynamic>;

    for (final next in evolvesTo) {
      final toUrl = next['species']['url'] as String;
      final toId = _idFromUrl(toUrl);

      final details = next['evolution_details'] as List<dynamic>;
      String method = 'unknown';
      if (details.isNotEmpty) {
        final d = details[0];
        if (d['min_level'] != null) {
          method = 'level-up:${d['min_level']}';
        } else if (d['item'] != null) {
          method = 'use-item:${d['item']['name']}';
        } else if (d['trigger']['name'] == 'trade') {
          method = 'trade';
        } else if (d['min_happiness'] != null) {
          method = 'friendship';
        }
      }

      await db.transaction((txn) async {
        await txn.insert('evolutions', {
          'from_id': fromId,
          'to_id': toId,
          'method': method,
          'chain_id': chainId,
        }, conflictAlgorithm: ConflictAlgorithm.ignore);
      });

      // Recursive call outside the transaction
      await _insertEvolutionChain(db, next, chainId);
    }

  }

  Future<void> _syncForms(Database db) async {
    const batchSize = 20;
    for (int id = 1; id <= AppConstants.totalPokemon; id += batchSize) {
      final futures = <Future>[];
      for (int sid = id; sid < id + batchSize && sid <= AppConstants.totalPokemon; sid++) {
        futures.add(() async {
          try {
            final species = await fetchSpecies(sid);
            final varieties = species['varieties'] as List<dynamic>;

            for (final variety in varieties) {
              final isPrimary = variety['is_default'] as bool;
              if (isPrimary) continue; // skip default — already stored

              final varietyUrl = variety['pokemon']['url'] as String;
              final varietyData = await _fetchJson(varietyUrl);
              final varietyName = varietyData['name'] as String;
              final sprites = varietyData['sprites'] as Map<String, dynamic>;

              //final otherSprites = sprites['other'] as Map<String, dynamic>?;
              //final officialArtwork = otherSprites?['official-artwork'] as Map<String, dynamic>?;
             // final spriteUrl = officialArtwork?['front_default'] as String?
                 // ?? sprites['front_default'] as String?
                  //?? '';
              final formSpriteUrl = sprites['front_default'] as String? ?? '';

              final existing = await db.query(
                'pokemon_forms',
                where: 'pokemon_id = ? AND form_name = ?',
                whereArgs: [sid, varietyName],
              );
              if (existing.isNotEmpty) continue;

              await db.insert('pokemon_forms', {
                'pokemon_id': sid,
                'form_name': varietyName,
                'sprite_url': formSpriteUrl,
              });

              // Store form types
              final formTypes = varietyData['types'] as List<dynamic>;
              for (final t in formTypes) {
                final typeName = t['type']['name'] as String;
                final typeUrl = t['type']['url'] as String;
                final typeId = _idFromUrl(typeUrl);

                await db.insert('types', {
                  'id': typeId,
                  'name': typeName,
                  'color_hex': '#000000',
                }, conflictAlgorithm: ConflictAlgorithm.ignore);

                await db.insert('pokemon_form_types', {
                  'form_name': varietyName,
                  'pokemon_id': sid,
                  'type_id': typeId,
                  'slot': t['slot'] as int,
                }, conflictAlgorithm: ConflictAlgorithm.ignore);
              }
            }
          } catch (e) {
            print('Failed to sync forms for pokemon $sid: $e');
          }
        }());
      }
      await Future.wait(futures);
    }
  }
}
