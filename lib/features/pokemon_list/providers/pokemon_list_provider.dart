

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kyodex/features/pokemon_list/data/pokemon_repository.dart';
import 'package:kyodex/models/pokemon.dart';

class PokemonListNotifier extends AsyncNotifier<List<Pokemon>>{

  @override
  Future<List<Pokemon>> build() async{
    return PokemonRepository.instance.getAllPokemon();
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(
        () => PokemonRepository.instance.getAllPokemon(),
    );
  }



}

final pokemonListProvider = AsyncNotifierProvider<PokemonListNotifier, List<Pokemon>>(
      () => PokemonListNotifier(),
);