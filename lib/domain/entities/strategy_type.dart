enum StrategyType {
  movingAverage('Moving Average'),
  rsi('RSI'),
  macd('MACD'),
  bollingerBands('Bollinger Bands'),
  volumeBreakout('Volume Breakout');

  final String displayName;

  const StrategyType(this.displayName);
}
