import 'dart:math';
import '../models/stock.dart';

List<Stock> generateMockStocks([int count = 20]) {
  final random = Random();

  final List<Map<String, String>> stockNames = [
    {'symbol': 'RELIANCE', 'name': 'Reliance Industries'},
    {'symbol': 'TCS', 'name': 'Tata Consultancy Services'},
    {'symbol': 'INFY', 'name': 'Infosys'},
    {'symbol': 'HDFCBANK', 'name': 'HDFC Bank'},
    {'symbol': 'ICICIBANK', 'name': 'ICICI Bank'},
    {'symbol': 'SBIN', 'name': 'State Bank of India'},
    {'symbol': 'BHARTIARTL', 'name': 'Bharti Airtel'},
    {'symbol': 'ITC', 'name': 'ITC Limited'},
    {'symbol': 'WIPRO', 'name': 'Wipro'},
    {'symbol': 'HCLTECH', 'name': 'HCL Technologies'},
    {'symbol': 'AXISBANK', 'name': 'Axis Bank'},
    {'symbol': 'LT', 'name': 'Larsen & Toubro'},
    {'symbol': 'ADANIENT', 'name': 'Adani Enterprises'},
    {'symbol': 'MARUTI', 'name': 'Maruti Suzuki'},
    {'symbol': 'TITAN', 'name': 'Titan Company'},
    {'symbol': 'BAJFINANCE', 'name': 'Bajaj Finance'},
    {'symbol': 'ONGC', 'name': 'Oil & Natural Gas Corp'},
    {'symbol': 'COALINDIA', 'name': 'Coal India'},
    {'symbol': 'HINDUNILVR', 'name': 'Hindustan Unilever'},
    {'symbol': 'ASIANPAINT', 'name': 'Asian Paints'},
  ];

  stockNames.shuffle(random);

  return stockNames.take(count).map((data) {
    final base = 100 + random.nextDouble() * 2500;
    final previous = base - random.nextDouble() * 50;

    // ✅ Ensure every value is a double
    final intraday = List<double>.generate(30, (i) {
      final change = (random.nextDouble() - 0.5) * 50;
      return (base + change).clamp(1, double.infinity).toDouble();
    });

    return Stock(
      symbol: data['symbol']!,
      name: data['name']!,
      price: intraday.last,
      previousClose: previous,
      intraday: intraday,
    );
  }).toList();
}
