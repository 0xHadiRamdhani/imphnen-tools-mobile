import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:pixelarticons/pixelarticons.dart';

import '../services/security_workspace.dart';
import '../widgets/screen_header.dart';

import 'security/api_mobile_screen.dart';
import 'security/network_scanner_screen.dart';
import 'security/recon_screen.dart';
import 'security/secrets_intel_screen.dart';
import 'security/crypto_screen.dart';
import 'security/password_screen.dart';
import 'security/security_report_screen.dart';

class SecurityScreen extends StatefulWidget {
  const SecurityScreen({required this.workspace, super.key});
  final SecurityWorkspace workspace;

  @override
  State<SecurityScreen> createState() => _SecurityScreenState();
}

class _SecurityScreenState extends State<SecurityScreen> {
  String _section = 'Overview';

  @override
  Widget build(BuildContext context) {
    final workspace = widget.workspace;
    return AnimatedBuilder(
      animation: workspace,
      builder: (context, _) {
        final critical = workspace.findings
            .where((f) => f.severity == 'Critical')
            .length;
        final high = workspace.findings
            .where((f) => f.severity == 'High')
            .length;
        return CustomScrollView(
          slivers: [
            SliverPadding(
              padding: EdgeInsets.fromLTRB(
                20,
                20,
                20,
                24 + MediaQuery.paddingOf(context).bottom,
              ),
              sliver: SliverList.list(
                children: [
                  const ScreenHeader(
                    title: 'Security Center',
                    subtitle: 'Authorized testing workspace',
                    icon: Pixel.shield,
                  ),
                  const SizedBox(height: 18),
                  _ScopeCard(workspace: workspace, onAdd: _addScope),
                  const SizedBox(height: 18),
                  SizedBox(
                    height: 40,
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      children: ['Overview', 'Assets', 'Findings', 'Evidence']
                          .map(
                            (item) => Padding(
                              padding: const EdgeInsets.only(right: 8),
                              child: ChoiceChip(
                                label: Text(item),
                                selected: _section == item,
                                onSelected: (_) =>
                                    setState(() => _section = item),
                              ),
                            ),
                          )
                          .toList(),
                    ),
                  ),
                  const SizedBox(height: 14),
                  if (_section == 'Overview') ...[
                    Text(
                      'Security overview',
                      style: Theme.of(context).textTheme.titleMedium
                          ?.copyWith(fontWeight: FontWeight.w800),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Expanded(
                          child: _MetricCard(
                            label: 'Assets',
                            value: '${workspace.assets.length}',
                            icon: Pixel.folder,
                            color: const Color(0xFF63B7C4),
                          ),
                        ),
                        const SizedBox(width: 9),
                        Expanded(
                          child: _MetricCard(
                            label: 'Findings',
                            value: '${workspace.findings.length}',
                            icon: Pixel.alert,
                            color: const Color(0xFFEA9A70),
                          ),
                        ),
                        const SizedBox(width: 9),
                        Expanded(
                          child: _MetricCard(
                            label: 'Evidence',
                            value: '${workspace.evidence.length}',
                            icon: Pixel.filemultiple,
                            color: const Color(0xFF9B82D2),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(15),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Finding severity',
                              style: Theme.of(context).textTheme.titleSmall
                                  ?.copyWith(fontWeight: FontWeight.w800),
                            ),
                            const SizedBox(height: 12),
                            Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children: [
                                _SeverityPill(
                                  'Critical',
                                  critical,
                                  const Color(0xFFE2677A),
                                ),
                                _SeverityPill(
                                  'High',
                                  high,
                                  const Color(0xFFE99864),
                                ),
                                _SeverityPill(
                                  'Medium',
                                  workspace.findings
                                      .where((f) => f.severity == 'Medium')
                                      .length,
                                  const Color(0xFFE0B64D),
                                ),
                                _SeverityPill(
                                  'Low',
                                  workspace.findings
                                      .where((f) => f.severity == 'Low')
                                      .length,
                                  const Color(0xFF62B7A1),
                                ),
                                _SeverityPill(
                                  'Info',
                                  workspace.findings
                                      .where(
                                        (f) => f.severity == 'Informational',
                                      )
                                      .length,
                                  const Color(0xFF7995D7),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            'Security modules',
                            style: Theme.of(context).textTheme.titleMedium
                                ?.copyWith(fontWeight: FontWeight.w800),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFF65B892)
                                .withValues(alpha: .15),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Text(
                            'Active',
                            style: TextStyle(
                              fontSize: 11,
                              color: Color(0xFF65B892),
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    _ActiveModuleTile(
                      icon: Pixel.search,
                      title: 'Recon & DNS',
                      subtitle:
                          'Domain analyzer, HTTP header audit, cert links',
                      color: const Color(0xFF5A9BD5),
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute<void>(
                          builder: (_) => const ReconScreen(),
                        ),
                      ),
                    ),
                    _ActiveModuleTile(
                      icon: Pixel.radiotower,
                      title: 'Network & Web Scanner',
                      subtitle: 'Port lookup, port reference, test payloads',
                      color: const Color(0xFF63B7C4),
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute<void>(
                          builder: (_) => const NetworkScannerScreen(),
                        ),
                      ),
                    ),
                    _ActiveModuleTile(
                      icon: Pixel.devicephone,
                      title: 'API & Mobile Security',
                      subtitle: 'JWT analyzer, API endpoint audit, Android permissions',
                      color: const Color(0xFF9B82D2),
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute<void>(
                          builder: (_) => ApiMobileSecurityScreen(),
                        ),
                      ),
                    ),
                    _ActiveModuleTile(
                      icon: Pixel.lock,
                      title: 'Secrets & CVE Intelligence',
                      subtitle: 'Secrets scanner, CVE lookup & reference',
                      color: const Color(0xFFD25757),
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute<void>(
                          builder: (_) => const SecretsIntelScreen(),
                        ),
                      ),
                    ),
                    _ActiveModuleTile(
                      icon: Pixel.analytics,
                      title: 'Copilot & Reports',
                      subtitle: 'Report generator & security checklists',
                      color: const Color(0xFFEA9A70),
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute<void>(
                          builder: (_) =>
                              SecurityReportScreen(workspace: workspace),
                        ),
                      ),
                    ),
                  ] else if (_section == 'Assets') ...[
                    _SectionHeader(
                      title: 'Assets',
                      action: 'Add asset',
                      onPressed: workspace.scopeTargets.isEmpty
                          ? null
                          : _addAsset,
                    ),
                    if (workspace.assets.isEmpty)
                      const _EmptyState(
                        text: 'Tambahkan target yang sudah masuk scope untuk membuat inventaris aset.',
                      ),
                    ...workspace.assets.map(
                      (asset) => _DataTile(
                        icon: Pixel.server,
                        title: asset.target,
                        subtitle: '${asset.type} · Authorized scope',
                      ),
                    ),
                  ] else if (_section == 'Findings') ...[
                    _SectionHeader(
                      title: 'Findings',
                      action: 'Add finding',
                      onPressed: workspace.assets.isEmpty ? null : _addFinding,
                    ),
                    if (workspace.findings.isEmpty)
                      const _EmptyState(
                        text: 'Belum ada finding. Catat hasil temuan secara manual; aplikasi belum menjalankan scanner.',
                      ),
                    ...workspace.findings.map(
                      (finding) => _DataTile(
                        icon: Pixel.alert,
                        title: finding.title,
                        subtitle:
                            '${finding.severity} · ${finding.status} · ${finding.asset}',
                      ),
                    ),
                  ] else ...[
                    _SectionHeader(
                      title: 'Evidence',
                      action: 'Add evidence',
                      onPressed: _addEvidence,
                    ),
                    if (workspace.evidence.isEmpty)
                      const _EmptyState(
                        text: 'Simpan catatan atau output teknis sebagai evidence lokal.',
                      ),
                    ...workspace.evidence.map(
                      (item) => _DataTile(
                        icon: Pixel.file,
                        title: item.title,
                        subtitle:
                            '${item.findingId ?? 'General evidence'} · ${_date(item.created)}',
                      ),
                    ),
                  ],
                  const SizedBox(height: 20),
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.secondaryContainer
                          .withValues(alpha: .45),
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(
                          Pixel.infobox,
                          size: 19,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                        const SizedBox(width: 10),
                        const Expanded(
                          child: Text(
                            'Data disimpan lokal di perangkat. Tidak ada pemindaian jaringan otomatis; target harus dinyatakan masuk scope sebelum dapat dicatat sebagai aset.',
                            style: TextStyle(fontSize: 12, height: 1.35),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  Future<void> _addScope() async {
    final target = TextEditingController();
    var authorized = false;
    var excluded = false;
    final ok = await showAdaptiveDialog<bool>(
      context: context,
      builder: (dialogContext) {
        final isIOS = Theme.of(context).platform == TargetPlatform.iOS;
        return StatefulBuilder(
          builder: (context, refresh) => AlertDialog.adaptive(
            title: const Text('Define authorized scope'),
            content: Material(
              color: Colors.transparent,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const SizedBox(height: 12),
                  TextField(
                    controller: target,
                    decoration: const InputDecoration(hintText: 'example.com'),
                    keyboardType: TextInputType.url,
                  ),
                  const SizedBox(height: 8),
                  GestureDetector(
                    onTap: () => refresh(() => excluded = !excluded),
                    child: Row(
                      children: [
                        Checkbox.adaptive(
                          value: excluded,
                          onChanged: (value) =>
                              refresh(() => excluded = value ?? false),
                        ),
                        const Expanded(
                          child: Text(
                            'Mark as excluded target',
                            textAlign: TextAlign.left,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (!excluded)
                    GestureDetector(
                      onTap: () => refresh(() => authorized = !authorized),
                      child: Row(
                        children: [
                          Checkbox.adaptive(
                            value: authorized,
                            onChanged: (value) =>
                                refresh(() => authorized = value ?? false),
                          ),
                          const Expanded(
                            child: Text(
                              'I am authorized to test this target',
                              textAlign: TextAlign.left,
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
            actions: [
              if (isIOS) ...[
                CupertinoDialogAction(
                  onPressed: () => Navigator.pop(dialogContext, false),
                  child: const Text('Cancel'),
                ),
                CupertinoDialogAction(
                  isDefaultAction: true,
                  onPressed: () => Navigator.pop(dialogContext, true),
                  child: const Text('Save'),
                ),
              ] else ...[
                TextButton(
                  onPressed: () => Navigator.pop(dialogContext, false),
                  child: const Text('Cancel'),
                ),
                FilledButton(
                  onPressed: () => Navigator.pop(dialogContext, true),
                  child: const Text('Save'),
                ),
              ],
            ],
          ),
        );
      },
    );
    if (ok != true) return;
    if (!excluded && !authorized) {
      _message('Confirm authorization before adding an in-scope target.');
      return;
    }
    final saved = await widget.workspace.addScopeTarget(
      target.text,
      excluded: excluded,
    );
    if (!saved) {
      _message(
        'Target invalid or already listed. Use a domain such as example.com.',
      );
    }
    target.dispose();
  }

  Future<void> _addAsset() async {
    final target = TextEditingController();
    var type = 'Domain';
    final ok = await showAdaptiveDialog<bool>(
      context: context,
      builder: (dialogContext) {
        final isIOS = Theme.of(context).platform == TargetPlatform.iOS;
        return StatefulBuilder(
          builder: (context, refresh) => AlertDialog.adaptive(
            title: const Text('Add scoped asset'),
            content: Material(
              color: Colors.transparent,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: target,
                    decoration: const InputDecoration(
                      labelText: 'Domain / subdomain',
                    ),
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    initialValue: type,
                    items: const ['Domain', 'Subdomain', 'API']
                        .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                        .toList(),
                    onChanged: (value) => refresh(() => type = value ?? type),
                  ),
                ],
              ),
            ),
            actions: [
              if (isIOS) ...[
                CupertinoDialogAction(
                  onPressed: () => Navigator.pop(dialogContext, false),
                  child: const Text('Cancel'),
                ),
                CupertinoDialogAction(
                  isDefaultAction: true,
                  onPressed: () => Navigator.pop(dialogContext, true),
                  child: const Text('Add'),
                ),
              ] else ...[
                TextButton(
                  onPressed: () => Navigator.pop(dialogContext, false),
                  child: const Text('Cancel'),
                ),
                FilledButton(
                  onPressed: () => Navigator.pop(dialogContext, true),
                  child: const Text('Add'),
                ),
              ],
            ],
          ),
        );
      },
    );
    if (ok != true) return;
    final saved = await widget.workspace.addAsset(target.text, type);
    if (!saved) {
      _message(
        widget.workspace.isAuthorized(target.text)
            ? 'Asset is invalid or already recorded.'
            : 'Blocked: target is outside the declared authorized scope.',
      );
    }
    target.dispose();
  }

  Future<void> _addFinding() async {
    final title = TextEditingController();
    final notes = TextEditingController();
    var asset = widget.workspace.assets.first.target;
    var severity = 'Medium';
    final ok = await showAdaptiveDialog<bool>(
      context: context,
      builder: (dialogContext) {
        final isIOS = Theme.of(context).platform == TargetPlatform.iOS;
        return StatefulBuilder(
          builder: (context, refresh) => AlertDialog.adaptive(
            title: const Text('Record finding'),
            content: Material(
              color: Colors.transparent,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: title,
                      decoration: const InputDecoration(labelText: 'Title'),
                    ),
                    const SizedBox(height: 10),
                    DropdownButtonFormField<String>(
                      initialValue: asset,
                      decoration: const InputDecoration(
                        labelText: 'Scoped asset',
                      ),
                      items: widget.workspace.assets
                          .map(
                            (e) => DropdownMenuItem(
                              value: e.target,
                              child: Text(
                                e.target,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          )
                          .toList(),
                      onChanged: (value) =>
                          refresh(() => asset = value ?? asset),
                    ),
                    const SizedBox(height: 10),
                    DropdownButtonFormField<String>(
                      initialValue: severity,
                      decoration: const InputDecoration(labelText: 'Severity'),
                      items:
                          const [
                                'Critical',
                                'High',
                                'Medium',
                                'Low',
                                'Informational',
                              ]
                              .map(
                                (e) =>
                                    DropdownMenuItem(value: e, child: Text(e)),
                              )
                              .toList(),
                      onChanged: (value) =>
                          refresh(() => severity = value ?? severity),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: notes,
                      maxLines: 3,
                      decoration: const InputDecoration(
                        labelText: 'Notes / evidence context',
                      ),
                    ),
                    _ActiveModuleTile(
                      icon: Pixel.code,
                      title: 'Cryptography & Encoders',
                      subtitle: 'Hash generator, Base64, URL Encode',
                      color: const Color(0xFFE99864),
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute<void>(
                          builder: (_) => const CryptoScreen(),
                        ),
                      ),
                    ),
                    _ActiveModuleTile(
                      icon: Pixel.lock,
                      title: 'Password Tools',
                      subtitle: 'Generator & Strength Checker',
                      color: const Color(0xFF62B7A1),
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute<void>(
                          builder: (_) => const PasswordScreen(),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            actions: [
              if (isIOS) ...[
                CupertinoDialogAction(
                  onPressed: () => Navigator.pop(dialogContext, false),
                  child: const Text('Cancel'),
                ),
                CupertinoDialogAction(
                  isDefaultAction: true,
                  onPressed: () => Navigator.pop(dialogContext, true),
                  child: const Text('Save'),
                ),
              ] else ...[
                TextButton(
                  onPressed: () => Navigator.pop(dialogContext, false),
                  child: const Text('Cancel'),
                ),
                FilledButton(
                  onPressed: () => Navigator.pop(dialogContext, true),
                  child: const Text('Save'),
                ),
              ],
            ],
          ),
        );
      },
    );
    if (ok == true && title.text.trim().isNotEmpty) {
      await widget.workspace.addFinding(
        title: title.text.trim(),
        severity: severity,
        asset: asset,
        notes: notes.text.trim(),
      );
    }
    title.dispose();
    notes.dispose();
  }

  Future<void> _addEvidence() async {
    final title = TextEditingController();
    final content = TextEditingController();
    String? findingId;
    final ok = await showAdaptiveDialog<bool>(
      context: context,
      builder: (dialogContext) {
        final isIOS = Theme.of(context).platform == TargetPlatform.iOS;
        return StatefulBuilder(
          builder: (context, refresh) => AlertDialog.adaptive(
            title: const Text('Add local evidence'),
            content: Material(
              color: Colors.transparent,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: title,
                      decoration: const InputDecoration(
                        labelText: 'Evidence title',
                      ),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: content,
                      maxLines: 5,
                      decoration: const InputDecoration(
                        labelText: 'Notes / text / scanner output',
                      ),
                    ),
                    if (widget.workspace.findings.isNotEmpty) ...[
                      const SizedBox(height: 10),
                      DropdownButtonFormField<String?>(
                        initialValue: findingId,
                        decoration: const InputDecoration(
                          labelText: 'Link to finding (optional)',
                        ),
                        items: [
                          const DropdownMenuItem<String?>(
                            value: null,
                            child: Text('Unlinked'),
                          ),
                          ...widget.workspace.findings.map(
                            (f) => DropdownMenuItem<String?>(
                              value: f.id,
                              child: Text(
                                f.title,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ),
                        ],
                        onChanged: (value) => refresh(() => findingId = value),
                      ),
                    ],
                  ],
                ),
              ),
            ),
            actions: [
              if (isIOS) ...[
                CupertinoDialogAction(
                  onPressed: () => Navigator.pop(dialogContext, false),
                  child: const Text('Cancel'),
                ),
                CupertinoDialogAction(
                  isDefaultAction: true,
                  onPressed: () => Navigator.pop(dialogContext, true),
                  child: const Text('Save'),
                ),
              ] else ...[
                TextButton(
                  onPressed: () => Navigator.pop(dialogContext, false),
                  child: const Text('Cancel'),
                ),
                FilledButton(
                  onPressed: () => Navigator.pop(dialogContext, true),
                  child: const Text('Save'),
                ),
              ],
            ],
          ),
        );
      },
    );
    if (ok == true &&
        title.text.trim().isNotEmpty &&
        content.text.trim().isNotEmpty) {
      await widget.workspace.addEvidence(
        title: title.text.trim(),
        content: content.text.trim(),
        findingId: findingId,
      );
    }
    title.dispose();
    content.dispose();
  }

  void _message(String text) =>
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text)));
}

class _ScopeCard extends StatelessWidget {
  const _ScopeCard({required this.workspace, required this.onAdd});
  final SecurityWorkspace workspace;
  final VoidCallback onAdd;
  @override
  Widget build(BuildContext context) => Card(
    color: Theme.of(context).colorScheme.primaryContainer
        .withValues(alpha: .36),
    child: Padding(
      padding: const EdgeInsets.all(15),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const _AnimeSticker(
                icon: Pixel.shield,
                color: Color(0xFF65B892),
                size: 32,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Authorized scope',
                  style: Theme.of(context).textTheme.titleSmall
                      ?.copyWith(fontWeight: FontWeight.w800),
                ),
              ),
              TextButton.icon(
                onPressed: onAdd,
                icon: const Icon(Pixel.plus, size: 17),
                label: const Text('Define'),
              ),
            ],
          ),
          if (workspace.scopeTargets.isEmpty)
            const Text(
              'No authorized targets yet. Scanning stays blocked until you declare scope.',
              style: TextStyle(fontSize: 12, height: 1.3),
            )
          else
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: workspace.scopeTargets
                  .map(
                    (target) => Chip(
                      avatar: const Icon(Pixel.shield, size: 15),
                      label: Text(target),
                      visualDensity: VisualDensity.compact,
                    ),
                  )
                  .toList(),
            ),
          if (workspace.excludedTargets.isNotEmpty) ...[
            const SizedBox(height: 5),
            Text(
              'Excluded: ${workspace.excludedTargets.join(', ')}',
              style: Theme.of(context).textTheme.bodySmall
                  ?.copyWith(color: Theme.of(context).colorScheme.error),
            ),
          ],
        ],
      ),
    ),
  );
}

class _MetricCard extends StatelessWidget {
  const _MetricCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });
  final String label, value;
  final IconData icon;
  final Color color;
  @override
  Widget build(BuildContext context) => Card(
    child: Padding(
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _AnimeSticker(icon: icon, color: color, size: 32),
          const SizedBox(height: 9),
          Text(
            value,
            style: Theme.of(context).textTheme.titleLarge
                ?.copyWith(fontWeight: FontWeight.w900),
          ),
          Text(
            label,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    ),
  );
}

class _SeverityPill extends StatelessWidget {
  const _SeverityPill(this.label, this.count, this.color);
  final String label;
  final int count;
  final Color color;
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
    decoration: BoxDecoration(
      color: color.withValues(alpha: .13),
      borderRadius: BorderRadius.circular(18),
    ),
    child: Text(
      '$label  $count',
      style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.w800),
    ),
  );
}

class _ModuleTile extends StatelessWidget {
  const _ModuleTile({
    required this.icon,
    required this.title,
    required this.subtitle,
  });
  final IconData icon;
  final String title, subtitle;
  @override
  Widget build(BuildContext context) => Card(
    child: ListTile(
      leading: _AnimeSticker(
        icon: icon,
        color: Theme.of(context).colorScheme.primary,
        size: 38,
      ),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w700)),
      subtitle: Text(subtitle),
      trailing: const Icon(Pixel.lock, size: 17),
    ),
  );
}

class _ActiveModuleTile extends StatelessWidget {
  const _ActiveModuleTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.onTap,
  });
  final IconData icon;
  final String title, subtitle;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Card(
    child: InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        child: Row(
          children: [
            _AnimeSticker(icon: icon, color: color, size: 42),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Pixel.chevronright,
              size: 18,
              color: color.withValues(alpha: .7),
            ),
          ],
        ),
      ),
    ),
  );
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({
    required this.title,
    required this.action,
    required this.onPressed,
  });
  final String title, action;
  final VoidCallback? onPressed;
  @override
  Widget build(BuildContext context) => Row(
    children: [
      Expanded(
        child: Text(
          title,
          style: Theme.of(context).textTheme.titleMedium
              ?.copyWith(fontWeight: FontWeight.w800),
        ),
      ),
      TextButton.icon(
        onPressed: onPressed,
        icon: const Icon(Pixel.plus, size: 17),
        label: Text(action),
      ),
    ],
  );
}

class _DataTile extends StatelessWidget {
  const _DataTile({
    required this.icon,
    required this.title,
    required this.subtitle,
  });
  final IconData icon;
  final String title, subtitle;
  @override
  Widget build(BuildContext context) => Card(
    child: ListTile(
      leading: _AnimeSticker(
        icon: icon,
        color: Theme.of(context).colorScheme.primary,
        size: 38,
      ),
      title: Text(title, maxLines: 2, overflow: TextOverflow.ellipsis),
      subtitle: Text(subtitle, maxLines: 2, overflow: TextOverflow.ellipsis),
    ),
  );
}

class _AnimeSticker extends StatelessWidget {
  const _AnimeSticker({
    required this.icon,
    required this.color,
    this.size = 38,
  });
  final IconData icon;
  final Color color;
  final double size;

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: (dark ? const Color(0xFF211D32) : Colors.white).withValues(
          alpha: .9,
        ),
        borderRadius: BorderRadius.circular(size * .34),
        border: Border.all(color: color.withValues(alpha: .4), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: .16),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Icon(icon, size: size * .52, color: color),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.text});
  final String text;
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 12),
    child: Center(
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant),
      ),
    ),
  );
}

String _date(DateTime date) =>
    '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
