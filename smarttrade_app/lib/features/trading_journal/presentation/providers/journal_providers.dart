import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:smarttrade_app/core/providers/core_providers.dart';
import 'package:smarttrade_app/core/usecase/usecase.dart';
import 'package:smarttrade_app/features/trading_journal/data/datasources/asset_preference_local_datasource.dart';
import 'package:smarttrade_app/features/trading_journal/data/datasources/journal_local_datasource.dart';
import 'package:smarttrade_app/features/trading_journal/data/repositories/asset_preference_repository_impl.dart';
import 'package:smarttrade_app/features/trading_journal/data/repositories/journal_repository_impl.dart';
import 'package:smarttrade_app/features/trading_journal/domain/entities/journal_entry.dart';
import 'package:smarttrade_app/features/trading_journal/domain/repositories/asset_preference_repository.dart';
import 'package:smarttrade_app/features/trading_journal/domain/repositories/journal_repository.dart';
import 'package:smarttrade_app/features/trading_journal/domain/usecases/add_journal_entry_usecase.dart';
import 'package:smarttrade_app/features/trading_journal/domain/usecases/get_journal_entries_usecase.dart';

final journalLocalDataSourceProvider = Provider<JournalLocalDataSource>((ref) {
  return JournalLocalDataSource(ref.watch(databaseProvider).instance);
});

final journalRepositoryProvider = Provider<JournalRepository>((ref) {
  return JournalRepositoryImpl(ref.watch(journalLocalDataSourceProvider));
});

final getJournalEntriesUseCaseProvider = Provider<GetJournalEntriesUseCase>((ref) {
  return GetJournalEntriesUseCase(ref.watch(journalRepositoryProvider));
});

final addJournalEntryUseCaseProvider = Provider<AddJournalEntryUseCase>((ref) {
  return AddJournalEntryUseCase(ref.watch(journalRepositoryProvider));
});

final assetPreferenceLocalDataSourceProvider =
    Provider<AssetPreferenceLocalDataSource>((ref) {
  return AssetPreferenceLocalDataSource(ref.watch(databaseProvider).instance);
});

final assetPreferenceRepositoryProvider = Provider<AssetPreferenceRepository>((ref) {
  return AssetPreferenceRepositoryImpl(ref.watch(assetPreferenceLocalDataSourceProvider));
});

final journalEntriesProvider =
    AsyncNotifierProvider<JournalEntriesNotifier, List<JournalEntry>>(
  JournalEntriesNotifier.new,
);

/// Loads the offline trading journal and lets the ticket/journal
/// screens append a new entry without a full refetch.
class JournalEntriesNotifier extends AsyncNotifier<List<JournalEntry>> {
  @override
  Future<List<JournalEntry>> build() async {
    final result = await ref.read(getJournalEntriesUseCaseProvider).call(const NoParams());
    return result.fold((failure) => <JournalEntry>[], (data) => data);
  }

  Future<void> addEntry(JournalEntry entry) async {
    final result = await ref
        .read(addJournalEntryUseCaseProvider)
        .call(AddJournalEntryParams(entry));

    result.fold(
      (failure) => null,
      (_) {
        final current = state.value ?? const [];
        state = AsyncData([entry, ...current]);
      },
    );
  }
}
