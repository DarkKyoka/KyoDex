import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:kyodex/core/constants/app_constants.dart';
import 'package:kyodex/features/pokemon_detail/providers/detail_provider.dart';
import 'package:kyodex/features/pokemon_list/ui/widgets/type_badge.dart';
import 'package:kyodex/features/pokemon_detail/ui/widgets/evolution_tree.dart';
import 'package:kyodex/features/pokemon_detail/ui/widgets/forms_section.dart';

class DetailScreen extends ConsumerWidget {
  final int pokemonId;
  const DetailScreen({super.key, required this.pokemonId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final detailAsync = ref.watch(detailProvider(pokemonId));

    return Scaffold(
      backgroundColor: const Color(0xff121212),
      appBar: AppBar(
        backgroundColor: AppConstants.accentRed,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => context.pop(),
        ),
        title: const Text(
          'Pokémon Details',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
      body: detailAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, st) => Center(child: Text('Error: $e')),
        data: (detail) => SingleChildScrollView(
          padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              // Pokemon summary Panel
              _PanelContainer(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '# ${detail.pokemon.nationalDex.toString().padLeft(2, '0')}',
                            style: const TextStyle(
                                color: AppConstants.textMuted, fontSize: 13),
                          ),
                          const SizedBox(height: 18),
                          Text(
                            detail.pokemon.name[0].toUpperCase() +
                                detail.pokemon.name.substring(1),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 26,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            detail.pokemon.category,
                            style: const TextStyle(
                              color: AppConstants.speciesText,
                              fontSize: 13,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Wrap(
                            spacing: 2,
                            children: detail.pokemon.types
                                .map((t) => TypeBadge(type: t, badgeWidth: 16, badgeHeight: 4, fontSize: 12,))
                                .toList(),
                          ),
                        ],
                      ),
                    ),
                    CachedNetworkImage(
                      imageUrl: detail.pokemon.spriteUrl,
                      height: 110,
                      width: 110,
                      errorWidget: (c, u, e) =>
                      const Icon(Icons.catching_pokemon, size: 80),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 7),

              // Description Panel
              _PanelContainer(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const _SectionHeader(title: 'Description'),
                    const SizedBox(height: 8),
                    _DescriptionPageView(
                      descriptions: detail.pokemon.descriptions
                          .map((d) => d.description)
                          .toList(),
                      versions: detail.pokemon.descriptions
                          .map((d) => d.version)
                          .toList(),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 7),

              // Evolution Tree Panel
              _PanelContainer(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const _SectionHeader(title: 'Evolution Tree'),
                    const SizedBox(height: 8),
                    EvolutionTree(
                      evolutions: detail.evolutions,
                      megaForms: detail.megaForms,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 7),

              // Other Forms Panel
              if (detail.forms.isNotEmpty) ...[
                _PanelContainer(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const _SectionHeader(title: 'Other Forms'),
                      const SizedBox(height: 8),
                      FormsSection(forms: detail.forms),
                    ],
                  ),
                ),
              ],

              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}



//___ Reusable widgets _________________________________________________________

class _PanelContainer extends StatelessWidget {
  final Widget child;
  const _PanelContainer({required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppConstants.bgCard,
        borderRadius: BorderRadius.circular(12),
      ),
      child: child,
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: const TextStyle(
        color: Colors.white,
        fontSize: 18,
        fontWeight: FontWeight.bold,
      ),
    );
  }
}

//___ Description PageView _____________________________________________________

class _DescriptionPageView extends StatefulWidget {
  final List<String> descriptions;
  final List<String> versions;

  const _DescriptionPageView({
    required this.descriptions,
    required this.versions,
  });

  @override
  State<_DescriptionPageView> createState() => _DescriptionPageViewState();
}

class _DescriptionPageViewState extends State<_DescriptionPageView> {
  int _currentPage = 0;
  late final PageController _controller = PageController(viewportFraction: 1);

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  String _formatVersion(String version) {
    return version
        .split('-')
        .map((w) => w[0].toUpperCase() + w.substring(1))
        .join(' ');
  }

  @override
  Widget build(BuildContext context) {
    if (widget.descriptions.isEmpty) {
      return const Text(
        'No description available X<',
        style: TextStyle(color: AppConstants.textMuted),
      );
    }

    final total = widget.descriptions.length;
    final currentVersion = widget.versions.isNotEmpty
        ? _formatVersion(widget.versions[_currentPage])
        : '';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [

        // Page view
        SizedBox(
          height: 80,
          child: PageView.builder(
            controller: _controller,
            padEnds: false,   //Padding to both sides
            itemCount: total,
            onPageChanged: (index) => setState(() => _currentPage = index),
            itemBuilder: (context, index) {
              final rawDesc = widget.descriptions[index];
              // Strip the appended version if it exists (for old synced data)
              final cleanDesc = rawDesc.split('— Pokémon').first.trim();
              
              return Padding(
                padding: const EdgeInsets.only(right: 12),
                child: Text(
                  cleanDesc,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 13,
                    height: 1.4,
                  ),
                ),
              );
            },
          ),
        ),

        const SizedBox(height: 6),

        // Description entry Counter and Version
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '${_currentPage + 1} / $total',
              style: const TextStyle(color: AppConstants.textMuted, fontSize: 10),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                '— Pokémon $currentVersion',
                textAlign: TextAlign.end,
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
                style: const TextStyle(
                  color: AppConstants.textMuted,
                  fontSize: 10,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
