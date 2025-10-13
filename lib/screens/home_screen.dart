import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'stock_detail_screen.dart';
import '../models/stock.dart';
import '../utils/mock_data.dart';
import '../widgets/settings_modal.dart';

class HomeScreen extends StatefulWidget {
  final Function(ThemeMode) themeModeSetter;
  final ThemeMode currentThemeMode;
  final Function(Duration) refreshIntervalSetter;
  final Duration currentRefreshInterval;
  final Function(String) currencySetter;
  final String currentCurrency;

  const HomeScreen({
    super.key,
    required this.themeModeSetter,
    required this.currentThemeMode,
    required this.refreshIntervalSetter,
    required this.currentRefreshInterval,
    required this.currencySetter,
    required this.currentCurrency,
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Stock> _stocks = [];
  List<Stock> filtered = [];
  String _query = '';
  Duration _refreshInterval = const Duration(seconds: 5);
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _stocks = generateMockStocks(20);
    filtered = _stocks;
    _startUpdates();
  }

  void _startUpdates() {
    _timer?.cancel();
    _timer = Timer.periodic(_refreshInterval, (_) {
      setState(() {
        final random = Random();

        for (var stock in _stocks) {
          // Keep prices fluctuating around their previousClose
          final double direction = random.nextBool() ? 1 : -1; // up or down
          final double volatility = random.nextDouble() * 25; // more movement
          // random range
          final double delta = direction * volatility;

          // Randomly move price a bit around previous close
          stock.price = (stock.previousClose + delta).clamp(1, double.infinity);
        }

        // Re-filter list if user is searching
        filtered = _stocks
            .where((s) =>
        s.symbol.toLowerCase().contains(_query.toLowerCase()) ||
            s.name.toLowerCase().contains(_query.toLowerCase()))
            .toList();
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
    return Scaffold(
      appBar: AppBar(
        title: const Text('Market Watch'),
        actions: [
          IconButton(icon: const Icon(Icons.settings), onPressed: _openSettings),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8),
            child: TextField(
              decoration: const InputDecoration(
                prefixIcon: Icon(Icons.search),
                hintText: 'Search stocks',
              ),
              onChanged: (v) {
                setState(() {
                  _query = v;
                  filtered = _stocks
                      .where((s) =>
                  s.symbol.toLowerCase().contains(v.toLowerCase()) ||
                      s.name.toLowerCase().contains(v.toLowerCase()))
                      .toList();
                });
              },
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: filtered.length,
              itemBuilder: (context, index) {
                final s = filtered[index];
                final change = s.changePercent;
                return ListTile(
                  leading: CircleAvatar(
                    backgroundColor: Colors.blueGrey.shade50,
                    child: Text(
                      s.symbol.substring(0, 2),
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                  title: Text(
                    '${s.symbol} — ${s.name}',
                    overflow: TextOverflow.ellipsis,
                  ),
                  subtitle: Row(
                    children: [
                      Text(
                        'Price: ${_formatPrice(s.price)} ',
                        style: const TextStyle(fontWeight: FontWeight.w500),
                      ),
                      const SizedBox(width: 4),
                      Icon(
                        change >= 0 ? Icons.arrow_drop_up : Icons.arrow_drop_down,
                        color: change >= 0 ? Colors.green : Colors.red,
                      ),
                      Text(
                        '${change.toStringAsFixed(2)}%',
                        style: TextStyle(
                          color: change >= 0 ? Colors.green : Colors.red,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  trailing: const Icon(Icons.chevron_right),
                  tileColor: change >= 0
                      ? Colors.green.withOpacity(0.05)
                      : Colors.red.withOpacity(0.05),
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => StockDetailScreen(
                        stock: s,
                        currency: widget.currentCurrency,
                      ),
                    ),
                  ),
                );

              },
            ),
          ),
        ],
      ),
    );
  }

  String _formatPrice(double p) =>
      widget.currentCurrency == 'USD'
          ? '\$${p.toStringAsFixed(2)}'
          : '₹${p.toStringAsFixed(2)}';

  void _openSettings() async {
    final result = await showModalBottomSheet<Map<String, dynamic>>(
      context: context,
      builder: (_) => SettingsModal(
        initialTheme: widget.currentThemeMode,
        initialInterval: _refreshInterval,
        initialCurrency: widget.currentCurrency,
      ),
    );

    if (result != null) {
      if (result.containsKey('theme')) widget.themeModeSetter(result['theme']);
      if (result.containsKey('interval')) {
        setState(() => _refreshInterval = result['interval']);
        widget.refreshIntervalSetter(_refreshInterval);
        _startUpdates();
      }
      if (result.containsKey('currency')) widget.currencySetter(result['currency']);
    }
  }
}
