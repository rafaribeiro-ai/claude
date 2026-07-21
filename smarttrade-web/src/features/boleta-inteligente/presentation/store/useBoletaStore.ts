import { create } from 'zustand'
import { TradingConstants } from '@/core/constants/tradingConstants'
import type { Result } from '@/core/result/result'
import { instrumentRepository } from '../../data/repositories/instrumentRepositoryImpl'
import type { Instrument } from '../../domain/entities/instrument'
import type { RiskCalculation } from '../../domain/entities/riskCalculation'
import type { TradeDirection } from '../../domain/entities/tradeDirection'
import { calculatePositionRisk } from '../../domain/usecases/calculatePositionRisk'
import { getAvailableInstruments } from '../../domain/usecases/getAvailableInstruments'

interface BoletaState {
  instruments: Instrument[]
  loading: boolean
  selectedInstrument: Instrument | null
  direction: TradeDirection
  entryPrice: number | null
  stopPrice: number | null
  targetPrice: number | null
  forexLotSize: number
  calculation: Result<RiskCalculation> | null

  loadInstruments: () => Promise<void>
  selectInstrument: (instrument: Instrument) => void
  setDirection: (direction: TradeDirection) => void
  setEntryPrice: (value: number | null) => void
  setStopPrice: (value: number | null) => void
  setTargetPrice: (value: number | null) => void
  setForexLotSize: (value: number) => void
}

/**
 * Drives the Smart Order Ticket screen. Every setter re-runs
 * `calculatePositionRisk` so the Risk/Reward panel updates live as the
 * user types, exactly like a real broker ticket.
 */
export const useBoletaStore = create<BoletaState>((set, get) => ({
  instruments: [],
  loading: true,
  selectedInstrument: null,
  direction: 'long',
  entryPrice: null,
  stopPrice: null,
  targetPrice: null,
  forexLotSize: TradingConstants.defaultForexLotSize,
  calculation: null,

  loadInstruments: async () => {
    const result = await getAvailableInstruments(instrumentRepository)
    if (result.ok) {
      set({
        instruments: result.value,
        selectedInstrument: result.value[0] ?? null,
        loading: false,
      })
    } else {
      set({ instruments: [], loading: false })
    }
  },

  selectInstrument: (instrument) => {
    set({ selectedInstrument: instrument })
    recalculate(get, set)
  },

  setDirection: (direction) => {
    set({ direction })
    recalculate(get, set)
  },

  setEntryPrice: (value) => {
    set({ entryPrice: value })
    recalculate(get, set)
  },

  setStopPrice: (value) => {
    set({ stopPrice: value })
    recalculate(get, set)
  },

  setTargetPrice: (value) => {
    set({ targetPrice: value })
    recalculate(get, set)
  },

  setForexLotSize: (value) => {
    set({ forexLotSize: value })
    recalculate(get, set)
  },
}))

function recalculate(
  get: () => BoletaState,
  set: (partial: Partial<BoletaState>) => void,
) {
  const state = get()
  const { selectedInstrument, entryPrice, stopPrice, targetPrice } = state

  if (selectedInstrument == null || entryPrice == null || stopPrice == null || targetPrice == null) {
    set({ calculation: null })
    return
  }

  const calculation = calculatePositionRisk({
    instrument: selectedInstrument,
    direction: state.direction,
    entryPrice,
    stopPrice,
    targetPrice,
    desiredForexLotSize: state.forexLotSize,
  })

  set({ calculation })
}
