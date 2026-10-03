import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pixelarticons/pixelarticons.dart';

class PasswordScreen extends StatefulWidget {
  const PasswordScreen({super.key});

  @override
  State<PasswordScreen> createState() => _PasswordScreenState();
}

class _PasswordScreenState extends State<PasswordScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tab;

  // Checker
  final _checkCtrl = TextEditingController();
  int _entropy = 0;
  String _strength = 'Sangat Lemah';
  Color _strengthColor = Colors.red;
  String _crackTime = '0 detik';

  // Generator
  double _len = 16;
  bool _incUpper = true;
  bool _incLower = true;
  bool _incNum = true;
  bool _incSym = true;
  String _generated = '';

  @override
  void initState() {
    super.initState();
    _tab = TabController(length: 2, vsync: this);
    _generate();
  }

  @override
  void dispose() {
    _tab.dispose();
    _checkCtrl.dispose();
    super.dispose();
  }

  void _check(String pwd) {
    if (pwd.isEmpty) {
      setState(() {
        _entropy = 0;
        _strength = 'Sangat Lemah';
        _strengthColor = Colors.red;
        _crackTime = '0 detik';
      });
      return;
    }

    int charset = 0;
    if (RegExp(r'[a-z]').hasMatch(pwd)) charset += 26;
    if (RegExp(r'[A-Z]').hasMatch(pwd)) charset += 26;
    if (RegExp(r'[0-9]').hasMatch(pwd)) charset += 10;
    if (RegExp(r'[^a-zA-Z0-9]').hasMatch(pwd)) charset += 32;

    final ent = (pwd.length * (log(charset > 0 ? charset : 1) / ln2)).round();

    String s;
    Color c;
    String time;
    if (ent < 28) {
      s = 'Sangat Lemah';
      c = Colors.red;
      time = 'Instan';
    } else if (ent < 36) {
      s = 'Lemah';
      c = Colors.orange;
      time = 'Beberapa detik';
    } else if (ent < 60) {
      s = 'Sedang';
      c = Colors.amber;
      time = 'Beberapa jam/hari';
    } else if (ent < 128) {
      s = 'Kuat';
      c = Colors.green;
      time = 'Bertahun-tahun';
    } else {
      s = 'Sangat Kuat';
      c = Colors.blue;
      time = 'Berabad-abad';
    }

    setState(() {
      _entropy = ent;
      _strength = s;
      _strengthColor = c;
      _crackTime = time;
    });
  }

  void _generate() {
    String chars = '';
    if (_incUpper) chars += 'ABCDEFGHIJKLMNOPQRSTUVWXYZ';
    if (_incLower) chars += 'abcdefghijklmnopqrstuvwxyz';
    if (_incNum) chars += '0123456789';
    if (_incSym) chars += '!@#\$%^&*()_+-=[]{}|;:,.<>?';

    if (chars.isEmpty) {
      setState(() => _generated = 'Pilih minimal 1 jenis karakter');
      return;
    }

    final rnd = Random.secure();
    final res = List.generate(
      _len.toInt(),
      (_) => chars[rnd.nextInt(chars.length)],
    ).join();
    setState(() => _generated = res);
  }

  void _copy(String text) {
    if (text.isEmpty || text.startsWith('Pilih')) return;
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Tersalin ke clipboard'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('Password Tools'),
        titleTextStyle: theme.textTheme.titleMedium?.copyWith(
          fontWeight: FontWeight.w800,
        ),
        bottom: TabBar(
          controller: _tab,
          tabs: const [
            Tab(text: 'Generator', icon: Icon(Pixel.lock)),
            Tab(text: 'Checker', icon: Icon(Pixel.search)),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tab,
        children: [_buildGenTab(theme), _buildCheckTab(theme)],
      ),
    );
  }

  Widget _buildGenTab(ThemeData theme) {
    return ListView(
      padding: EdgeInsets.fromLTRB(
        20,
        20,
        20,
        40 + MediaQuery.paddingOf(context).bottom,
      ),
      children: [
        Card(
          color: theme.colorScheme.primary.withValues(alpha: 0.1),
          elevation: 0,
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                SelectableText(
                  _generated,
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w800,
                    letterSpacing: 2,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                FilledButton.icon(
                  onPressed: () => _copy(_generated),
                  icon: const Icon(Pixel.copy),
                  label: const Text('Salin Password'),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 24),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Panjang Password',
              style: TextStyle(fontWeight: FontWeight.w700),
            ),
            Text(
              '${_len.toInt()} Karakter',
              style: TextStyle(
                color: theme.colorScheme.primary,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
        Slider.adaptive(
          value: _len,
          min: 8,
          max: 64,
          divisions: 56,
          onChanged: (v) {
            setState(() => _len = v);
            _generate();
          },
        ),
        const SizedBox(height: 16),
        SwitchListTile.adaptive(
          title: const Text('Huruf Besar (A-Z)'),
          value: _incUpper,
          onChanged: (v) {
            setState(() => _incUpper = v);
            _generate();
          },
        ),
        SwitchListTile.adaptive(
          title: const Text('Huruf Kecil (a-z)'),
          value: _incLower,
          onChanged: (v) {
            setState(() => _incLower = v);
            _generate();
          },
        ),
        SwitchListTile.adaptive(
          title: const Text('Angka (0-9)'),
          value: _incNum,
          onChanged: (v) {
            setState(() => _incNum = v);
            _generate();
          },
        ),
        SwitchListTile.adaptive(
          title: const Text('Simbol Khusus'),
          value: _incSym,
          onChanged: (v) {
            setState(() => _incSym = v);
            _generate();
          },
        ),
        const SizedBox(height: 24),
        OutlinedButton.icon(
          onPressed: _generate,
          icon: const Icon(Pixel.reload),
          label: const Text('Generate Ulang'),
        ),
      ],
    );
  }

  Widget _buildCheckTab(ThemeData theme) {
    return ListView(
      padding: EdgeInsets.fromLTRB(
        20,
        20,
        20,
        40 + MediaQuery.paddingOf(context).bottom,
      ),
      children: [
        const Text(
          'Ketik Password',
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: _checkCtrl,
          onChanged: _check,
          obscureText: true,
          decoration: const InputDecoration(hintText: 'Masukkan password...'),
        ),
        const SizedBox(height: 24),
        Card(
          margin: EdgeInsets.zero,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Kekuatan Password',
                  style: TextStyle(color: Colors.grey),
                ),
                const SizedBox(height: 4),
                Text(
                  _strength,
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w800,
                    color: _strengthColor,
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Estimasi Waktu Crack (Bruteforce)',
                  style: TextStyle(color: Colors.grey),
                ),
                const SizedBox(height: 4),
                Text(
                  _crackTime,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Information Entropy',
                  style: TextStyle(color: Colors.grey),
                ),
                const SizedBox(height: 4),
                Text(
                  '$_entropy bits',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
