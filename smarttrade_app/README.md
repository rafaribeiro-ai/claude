# SmartTrade App

MVP de um aplicativo de finanças e trading mobile, construído em Flutter
com Clean Architecture e Riverpod. O foco desta primeira entrega é a
**Boleta Inteligente** (Smart Order Ticket): cálculo dinâmico de
Risco/Retorno com a "Regra de Ouro" de 1 contrato por operação em
mercados futuros.

## Arquitetura

Cada feature segue Clean Architecture em três camadas:

```
lib/
  app/                    # tema, shell de navegação
  core/                   # erros, use case base, banco local, DI raiz
  features/
    boleta_inteligente/   # Smart Order Ticket (feature principal)
      domain/              entidades, contratos de repositório, use cases
      data/                modelos, datasources, implementação de repositório
      presentation/        providers (Riverpod), telas, widgets
    chart_analysis/        gráfico + marcações de estudo + tarja macro
    trading_journal/        diário de trading e preferências de ativos offline
```

## Regras de negócio implementadas

- **Regra de Ouro**: `CalculatePositionRiskUseCase` nunca lê uma
  quantidade de contratos futuros vinda do usuário — o parâmetro nem
  existe. Futuros são sempre calculados com 1 contrato fixo
  (`TradingConstants.fixedFuturesContractQuantity`).
- **Futuros** (ex.: Nasdaq/MNQ, Gold/MGC): risco calculado em
  ticks/pontos × valor do tick.
- **Forex/metais** (ex.: XAU/USD): risco calculado em pips × tamanho do
  contrato × lote (fracionado).
- **Gráfico**: interfaces (`CandleChartEngine`, `ChartDisplayMode`,
  `RenkoSettings`) preparadas para receber um motor de gráfico Renko no
  futuro, sem alterar a tela.
- **Marcações de estudo**: zonas de suporte/resistência, canais de
  referência, expansão de canais e anotações de ciclo de mercado,
  persistidas em sqlite.
- **Diário de trading** e **preferências de ativos**: persistidos
  offline via sqflite.

## Rodando o projeto

```bash
flutter pub get
flutter analyze
flutter test
flutter run
```
