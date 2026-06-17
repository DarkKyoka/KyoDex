import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:kyodex/core/constants/app_constants.dart';
import 'package:kyodex/features/search/providers/search_provider.dart';
import 'package:kyodex/features/pokemon_list/ui/widgets/pokemon_card.dart';
import 'package:kyodex/models/list_item.dart';

class PokemonListScreen extends ConsumerStatefulWidget {
  const PokemonListScreen({super.key});

  @override
  ConsumerState<PokemonListScreen> createState() => _PokemonListScreenState();
}

class _PokemonListScreenState extends ConsumerState<PokemonListScreen> {
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  SearchState _currentSearch = const SearchState();
  int _selectedGen = 0;
  List<ListItem> _allPokemon = [];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await ref.read(searchProvider.notifier).search(const SearchState());
      final result = ref.read(searchProvider).value;
      if (result != null) {
        setState(() => _allPokemon = result);
      }
    });
  }

  static const List<String> _gens = [
    'All',
    'Gen I',
    'Gen II',
    'Gen III',
    'Gen IV',
    'Gen V',
    'Gen VI',
    'Gen VII',
    'Gen VIII',
    'Gen IX',
  ];

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _onSearchChanged(String value) {
    setState(() {}); // Trigger rebuild for the X button visibility
    final newState = _currentSearch.copyWith(query: value);
    _currentSearch = newState;
    ref.read(searchProvider.notifier).search(newState);
  }

  void _onGenSelected(int index) {
    setState(() => _selectedGen = index);

    if (index == 0) {
      // restore cached full list
      ref.read(searchProvider.notifier).setList(_allPokemon);
      _currentSearch = const SearchState();
      return;
    }

    final newState = _currentSearch.copyWith(generation: index);
    _currentSearch = newState;
    ref.read(searchProvider.notifier).search(newState);
  }

  @override
  Widget build(BuildContext context) {
    final pokemonAsync = ref.watch(searchProvider);

    return Scaffold(
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 2),
                      RichText(
                        text: const TextSpan(
                          children: [
                            TextSpan(
                              text: 'Kyo',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 28,
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                            TextSpan(
                              text: 'Dex',
                              style: TextStyle(
                                color: AppConstants.accentRed,
                                fontSize: 28,
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Text(
                        'v1.0',
                        style: TextStyle(color: Colors.grey, fontSize: 11),
                      ),
                    ],
                  ),
                  GestureDetector(
                    onTap: () => context.push('/about'),
                    child: const Icon(Icons.info_outline, color: Colors.white),
                  )
                ],
              ),
            ),

            // Search bar
            Padding(
              padding: const EdgeInsets.only(
                left: 10,
                right: 10,
                bottom: 12,
                top: 5,
              ),
              child: Container(
                height: 37,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: AppConstants.accentRed.withValues(alpha: 0.3),
                  ),
                ),
                child: TextField(
                  controller: _searchController,
                  onChanged: _onSearchChanged,
                  style: const TextStyle(
                    color: Color.fromARGB(255, 26, 26, 26),
                  ),
                  decoration: InputDecoration(
                    suffixIcon: _searchController.text.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.close, color: Colors.grey),
                            onPressed: () {
                              _searchController.clear();
                              _onSearchChanged('');
                            },
                          )
                        : null,
                    hintText: 'Search by: Name, Region, Game, Id...',
                    hintStyle: const TextStyle(
                      color: Color.fromARGB(255, 26, 26, 26),
                      fontSize: 13,
                    ),
                    prefixIcon: const Icon(
                      Icons.search,
                      color: Color.fromARGB(255, 47, 47, 47),
                    ),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
            ),

            // Gen tabs
            SizedBox(
              height: 35,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 12),
                itemCount: _gens.length,
                itemBuilder: (context, index) {
                  final selected = _selectedGen == index;
                  return GestureDetector(
                    onTap: () => _onGenSelected(index),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      child: Text(
                        _gens[index],
                        style: TextStyle(
                          color: selected
                              ? AppConstants.accentRed
                              : Colors.white,
                          fontWeight: selected
                              ? FontWeight.bold
                              : FontWeight.normal,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),

            // Gen label + divider
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
              child: Row(
                children: [
                  Text(
                    _gens[_selectedGen],
                    style: const TextStyle(color: Colors.white, fontSize: 13),
                  ),
                  const SizedBox(width: 8),
                  const Expanded(child: Divider(color: Colors.grey)),
                ],
              ),
            ),

            // Grid
            Expanded(
              child: pokemonAsync.when(
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (e, st) => Center(child: Text('Error: $e')),
                data: (pokemonList) => Scrollbar(
                  thumbVisibility: true,
                  interactive: true,
                  controller: _scrollController,
                  child: GridView.builder(
                    controller: _scrollController,
                    physics: const BouncingScrollPhysics(),
                    cacheExtent: 1000,
                    keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
                    padding: const EdgeInsets.all(8),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: 3,
                          mainAxisSpacing: 3,
                          mainAxisExtent: 110,
                        ),
                    itemCount: pokemonList.length,
                    itemBuilder: (context, index) =>
                        PokemonCard(item: pokemonList[index]),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
