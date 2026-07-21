const usdFormatter = new Intl.NumberFormat('en-US', {
  style: 'currency',
  currency: 'USD',
  minimumFractionDigits: 2,
  maximumFractionDigits: 2,
})

export function formatUsd(value: number): string {
  return usdFormatter.format(value)
}

export function formatSignedUsd(value: number): string {
  const formatted = usdFormatter.format(Math.abs(value))
  return value < 0 ? `-${formatted}` : `+${formatted}`
}
