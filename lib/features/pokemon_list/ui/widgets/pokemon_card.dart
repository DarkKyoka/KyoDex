import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:kyodex/features/pokemon_list/ui/widgets/type_badge.dart';
import 'package:kyodex/models/list_item.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../pokemon_detail/ui/detail_screen.dart';

class PokemonCard extends StatelessWidget {
  final ListItem item;
  const PokemonCard({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => DetailScreen(pokemonId: item.pokemonId),
        ),
      ),
      child: Container(
        decoration: BoxDecoration(
          color: AppConstants.bgCard,
          borderRadius: BorderRadius.circular(7),
        ),
        child: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 9, horizontal: 8),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Text(
                          item.name[0].toUpperCase() + item.name.substring(1),
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w500,
                            fontSize: 14,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 1.5),
                        Wrap(
                          spacing: 3,
                          runSpacing: 2,
                          children: item.types
                              .map((type) => TypeBadge(type: type))
                              .toList(),
                        ),
                      ],
                    ),
                  ),
                  CachedNetworkImage(
                    imageUrl: item.spriteUrl,
                    height: 68,
                    width: 68,
                    placeholder: (context, url) =>
                        const SizedBox(height: 68, width: 68),
                    errorWidget: (context, url, error) =>
                        const Icon(Icons.question_mark, color: Colors.grey),
                  ),
                ],
              ),
            ),
            Positioned(
              top: 6,
              left: 7,
              child: Text(
                '#${item.nationalDex.toString().padLeft(2, '0')}',
                style: const TextStyle(
                  color: AppConstants.textMuted,
                  fontSize: 11,
                ),
              ),
            ),
            //Positioned(
             // top: 6,
              //right: 6,
              //child: Icon(
               // Icons.star_border,
                //color: Colors.grey.withAlpha((0.6 * 255).toInt()),
                //size: 18,
              //),
            //),
          ],
        ),
      ),
    );
  }
}
