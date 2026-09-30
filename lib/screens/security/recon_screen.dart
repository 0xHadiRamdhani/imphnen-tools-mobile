import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pixelarticons/pixelarticons.dart';

class ReconScreen extends StatefulWidget {
  const ReconScreen({super.key});

  @override
  State<ReconScreen> createState() => _ReconScreenState();
}

class _ReconScreenState extends State<ReconScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tab;
  final _urlCtrl = TextEditingController();
  final _headerCtrl = TextEditingController();
  String _urlResult = '';
  String _headerResult = '';
  String? _urlError;
  String? _headerError;

  @override
  void initState() {
    super.initState();
    _tab = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tab.dispose();
    _urlCtrl.dispose();
    _headerCtrl.dispose();
    super.dispose();
  }

  void _parseUrl() {
    final raw = _urlCtrl.text.trim();
    if (raw.isEmpty) {
      setState(() => _urlError = 'Masukkan URL atau domain.');
      return;
    }
    final input = raw.startsWith('http') ? raw : 'https://$raw';
    final uri = Uri.tryParse(input);
    if (uri == null) {
      setState(() => _urlError = 'Format URL tidak valid.');
      return;
    }
    final sb = StringBuffer();
    sb.writeln('Scheme       : ${uri.scheme}');
    sb.writeln('Host         : ${uri.host}');
    if (uri.port != 0) sb.writeln('Port         : ${uri.port}');
    if (uri.path.isNotEmpty && uri.path != '/')
      sb.writeln('Path         : ${uri.path}');
    if (uri.query.isNotEmpty) {
      sb.writeln('Query String : ${uri.query}');
      final params = uri.queryParameters;
      if (params.isNotEmpty) {
        sb.writeln('Parameters   :');
        for (final p in params.entries) {
          sb.writeln('  ${p.key} = ${p.value}');
        }
      }
    }
    if (uri.fragment.isNotEmpty) sb.writeln('Fragment     : ${uri.fragment}');
    final parts = uri.host.split('.');
    if (parts.length >= 2) {
      sb.writeln('');
      sb.writeln('TLD          : .${parts.last}');
      sb.writeln('Root Domain  : ${parts.sublist(parts.length - 2).join('.')}');
      if (parts.length > 2) {
        sb.writeln(
          'Subdomain    : ${parts.sublist(0, parts.length - 2).join('.')}',
        );
      }
    }
    setState(() {
      _urlError = null;
      _urlResult = sb.toString().trim();
    });
  }

  void _analyzeHeaders() {
    final raw = _headerCtrl.text.trim();
    if (raw.isEmpty) {
      setState(() => _headerError = 'Tempelkan HTTP response headers di sini.');
      return;
    }
    final lines = raw
        .split('\n')
        .map((l) => l.trim())
        .where((l) => l.isNotEmpty)
        .toList();
    final headers = <String, String>{};
    for (final line in lines) {
      final idx = line.indexOf(':');
      if (idx > 0) {
        final key = line.substring(0, idx).trim().toLowerCase();
        final val = line.substring(idx + 1).trim();
        headers[key] = val;
      }
    }

    final sb = StringBuffer();
    sb.writeln('=== Security Headers Analysis ===\n');

    final checks = [
      (
        'strict-transport-security',
        'HSTS',
        true,
        'Paksa HTTPS. Mencegah SSL strip attack.',
      ),
      (
        'content-security-policy',
        'CSP',
        true,
        'Mencegah XSS dengan membatasi sumber konten.',
      ),
      ('x-frame-options', 'X-Frame-Options', true, 'Mencegah clickjacking.'),
      (
        'x-content-type-options',
        'X-Content-Type-Options',
        true,
        'Mencegah MIME sniffing.',
      ),
      (
        'referrer-policy',
        'Referrer-Policy',
        false,
        'Mengontrol informasi referrer.',
      ),
      (
        'permissions-policy',
        'Permissions-Policy',
        false,
        'Mengontrol akses fitur browser.',
      ),
      (
        'x-xss-protection',
        'X-XSS-Protection',
        false,
        'XSS filter lama (sudah deprecated).',
      ),
      (
        'server',
        'Server',
        false,
        'Mengekspos informasi server (sebaiknya dihilangkan).',
      ),
    ];

    for (final check in checks) {
      final present = headers.containsKey(check.$1);
      final icon = present ? '✅' : (check.$3 ? '❌' : '⚠️');
      final status = present
          ? 'ADA'
          : (check.$3 ? 'TIDAK ADA (kritis)' : 'tidak ada');
      sb.writeln('$icon ${check.$2}');
      sb.writeln('   Status : $status');
      if (present) sb.writeln('   Nilai  : ${headers[check.$1]}');
      sb.writeln('   Info   : ${check.$4}');
      sb.writeln('');
    }

    setState(() {
      _headerError = null;
      _headerResult = sb.toString().trim();
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
        title: const Text('Recon & DNS'),
        bottom: TabBar(
          controller: _tab,
          tabs: const [
            Tab(text: 'URL Parser'),
            Tab(text: 'Header Audit'),
            Tab(text: 'Cert Links'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tab,
        children: [_urlParserTab(), _headerAuditTab(), _certLinksTab()],
      ),
    );
  }

  Widget _urlParserTab() {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        _infoBox(
          'Parsing URL/domain secara lokal. Tidak ada data yang dikirim ke server.',
          Pixel.cloud,
        ),
        const SizedBox(height: 16),
        TextField(
          controller: _urlCtrl,
          decoration: const InputDecoration(
            labelText: 'URL atau Domain',
            hintText: 'https://example.com/path?query=1',
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: FilledButton.icon(
                onPressed: _parseUrl,
                icon: const Icon(Pixel.play),
                label: const Text('Parse'),
              ),
            ),
            const SizedBox(width: 10),
            OutlinedButton.icon(
              onPressed: () => setState(() {
                _urlCtrl.clear();
                _urlResult = '';
                _urlError = null;
              }),
              icon: const Icon(Pixel.trash),
              label: const Text('Hapus'),
            ),
          ],
        ),
        if (_urlError != null) ...[
          const SizedBox(height: 12),
          _errorBox(_urlError!),
        ],
        if (_urlResult.isNotEmpty) ...[
          const SizedBox(height: 16),
          _resultCard(_urlResult),
        ],
      ],
    );
  }

  Widget _headerAuditTab() {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        _infoBox(
          'Tempelkan HTTP response headers (dari browser DevTools, curl, dll) untuk menganalisis keamanannya.',
          Pixel.list,
        ),
        const SizedBox(height: 16),
        TextField(
          controller: _headerCtrl,
          maxLines: 8,
          decoration: const InputDecoration(
            labelText: 'HTTP Response Headers',
            hintText: 'Content-Type: text/html\nStrict-Transport-Security: max-age=31536000\n...',
            alignLabelWithHint: true,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: FilledButton.icon(
                onPressed: _analyzeHeaders,
                icon: const Icon(Pixel.play),
                label: const Text('Analisis'),
              ),
            ),
            const SizedBox(width: 10),
            OutlinedButton.icon(
              onPressed: () => setState(() {
                _headerCtrl.clear();
                _headerResult = '';
                _headerError = null;
              }),
              icon: const Icon(Pixel.trash),
              label: const Text('Hapus'),
            ),
          ],
        ),
        if (_headerError != null) ...[
          const SizedBox(height: 12),
          _errorBox(_headerError!),
        ],
        if (_headerResult.isNotEmpty) ...[
          const SizedBox(height: 16),
          _resultCard(_headerResult),
        ],
      ],
    );
  }

  Widget _certLinksTab() {
    final links = [
      (
        'crt.sh',
        'crt.sh — Certificate Transparency Log',
        'Cari sertifikat yang dikeluarkan untuk sebuah domain. Berguna untuk subdomain discovery.',
      ),
      (
        'censys.io',
        'Censys — Internet-Wide Scanner',
        'Cari host, sertifikat, dan informasi infrastruktur di internet.',
      ),
      (
        'shodan.io',
        'Shodan — Search Engine for IoT/Servers',
        'Cari perangkat yang terhubung ke internet, port yang terbuka, dan servis yang berjalan.',
      ),
      (
        'dnsdumpster.com',
        'DNSDumpster — DNS Recon',
        'Peta DNS gratis untuk menemukan host yang terkait dengan sebuah domain.',
      ),
      (
        'securityheaders.com',
        'Security Headers Checker',
        'Analisis HTTP security headers dari sebuah URL secara online.',
      ),
      (
        'ssllabs.com/ssltest',
        'SSL Labs — SSL Test',
        'Analisis mendalam konfigurasi SSL/TLS server.',
      ),
      (
        'haveibeenpwned.com',
        'Have I Been Pwned',
        'Cek apakah email atau domain terlibat dalam data breach.',
      ),
      (
        'urlscan.io',
        'urlscan.io — URL Scanner',
        'Scan URL untuk analisis keamanan dan screenshot.',
      ),
    ];

    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        _infoBox(
          'Referensi tool online yang berguna untuk recon dan certificate analysis.',
          Pixel.bookopen,
        ),
        const SizedBox(height: 16),
        ...links.map(
          (l) => Card(
            margin: const EdgeInsets.only(bottom: 8),
            child: ListTile(
              leading: _sticker(
                Pixel.cloud,
                Theme.of(context).colorScheme.primary,
              ),
              title: Text(
                l.$2,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
              subtitle: Text(l.$3),
              trailing: IconButton(
                icon: const Icon(Pixel.copy, size: 17),
                tooltip: 'Salin URL',
                onPressed: () async {
                  await Clipboard.setData(
                    ClipboardData(text: 'https://${l.$1}'),
                  );
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('URL ${l.$1} disalin')),
                    );
                  }
                },
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _infoBox(String text, IconData icon) => Container(
    padding: const EdgeInsets.all(13),
    decoration: BoxDecoration(
      color: Theme.of(context).colorScheme.primaryContainer
          .withValues(alpha: .4),
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
      color: Theme.of(context).colorScheme.error.withValues(alpha: .09),
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
              if (mounted)
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Disalin ke clipboard')),
                );
            },
          ),
        ],
      ),
      Container(
        width: double.infinity,
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surfaceContainerHighest
              .withValues(alpha: .55),
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
      color: color.withValues(alpha: .12),
      borderRadius: BorderRadius.circular(10),
      border: Border.all(color: color.withValues(alpha: .35)),
    ),
    child: Icon(icon, size: 20, color: color),
  );
}
