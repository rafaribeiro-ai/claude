import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:smarttrade_app/app/theme/app_colors.dart';
import 'package:smarttrade_app/features/boleta_inteligente/domain/entities/instrument.dart';
import 'package:smarttrade_app/features/boleta_inteligente/domain/entities/trade_direction.dart';
import 'package:smarttrade_app/features/boleta_inteligente/domain/usecases/calculate_position_risk_usecase.dart';
import 'package:smarttrade_app/features/boleta_inteligente/presentation/providers/instrument_providers.dart';
import 'package:smarttrade_app/features/trading_journal/domain/entities/journal_entry.dart';
import 'package:smarttrade_app/features/trading_journal/domain/entities/trade_outcome.dart';
import 'package:smarttrade_app/features/trading_journal/presentation/providers/journal_providers.dart';
import 'package:smarttrade_app/features/trading_journal/presentation/widgets/journal_entry_card.dart';
import 'package:uuid/uuid.dart';

/// "Diário de Trading" - a saved, offline log of every position the user
/// entered. New entries are typically built straight from a completed
/// Boleta Inteligente calculation, so the risk math shown here always
/// matches what the user saw before pulling the trigger.
class TradingJournalScreen extends ConsumerWidget {
  const TradingJournalScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final entriesAsync = ref.watch(journalEntriesProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Diário de Trading')),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _openAddEntrySheet(context, ref),
        child: const Icon(Icons.add),
      ),
      body: entriesAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stackTrace) => const Center(
          child: Text(
            'Não foi possível carregar o diário.',
            style: TextStyle(color: AppColors.loss),
          ),
        ),
        data: (entries) {
          if (entries.isEmpty) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(24),
                child: Text(
                  'Nenhuma operação registrada ainda.\nUse a Boleta Inteligente e registre sua próxima entrada aqui.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: AppColors.textSecondary),
                ),
              ),
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 88),
            itemCount: entries.length,
            separatorBuilder: (_, _) => const SizedBox(height: 10),
            itemBuilder: (context, index) => JournalEntryCard(entry: entries[index]),
          );
        },
      ),
    );
  }

  void _openAddEntrySheet(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surface,
      builder: (context) => const _AddJournalEntrySheet(),
    );
  }
}

class _AddJournalEntrySheet extends HookConsumerWidget {
  const _AddJournalEntrySheet();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final instrumentsAsync = ref.watch(availableInstrumentsProvider);
    final selectedInstrument = useState<Instrument?>(null);
    final direction = useState(TradeDirection.long);
    final entryController = useTextEditingController();
    final stopController = useTextEditingController();
    final targetController = useTextEditingController();
    final notesController = useTextEditingController();

    return Padding(
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
        top: 16,
        bottom: MediaQuery.of(context).viewInsets.bottom + 16,
      ),
      child: instrumentsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, _) => const Text('Erro ao carregar instrumentos.'),
        data: (instruments) {
          selectedInstrument.value ??= instruments.isNotEmpty ? instruments.first : null;

          return SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Registrar operação',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<Instrument>(
                  initialValue: selectedInstrument.value,
                  dropdownColor: AppColors.surfaceElevated,
                  items: [
                    for (final instrument in instruments)
                      DropdownMenuItem(value: instrument, child: Text(instrument.symbol)),
                  ],
                  onChanged: (value) => selectedInstrument.value = value,
                  decoration: const InputDecoration(labelText: 'Ativo'),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: entryController,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  decoration: const InputDecoration(labelText: 'Entrada'),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: stopController,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  decoration: const InputDecoration(labelText: 'Stop Loss'),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: targetController,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  decoration: const InputDecoration(labelText: 'Alvo'),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: notesController,
                  decoration: const InputDecoration(labelText: 'Notas (opcional)'),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed: () => _submit(
                      context: context,
                      ref: ref,
                      instrument: selectedInstrument.value,
                      direction: direction.value,
                      entryText: entryController.text,
                      stopText: stopController.text,
                      targetText: targetController.text,
                      notes: notesController.text,
                    ),
                    child: const Text('Salvar no Diário'),
                  ),
                ),
                const SizedBox(height: 8),
              ],
            ),
          );
        },
      ),
    );
  }

  Future<void> _submit({
    required BuildContext context,
    required WidgetRef ref,
    required Instrument? instrument,
    required TradeDirection direction,
    required String entryText,
    required String stopText,
    required String targetText,
    required String notes,
  }) async {
    final entry = double.tryParse(entryText);
    final stop = double.tryParse(stopText);
    final target = double.tryParse(targetText);

    if (instrument == null || entry == null || stop == null || target == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Preencha entrada, stop e alvo corretamente.')),
      );
      return;
    }

    const useCase = CalculatePositionRiskUseCase();
    final result = useCase(
      CalculatePositionRiskParams(
        instrument: instrument,
        direction: direction,
        entryPrice: entry,
        stopPrice: stop,
        targetPrice: target,
      ),
    );

    result.fold(
      (failure) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(failure.message)),
        );
      },
      (calculation) async {
        final journalEntry = JournalEntry(
          id: const Uuid().v4(),
          instrumentSymbol: instrument.symbol,
          direction: direction,
          entryPrice: entry,
          stopPrice: stop,
          targetPrice: target,
          riskAmount: calculation.riskAmount,
          rewardAmount: calculation.rewardAmount,
          riskRewardRatio: calculation.riskRewardRatio,
          positionSize: calculation.positionSize,
          outcome: TradeOutcome.open,
          openedAt: DateTime.now(),
          notes: notes.isEmpty ? null : notes,
        );

        await ref.read(journalEntriesProvider.notifier).addEntry(journalEntry);
        if (context.mounted) Navigator.of(context).pop();
      },
    );
  }
}
