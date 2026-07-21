import { NavLink, Route, HashRouter, Routes } from 'react-router-dom'
import { SmartOrderTicketPage } from '@/features/boleta-inteligente/presentation/pages/SmartOrderTicketPage'
import { TradingChartPage } from '@/features/chart-analysis/presentation/pages/TradingChartPage'
import { TradingJournalPage } from '@/features/trading-journal/presentation/pages/TradingJournalPage'

const NAV_ITEMS = [
  { to: '/', label: 'Boleta', icon: '🧾' },
  { to: '/grafico', label: 'Gráfico', icon: '📈' },
  { to: '/diario', label: 'Diário', icon: '📓' },
]

export function App() {
  return (
    <HashRouter>
      <div className="flex h-screen flex-col bg-background text-text-primary">
        <main className="min-h-0 flex-1 overflow-y-auto">
          <Routes>
            <Route path="/" element={<SmartOrderTicketPage />} />
            <Route path="/grafico" element={<TradingChartPage />} />
            <Route path="/diario" element={<TradingJournalPage />} />
          </Routes>
        </main>

        <nav className="flex shrink-0 border-t border-border bg-surface">
          {NAV_ITEMS.map((item) => (
            <NavLink
              key={item.to}
              to={item.to}
              end={item.to === '/'}
              className={({ isActive }) =>
                `flex flex-1 flex-col items-center gap-0.5 py-2.5 text-[11px] font-medium ${
                  isActive ? 'text-accent' : 'text-text-secondary'
                }`
              }
            >
              <span className="text-lg" aria-hidden="true">
                {item.icon}
              </span>
              {item.label}
            </NavLink>
          ))}
        </nav>
      </div>
    </HashRouter>
  )
}
