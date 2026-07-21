import { useEffect, useState } from 'react'
import { useBoletaStore } from '@/features/boleta-inteligente/presentation/store/useBoletaStore'
import { AddJournalEntryForm } from '../components/AddJournalEntryForm'
import { JournalEntryCard } from '../components/JournalEntryCard'
import { useJournalStore } from '../store/useJournalStore'

export function TradingJournalPage() {
  const { entries, loading, loadEntries } = useJournalStore()
  const loadInstruments = useBoletaStore((state) => state.loadInstruments)
  const [isFormOpen, setFormOpen] = useState(false)

  useEffect(() => {
    loadEntries()
    loadInstruments()
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, [])

  return (
    <div className="relative mx-auto flex h-full max-w-xl flex-col p-4 pb-24">
      <div className="flex items-center justify-between">
        <h1 className="text-xl font-bold text-text-primary">Diário de Trading</h1>
        <button
          type="button"
          onClick={() => setFormOpen(true)}
          className="flex h-9 w-9 items-center justify-center rounded-full bg-accent text-lg font-bold text-white"
          aria-label="Registrar operação"
        >
          +
        </button>
      </div>

      {loading ? (
        <p className="mt-6 text-sm text-text-secondary">Carregando…</p>
      ) : entries.length === 0 ? (
        <p className="mt-6 text-center text-sm text-text-secondary">
          Nenhuma operação registrada ainda.
          <br />
          Use a Boleta Inteligente e registre sua próxima entrada aqui.
        </p>
      ) : (
        <div className="mt-4 flex flex-col gap-2.5">
          {entries.map((entry) => (
            <JournalEntryCard key={entry.id} entry={entry} />
          ))}
        </div>
      )}

      {isFormOpen && <AddJournalEntryForm onClose={() => setFormOpen(false)} />}
    </div>
  )
}
