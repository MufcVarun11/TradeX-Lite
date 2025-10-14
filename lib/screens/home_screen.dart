import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import '../models/stock.dart';
import '../utils/mock_data.dart';
import 'stock_detail_screen.dart';
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
  List<Stock> _filtered = [];
  List<Stock> _watchlist = [];
  String _query = '';
  Duration _refreshInterval = const Duration(seconds: 5);
  Timer? _timer;
  int _currentIndex = 0;

  final watchlistBox = Hive.box('watchlistBox');

  @override
  void initState() {
    super.initState();
    _stocks = generateMockStocks(100);
    _loadWatchlist();
    _filtered = _stocks;
    _startUpdates();
  }

  void _loadWatchlist() {
    final symbols = watchlistBox.get('symbols', defaultValue: <String>[]);
    for (var s in _stocks) {
      s.isInWatchlist = symbols.contains(s.symbol);
    }
    _updateWatchlist();
  }

  void _updateWatchlist() {
    setState(() {
      _watchlist = _stocks.where((s) => s.isInWatchlist).toList();
    });
  }

  void _toggleWatchlist(Stock stock) {
    final symbols = List<String>.from(watchlistBox.get('symbols', defaultValue: <String>[]));
    setState(() {
      if (stock.isInWatchlist) {
        stock.isInWatchlist = false;
        symbols.remove(stock.symbol);
      } else {
        stock.isInWatchlist = true;
        symbols.add(stock.symbol);
      }
      watchlistBox.put('symbols', symbols);
      _updateWatchlist();
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
    setState(() {
      _filtered = _stocks
          .where((s) =>
      s.symbol.toLowerCase().contains(query.toLowerCase()) ||
          s.name.toLowerCase().contains(query.toLowerCase()))
          .toList();
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? const Color(0xFF121212) : Colors.grey[50];

    final screens = [
      _buildMarketScreen(),
      _buildWatchlistScreen(),
    ];

    final appBars = [
      AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text('Market Watch', style: TextStyle(fontWeight: FontWeight.bold)),
        actions: [IconButton(icon: const Icon(Icons.settings), onPressed: _openSettings)],
      ),
      AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text('My Watchlist', style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
    ];

    return Scaffold(
      backgroundColor: bgColor,
      appBar: appBars[_currentIndex],
      body: screens[_currentIndex],
      bottomNavigationBar: Container(
        margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
          borderRadius: BorderRadius.circular(28),
          boxShadow: [
            BoxShadow(
              color: isDark ? Colors.black.withOpacity(0.4) : Colors.blueAccent.withOpacity(0.15),
              blurRadius: 25,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _animatedNavItem(icon: Icons.show_chart_rounded, label: 'Market', index: 0),
              _animatedNavItem(icon: Icons.star_rounded, label: 'Watchlist', index: 1),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMarketScreen() {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(10, 0, 10, 10),
          child: Container(
            decoration: BoxDecoration(
              color: isDark ? Colors.grey[850] : Colors.white,
              borderRadius: BorderRadius.circular(30),
              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 5, offset: const Offset(0, 3))],
            ),
            child: TextField(
              onChanged: _filterList,
              decoration: InputDecoration(
                hintText: 'Search stocks (e.g. RELIANCE, TCS, HDFCBANK)',
                prefixIcon: const Icon(Icons.search),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
              ),
            ),
          ),
        ),
        Expanded(
          child: _filtered.isEmpty
              ? const Center(child: Text('No stocks found', style: TextStyle(fontSize: 16, color: Colors.grey)))
              : ListView.separated(
            itemCount: _filtered.length,
            separatorBuilder: (_, __) => Divider(color: isDark ? Colors.grey[800] : Colors.grey[300], height: 1),
            itemBuilder: (context, index) {
              final s = _filtered[index];
              final change = s.changePercent;
              final isUp = change >= 0;

              return InkWell(
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => StockDetailScreen(stock: s, currency: widget.currentCurrency)),
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
                            Text(s.name, overflow: TextOverflow.ellipsis, style: TextStyle(color: Colors.grey.shade600, fontSize: 13)),
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
                              Text('${change.toStringAsFixed(2)}%', style: TextStyle(color: isUp ? Colors.green : Colors.red, fontWeight: FontWeight.w600, fontSize: 13)),
                            ],
                          ),
                        ],
                      ),
                      IconButton(
                        icon: Icon(s.isInWatchlist ? Icons.star_rounded : Icons.star_border_rounded, color: s.isInWatchlist ? Colors.amber : Colors.grey),
                        onPressed: () => _toggleWatchlist(s),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildWatchlistScreen() {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (_watchlist.isEmpty) {
      return const Center(
        child: Text(
          'No stocks added to watchlist yet.',
          style: TextStyle(fontSize: 16, color: Colors.grey, fontWeight: FontWeight.w500),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
      itemCount: _watchlist.length,
      itemBuilder: (context, index) {
        final s = _watchlist[index];
        final change = s.changePercent;
        final isUp = change >= 0;

        return AnimatedContainer(
          duration: const Duration(milliseconds: 500),
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color: isDark ? Colors.grey[850]?.withOpacity(0.9) : Colors.white,
            borderRadius: BorderRadius.circular(18),
            boxShadow: [
              BoxShadow(
                color: isDark ? Colors.black.withOpacity(0.3) : Colors.blueAccent.withOpacity(0.08),
                blurRadius: 12,
                offset: const Offset(0, 6),
              ),
            ],
            border: Border.all(
              color: isUp ? Colors.green.withOpacity(0.2) : Colors.red.withOpacity(0.2),
              width: 1,
            ),
          ),
          child: InkWell(
            borderRadius: BorderRadius.circular(18),
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => StockDetailScreen(stock: s, currency: widget.currentCurrency)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      radius: 22,
                      backgroundColor: isUp ? Colors.green.withOpacity(0.15) : Colors.red.withOpacity(0.15),
                      child: Text(s.symbol.substring(0, 2), style: TextStyle(color: isUp ? Colors.green : Colors.redAccent, fontWeight: FontWeight.bold)),
                    ),
                    const SizedBox(width: 14),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(s.symbol, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
                        const SizedBox(height: 4),
                        Text(s.name, style: TextStyle(fontSize: 13, color: Colors.grey.shade600), overflow: TextOverflow.ellipsis),
                      ],
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(_formatPrice(s.price), style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16, color: isUp ? Colors.green : Colors.red)),
                    const SizedBox(height: 3),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(isUp ? Icons.arrow_drop_up_rounded : Icons.arrow_drop_down_rounded, color: isUp ? Colors.green : Colors.redAccent),
                        Text('${change.toStringAsFixed(2)}%', style: TextStyle(color: isUp ? Colors.green : Colors.redAccent, fontWeight: FontWeight.w600, fontSize: 13)),
                      ],
                    ),
                  ],
                ),
                IconButton(
                  icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
                  onPressed: () => _toggleWatchlist(s),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _animatedNavItem({
    required IconData icon,
    required String label,
    required int index,
  }) {
    final bool isActive = _currentIndex == index;
    final activeColor = Colors.blueAccent;
    final inactiveColor = Theme.of(context).brightness == Brightness.dark
        ? Colors.white70
        : Colors.grey.shade600;

    return GestureDetector(
      onTap: () => setState(() => _currentIndex = index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeOutCubic,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isActive ? activeColor.withOpacity(0.15) : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedScale(
              scale: isActive ? 1.3 : 1.0,
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeOut,
              child: Icon(icon, size: 24, color: isActive ? activeColor : inactiveColor),
            ),
            const SizedBox(height: 5),
            AnimatedDefaultTextStyle(
              duration: const Duration(milliseconds: 250),
              style: TextStyle(
                fontSize: isActive ? 13 : 11,
                fontWeight: isActive ? FontWeight.bold : FontWeight.w500,
                color: isActive ? activeColor : inactiveColor,
              ),
              child: Text(label),
            ),
          ],
        ),
      ),
    );
  }

  String _formatPrice(double p) => widget.currentCurrency == 'USD' ? '\$${p.toStringAsFixed(2)}' : '₹${p.toStringAsFixed(2)}';

  Future<void> _openSettings() async {
    final result = await showModalBottomSheet<Map<String, dynamic>>(
      context: context,
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
      builder: (_) => SettingsModal(initialTheme: widget.currentThemeMode, initialInterval: _refreshInterval, initialCurrency: widget.currentCurrency),
    );

    if (result != null) {
      final box = Hive.box('authBox');
      if (result.containsKey('theme')) {
        widget.themeModeSetter(result['theme']);
        await box.put('themeMode', result['theme'] == ThemeMode.dark ? 'dark' : 'light');
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