import { create } from 'zustand'
import { macroNewsRepository } from '../../data/repositories/macroNewsRepositoryImpl'
import { chartAnnotationRepository } from '../../data/repositories/chartAnnotationRepositoryImpl'
import type { ChartAnnotation } from '../../domain/entities/chartAnnotation'
import type { ChartDisplayMode } from '../../domain/entities/chartDisplayMode'
import type { MacroNewsHeadline } from '../../domain/entities/macroNewsHeadline'
import { getChartAnnotations } from '../../domain/usecases/getChartAnnotations'

interface ChartState {
  displayMode: ChartDisplayMode
  headlines: MacroNewsHeadline[]
  annotationsBySymbol: Record<string, ChartAnnotation[]>

  setDisplayMode: (mode: ChartDisplayMode) => void
  loadHeadlines: () => Promise<void>
  loadAnnotations: (instrumentSymbol: string) => Promise<void>
}

export const useChartStore = create<ChartState>((set) => ({
  displayMode: 'time',
  headlines: [],
  annotationsBySymbol: {},

  setDisplayMode: (mode) => set({ displayMode: mode }),

  loadHeadlines: async () => {
    const result = await macroNewsRepository.getLatestHeadlines()
    if (result.ok) set({ headlines: result.value })
  },

  loadAnnotations: async (instrumentSymbol) => {
    const result = await getChartAnnotations(chartAnnotationRepository, instrumentSymbol)
    if (result.ok) {
      set((state) => ({
        annotationsBySymbol: { ...state.annotationsBySymbol, [instrumentSymbol]: result.value },
      }))
    }
  },
}))
