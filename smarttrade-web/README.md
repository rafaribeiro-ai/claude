# SmartTrade App (Web)

MVP de um aplicativo de finanças e trading web, construído com React,
TypeScript e Vite, seguindo Clean Architecture. O foco desta primeira
entrega é a **Boleta Inteligente** (Smart Order Ticket): cálculo
dinâmico de Risco/Retorno com a "Regra de Ouro" de 1 contrato por
operação em mercados futuros.

100% client-side: não há backend. A persistência offline (Diário de
Trading, preferências de ativos, marcações de gráfico) usa IndexedDB via
[Dexie](https://dexie.org/).

## Stack

- **React 19 + TypeScript + Vite** - SPA client-side.
- **React Router** (`HashRouter`) - navegação entre as 3 telas sem
  precisar de configuração de servidor.
- **Zustand** - estado por feature, um store por domínio.
- **Dexie (IndexedDB)** - persistência local offline.
- **lightweight-charts** - motor de gráfico de velas.
- **Tailwind CSS v4** - tema escuro sóbrio e profissional.
- **Vitest** - testes de unidade da camada de domínio.

## Arquitetura

Cada feature segue Clean Architecture em três camadas:

```
src/
  app/                     # shell da aplicação, rotas, navegação
  core/                    # Result/Failure, banco (Dexie), constantes, utils
  features/
    boleta-inteligente/    # Smart Order Ticket (feature principal)
      domain/                entidades, contratos de repositório, casos de uso
      data/                  datasources, implementação de repositório
      presentation/          stores (Zustand), páginas, componentes
    chart-analysis/         gráfico + marcações de estudo + tarja macro
    trading-journal/         diário de trading e preferências de ativos offline
```

## Regras de negócio implementadas

- **Regra de Ouro**: `calculatePositionRisk` nunca lê uma quantidade de
  contratos futuros vinda do usuário - o parâmetro nem existe no tipo.
  Futuros são sempre calculados com 1 contrato fixo
  (`TradingConstants.fixedFuturesContractQuantity`).
- **Futuros** (ex.: Nasdaq/MNQ, Gold/MGC): risco calculado em
  ticks/pontos × valor do tick.
- **Forex/metais** (ex.: XAU/USD): risco calculado em pips × tamanho do
  contrato × lote (fracionado).
- **Gráfico**: `CandleChartEngine` é o único ponto de acoplamento com a
  biblioteca de gráficos: hoje renderiza velas com lightweight-charts;
  `ChartDisplayMode`/`RenkoSettings` já modelam o modo atemporal (Renko)
  para um motor dedicado futuro, sem alterar a tela.
- **Marcações de estudo**: zonas de suporte/resistência, canais de
  referência, expansão de canais e anotações de ciclo de mercado,
  persistidas no IndexedDB.
- **Diário de trading** e **preferências de ativos**: persistidos
  offline via IndexedDB (Dexie).

## Rodando o projeto

```bash
npm install
npm run dev        # http://localhost:5173
npm run build       # build de produção em dist/
npm run test         # testes de unidade (Vitest)
npm run lint          # oxlint
```

Como é 100% client-side, `npm run build` gera um `dist/` estático que
pode ser hospedado em qualquer serviço de arquivos estáticos (Vercel,
Netlify, GitHub Pages, S3, etc.) - não precisa de servidor Node em
produção.
