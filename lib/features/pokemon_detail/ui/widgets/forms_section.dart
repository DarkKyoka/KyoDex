import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:kyodex/models/pokemon_forms.dart';

class FormsSection extends StatelessWidget {
  final List<PokemonForms> forms;
  const FormsSection({super.key, required this.forms});

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 16,
      runSpacing: 16,
      children: forms.map((form) => _FormCard(form: form)).toList(),
    );
  }
}

class _FormCard extends StatelessWidget {
  final PokemonForms form;
  const _FormCard({required this.form});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        CachedNetworkImage(
          imageUrl: form.spriteUrl,
          height: 80,
          width: 80,
          errorWidget: (c, u, e) =>
          const Icon(Icons.catching_pokemon, size: 60),
        ),
        const SizedBox(height: 4),
        Text(
          form.formName[0].toUpperCase() + form.formName.substring(1),
          style: const TextStyle(color: Colors.white, fontSize: 12),
        ),
      ],
    );
  }
}