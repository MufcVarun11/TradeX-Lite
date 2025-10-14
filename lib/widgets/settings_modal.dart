import 'package:flutter/material.dart';

class SettingsModal extends StatefulWidget {
  final ThemeMode initialTheme;
  final Duration initialInterval;
  final String initialCurrency;

  const SettingsModal({
    required this.initialTheme,
    required this.initialInterval,
    required this.initialCurrency,
  });

  @override
  State<SettingsModal> createState() => _SettingsModalState();
}

class _SettingsModalState extends State<SettingsModal> {
  late ThemeMode _theme;
  late Duration _interval;
  late String _currency;

  @override
  void initState() {
    super.initState();
    _theme = widget.initialTheme;
    _interval = widget.initialInterval;
    _currency = widget.initialCurrency;
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Dark Mode',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
              Switch(
                value: _theme == ThemeMode.dark,
                activeColor: Colors.blueAccent,
                onChanged: (v) {
                  setState(() => _theme = v ? ThemeMode.dark : ThemeMode.light);
                },
              ),
            ],
          ),
          const Divider(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Refresh Interval',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
              DropdownButton<Duration>(
                value: _interval,
                underline: const SizedBox(),
                items: const [
                  Duration(seconds: 5),
                  Duration(seconds: 10),
                  Duration(seconds: 30),
                ]
                    .map((d) => DropdownMenuItem(
                  value: d,
                  child: Text('${d.inSeconds}s'),
                ))
                    .toList(),
                onChanged: (v) => setState(() => _interval = v!),
              ),
            ],
          ),
          const Divider(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Currency',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
              DropdownButton<String>(
                value: _currency,
                underline: const SizedBox(),
                items: ['INR', 'USD']
                    .map((c) => DropdownMenuItem(
                  value: c,
                  child: Text(c),
                ))
                    .toList(),
                onChanged: (v) => setState(() => _currency = v!),
              ),
            ],
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: 120,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.transparent,
                shadowColor: Colors.transparent,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                  side: const BorderSide(color: Colors.blueAccent, width: 1.5),
                ),
              ),
              onPressed: () {
                Navigator.pop(context, {
                  'theme': _theme,
                  'interval': _interval,
                  'currency': _currency,
                });
              },
              child: const Text(
                'Apply',
                style: TextStyle(
                  color: Colors.blueAccent,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}
