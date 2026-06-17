import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kyodex/features/search/data/search_repository.dart';
import 'package:kyodex/models/list_item.dart';

class SearchState {
  final String query;
  final String? type;
  final int? generation;

  const SearchState({
    this.query = '',
    this.type,
    this.generation,
  });

  SearchState copyWith({
    String? query,
    String? type,
    int? generation,
  }) {
    return SearchState(
      query: query ?? this.query,
      type: type ?? this.type,
      generation: generation ?? this.generation,
    );
  }
}

class SearchNotifier extends AsyncNotifier<List<ListItem>> {
  @override
  Future<List<ListItem>> build() async {
    return SearchRepository.instance.searchPokemon();
  }

  Future<void> search(SearchState state) async {
    this.state = const AsyncLoading();
    this.state = await AsyncValue.guard(() =>
        SearchRepository.instance.searchPokemon(
          name: state.query.isEmpty ? null : state.query,
          type: state.type,
          generation: state.generation,
        ),
    );
  }

  void setList(List<ListItem> list) {
    state = AsyncData(list);
  }
}

final searchProvider =
AsyncNotifierProvider<SearchNotifier, List<ListItem>>(
      () => SearchNotifier(),
);