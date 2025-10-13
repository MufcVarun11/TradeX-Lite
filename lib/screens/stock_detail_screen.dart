import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import '../models/stock.dart';
import '../widgets/line_chart.dart';

class StockDetailScreen extends StatefulWidget {
  final Stock stock;
  final String currency;

  const StockDetailScreen({
    super.key,
    required this.stock,
    required this.currency,
  });

  @override
  State<StockDetailScreen> createState() => _StockDetailScreenState();
}

class _StockDetailScreenState extends State<StockDetailScreen> {
  late Stock _stock;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _stock = widget.stock;
    _startMockUpdates();
  }
  void _startMockUpdates() {
    // update every 5 seconds
    _timer = Timer.periodic(const Duration(seconds: 5), (_) {
      setState(() {
        final rnd = Random();
        final change = (rnd.nextDouble() - 0.5) * 2;
        _stock.price = (_stock.price + change).clamp(1, double.infinity);
        _stock.intraday = [..._stock.intraday.skip(1), _stock.price];
      });
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final change = _stock.changePercent;

    return Scaffold(
      appBar: AppBar(title: Text(_stock.symbol)),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              _stock.name,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 400),
                  transitionBuilder: (child, anim) => FadeTransition(opacity: anim, child: child),
                  child: Text(
                    _formatPrice(_stock.price),
                    key: ValueKey(_stock.price),
                    style: TextStyle(
                      fontSize: 28,
                      color: change >= 0 ? Colors.green : Colors.red,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Icon(
                  change >= 0 ? Icons.arrow_drop_up : Icons.arrow_drop_down,
                  color: change >= 0 ? Colors.green : Colors.red,
                  size: 32,
                ),
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 400),
                  transitionBuilder: (child, anim) => FadeTransition(opacity: anim, child: child),
                  child: Text(
                    '${change.toStringAsFixed(2)}%',
                    key: ValueKey(change),
                    style: TextStyle(
                      color: change >= 0 ? Colors.green : Colors.red,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            const Text(
              'Price Trends',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 20),
            SizedBox(
              height: 120,
              child: LineChart(
                points: _stock.intraday,
                lineColor: change >= 0 ? Colors.green : Colors.red,
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatPrice(double p) =>
      widget.currency == 'USD' ? '\$${p.toStringAsFixed(2)}' : '₹${p.toStringAsFixed(2)}';
}
