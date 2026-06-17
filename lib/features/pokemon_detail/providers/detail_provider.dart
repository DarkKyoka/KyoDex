import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kyodex/features/pokemon_detail/data/detail_repository.dart';
import 'package:kyodex/features/search/data/search_repository.dart';
import 'package:kyodex/models/pokemon.dart';
import 'package:kyodex/models/pokemon_forms.dart';
import 'package:kyodex/models/evolution.dart';
import 'package:kyodex/models/list_item.dart';


//Holds data per one pokemon detail screen
class DetailState {
  final Pokemon pokemon;
  final List<PokemonForms> forms;
  final List<PokemonForms> megaForms;
  final List<Evolution> evolutions;
  final List<ListItem> evolutionItems;

  const DetailState({
    required this.pokemon,
    required this.forms,
    required this.megaForms,
    required this.evolutions,
    required this.evolutionItems,
  });
}

class DetailNotifier extends FamilyAsyncNotifier<DetailState, int>{

  @override
  Future<DetailState> build(int pokemonId) async {
    final pokemon = await DetailRepository.instance.getPokemon(pokemonId);
    final forms = await DetailRepository.instance.getFormsWithTypes(pokemonId);
    final evolutions = await DetailRepository.instance.getEvolutionChain(pokemonId);

    // Get unique IDs from evolution chain
    final evolutionIds = <int>{};
    for (final e in evolutions) {
      evolutionIds.add(e.fromId);
      evolutionIds.add(e.toId);
    }
    
    // If no evolutions, the root is the pokemon itself
    if (evolutionIds.isEmpty) {
      evolutionIds.add(pokemonId);
    }

    final evolutionItems = await SearchRepository.instance.getItemsByIds(evolutionIds.toList());

    // Find the final evolution ID to load mega forms
    final allToIds = evolutions.map((e) => e.toId).toSet();
    final allFromIds = evolutions.map((e) => e.fromId).toSet();

    // Final evolution = toId that is never a fromId
    final finalIds = allToIds.difference(allFromIds);

    List<PokemonForms> megaForms = [];
    for (final finalId in finalIds) {
      final megas = await DetailRepository.instance.getMegaForms(finalId);
      megaForms.addAll(megas);
    }

    // Also check current pokemon if no evolutions
    if (evolutions.isEmpty) {
      megaForms = await DetailRepository.instance.getMegaForms(pokemonId);
    }

    return DetailState(
      pokemon: pokemon,
      forms: forms,
      megaForms: megaForms,
      evolutions: evolutions,
      evolutionItems: evolutionItems,
    );
  }
}


final detailProvider = AsyncNotifierProviderFamily<DetailNotifier, DetailState, int>( () => DetailNotifier(),);