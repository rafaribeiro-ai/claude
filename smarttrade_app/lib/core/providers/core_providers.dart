import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:smarttrade_app/core/database/app_database.dart';
import 'package:uuid/uuid.dart';

/// Dependency injection root for cross-feature singletons.
///
/// [databaseProvider] is deliberately left unimplemented here: the
/// database must be opened asynchronously before the widget tree exists,
/// so `main.dart` awaits [AppDatabase.open] and injects the instance via
/// `ProviderScope(overrides: [databaseProvider.overrideWithValue(db)])`.
/// Every repository that needs sqflite reads it from this single
/// provider instead of opening its own connection.
final databaseProvider = Provider<AppDatabase>((ref) {
  throw UnimplementedError(
    'databaseProvider must be overridden with a live AppDatabase in main().',
  );
});

final uuidProvider = Provider<Uuid>((ref) => const Uuid());
