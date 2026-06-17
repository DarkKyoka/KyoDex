import 'package:flutter/material.dart';

class AppConstants {
  AppConstants._();

  //Database data
  static const String dbName = 'kyoDex.db';
  static const int dbVersion = 3;
  static const int totalPokemon = 1025;
  static const String formsVersionKey = 'forms_synced_v1';
  //PokeAPI
  static const String baseURL = 'https://pokeapi.co/api/v2';
  static const String pokemonEndpoint = '$baseURL/pokemon';
  static const String speciesEndpoint = '$baseURL/pokemon-species';
  static const String evolutionEndpoint = '$baseURL/evolution-chain';
  static const String generationEndpoint = '$baseURL/generation';

  static const Map<String, String> typeColors = {
    'normal': '#A8A878',
    'fire': '#F08030',
    'water': '#6890F0',
    'electric': '#F8D030',
    'grass': '#78C850',
    'ice': '#98D8D8',
    'fighting': '#C03028',
    'poison': '#A040A0',
    'ground': '#E0C068',
    'flying': '#A890F0',
    'psychic': '#F85888',
    'bug': '#A8B820',
    'rock': '#B8A038',
    'ghost': '#705898',
    'dragon': '#7038F8',
    'dark': '#705848',
    'steel': '#B8B8D0',
    'fairy': '#EE99AC',
  };

  static const Map<String, int>region_To_Generation = {
    // Region names
    'kanto': 1,
    'johto': 2,
    'hoenn': 3,
    'sinnoh': 4,
    'unova': 5,
    'kalos': 6,
    'alola': 7,
    'galar': 8,
    'paldea': 9,

    //Gen Names and Alterations to fit the search
    'generation 1': 1,
    'generation i': 1,
    'gen i': 1,
    'gen 1': 1,

    'generation 2': 2,
    'generation ii': 2,
    'gen ii': 2,
    'gen 2': 2,

    'generation 3': 3,
    'generation-iii': 3,
    'gen iii': 3,
    'gen 3': 3,

    'generation 4': 4,
    'generation-iv': 4,
    'gen iv': 4,
    'gen 4': 4,

    'generation 5': 5,
    'generation-v': 5,
    'gen v': 5,
    'gen 5': 5,

    'generation 6': 6,
    'generation-vi': 6,
    'gen vi': 6,
    'gen 6': 6,

    'generation 7': 7,
    'generation-vii': 7,
    'gen vii': 7,
    'gen 7': 7,

    'generation 8': 8,
    'generation-viii': 8,
    'gen viii': 8,
    'gen 8': 8,

    'generation 9': 9,
    'generation-ix': 9,
    'gen ix': 9,
    'gen 9': 9,


  };



  //color pallete
  static const Color bgPrimary = Color(0xFF1A1A1A);
  static const Color bgCard = Color(0xFF333333);
  static const Color accentRed = Color(0xFFE53935);
  static const Color textPrimary = Color(0xFFFFFFFF);
  static const Color textMuted = Color(0xFF9E9E9E);
  static const Color speciesText = Color.fromRGBO(255, 133, 51, 1.0);
}
