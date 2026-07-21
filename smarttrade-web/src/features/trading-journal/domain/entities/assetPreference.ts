/**
 * Per-instrument preferences persisted offline (favorited assets, the
 * last forex lot size used, display order in pickers).
 */
export interface AssetPreference {
  instrumentSymbol: string
  isFavorite: boolean
  defaultForexLotSize?: number
  displayOrder: number
}
