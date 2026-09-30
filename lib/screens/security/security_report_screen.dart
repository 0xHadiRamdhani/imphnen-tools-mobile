import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pixelarticons/pixelarticons.dart';

import '../../services/security_workspace.dart';

class SecurityReportScreen extends StatefulWidget {
  const SecurityReportScreen({required this.workspace, super.key});
  final SecurityWorkspace workspace;

  @override
  State<SecurityReportScreen> createState() => _SecurityReportScreenState();
}

class _SecurityReportScreenState extends State<SecurityReportScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tab;
  String _reportText = '';
  String _reportType = 'Markdown';

  final _checklist = <(String, String)>[
    ('Reconnaissance', 'Lakukan footprinting dan OSINT pada target'),
    ('Scope Definition', 'Definisikan scope pengujian dengan jelas'),
    ('Port Scanning', 'Scan port dan identifikasi service yang berjalan'),
    ('Service Enumeration', 'Enumerasi versi service dan banner grabbing'),
    ('Vulnerability Scanning', 'Scan kerentanan menggunakan tools otomatis'),
    ('Authentication Testing', 'Uji mekanisme autentikasi dan otorisasi'),
    (
      'Input Validation',
      'Uji XSS, SQL Injection, dan input validation lainnya',
    ),
    ('Session Management', 'Analisis session token, cookie, dan JWT'),
    ('API Security', 'Uji keamanan API endpoint dan parameter'),
    ('Cryptography', 'Verifikasi penggunaan enkripsi yang aman'),
    (
      'Error Handling',
      'Periksa apakah error message mengekspos informasi sensitif',
    ),
    ('Logging & Monitoring', 'Verifikasi logging keamanan yang memadai'),
    ('Report Writing', 'Tulis laporan dengan findings dan rekomendasi'),
  ];
  late List<bool> _checkStates;

  @override
  void initState() {
    super.initState();
    _tab = TabController(length: 3, vsync: this);
    _checkStates = List.filled(_checklist.length, false);
  }

  @override
  void dispose() {
    _tab.dispose();
    super.dispose();
  }

  void _generateReport() {
    final ws = widget.workspace;
    final now = DateTime.now();
    final findings = ws.findings;
    final critical = findings.where((f) => f.severity == 'Critical').length;
    final high = findings.where((f) => f.severity == 'High').length;
    final medium = findings.where((f) => f.severity == 'Medium').length;
    final low = findings.where((f) => f.severity == 'Low').length;
    final scope = ws.scopeTargets.join(', ');

    final sb = StringBuffer();

    if (_reportType == 'Markdown') {
      sb.writeln('# Security Assessment Report');
      sb.writeln('');
      sb.writeln('**Date:** ${now.toLocal().toString().substring(0, 10)}');
      sb.writeln('**Scope:** ${scope.isEmpty ? "(belum diisi)" : scope}');
      sb.writeln('');
      sb.writeln('## Executive Summary');
      sb.writeln('');
      sb.writeln('Total findings: **${findings.length}**');
      sb.writeln('');
      sb.writeln('| Severity | Count |');
      sb.writeln('|----------|-------|');
      sb.writeln('| Critical | $critical |');
      sb.writeln('| High     | $high |');
      sb.writeln('| Medium   | $medium |');
      sb.writeln('| Low      | $low |');
      sb.writeln('');
      sb.writeln('## Findings');
      sb.writeln('');
      if (findings.isEmpty) {
        sb.writeln('*Belum ada temuan yang dicatat.*');
      } else {
        for (int i = 0; i < findings.length; i++) {
          final f = findings[i];
          sb.writeln('### ${i + 1}. ${f.title}');
          sb.writeln('');
          sb.writeln('- **Severity:** ${f.severity}');
          sb.writeln('- **Asset:** ${f.asset}');
          sb.writeln('- **Status:** ${f.status}');
          if (f.notes.isNotEmpty) sb.writeln('- **Notes:** ${f.notes}');
          sb.writeln('');
        }
      }
    } else if (_reportType == 'Executive') {
      sb.writeln('EXECUTIVE SUMMARY REPORT');
      sb.writeln('========================');
      sb.writeln('');
      sb.writeln('Date    : ${now.toLocal().toString().substring(0, 10)}');
      sb.writeln('Scope   : ${scope.isEmpty ? "(belum diisi)" : scope}');
      sb.writeln('');
      sb.writeln('RISK OVERVIEW');
      sb.writeln('-------------');
      final riskLevel = critical > 0
          ? 'CRITICAL'
          : high > 0
          ? 'HIGH'
          : medium > 0
          ? 'MEDIUM'
          : 'LOW';
      sb.writeln('Overall Risk Level : $riskLevel');
      sb.writeln('Total Findings     : ${findings.length}');
      sb.writeln('  Critical : $critical');
      sb.writeln('  High     : $high');
      sb.writeln('  Medium   : $medium');
      sb.writeln('  Low      : $low');
      sb.writeln('');
      sb.writeln('KEY FINDINGS');
      sb.writeln('------------');
      if (findings.isEmpty) {
        sb.writeln('Tidak ada temuan yang dicatat.');
      } else {
        final urgent = findings
            .where((f) => f.severity == 'Critical' || f.severity == 'High')
            .toList();
        if (urgent.isEmpty) {
          sb.writeln('Tidak ada temuan Critical/High.');
        }
        for (int i = 0; i < urgent.length && i < 5; i++) {
          sb.writeln(
            '${i + 1}. [${urgent[i].severity}] ${urgent[i].title} (${urgent[i].asset})',
          );
        }
      }
    } else {
      // Technical
      sb.writeln('TECHNICAL SECURITY REPORT');
      sb.writeln('=========================');
      sb.writeln('Generated : ${now.toIso8601String()}');
      sb.writeln('Scope     : ${scope.isEmpty ? "(belum diisi)" : scope}');
      sb.writeln('Assets    : ${ws.assets.length}');
      sb.writeln('Evidence  : ${ws.evidence.length}');
      sb.writeln('');
      if (findings.isEmpty) {
        sb.writeln('Tidak ada findings yang dicatat.');
      }
      for (int i = 0; i < findings.length; i++) {
        final f = findings[i];
        sb.writeln('[FINDING-${(i + 1).toString().padLeft(3, '0')}]');
        sb.writeln('ID        : ${f.id}');
        sb.writeln('Title     : ${f.title}');
        sb.writeln('Severity  : ${f.severity}');
        sb.writeln('Asset     : ${f.asset}');
        sb.writeln('Status    : ${f.status}');
        if (f.notes.isNotEmpty) sb.writeln('Notes     : ${f.notes}');
        sb.writeln('Created   : ${f.created.toIso8601String()}');
        sb.writeln('---');
      }
    }

    setState(() => _reportText = sb.toString());
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
        title: const Text('Copilot & Reports'),
        bottom: TabBar(
          controller: _tab,
          tabs: const [
            Tab(text: 'Report Generator'),
            Tab(text: 'Checklist'),
            Tab(text: 'Tips'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tab,
        children: [_reportTab(), _checklistTab(), _tipsTab()],
      ),
    );
  }

  Widget _reportTab() {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        _infoBox(
          'Generate laporan security dari workspace aktif. Data diambil dari findings yang sudah dicatat.',
          Pixel.analytics,
        ),
        const SizedBox(height: 16),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Ringkasan Workspace',
                  style: Theme.of(context).textTheme.titleSmall
                      ?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text(
                  'Scope    : ${widget.workspace.scopeTargets.isEmpty ? "(belum diisi)" : widget.workspace.scopeTargets.length.toString() + " target"}',
                ),
                Text('Assets   : ${widget.workspace.assets.length}'),
                Text('Findings : ${widget.workspace.findings.length}'),
                Text('Evidence : ${widget.workspace.evidence.length}'),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        SegmentedButton<String>(
          segments: const [
            ButtonSegment(value: 'Markdown', label: Text('Markdown')),
            ButtonSegment(value: 'Executive', label: Text('Executive')),
            ButtonSegment(value: 'Technical', label: Text('Technical')),
          ],
          selected: {_reportType},
          onSelectionChanged: (s) => setState(() => _reportType = s.first),
        ),
        const SizedBox(height: 12),
        FilledButton.icon(
          onPressed: _generateReport,
          icon: const Icon(Pixel.analytics),
          label: const Text('Generate Report'),
        ),
        if (_reportText.isNotEmpty) ...[
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: Text(
                  'Laporan',
                  style: Theme.of(context).textTheme.titleMedium
                      ?.copyWith(fontWeight: FontWeight.w800),
                ),
              ),
              IconButton(
                icon: const Icon(Pixel.copy),
                tooltip: 'Salin laporan',
                onPressed: () async {
                  await Clipboard.setData(ClipboardData(text: _reportText));
                  if (mounted)
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Laporan disalin ke clipboard'),
                      ),
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
              _reportText,
              style: const TextStyle(
                fontFamily: 'monospace',
                fontSize: 12,
                height: 1.6,
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _checklistTab() {
    final done = _checkStates.where((v) => v).length;
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        _infoBox(
          'Gunakan checklist ini sebagai panduan selama proses pengujian.',
          Pixel.check,
        ),
        const SizedBox(height: 12),
        LinearProgressIndicator(value: done / _checklist.length),
        const SizedBox(height: 4),
        Text(
          '$done/${_checklist.length} selesai',
          style: const TextStyle(fontSize: 12),
        ),
        const SizedBox(height: 12),
        ..._checklist.asMap().entries.map((e) {
          final idx = e.key;
          final item = e.value;
          return Card(
            margin: const EdgeInsets.only(bottom: 6),
            child: CheckboxListTile(
              value: _checkStates[idx],
              onChanged: (v) => setState(() => _checkStates[idx] = v ?? false),
              title: Text(
                item.$1,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  decoration: _checkStates[idx]
                      ? TextDecoration.lineThrough
                      : null,
                ),
              ),
              subtitle: Text(item.$2),
              controlAffinity: ListTileControlAffinity.leading,
            ),
          );
        }),
        const SizedBox(height: 8),
        OutlinedButton.icon(
          onPressed: () => setState(
            () => _checkStates = List.filled(_checklist.length, false),
          ),
          icon: const Icon(Pixel.trash),
          label: const Text('Reset Checklist'),
        ),
      ],
    );
  }

  Widget _tipsTab() {
    final tips = [
      (
        '🔍 Reconnaissance',
        'Mulai dari passive recon (OSINT, crt.sh, shodan) sebelum active scanning. Dokumentasikan semua yang Anda temukan.',
      ),
      (
        '🛡️ Scope & Authorization',
        'Selalu pastikan Anda memiliki izin tertulis sebelum melakukan pengujian. Bug bounty scope harus dibaca dengan teliti.',
      ),
      (
        '🔐 Authentication Bugs',
        'Uji: password spraying, credential stuffing, MFA bypass, dan session fixation.',
      ),
      (
        '💉 Injection Testing',
        'Uji XSS (reflected, stored, DOM), SQLi, Command Injection, SSTI, XXE, dan SSRF.',
      ),
      (
        '🔑 JWT Testing',
        'Periksa algorithm "none", weak secrets (brute force), claim manipulation (role/id), dan expired tokens.',
      ),
      (
        '📱 Mobile (Android)',
        'Periksa: exported components, hardcoded secrets, insecure storage, network security config, dan dynamic analysis.',
      ),
      (
        '🔗 API Testing',
        'Uji: BOLA (IDOR), BFLA, mass assignment, rate limiting bypass, dan improper error handling.',
      ),
      (
        '📝 Reporting',
        'Gunakan format: Title, Severity, Description, Steps to Reproduce, Impact, Recommendation. Sertakan PoC yang jelas.',
      ),
    ];
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        _infoBox(
          'Tips dan best practices untuk penetration testing yang efektif.',
          Pixel.bookopen,
        ),
        const SizedBox(height: 16),
        ...tips.map(
          (t) => Card(
            margin: const EdgeInsets.only(bottom: 10),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    t.$1,
                    style: const TextStyle(
                      fontWeight: FontWeight.w800,
                      fontSize: 15,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(t.$2, style: const TextStyle(height: 1.5)),
                ],
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
}
