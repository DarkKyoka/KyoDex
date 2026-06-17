import 'package:flutter/material.dart';
import 'package:kyodex/core/constants/app_constants.dart';
import 'package:kyodex/models/pokemon_type.dart';

class TypeBadge extends StatelessWidget {
  final PokemonType type;

  final int? badgeWidth;
  final int? badgeHeight;
  final int? fontSize;

  const TypeBadge({super.key, required this.type, this.badgeWidth, this.badgeHeight, this.fontSize});



  Color get _color {
    final hex = AppConstants.typeColors[type.name] ?? '#777777';
    return Color(int.parse(hex.replaceAll('#', '0xFF')));
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
          horizontal: badgeWidth?.toDouble() ?? 8,//8,

          vertical: badgeHeight?.toDouble() ?? 3

      ),
      decoration: BoxDecoration(
        color: _color,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        type.name[0].toUpperCase() + type.name.substring(1),
        style:  TextStyle(
          color: Colors.white,
          fontSize: fontSize?.toDouble() ?? 8,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}