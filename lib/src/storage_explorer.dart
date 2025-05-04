import 'package:flutter/foundation.dart' show kDebugMode;
import 'package:flutter/material.dart';
import 'package:storage_explorer/src/storage_explorer_view.dart';

/// A widget that provides a floating action button to open the SQLite database explorer.
///
/// This widget is only visible in debug mode and provides a convenient way to inspect
/// the contents of a SQLite database during development.
class StorageExplorer extends StatelessWidget {
  /// The path to the SQLite database file.
  final String databasePath;

  /// Creates a [StorageExplorer] widget.
  ///
  /// [databasePath] must not be empty.
  const StorageExplorer({super.key, required this.databasePath});

  @override
  Widget build(BuildContext context) {
    assert(databasePath.isNotEmpty, 'databasePath must not be empty');

    if (!kDebugMode) return const SizedBox.shrink();

    return FloatingActionButton(
      heroTag: 'storage_explorer_fab',
      child: const Icon(Icons.storage),
      onPressed: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => StorageExplorerView(databasePath: databasePath),
          ),
        );
      },
    );
  }
}
