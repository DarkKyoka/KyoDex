import 'package:flutter/material.dart';
import 'package:kyodex/features/pokemon_list/ui/pokemon_list_screen.dart';
import 'package:kyodex/features/sync/data/sync_service.dart';
import 'package:go_router/go_router.dart';
import 'package:kyodex/core/router/app_router.dart';


class SyncScreen extends StatefulWidget {
  const SyncScreen({super.key});

  @override
  State<SyncScreen> createState() => _SyncScreenState();
}

class _SyncScreenState extends State<SyncScreen> {
  int _current = 0;
  int _total = 0;
  bool _syncing = false;
  String _status = 'Preparing...';


  @override
  void initState() {
    super.initState();
    _startSync();
  }

  Future<void> _startSync() async {
    setState(() => _syncing = true);

    try {
      await SyncService.instance.syncAll(
        onProgress: (current, total) {
          setState(() {
            _current = current;
            _total = total;
            _status = 'Downloading Pokémon $current of $total...';
          });
        },
        onStatus: (status) {
          setState(() => _status = status);
        },
      );

      print('Sync Complete - Navigating');
      syncComplete = true;
      if (mounted) {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => const PokemonListScreen()),
              (route) => false,
        );
      }
    } catch (e, st) {
      print('SYNC CRASHED: $e');
      print(st);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'KyoDex',
                style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 32),
              Text(_status),
              const SizedBox(height: 16),
              if (_total > 0) LinearProgressIndicator(value: _current / _total),
            ],
          ),
        ),
      ),
    );
  }
}
