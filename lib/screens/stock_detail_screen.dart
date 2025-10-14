import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import '../models/stock.dart';
import '../widgets/line_chart.dart';
import 'package:intl/intl.dart';

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
    _timer = Timer.periodic(const Duration(seconds: 5), (_) {
      setState(() {
        final rnd = Random();
        final change = (rnd.nextDouble() - 0.5) * 2;
        _stock.price = (_stock.price + change).clamp(1, double.infinity);
        _stock.intraday = [..._stock.intraday.skip(1), _stock.price];
        _stock.high = max(_stock.high, _stock.price);
        _stock.low = min(_stock.low, _stock.price);
      });
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  String _formatNumber(num value) {
    final formatter = NumberFormat.decimalPattern('en_IN');
    return formatter.format(value);
  }

  String _formatPrice(double p) =>
      widget.currency == 'USD' ? '\$${p.toStringAsFixed(2)}' : '₹${p.toStringAsFixed(2)}';

  @override
  Widget build(BuildContext context) {
    final change = _stock.changePercent;
    final isUp = change >= 0;
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          _stock.symbol,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        elevation: 1,
      ),
      body: Container(
        color: theme.scaffoldBackgroundColor,
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ---- Stock Name and Price ----
              Text(
                _stock.name,
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  fontSize: 22,
                ),
              ),
              const SizedBox(height: 12),

              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 400),
                    transitionBuilder: (child, anim) =>
                        FadeTransition(opacity: anim, child: child),
                    child: Text(
                      _formatPrice(_stock.price),
                      key: ValueKey(_stock.price),
                      style: TextStyle(
                        fontSize: 30,
                        color: isUp ? Colors.green : Colors.red,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Icon(
                    isUp ? Icons.arrow_drop_up : Icons.arrow_drop_down,
                    color: isUp ? Colors.green : Colors.red,
                    size: 32,
                  ),
                  Text(
                    '${change.toStringAsFixed(2)}%',
                    style: TextStyle(
                      color: isUp ? Colors.green : Colors.red,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                'Last updated: ${DateFormat('hh:mm:ss a').format(DateTime.now())}',
                style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
              ),

              const SizedBox(height: 24),

              // ---- Chart Section ----
              Container(
                decoration: BoxDecoration(
                  color: theme.cardColor,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.08),
                      blurRadius: 6,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Price Trends',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 12),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: SizedBox(
                        height: 200,
                        child: SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          physics: const BouncingScrollPhysics(),
                          child: SizedBox(
                            width: max(MediaQuery.of(context).size.width, 600),
                            child: LineChart(
                              points: _stock.intraday,
                              lineColor: isUp ? Colors.green : Colors.red,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),


              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [theme.cardColor, theme.cardColor.withOpacity(0.9)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(18),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.08),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                  border: Border.all(
                    color: Colors.grey.withOpacity(0.2),
                    width: 0.8,
                  ),
                ),
                padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: const [
                        Icon(Icons.bar_chart_rounded, size: 22, color: Colors.blueAccent),
                        SizedBox(width: 8),
                        Text(
                          'Market Information',
                          style: TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 18,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 18),


                    GridView.count(
                      crossAxisCount: 2,
                      shrinkWrap: true,
                      mainAxisSpacing: 18,
                      crossAxisSpacing: 20,
                      childAspectRatio: 2.5,
                      physics: const NeverScrollableScrollPhysics(),
                      children: [
                        _infoTileWithIcon(
                          icon: Icons.trending_up_rounded,
                          title: 'Open',
                          value: _stock.intraday.first.toStringAsFixed(2),
                          color: Colors.teal,
                        ),
                        _infoTileWithIcon(
                          icon: Icons.arrow_circle_up_rounded,
                          title: 'High',
                          value: _stock.high.toStringAsFixed(2),
                          color: Colors.green,
                        ),
                        _infoTileWithIcon(
                          icon: Icons.arrow_circle_down_rounded,
                          title: 'Low',
                          value: _stock.low.toStringAsFixed(2),
                          color: Colors.redAccent,
                        ),
                        _infoTileWithIcon(
                          icon: Icons.refresh_rounded,
                          title: 'Prev Close',
                          value: _stock.previousClose.toStringAsFixed(2),
                          color: Colors.blueAccent,
                        ),
                        _infoTileWithIcon(
                          icon: Icons.stacked_line_chart_rounded,
                          title: 'Volume',
                          value: _formatNumber(_stock.volume),
                          color: Colors.deepPurple,
                        ),
                        _infoTileWithIcon(
                          icon: Icons.pie_chart_rounded,
                          title: 'Market Cap',
                          value: _formatNumber(_stock.marketCap),
                          color: Colors.orangeAccent,
                        ),
                      ],
                    ),
                  ],
                ),
              )

            ],
          ),
        ),
      ),
    );
  }

  Widget _infoTile(String title, String value) {
    return SizedBox(
      width: 130,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
              style: const TextStyle(
                fontSize: 12,
                color: Colors.grey,
              )),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 15,
            ),
          ),
        ],
      ),
    );
  }

  Widget _infoTileWithIcon({
    required IconData icon,
    required String title,
    required String value,
    required Color color,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: color.withOpacity(0.07),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.15), width: 1),
      ),
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: color.withOpacity(0.15),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 16, color: color),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.grey,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  value,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

}
