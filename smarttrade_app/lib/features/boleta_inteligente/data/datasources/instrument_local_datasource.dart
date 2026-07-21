import 'package:smarttrade_app/features/boleta_inteligente/domain/entities/instrument.dart';

/// MVP catalog: a hard-coded seed list of instruments.
///
/// Real contract specs (tick size/value, pip size, lot size) so the risk
/// math is accurate out of the box. Swapping this for a remote/broker-fed
/// catalog later only touches this file - the domain and presentation
/// layers depend on [InstrumentRepository], not on where the list comes
/// from.
abstract final class InstrumentLocalDataSource {
  static final List<Instrument> seedInstruments = [
    const FuturesInstrument(
      symbol: 'MNQ',
      displayName: 'Micro E-mini Nasdaq-100',
      exchange: 'CME',
      tickSize: 0.25,
      tickValue: 0.50,
    ),
    const FuturesInstrument(
      symbol: 'NQ',
      displayName: 'E-mini Nasdaq-100',
      exchange: 'CME',
      tickSize: 0.25,
      tickValue: 5.00,
    ),
    const FuturesInstrument(
      symbol: 'MGC',
      displayName: 'Micro Gold Futures',
      exchange: 'COMEX',
      tickSize: 0.10,
      tickValue: 1.00,
    ),
    const ForexInstrument(
      symbol: 'XAUUSD',
      displayName: 'Ouro (Spot)',
      exchange: 'OTC',
      pipSize: 0.01,
      contractSize: 100,
    ),
    const ForexInstrument(
      symbol: 'EURUSD',
      displayName: 'Euro / Dólar',
      exchange: 'OTC',
      pipSize: 0.0001,
      contractSize: 100000,
    ),
  ];
}
