import 'package:flutter/material.dart';
class SettingsModal extends StatefulWidget {
  final ThemeMode initialTheme;
  final Duration initialInterval;
  final String initialCurrency;
  const SettingsModal({required this.initialTheme, required this.initialInterval, required this.initialCurrency});


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
      padding: const EdgeInsets.all(12.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text('Dark mode'), Switch(value: _theme == ThemeMode.dark, onChanged: (v) => setState(() => _theme = v ? ThemeMode.dark : ThemeMode.light))]),
          Divider(),
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text('Refresh interval'), DropdownButton<Duration>(value: _interval, items: [Duration(seconds:5), Duration(seconds:10), Duration(seconds:30)].map((d) => DropdownMenuItem(value: d, child: Text('${d.inSeconds}s'))).toList(), onChanged: (v) => setState(() => _interval = v!))]),
          Divider(),
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text('Currency'), DropdownButton<String>(value: _currency, items: ['INR', 'USD'].map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(), onChanged: (v) => setState(() => _currency = v!))]),
          SizedBox(height: 12),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context, {'theme': _theme, 'interval': _interval, 'currency': _currency});
            },
            child: Text('Apply'),
          ),
          SizedBox(height: 12),
        ],
      ),
    );
  }
}