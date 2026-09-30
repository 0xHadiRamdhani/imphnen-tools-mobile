import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pixelarticons/pixelarticons.dart';

class SecretsIntelScreen extends StatefulWidget {
  const SecretsIntelScreen({super.key});

  @override
  State<SecretsIntelScreen> createState() => _SecretsIntelScreenState();
}

class _SecretsIntelScreenState extends State<SecretsIntelScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tab;
  final _textCtrl = TextEditingController();
  final _cveCtrl = TextEditingController();
  List<(String, String, String)> _scanResults = [];
  bool _hasScanned = false;
  String _cveResult = '';
  String? _cveError;

  @override
  void initState() {
    super.initState();
    _tab = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tab.dispose();
    _textCtrl.dispose();
    _cveCtrl.dispose();
    super.dispose();
  }

  // Use r'''...''' to avoid quote escaping issues
  static final _secretPatterns = <(String, RegExp, String)>[
    ('AWS Access Key ID', RegExp(r'''AKIA[0-9A-Z]{16}'''), 'Critical'),
    (
      'AWS Secret Access Key',
      RegExp(
        r'''(?:aws[_\-]?secret|secret[_\-]?access[_\-]?key)["\s:=]+([A-Za-z0-9/+=]{40})''',
        caseSensitive: false,
      ),
      'Critical',
    ),
    (
      'Generic API Key',
      RegExp(
        r'''(?:api[_\-]?key|apikey)["\s:=]+([A-Za-z0-9_\-]{16,64})''',
        caseSensitive: false,
      ),
      'High',
    ),
    ('Bearer Token', RegExp(r'''Bearer\s+[A-Za-z0-9\-._~+/]+=*'''), 'High'),
    (
      'JWT Token',
      RegExp(r'''eyJ[A-Za-z0-9\-_]+\.[A-Za-z0-9\-_]+\.[A-Za-z0-9\-_.+/]*'''),
      'Medium',
    ),
    ('Google API Key', RegExp(r'''AIza[0-9A-Za-z\-_]{35}'''), 'Critical'),
    (
      'Private Key (PEM)',
      RegExp(r'''-----BEGIN (?:RSA |EC )?PRIVATE KEY-----'''),
      'Critical',
    ),
    (
      'Password in Config',
      RegExp(
        r'''(?:password|passwd|pwd)["\s:=]+["']?([^\s"']{6,})["']?''',
        caseSensitive: false,
      ),
      'High',
    ),
    (
      'Database Connection String',
      RegExp(
        r'''(?:mysql|postgres|mongodb|redis|mssql):\/\/[^\s]+''',
        caseSensitive: false,
      ),
      'Critical',
    ),
    ('GitHub Token', RegExp(r'''gh[pousr]_[A-Za-z0-9]{36}'''), 'Critical'),
    ('Slack Token', RegExp(r'''xox[baprs]-[0-9A-Za-z\-]+'''), 'High'),
    (
      'Stripe Key',
      RegExp(r'''sk_(?:live|test)_[0-9a-zA-Z]{24,}'''),
      'Critical',
    ),
    (
      'Firebase Config',
      RegExp(r'''"apiKey"\s*:\s*"AIza[0-9A-Za-z\-_]{35}"'''),
      'High',
    ),
    (
      'Generic Secret',
      RegExp(
        r'''(?:secret|SECRET)["\s:=]+["']?([A-Za-z0-9_\-]{16,})["']?''',
        caseSensitive: false,
      ),
      'Medium',
    ),
    (
      'SSH Private Key',
      RegExp(r'''-----BEGIN OPENSSH PRIVATE KEY-----'''),
      'Critical',
    ),
    (
      'Email Address',
      RegExp(r'''[a-zA-Z0-9._%+\-]+@[a-zA-Z0-9.\-]+\.[a-zA-Z]{2,}'''),
      'Low',
    ),
    (
      'IP Address',
      RegExp(
        r'''\b(?:10|172\.(?:1[6-9]|2\d|3[01])|192\.168)\.\d{1,3}\.\d{1,3}\b''',
      ),
      'Low',
    ),
  ];

  static const _riskColor = {
    'Low': Color(0xFF6AAB6E),
    'Medium': Color(0xFFD2933A),
    'High': Color(0xFFE07B50),
    'Critical': Color(0xFFD25757),
  };

  void _scanText() {
    final text = _textCtrl.text;
    if (text.isEmpty) {
      setState(() {
        _scanResults.clear();
        _hasScanned = true;
      });
      return;
    }

    final results = <(String, String, String)>[];
    for (final pattern in _secretPatterns) {
      final matches = pattern.$2.allMatches(text);
      for (final match in matches) {
        final found = match.group(0) ?? '';
        // Truncate long findings for display
        final display = found.length > 50
            ? '${found.substring(0, 47)}...'
            : found;
        results.add((pattern.$1, display, pattern.$3));
      }
    }

    setState(() {
      _scanResults = results;
      _hasScanned = true;
    });
  }

  void _lookupCVE() {
    final raw = _cveCtrl.text.trim().toUpperCase();
    if (raw.isEmpty) {
      setState(() {
        _cveError = 'Masukkan ID CVE';
        _cveResult = '';
      });
      return;
    }

    final cveRegex = RegExp(r'''^CVE-\d{4}-\d{4,}$''');
    if (!cveRegex.hasMatch(raw)) {
      setState(() {
        _cveError = 'Format salah. Gunakan format: CVE-YYYY-NNNN';
        _cveResult = '';
      });
      return;
    }

    setState(() {
      _cveError = null;
      _cveResult =
          'ID $raw memiliki format valid.\n\nDalam versi lokal ini, Anda dapat menyalin ID ini dan mencarinya di NVD (nvd.nist.gov) atau MITRE (cve.mitre.org).';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.surface
            .withValues(alpha: .65),
        elevation: 0,
        scrolledUnderElevation: 0,
        flexibleSpace: ClipRect(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
            child: Container(color: Colors.transparent),
          ),
        ),
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Pixel.chevronleft),
        ),
        title: const Text('Secrets & CVE Intelligence'),
        bottom: TabBar(
          controller: _tab,
          tabs: const [
            Tab(text: 'Secrets Scanner'),
            Tab(text: 'CVE Lookup'),
          ],
        ),
      ),
      body: TabBarView(controller: _tab, children: [_secretsTab(), _cveTab()]),
    );
  }

  Widget _secretsTab() {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        _infoBox(
          'Pindai teks mentah, kode, atau konfigurasi untuk mencari rahasia (API key, token, password) yang tidak sengaja terekspos. Diproses secara lokal di perangkat Anda.',
          Pixel.lock,
        ),
        const SizedBox(height: 16),
        TextField(
          controller: _textCtrl,
          maxLines: 8,
          decoration: const InputDecoration(
            labelText: 'Teks / Kode Mentah',
            hintText:
                'Tempelkan kode sumber, file konfigurasi, atau log di sini...',
            alignLabelWithHint: true,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: FilledButton.icon(
                onPressed: _scanText,
                icon: const Icon(Pixel.search),
                label: const Text('Pindai'),
              ),
            ),
            const SizedBox(width: 10),
            OutlinedButton.icon(
              onPressed: () {
                _textCtrl.clear();
                setState(() {
                  _hasScanned = false;
                  _scanResults.clear();
                });
              },
              icon: const Icon(Pixel.trash),
              label: const Text('Hapus'),
            ),
          ],
        ),
        const SizedBox(height: 20),
        if (_hasScanned) ...[
          Text(
            'Hasil Pemindaian (${_scanResults.length})',
            style: Theme.of(context).textTheme.titleMedium
                ?.copyWith(fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 8),
          if (_scanResults.isEmpty)
            _infoBox(
              'Tidak ada rahasia yang terdeteksi pada teks tersebut.',
              Pixel.check,
            )
          else
            ..._scanResults.map((r) {
              final color = _riskColor[r.$3] ?? Colors.grey;
              return Card(
                margin: const EdgeInsets.only(bottom: 8),
                child: ListTile(
                  leading: Icon(Pixel.alert, color: color),
                  title: Text(
                    r.$1,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(
                    r.$2,
                    style: const TextStyle(
                      fontFamily: 'monospace',
                      fontSize: 12,
                    ),
                  ),
                  trailing: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: color.withOpacity(.15),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      r.$3,
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: color,
                      ),
                    ),
                  ),
                ),
              );
            }),
        ],
      ],
    );
  }

  Widget _cveTab() {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        _infoBox(
          'Validasi format ID CVE dan dapatkan panduan pencarian di database keamanan.',
          Pixel.bookopen,
        ),
        const SizedBox(height: 16),
        TextField(
          controller: _cveCtrl,
          decoration: const InputDecoration(
            labelText: 'ID CVE',
            hintText: 'contoh: CVE-2021-44228',
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: FilledButton.icon(
                onPressed: _lookupCVE,
                icon: const Icon(Pixel.search),
                label: const Text('Validasi'),
              ),
            ),
          ],
        ),
        if (_cveError != null) ...[
          const SizedBox(height: 12),
          _errorBox(_cveError!),
        ],
        if (_cveResult.isNotEmpty) ...[
          const SizedBox(height: 16),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surfaceVariant
                  .withOpacity(.55),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: Colors.green.withOpacity(.3)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  children: [
                    Icon(Pixel.check, color: Colors.green),
                    SizedBox(width: 8),
                    Text(
                      'Format Valid',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.green,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(_cveResult),
              ],
            ),
          ),
        ],
      ],
    );
  }

  Widget _infoBox(String text, IconData icon) => Container(
    padding: const EdgeInsets.all(13),
    decoration: BoxDecoration(
      color: Theme.of(context).colorScheme.primaryContainer.withOpacity(.4),
      borderRadius: BorderRadius.circular(14),
    ),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 18, color: Theme.of(context).colorScheme.primary),
        const SizedBox(width: 10),
        Expanded(child: Text(text, style: const TextStyle(fontSize: 12))),
      ],
    ),
  );

  Widget _errorBox(String text) => Container(
    padding: const EdgeInsets.all(13),
    decoration: BoxDecoration(
      color: Theme.of(context).colorScheme.error.withOpacity(.09),
      borderRadius: BorderRadius.circular(14),
    ),
    child: Row(
      children: [
        Icon(Pixel.alert, color: Theme.of(context).colorScheme.error),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            text,
            style: TextStyle(color: Theme.of(context).colorScheme.error),
          ),
        ),
      ],
    ),
  );
}
