import 'dart:ui';
import 'dart:convert';
import 'dart:math';

import 'package:crypto/crypto.dart';
import 'package:flutter/material.dart';
import 'package:pixelarticons/pixelarticons.dart';
import 'package:flutter/services.dart';

import '../app_strings.dart';
import '../models/tool.dart';
import '../services/app_controller.dart';

class ToolScreen extends StatefulWidget {
  const ToolScreen({required this.tool, super.key});
  final ToolDefinition tool;
  @override
  State<ToolScreen> createState() => _ToolScreenState();
}

class _ToolScreenState extends State<ToolScreen> {
  final _input = TextEditingController();
  final _second = TextEditingController();
  final _pattern = TextEditingController();
  String _output = '';
  String? _error;
  bool _minify = false;
  bool _globalRegex = true;
  bool _caseInsensitive = false;
  int _passwordLength = 20;

  @override
  void dispose() {
    _input.dispose();
    _second.dispose();
    _pattern.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final id = AppControllerScope.of(context).indonesian;
    final tool = widget.tool;
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
        automaticallyImplyLeading: false,
        leading: IconButton(
          tooltip: id ? 'Kembali' : 'Back',
          onPressed: () => Navigator.of(context).maybePop(),
          icon: const Icon(Pixel.chevronleft),
        ),
        title: Text(tool.name),
        actions: [
          IconButton(
            tooltip: id ? 'Favorit' : 'Favorite',
            onPressed: () =>
                AppControllerScope.of(context).toggleFavorite(tool.id),
            icon: Icon(
              AppControllerScope.of(context).favorites.contains(tool.id)
                  ? Pixel.heart
                  : Pixel.heart,
            ),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 28),
        children: [
          Container(
            padding: const EdgeInsets.all(15),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primaryContainer
                  .withValues(alpha: .48),
              borderRadius: BorderRadius.circular(18),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(tool.icon, color: Theme.of(context).colorScheme.primary),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    tool.description,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          if (!tool.local)
            _providerNotice(id)
          else ...[
            if (tool.id == 'password-generator') _passwordOptions(id),
            if (tool.id == 'uuid-generator') _uuidOptions(id),
            if (tool.id == 'regex-tester') _regexOptions(id),
            if (tool.id == 'timestamp-converter') _timestampMode(id),
            if (tool.id == 'javascript-minifier')
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Text(
                  id
                      ? 'Minifier dasar dapat mengubah kode dengan format kompleks. Periksa hasil sebelum digunakan.'
                      : 'This basic minifier can change complex code. Review the output before using it.',
                  style: Theme.of(context).textTheme.bodySmall
                      ?.copyWith(color: Theme.of(context).colorScheme.error),
                ),
              ),
            if (const {
              'json-formatter',
              'base64-converter',
              'url-encoder-decoder',
            }.contains(tool.id))
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: SegmentedButton<bool>(
                  segments: [
                    ButtonSegment(
                      value: false,
                      label: Text(id ? 'Format / Encode' : 'Format / Encode'),
                    ),
                    ButtonSegment(
                      value: true,
                      label: Text(id ? 'Minify / Decode' : 'Minify / Decode'),
                    ),
                  ],
                  selected: {_minify},
                  onSelectionChanged: (value) =>
                      setState(() => _minify = value.first),
                ),
              ),
            if (!const {
              'password-generator',
              'uuid-generator',
            }.contains(tool.id))
              TextField(
                controller: _input,
                minLines: _singleline ? 1 : (_multiline ? 5 : 2),
                maxLines: _singleline ? 1 : (_multiline ? 12 : 5),
                keyboardType: _keyboardType,
                decoration: InputDecoration(
                  labelText: _label(id),
                  hintText: _hint(id),
                  alignLabelWithHint: true,
                ),
              ),
            if (tool.id == 'diff-checker') ...[
              const SizedBox(height: 12),
              TextField(
                controller: _second,
                minLines: 4,
                maxLines: 8,
                decoration: InputDecoration(
                  labelText: id ? 'Teks yang diubah' : 'Modified text',
                  alignLabelWithHint: true,
                ),
              ),
            ],
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: FilledButton.icon(
                    onPressed: _run,
                    icon: const Icon(Pixel.play),
                    label: Text(tr(id, 'run')),
                  ),
                ),
                const SizedBox(width: 10),
                OutlinedButton.icon(
                  onPressed: _clear,
                  icon: const Icon(Pixel.trash),
                  label: Text(tr(id, 'clear')),
                ),
              ],
            ),
            if (tool.id == 'jwt-decoder')
              Padding(
                padding: const EdgeInsets.only(top: 12),
                child: Text(
                  tr(id, 'jwt_warning'),
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.error,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            if (_error != null) ...[
              const SizedBox(height: 16),
              _MessageBox(
                icon: Pixel.alert,
                color: Theme.of(context).colorScheme.error,
                text: _error!,
              ),
            ],
            if (_output.isNotEmpty) ...[
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      tr(id, 'result'),
                      style: Theme.of(context).textTheme.titleMedium
                          ?.copyWith(fontWeight: FontWeight.w800),
                    ),
                  ),
                  IconButton(
                    tooltip: tr(id, 'copy'),
                    onPressed: () async {
                      await Clipboard.setData(ClipboardData(text: _output));
                      if (mounted)
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text(tr(id, 'copied'))),
                        );
                    },
                    icon: const Icon(Pixel.copy),
                  ),
                ],
              ),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(15),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surfaceContainerHighest
                      .withValues(alpha: .58),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: SelectableText(
                  _output,
                  style: const TextStyle(fontFamily: 'monospace', height: 1.5),
                ),
              ),
            ],
            if (!_implemented) ...[
              const SizedBox(height: 14),
              _MessageBox(
                icon: Pixel.infobox,
                color: Theme.of(context).colorScheme.primary,
                text: id
                    ? 'Pemroses lokal untuk alat ini belum tersedia di aplikasi mobile.'
                    : 'A local processor for this tool is not available in the mobile app yet.',
              ),
            ],
          ],
        ],
      ),
    );
  }

  bool get _implemented => const {
    'json-formatter',
    'jwt-decoder',
    'uuid-generator',
    'password-generator',
    'base64-converter',
    'url-encoder-decoder',
    'hash-generator',
    'regex-tester',
    'diff-checker',
    'timestamp-converter',
    'url-parser',
    'http-status-checker',
    'cron-generator',
    'sql-formatter',
    'html-minifier',
    'css-minifier',
    'javascript-minifier',
    'markdown-preview',
    'color-picker',
  }.contains(widget.tool.id);
  bool get _multiline => const {
    'json-formatter',
    'jwt-decoder',
    'base64-converter',
    'diff-checker',
    'sql-formatter',
    'html-minifier',
    'css-minifier',
    'javascript-minifier',
    'markdown-preview',
  }.contains(widget.tool.id);
  bool get _singleline => const {
    'timestamp-converter',
    'http-status-checker',
    'cron-generator',
    'color-picker',
    'url-parser',
    'hash-generator',
  }.contains(widget.tool.id);

  TextInputType get _keyboardType {
    if (widget.tool.id == 'timestamp-converter' ||
        widget.tool.id == 'http-status-checker') {
      return TextInputType.number;
    }
    return _singleline ? TextInputType.text : TextInputType.multiline;
  }

  Widget _providerNotice(bool id) => _MessageBox(
    icon: Pixel.cloud,
    color: Theme.of(context).colorScheme.primary,
    text: '${tr(id, 'processing')}. ${tr(id, 'processing_detail')}',
  );

  Widget _passwordOptions(bool id) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text('${tr(id, 'length')}: $_passwordLength'),
      Slider.adaptive(
        value: _passwordLength.toDouble(),
        min: 8,
        max: 64,
        divisions: 56,
        label: '$_passwordLength',
        onChanged: (value) => setState(() => _passwordLength = value.round()),
      ),
      const SizedBox(height: 8),
    ],
  );

  Widget _uuidOptions(bool id) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(id ? 'Jumlah UUID: $_passwordLength' : 'Amount: $_passwordLength'),
      Slider.adaptive(
        value: _passwordLength.toDouble(),
        min: 1,
        max: 100,
        divisions: 99,
        label: '$_passwordLength',
        onChanged: (value) => setState(() => _passwordLength = value.round()),
      ),
      const SizedBox(height: 8),
    ],
  );

  Widget _regexOptions(bool id) => Column(
    children: [
      TextField(
        controller: _pattern,
        decoration: InputDecoration(
          labelText: id ? 'Pola regex' : 'Regex pattern',
          hintText: r'\b\w+\b',
        ),
      ),
      Row(
        children: [
          Expanded(
            child: SwitchListTile.adaptive(
              contentPadding: EdgeInsets.zero,
              title: const Text('Global (g)'),
              value: _globalRegex,
              onChanged: (value) => setState(() => _globalRegex = value),
            ),
          ),
          Expanded(
            child: SwitchListTile.adaptive(
              contentPadding: EdgeInsets.zero,
              title: const Text('Ignore case (i)'),
              value: _caseInsensitive,
              onChanged: (value) => setState(() => _caseInsensitive = value),
            ),
          ),
        ],
      ),
    ],
  );

  Widget _timestampMode(bool id) => Padding(
    padding: const EdgeInsets.only(bottom: 10),
    child: Text(
      id
          ? 'Masukkan tanggal ISO atau timestamp Unix (detik/milidetik).'
          : 'Enter an ISO date or Unix timestamp (seconds/milliseconds).',
      style: Theme.of(context).textTheme.bodySmall,
    ),
  );

  String _label(bool id) {
    if (widget.tool.id == 'diff-checker')
      return id ? 'Teks asli' : 'Original text';
    if (widget.tool.id == 'regex-tester')
      return id ? 'Teks untuk diuji' : 'Test string';
    return tr(id, 'input');
  }

  String _hint(bool id) => switch (widget.tool.id) {
    'json-formatter' => '{"name":"IMPHNEN","tools":50}',
    'jwt-decoder' => 'eyJhbGciOi...',
    'timestamp-converter' => '1710000000 atau 2026-09-29T12:00:00Z',
    'http-status-checker' => '404',
    'url-parser' => 'https://example.com/path?key=value',
    'color-picker' => '#3AA6D8',
    'cron-generator' => '*/5 * * * *',
    'hash-generator' => id ? 'Teks untuk di-hash...' : 'Text to hash...',
    _ =>
      id ? 'Tulis atau tempel teks di sini...' : 'Type or paste text here...',
  };

  void _clear() => setState(() {
    _input.clear();
    _second.clear();
    _pattern.clear();
    _output = '';
    _error = null;
  });

  void _run() {
    final input = _input.text;
    setState(() {
      _error = null;
      _output = '';
    });
    try {
      final result = switch (widget.tool.id) {
        'json-formatter' => _formatJson(input),
        'jwt-decoder' => _decodeJwt(input),
        'uuid-generator' => _generateUuids(_passwordLength.toString()),
        'password-generator' => _generatePassword(),
        'base64-converter' => _base64(input),
        'url-encoder-decoder' => _urlEncodeDecode(input),
        'hash-generator' => _hash(input),
        'regex-tester' => _testRegex(input),
        'diff-checker' => _diff(input, _second.text),
        'timestamp-converter' => _timestamp(input),
        'url-parser' => _parseUrl(input),
        'http-status-checker' => _httpStatus(input),
        'cron-generator' => _cron(input),
        'sql-formatter' => _formatSql(input),
        'html-minifier' =>
          input
              .replaceAll(RegExp(r'>\s+<'), '><')
              .replaceAll(RegExp(r'\s{2,}'), ' ')
              .trim(),
        'css-minifier' => _minifyCss(input),
        'javascript-minifier' => _minifyJs(input),
        'markdown-preview' => _markdownPreview(input),
        'color-picker' => _color(input),
        _ => throw const FormatException('Tool is unavailable.'),
      };
      setState(() => _output = result);
    } on FormatException catch (error) {
      setState(
        () => _error = error.message.isEmpty
            ? (AppControllerScope.of(context).indonesian
                  ? 'Input tidak valid. Periksa kembali lalu coba lagi.'
                  : 'Invalid input. Check it and try again.')
            : error.message,
      );
    } catch (_) {
      final id = AppControllerScope.of(context).indonesian;
      setState(
        () => _error = id
            ? 'Proses gagal. Periksa input lalu coba lagi.'
            : 'Processing failed. Check the input and try again.',
      );
    }
  }

  String _formatJson(String input) {
    final decoded = jsonDecode(input);
    return _minify
        ? jsonEncode(decoded)
        : const JsonEncoder.withIndent('  ').convert(decoded);
  }

  String _decodeJwt(String input) {
    final parts = input.trim().split('.');
    if (parts.length != 3)
      throw const FormatException(
        'JWT harus memiliki tiga bagian yang dipisahkan titik.',
      );
    dynamic decodePart(String value) =>
        jsonDecode(utf8.decode(base64Url.decode(base64Url.normalize(value))));
    return 'HEADER\n${const JsonEncoder.withIndent('  ').convert(decodePart(parts[0]))}\n\nPAYLOAD\n${const JsonEncoder.withIndent('  ').convert(decodePart(parts[1]))}\n\nSIGNATURE\n${parts[2].isEmpty ? '(kosong)' : 'Tersedia; tidak diverifikasi.'}';
  }

  String _generateUuids(String input) {
    final count = int.tryParse(input.trim());
    final amount = (count ?? 1).clamp(1, 100);
    final random = Random.secure();
    return List.generate(amount, (_) {
      final bytes = List<int>.generate(16, (_) => random.nextInt(256));
      bytes[6] = (bytes[6] & 0x0f) | 0x40;
      bytes[8] = (bytes[8] & 0x3f) | 0x80;
      final hex = bytes
          .map((byte) => byte.toRadixString(16).padLeft(2, '0'))
          .join();
      return '${hex.substring(0, 8)}-${hex.substring(8, 12)}-${hex.substring(12, 16)}-${hex.substring(16, 20)}-${hex.substring(20)}';
    }).join('\n');
  }

  String _generatePassword() {
    const chars =
        'ABCDEFGHJKLMNPQRSTUVWXYZabcdefghijkmnopqrstuvwxyz23456789!@#\$%^&*_-+=';
    final random = Random.secure();
    return List.generate(
      _passwordLength,
      (_) => chars[random.nextInt(chars.length)],
    ).join();
  }

  String _base64(String input) {
    if (_minify)
      return utf8.decode(base64.decode(base64.normalize(input.trim())));
    return base64.encode(utf8.encode(input));
  }

  String _urlEncodeDecode(String input) =>
      _minify ? Uri.decodeComponent(input) : Uri.encodeComponent(input);

  String _hash(String input) =>
      'SHA-1\n${sha1.convert(utf8.encode(input))}\n\nSHA-256\n${sha256.convert(utf8.encode(input))}\n\nSHA-512\n${sha512.convert(utf8.encode(input))}';

  String _testRegex(String input) {
    final pattern = _pattern.text;
    if (pattern.isEmpty)
      throw const FormatException('Masukkan pola regex terlebih dahulu.');
    final regex = RegExp(
      pattern,
      caseSensitive: !_caseInsensitive,
      multiLine: true,
    );
    final matches = _globalRegex
        ? regex.allMatches(input).toList()
        : [regex.firstMatch(input)].whereType<RegExpMatch>().toList();
    if (matches.isEmpty) return 'Tidak ada kecocokan.';
    return matches
        .asMap()
        .entries
        .map((entry) {
          final match = entry.value;
          final groups = [
            for (var i = 0; i <= match.groupCount; i++)
              '  $i: ${match.group(i)}',
          ].join('\n');
          return 'Match ${entry.key + 1}: ${match.group(0)} (index ${match.start}–${match.end})\n$groups';
        })
        .join('\n\n');
  }

  String _diff(String original, String modified) {
    final a = original.split('\n');
    final b = modified.split('\n');
    final length = max(a.length, b.length);
    return List.generate(length, (i) {
      if (i >= a.length) return '+ ${b[i]}';
      if (i >= b.length) return '- ${a[i]}';
      if (a[i] == b[i]) return '  ${a[i]}';
      return '- ${a[i]}\n+ ${b[i]}';
    }).join('\n');
  }

  String _timestamp(String input) {
    final numeric = int.tryParse(input.trim());
    final date = numeric != null
        ? DateTime.fromMillisecondsSinceEpoch(
            numeric.abs() < 100000000000 ? numeric * 1000 : numeric,
            isUtc: true,
          )
        : DateTime.tryParse(input.trim())?.toUtc();
    if (date == null)
      throw const FormatException('Tanggal atau timestamp tidak valid.');
    return 'UTC: ${date.toIso8601String()}\nUnix (detik): ${date.millisecondsSinceEpoch ~/ 1000}\nUnix (milidetik): ${date.millisecondsSinceEpoch}\nLokal: ${date.toLocal()}';
  }

  String _parseUrl(String input) {
    final uri = Uri.tryParse(input.trim());
    if (uri == null || uri.host.isEmpty)
      throw const FormatException('Masukkan URL lengkap, termasuk hostname.');
    return 'Protocol: ${uri.scheme}\nHostname: ${uri.host}\nPort: ${uri.hasPort ? uri.port : '(default)'}\nPathname: ${uri.path}\nQuery parameters:\n${uri.queryParameters.entries.map((e) => '  ${e.key}: ${e.value}').join('\n')}\nHash: ${uri.fragment}';
  }

  String _httpStatus(String input) {
    final code = int.tryParse(input.trim());
    if (code == null || code < 100 || code > 599)
      throw const FormatException(
        'Masukkan kode status HTTP antara 100 dan 599.',
      );
    const common = {
      200: 'OK',
      201: 'Created',
      204: 'No Content',
      301: 'Moved Permanently',
      302: 'Found',
      304: 'Not Modified',
      400: 'Bad Request',
      401: 'Unauthorized',
      403: 'Forbidden',
      404: 'Not Found',
      405: 'Method Not Allowed',
      408: 'Request Timeout',
      409: 'Conflict',
      410: 'Gone',
      418: "I'm a teapot",
      422: 'Unprocessable Content',
      429: 'Too Many Requests',
      500: 'Internal Server Error',
      501: 'Not Implemented',
      502: 'Bad Gateway',
      503: 'Service Unavailable',
      504: 'Gateway Timeout',
    };
    final group = code ~/ 100;
    final family = {
      1: 'Informational',
      2: 'Success',
      3: 'Redirection',
      4: 'Client Error',
      5: 'Server Error',
    }[group]!;
    return '$code ${common[code] ?? family}\nClass: $family';
  }

  String _cron(String input) {
    final fields = input.trim().split(RegExp(r'\s+'));
    if (fields.length != 5 ||
        fields.any((field) => !RegExp(r'^[0-9*/?,\-LW#]+$').hasMatch(field)))
      throw const FormatException(
        'Ekspresi cron harus memiliki 5 bagian: menit jam tanggal bulan hari.',
      );
    return 'Ekspresi valid (5 field):\n${fields.join(' ')}\n\nMenit: ${fields[0]}\nJam: ${fields[1]}\nTanggal: ${fields[2]}\nBulan: ${fields[3]}\nHari: ${fields[4]}';
  }

  String _formatSql(String input) {
    const keywords = [
      'SELECT',
      'FROM',
      'WHERE',
      'GROUP BY',
      'ORDER BY',
      'HAVING',
      'LIMIT',
      'OFFSET',
      'JOIN',
      'LEFT JOIN',
      'RIGHT JOIN',
      'INNER JOIN',
      'OUTER JOIN',
      'ON',
      'AND',
      'OR',
      'INSERT INTO',
      'VALUES',
      'UPDATE',
      'SET',
      'DELETE FROM',
    ];
    var sql = input.trim().replaceAll(RegExp(r'\s+'), ' ');
    for (final keyword in keywords) {
      sql = sql.replaceAll(
        RegExp('\\b${RegExp.escape(keyword)}\\b', caseSensitive: false),
        '\n$keyword',
      );
    }
    return sql.trim().split('\n').map((line) => line.trim()).join('\n');
  }

  String _minifyCss(String input) => input
      .replaceAll(RegExp(r'/\*[\s\S]*?\*/'), '')
      .replaceAll(RegExp(r'\s*([{}:;,>])\s*'), r'$1')
      .replaceAll(RegExp(r'\s+'), ' ')
      .trim();
  String _minifyJs(String input) => input
      .replaceAll(RegExp(r'//[^\n]*'), '')
      .replaceAll(RegExp(r'/\*[\s\S]*?\*/'), '')
      .replaceAll(RegExp(r'\s*([{}();,:])\s*'), r'$1')
      .replaceAll(RegExp(r'\s+'), ' ')
      .trim();
  String _markdownPreview(String input) => input
      .split('\n')
      .map((line) {
        final heading = RegExp(r'^(#{1,6})\s+(.*)$').firstMatch(line);
        if (heading != null)
          return '${heading.group(1)!.length * 2} ${heading.group(2)}';
        if (line.startsWith('>')) return '│ ${line.substring(1).trim()}';
        if (line.startsWith('- ') || line.startsWith('* '))
          return '• ${line.substring(2)}';
        if (RegExp(r'^\d+\. ').hasMatch(line)) return line;
        return line
            .replaceAll(RegExp(r'\*\*(.+?)\*\*'), r'$1')
            .replaceAll(RegExp(r'`(.+?)`'), r'$1');
      })
      .join('\n');
  String _color(String input) {
    final match = RegExp(r'^#?([0-9a-fA-F]{6})$').firstMatch(input.trim());
    if (match == null)
      throw const FormatException(
        'Masukkan warna HEX 6 digit, misalnya #3AA6D8.',
      );
    final hex = match.group(1)!;
    final r = int.parse(hex.substring(0, 2), radix: 16);
    final g = int.parse(hex.substring(2, 4), radix: 16);
    final b = int.parse(hex.substring(4, 6), radix: 16);
    final maxValue = max(r, max(g, b)) / 255;
    final minValue = min(r, min(g, b)) / 255;
    final delta = maxValue - minValue;
    final lightness = (maxValue + minValue) / 2;
    final saturation = delta == 0
        ? 0.0
        : delta / (1 - (2 * lightness - 1).abs());
    var hue = 0.0;
    if (delta != 0) {
      if (maxValue == r / 255)
        hue = ((g - b) / 255 / delta) % 6;
      else if (maxValue == g / 255)
        hue = (b - r) / 255 / delta + 2;
      else
        hue = (r - g) / 255 / delta + 4;
      hue *= 60;
      if (hue < 0) hue += 360;
    }
    return 'HEX: #${hex.toUpperCase()}\nRGB: rgb($r, $g, $b)\nHSL: hsl(${hue.round()}, ${(saturation * 100).round()}%, ${(lightness * 100).round()}%)';
  }
}

class _MessageBox extends StatelessWidget {
  const _MessageBox({
    required this.icon,
    required this.color,
    required this.text,
  });
  final IconData icon;
  final Color color;
  final String text;
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(15),
    decoration: BoxDecoration(
      color: color.withValues(alpha: .09),
      borderRadius: BorderRadius.circular(16),
    ),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: color),
        const SizedBox(width: 10),
        Expanded(
          child: Text(text, style: TextStyle(color: color, height: 1.4)),
        ),
      ],
    ),
  );
}
