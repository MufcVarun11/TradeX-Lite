class Stock {
  final String symbol;
  final String name;
  double price;
  double previousClose;
  double high;
  double low;
  int volume;
  double marketCap;
  List<double> intraday;

  Stock({
    required this.symbol,
    required this.name,
    required this.price,
    required this.previousClose,
    required this.high,
    required this.low,
    required this.volume,
    required this.marketCap,
    required this.intraday,
  });

  double get changePercent {
    if (previousClose == 0) return 0;
    return ((price - previousClose) / previousClose) * 100;
  }
}
