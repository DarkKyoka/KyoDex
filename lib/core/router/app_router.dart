import 'package:go_router/go_router.dart';
import 'package:kyodex/features/pokemon_list/ui/about_screen.dart';
import 'package:kyodex/features/pokemon_list/ui/pokemon_list_screen.dart';
import 'package:kyodex/features/pokemon_detail/ui/detail_screen.dart';
import 'package:kyodex/features/pokemon_list/ui/sync_screen.dart';
import 'package:kyodex/core/database/database_helper.dart';

bool syncComplete = false;


late final appRouter = GoRouter(
  initialLocation: _initialRoute,
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => const PokemonListScreen(),
    ),
    GoRoute(
      path: '/sync',
      builder: (context, state) => const SyncScreen(),
    ),
    GoRoute(
      path: '/about',
      builder: (context, state) => const AboutScreen(),
    ),
    GoRoute(
      path: '/pokemon/:id',
      builder: (context, state) {
        final id = int.parse(state.pathParameters['id']!);
        return DetailScreen(pokemonId: id);
      },
    ),
  ],
);

String _initialRoute = '/';

Future<String> getInitialRoute() async {
  final db = await DatabaseHelper.instance.database;
  final rows = await db.query('pokemon', limit: 1);
  _initialRoute = rows.isEmpty ? '/sync' : '/';
  return _initialRoute;
}
