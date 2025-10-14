import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'stock_detail_screen.dart';
import '../models/stock.dart';
import '../utils/mock_data.dart';
import '../widgets/settings_modal.dart';
import 'package:hive/hive.dart';

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
  List<Stock> _filtered = [];
  String _query = '';
  Duration _refreshInterval = const Duration(seconds: 5);
  Timer? _timer;
  final ScrollController _scrollController = ScrollController();
  bool _isLoadingMore = false;
  int _page = 0;

  @override
  void initState() {
    super.initState();
    _loadInitialStocks();
    _scrollController.addListener(_onScroll);

    _refreshInterval = widget.currentRefreshInterval;
    _startUpdates();
  }

  void _loadInitialStocks() {
    _stocks = generateMockStocks(30, _page * 30);
    _filtered = _stocks;
    _startUpdates();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200 &&
        !_isLoadingMore) {
      _loadMoreStocks();
    }
  }

  Future<void> _loadMoreStocks() async {
    setState(() => _isLoadingMore = true);
    await Future.delayed(const Duration(seconds: 1));
    _page++;
    final newStocks = generateMockStocks(30, _page * 30);
    setState(() {
      _stocks.addAll(newStocks);
      _filterList(_query);
      _isLoadingMore = false;
    });
  }

  void _startUpdates() {
    _timer?.cancel();
    _timer = Timer.periodic(_refreshInterval, (_) {
      setState(() {
        final random = Random();
        for (var stock in _stocks) {
          final direction = random.nextBool() ? 1 : -1;
          final volatility = random.nextDouble() * 15;
          final delta = direction * volatility;
          stock.price = (stock.previousClose + delta).clamp(1, double.infinity);
        }
        _filterList(_query);
      });
    });
  }

  void _filterList(String query) {
    _filtered = _stocks
        .where((s) =>
    s.symbol.toLowerCase().contains(query.toLowerCase()) ||
        s.name.toLowerCase().contains(query.toLowerCase()))
        .toList();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? Colors.grey[900] : Colors.grey[50];

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 1,
        title: const Text('Market Watch', style: TextStyle(fontWeight: FontWeight.bold)),
        actions: [IconButton(icon: const Icon(Icons.settings), onPressed: _openSettings)],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(10.0),
            child: Container(
              decoration: BoxDecoration(
                color: isDark ? Colors.grey[850] : Colors.white,
                borderRadius: BorderRadius.circular(30),
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 5, offset: const Offset(0, 3))],
              ),
              child: TextField(
                decoration: InputDecoration(
                  hintText: 'Search stocks (e.g. RELIANCE, TCS, HDFCBANK)',
                  prefixIcon: const Icon(Icons.search),
                  suffixIcon: _query.isNotEmpty
                      ? IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () {
                      setState(() {
                        _query = '';
                        _filtered = _stocks;
                      });
                    },
                  )
                      : null,
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
                ),
                onChanged: (v) => setState(() {
                  _query = v;
                  _filterList(v);
                }),
              ),
            ),
          ),
          Expanded(
            child: _filtered.isEmpty
                ? const Center(
              child: Text('No stocks found', style: TextStyle(fontSize: 16, color: Colors.grey)),
            )
                : ListView.separated(
              controller: _scrollController,
              itemCount: _filtered.length + (_isLoadingMore ? 1 : 0),
              separatorBuilder: (_, __) => Divider(color: isDark ? Colors.grey[800] : Colors.grey[300], height: 1),
              itemBuilder: (context, index) {
                if (index >= _filtered.length) {
                  return const Padding(
                    padding: EdgeInsets.symmetric(vertical: 20),
                    child: Center(child: CircularProgressIndicator(color: Colors.blueAccent)),
                  );
                }

                final s = _filtered[index];
                final change = s.changePercent;
                final isUp = change >= 0;

                return InkWell(
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => StockDetailScreen(stock: s, currency: widget.currentCurrency),
                    ),
                  ),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeInOut,
                    color: isUp ? Colors.green.withOpacity(0.04) : Colors.red.withOpacity(0.04),
                    padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                    child: Row(
                      children: [
                        CircleAvatar(
                          backgroundColor: isUp ? Colors.green.withOpacity(0.1) : Colors.red.withOpacity(0.1),
                          child: Text(s.symbol.substring(0, 2), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(s.symbol, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                              const SizedBox(height: 4),
                              Text(
                                s.name,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
                              ),
                            ],
                          ),
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(_formatPrice(s.price), style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16)),
                            const SizedBox(height: 3),
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(isUp ? Icons.arrow_drop_up : Icons.arrow_drop_down, color: isUp ? Colors.green : Colors.red, size: 20),
                                Text(
                                  '${change.toStringAsFixed(2)}%',
                                  style: TextStyle(color: isUp ? Colors.green : Colors.red, fontWeight: FontWeight.w600, fontSize: 13),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ],
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

  String _formatPrice(double p) => widget.currentCurrency == 'USD' ? '\$${p.toStringAsFixed(2)}' : '₹${p.toStringAsFixed(2)}';

  void _openSettings() async {
    final result = await showModalBottomSheet<Map<String, dynamic>>(
      context: context,
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) => SettingsModal(
        initialTheme: widget.currentThemeMode,
        initialInterval: _refreshInterval,
        initialCurrency: widget.currentCurrency,
      ),
    );

    if (result != null) {
      final box = Hive.box('authBox');

      if (result.containsKey('theme')) {
        widget.themeModeSetter(result['theme']);
        await box.put(
          'themeMode',
          result['theme'] == ThemeMode.dark ? 'dark' : 'light',
        );
      }

      if (result.containsKey('interval')) {
        setState(() => _refreshInterval = result['interval']);
        widget.refreshIntervalSetter(_refreshInterval);
        await box.put('refreshInterval', _refreshInterval.inSeconds);
        _startUpdates();
      }

      if (result.containsKey('currency')) {
        widget.currencySetter(result['currency']);
        await box.put('currency', result['currency']);
      }
    }
  }



}
