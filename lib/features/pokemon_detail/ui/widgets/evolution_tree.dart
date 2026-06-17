import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:kyodex/core/constants/app_constants.dart';
import 'package:kyodex/models/evolution.dart';
import 'package:kyodex/models/pokemon_forms.dart';

import '../detail_screen.dart';


class EvolutionTree extends StatelessWidget {
  final List<Evolution> evolutions;
  final List<PokemonForms> megaForms;
  const EvolutionTree({super.key, required this.evolutions, required this.megaForms});

  // Find root — pokemon that is never a to_id
  int _findRoot() {
    final toIds = evolutions.map((e) => e.toId).toSet();
    for (final e in evolutions) {
      if (!toIds.contains(e.fromId)) return e.fromId;
    }
    return evolutions.first.fromId;
  }

  // Get all evolutions from a given pokemon
  List<Evolution> _childrenOf(int id) =>
      evolutions.where((e) => e.fromId == id).toList();

  String _methodLabel(String method) {
    if (method.startsWith('level-up:')) {
      return 'Level ${method.split(':')[1]}';
    } else if (method.startsWith('use-item:')) {
      return method.split(':')[1].replaceAll('-', ' ');
    } else if (method == 'trade') {
      return 'Trade';
    } else if (method == 'friendship') {
      return 'Friendship';
    }
    return method;
  }

  @override
  Widget build(BuildContext context) {
    print('EVOLUTIONS: ${evolutions.map((e) => '${e.fromId}→${e.toId}').toList()}');
    if (evolutions.isEmpty) {
      return const Text('No evolution data.', style: TextStyle(color: Colors.grey));
    }
    final root = _findRoot();
    print('ROOT: $root');
    return Center(child: _buildNode(root, context));
  }

  Widget _buildNode(int pokemonId, BuildContext context) {
    final children = _childrenOf(pokemonId);
    print('NODE $pokemonId — children: ${children.map((e) => e.toId).toList()}, megaForms: ${megaForms.length}');

    //final paddedId = pokemonId.toString().padLeft(3,'0');
    final spriteUrl = 'https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/$pokemonId.png';

    return Column(
      children: [
        // Sprite
        Image.network(spriteUrl, height: 72, width: 72,
            errorBuilder: (c, e, s) =>
            const Icon(Icons.catching_pokemon, size: 60)),

        if (children.isEmpty) const SizedBox.shrink(),

        // For each child evolution
        if (children.length == 1) ...[
          _ArrowDown(label: _methodLabel(children[0].method)),
          _buildNode(children[0].toId, context),
        ],

        // Branching — multiple children (Eevee, Megas)
        if (children.isEmpty) ...[
          if (megaForms.isNotEmpty) ...[
            const SizedBox(height: 8),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: megaForms.map((form) => Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: Column(
                    children: [
                      _ArrowDown(label: form.formName.contains('gmax') ? 'G-Max' : 'Mega'),
                      GestureDetector(
                        onTap: () => Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => DetailScreen(pokemonId: pokemonId),
                          ),
                        ),
                        child: Image.network(
                          form.spriteUrl,
                          height: 72,
                          width: 72,
                          errorBuilder: (c, e, s) => const Icon(Icons.question_mark, size: 60),
                        ),
                      ),
                      Text(
                        form.formName,
                        style: const TextStyle(color: Colors.white, fontSize: 11),
                      ),
                    ],
                  ),
                )).toList(),
              ),
            ),
          ],
        ],
      ],
    );
  }
}

class _ArrowDown extends StatelessWidget {
  final String label;
  const _ArrowDown({required this.label});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 4),
        const Icon(Icons.arrow_downward, color: Colors.white, size: 20),
        Text(
          label,
          style: const TextStyle(color: Colors.white, fontSize: 12),
        ),
        const SizedBox(height: 4),
      ],
    );
  }
}