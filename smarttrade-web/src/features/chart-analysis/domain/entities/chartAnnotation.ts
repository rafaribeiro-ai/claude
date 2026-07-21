/** Whether a {@link SupportResistanceZone} is acting as a floor or a ceiling. */
export type ZoneKind = 'support' | 'resistance'

interface BaseAnnotation {
  id: string
  instrumentSymbol: string
  createdAt: Date
  label?: string
  note?: string
}

/** A horizontal price band the user marked as support or resistance. */
export interface SupportResistanceZone extends BaseAnnotation {
  type: 'support_resistance'
  kind: ZoneKind
  priceHigh: number
  priceLow: number
}

/**
 * Two parallel trendlines (upper/lower bound) drawn between two points
 * in time, used as a reference for the prevailing trend structure.
 */
export interface ReferenceChannel extends BaseAnnotation {
  type: 'reference_channel'
  anchorTime: Date
  endTime: Date
  upperPriceStart: number
  lowerPriceStart: number
  upperPriceEnd: number
  lowerPriceEnd: number
}

/**
 * A projected expansion of an existing {@link ReferenceChannel} (e.g. a
 * Fibonacci-style multiple of the channel width projected forward in
 * time), kept as its own annotation so the original channel is never
 * mutated once drawn.
 */
export interface ChannelExpansion extends BaseAnnotation {
  type: 'channel_expansion'
  /** `ReferenceChannel.id` this expansion was projected from. */
  sourceChannelId: string
  /** Multiple of the source channel's width (e.g. 1.618). */
  expansionFactor: number
  projectedTime: Date
  projectedUpperPrice: number
  projectedLowerPrice: number
}

/**
 * A temporal marker used to track recurring market cycles (e.g. "this
 * looks like the start of a new accumulation cycle").
 */
export interface CycleAnnotation extends BaseAnnotation {
  type: 'cycle'
  cycleStart: Date
  cycleEnd?: Date
  expectedCycleLengthDays?: number
}

/**
 * A saved study mark on an instrument's chart.
 *
 * A discriminated union (on `type`) over the four study types the MVP
 * needs to persist: price zones, reference channels, channel
 * expansions, and cycle-tracking time markers. Every concrete variant is
 * stored in the same IndexedDB `chartAnnotations` table (see
 * `core/persistence/db.ts`) since Dexie is schema-less per record, so
 * adding a fifth study type later doesn't require a migration.
 */
export type ChartAnnotation =
  | SupportResistanceZone
  | ReferenceChannel
  | ChannelExpansion
  | CycleAnnotation
