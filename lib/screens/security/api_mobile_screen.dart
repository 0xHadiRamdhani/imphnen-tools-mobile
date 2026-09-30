import 'dart:ui';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pixelarticons/pixelarticons.dart';

class ApiMobileSecurityScreen extends StatefulWidget {
  const ApiMobileSecurityScreen({super.key});

  @override
  State<ApiMobileSecurityScreen> createState() =>
      _ApiMobileSecurityScreenState();
}

class _ApiMobileSecurityScreenState extends State<ApiMobileSecurityScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tab;
  final _jwtCtrl = TextEditingController();
  final _endpointCtrl = TextEditingController();
  final _permissionCtrl = TextEditingController();
  String _jwtResult = '';
  String _endpointResult = '';
  String _permissionResult = '';
  String? _jwtError;
  String? _endpointError;
  String? _permissionError;

  @override
  void initState() {
    super.initState();
    _tab = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tab.dispose();
    _jwtCtrl.dispose();
    _endpointCtrl.dispose();
    _permissionCtrl.dispose();
    super.dispose();
  }

  String _decodeBase64(String b64) {
    String normalized = b64.replaceAll('-', '+').replaceAll('_', '/');
    while (normalized.length % 4 != 0) normalized += '=';
    try {
      final bytes = base64.decode(normalized);
      return utf8.decode(bytes);
    } catch (_) {
      return '(tidak dapat didekode)';
    }
  }

  void _decodeJwt() {
    final token = _jwtCtrl.text.trim();
    if (token.isEmpty) {
      setState(() => _jwtError = 'Masukkan token JWT.');
      return;
    }
    final parts = token.split('.');
    if (parts.length != 3) {
      setState(
        () => _jwtError =
            'Token JWT harus memiliki 3 bagian (header.payload.signature).',
      );
      return;
    }
    final headerRaw = _decodeBase64(parts[0]);
    final payloadRaw = _decodeBase64(parts[1]);

    final sb = StringBuffer();
    sb.writeln('=== HEADER ===');
    try {
      final h = jsonDecode(headerRaw) as Map<String, dynamic>;
      sb.writeln(const JsonEncoder.withIndent('  ').convert(h));
      if (h['alg'] == 'none')
        sb.writeln(
          '\n⚠️  RISIKO: Algoritma "none" — token tidak terverifikasi!',
        );
      if (h['alg'] == 'HS256')
        sb.writeln(
          '\nℹ️  Menggunakan HS256 (symmetric). Pastikan secret key kuat.',
        );
    } catch (_) {
      sb.writeln(headerRaw);
    }
    sb.writeln('\n=== PAYLOAD ===');
    try {
      final p = jsonDecode(payloadRaw) as Map<String, dynamic>;
      sb.writeln(const JsonEncoder.withIndent('  ').convert(p));
      if (p.containsKey('exp')) {
        final exp = DateTime.fromMillisecondsSinceEpoch(
          (p['exp'] as int) * 1000,
        );
        final isExpired = exp.isBefore(DateTime.now());
        sb.writeln(
          '\nExpiry : $exp (${isExpired ? "❌ SUDAH EXPIRED" : "✅ Masih valid"})',
        );
      }
    } catch (_) {
      sb.writeln(payloadRaw);
    }
    sb.writeln('\n=== SIGNATURE ===');
    sb.writeln('${parts[2]}');
    sb.writeln(
      '\n⚠️  Signature tidak dapat diverifikasi secara lokal tanpa secret key.',
    );

    setState(() {
      _jwtError = null;
      _jwtResult = sb.toString().trim();
    });
  }

  void _auditEndpoints() {
    final raw = _endpointCtrl.text.trim();
    if (raw.isEmpty) {
      setState(() => _endpointError = 'Masukkan endpoint (satu per baris).');
      return;
    }
    final endpoints = raw
        .split('\n')
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .toList();
    final sb = StringBuffer();
    sb.writeln('=== API Endpoint Audit ===\n');

    final riskyPatterns = [
      (
        RegExp(r'\/admin', caseSensitive: false),
        'High',
        'Endpoint admin terekspos',
      ),
      (
        RegExp(r'\/debug', caseSensitive: false),
        'High',
        'Endpoint debug terekspos',
      ),
      (
        RegExp(r'\/swagger|\/api-docs|\/openapi', caseSensitive: false),
        'Medium',
        'API dokumentasi publik',
      ),
      (
        RegExp(r'\/v1\/|\/v2\/|\/v3\/'),
        'Low',
        'Versioning terlihat — pastikan versi lama dinonaktifkan',
      ),
      (
        RegExp(r'\/internal|\/private', caseSensitive: false),
        'Critical',
        'Endpoint internal terekspos',
      ),
      (
        RegExp(r'\/config|\/settings|\/env', caseSensitive: false),
        'Critical',
        'Endpoint konfigurasi terekspos',
      ),
      (
        RegExp(r'\/backup|\/dump|\/export', caseSensitive: false),
        'Critical',
        'Endpoint backup/export terekspos',
      ),
      (
        RegExp(r'\/test|\/dev|\/staging', caseSensitive: false),
        'High',
        'Endpoint development terekspos',
      ),
      (
        RegExp(r'\?id=|\?user=|\?file=', caseSensitive: false),
        'Medium',
        'Parameter sensitif terlihat — cek IDOR/path traversal',
      ),
    ];

    for (final ep in endpoints) {
      sb.writeln('📍 $ep');
      var found = false;
      for (final p in riskyPatterns) {
        if (p.$1.hasMatch(ep)) {
          sb.writeln('   [${p.$2}] ${p.$3}');
          found = true;
        }
      }
      if (!found)
        sb.writeln('   [Info] Tidak ada pola risiko yang terdeteksi.');
      sb.writeln('');
    }

    setState(() {
      _endpointError = null;
      _endpointResult = sb.toString().trim();
    });
  }

  void _analyzePermissions() {
    final raw = _permissionCtrl.text.trim();
    if (raw.isEmpty) {
      setState(
        () => _permissionError =
            'Tempelkan daftar uses-permission dari AndroidManifest.xml.',
      );
      return;
    }
    final lines = raw
        .split('\n')
        .map((l) => l.trim())
        .where((l) => l.isNotEmpty)
        .toList();
    final permissions = lines
        .where((l) => l.contains('uses-permission'))
        .map((l) {
          final m = RegExp(r'android:name="([^"]+)"').firstMatch(l);
          return m?.group(1) ?? '';
        })
        .where((p) => p.isNotEmpty)
        .toList();

    final dangerousPerms = {
      'android.permission.READ_CONTACTS': ('High', 'Akses kontak pengguna'),
      'android.permission.WRITE_CONTACTS': (
        'High',
        'Modifikasi kontak pengguna',
      ),
      'android.permission.ACCESS_FINE_LOCATION': ('High', 'GPS presisi tinggi'),
      'android.permission.ACCESS_COARSE_LOCATION': ('Medium', 'Lokasi kasar'),
      'android.permission.RECORD_AUDIO': ('High', 'Rekam audio/mikrofon'),
      'android.permission.CAMERA': ('High', 'Akses kamera'),
      'android.permission.READ_SMS': ('Critical', 'Baca SMS — sangat sensitif'),
      'android.permission.SEND_SMS': ('Critical', 'Kirim SMS tanpa konfirmasi'),
      'android.permission.READ_CALL_LOG': ('Critical', 'Baca log panggilan'),
      'android.permission.PROCESS_OUTGOING_CALLS': (
        'Critical',
        'Intersepsi panggilan keluar',
      ),
      'android.permission.READ_EXTERNAL_STORAGE': (
        'Medium',
        'Akses file eksternal',
      ),
      'android.permission.WRITE_EXTERNAL_STORAGE': (
        'Medium',
        'Tulis file eksternal',
      ),
      'android.permission.GET_ACCOUNTS': (
        'Medium',
        'Akses daftar akun di perangkat',
      ),
      'android.permission.INTERNET': ('Low', 'Akses internet (normal)'),
      'android.permission.RECEIVE_BOOT_COMPLETED': (
        'Low',
        'Autostart saat boot',
      ),
    };

    final sb = StringBuffer();
    sb.writeln('=== Android Permission Analysis ===\n');
    sb.writeln('Total permissions: ${permissions.length}\n');

    if (permissions.isEmpty) {
      sb.writeln('Tidak ada permission yang terdeteksi dari input ini.');
    }

    for (final p in permissions) {
      final info = dangerousPerms[p];
      if (info != null) {
        sb.writeln('⚠️  [${info.$1}] ${p.split('.').last}');
        sb.writeln('     $p');
        sb.writeln('     Info: ${info.$2}');
      } else {
        sb.writeln('ℹ️  [Normal] ${p.split('.').last}');
        sb.writeln('     $p');
      }
      sb.writeln('');
    }

    setState(() {
      _permissionError = null;
      _permissionResult = sb.toString().trim();
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
        title: const Text('API & Mobile Security'),
        bottom: TabBar(
          controller: _tab,
          tabs: const [
            Tab(text: 'JWT'),
            Tab(text: 'Endpoints'),
            Tab(text: 'Android'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tab,
        children: [_jwtTab(), _endpointTab(), _androidTab()],
      ),
    );
  }

  Widget _jwtTab() => ListView(
    padding: const EdgeInsets.all(20),
    children: [
      _infoBox(
        'Decode dan analisis JWT token secara lokal. Token tidak keluar dari perangkat.',
        Pixel.lock,
      ),
      const SizedBox(height: 16),
      TextField(
        controller: _jwtCtrl,
        maxLines: 4,
        decoration: const InputDecoration(
          labelText: 'JWT Token',
          hintText: 'eyJhbGciOiJIUzI1NiJ9...',
          alignLabelWithHint: true,
        ),
      ),
      const SizedBox(height: 12),
      Row(
        children: [
          Expanded(
            child: FilledButton.icon(
              onPressed: _decodeJwt,
              icon: const Icon(Pixel.play),
              label: const Text('Decode'),
            ),
          ),
          const SizedBox(width: 10),
          OutlinedButton.icon(
            onPressed: () => setState(() {
              _jwtCtrl.clear();
              _jwtResult = '';
              _jwtError = null;
            }),
            icon: const Icon(Pixel.trash),
            label: const Text('Hapus'),
          ),
        ],
      ),
      if (_jwtError != null) ...[
        const SizedBox(height: 12),
        _errorBox(_jwtError!),
      ],
      if (_jwtResult.isNotEmpty) ...[
        const SizedBox(height: 16),
        _resultCard(_jwtResult),
      ],
    ],
  );

  Widget _endpointTab() => ListView(
    padding: const EdgeInsets.all(20),
    children: [
      _infoBox(
        'Masukkan daftar API endpoint (satu per baris) untuk analisis pola risiko.',
        Pixel.list,
      ),
      const SizedBox(height: 16),
      TextField(
        controller: _endpointCtrl,
        maxLines: 7,
        decoration: const InputDecoration(
          labelText: 'API Endpoints',
          hintText: '/api/v1/users\n/admin/dashboard\n/api/v2/config',
          alignLabelWithHint: true,
        ),
      ),
      const SizedBox(height: 12),
      Row(
        children: [
          Expanded(
            child: FilledButton.icon(
              onPressed: _auditEndpoints,
              icon: const Icon(Pixel.play),
              label: const Text('Audit'),
            ),
          ),
          const SizedBox(width: 10),
          OutlinedButton.icon(
            onPressed: () => setState(() {
              _endpointCtrl.clear();
              _endpointResult = '';
              _endpointError = null;
            }),
            icon: const Icon(Pixel.trash),
            label: const Text('Hapus'),
          ),
        ],
      ),
      if (_endpointError != null) ...[
        const SizedBox(height: 12),
        _errorBox(_endpointError!),
      ],
      if (_endpointResult.isNotEmpty) ...[
        const SizedBox(height: 16),
        _resultCard(_endpointResult),
      ],
    ],
  );

  Widget _androidTab() => ListView(
    padding: const EdgeInsets.all(20),
    children: [
      _infoBox(
        'Tempelkan konten AndroidManifest.xml atau hanya baris <uses-permission> untuk analisis.',
        Pixel.devicephone,
      ),
      const SizedBox(height: 16),
      TextField(
        controller: _permissionCtrl,
        maxLines: 8,
        decoration: const InputDecoration(
          labelText: 'AndroidManifest.xml',
          hintText: '<uses-permission android:name="android.permission.CAMERA"/>\n<uses-permission android:name="android.permission.READ_SMS"/>',
          alignLabelWithHint: true,
        ),
      ),
      const SizedBox(height: 12),
      Row(
        children: [
          Expanded(
            child: FilledButton.icon(
              onPressed: _analyzePermissions,
              icon: const Icon(Pixel.play),
              label: const Text('Analisis'),
            ),
          ),
          const SizedBox(width: 10),
          OutlinedButton.icon(
            onPressed: () => setState(() {
              _permissionCtrl.clear();
              _permissionResult = '';
              _permissionError = null;
            }),
            icon: const Icon(Pixel.trash),
            label: const Text('Hapus'),
          ),
        ],
      ),
      if (_permissionError != null) ...[
        const SizedBox(height: 12),
        _errorBox(_permissionError!),
      ],
      if (_permissionResult.isNotEmpty) ...[
        const SizedBox(height: 16),
        _resultCard(_permissionResult),
      ],
    ],
  );

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
}
