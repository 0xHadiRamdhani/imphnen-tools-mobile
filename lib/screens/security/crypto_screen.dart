import 'dart:convert';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:crypto/crypto.dart';
import 'package:pixelarticons/pixelarticons.dart';

class CryptoScreen extends StatefulWidget {
  const CryptoScreen({super.key});

  @override
  State<CryptoScreen> createState() => _CryptoScreenState();
}

class _CryptoScreenState extends State<CryptoScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tab;

  // Hash Generator
  final _hashCtrl = TextEditingController();
  String _hashResultMd5 = '';
  String _hashResultSha1 = '';
  String _hashResultSha256 = '';

  // Encoders
  final _encCtrl = TextEditingController();
  String _encBase64 = '';
  String _encUrl = '';
  String _encHex = '';

  @override
  void initState() {
    super.initState();
    _tab = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tab.dispose();
    _hashCtrl.dispose();
    _encCtrl.dispose();
    super.dispose();
  }

  void _generateHashes() {
    final raw = _hashCtrl.text;
    if (raw.isEmpty) {
      setState(() {
        _hashResultMd5 = '';
        _hashResultSha1 = '';
        _hashResultSha256 = '';
      });
      return;
    }

    final bytes = utf8.encode(raw);

    setState(() {
      _hashResultMd5 = md5.convert(bytes).toString();
      _hashResultSha1 = sha1.convert(bytes).toString();
      _hashResultSha256 = sha256.convert(bytes).toString();
    });
  }

  void _generateEncodings() {
    final raw = _encCtrl.text;
    if (raw.isEmpty) {
      setState(() {
        _encBase64 = '';
        _encUrl = '';
        _encHex = '';
      });
      return;
    }

    final bytes = utf8.encode(raw);

    setState(() {
      _encBase64 = base64.encode(bytes);
      _encUrl = Uri.encodeComponent(raw);
      _encHex = bytes.map((b) => b.toRadixString(16).padLeft(2, '0')).join('');
    });
  }

  void _copy(String text) {
    if (text.isEmpty) return;
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
        title: const Text('Cryptography & Encoders'),
        titleTextStyle: theme.textTheme.titleMedium?.copyWith(
          fontWeight: FontWeight.w800,
        ),
        bottom: TabBar(
          controller: _tab,
          tabs: const [
            Tab(text: 'Hashes', icon: Icon(Pixel.lock)),
            Tab(text: 'Encoders', icon: Icon(Pixel.code)),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tab,
        children: [_buildHashTab(theme), _buildEncoderTab(theme)],
      ),
    );
  }

  Widget _buildHashTab(ThemeData theme) {
    return ListView(
      padding: EdgeInsets.fromLTRB(
        20,
        20,
        20,
        40 + MediaQuery.paddingOf(context).bottom,
      ),
      children: [
        const Text('Input Text', style: TextStyle(fontWeight: FontWeight.w700)),
        const SizedBox(height: 8),
        TextField(
          controller: _hashCtrl,
          maxLines: 4,
          onChanged: (_) => _generateHashes(),
          decoration: const InputDecoration(
            hintText: 'Masukkan teks yang ingin di-hash...',
          ),
        ),
        const SizedBox(height: 24),
        if (_hashResultMd5.isNotEmpty) ...[
          _buildResultCard(theme, 'MD5', _hashResultMd5),
          const SizedBox(height: 12),
          _buildResultCard(theme, 'SHA-1', _hashResultSha1),
          const SizedBox(height: 12),
          _buildResultCard(theme, 'SHA-256', _hashResultSha256),
        ],
      ],
    );
  }

  Widget _buildEncoderTab(ThemeData theme) {
    return ListView(
      padding: EdgeInsets.fromLTRB(
        20,
        20,
        20,
        40 + MediaQuery.paddingOf(context).bottom,
      ),
      children: [
        const Text('Input Text', style: TextStyle(fontWeight: FontWeight.w700)),
        const SizedBox(height: 8),
        TextField(
          controller: _encCtrl,
          maxLines: 4,
          onChanged: (_) => _generateEncodings(),
          decoration: const InputDecoration(
            hintText: 'Masukkan teks untuk di-encode...',
          ),
        ),
        const SizedBox(height: 24),
        if (_encBase64.isNotEmpty) ...[
          _buildResultCard(theme, 'Base64', _encBase64),
          const SizedBox(height: 12),
          _buildResultCard(theme, 'URL Encode', _encUrl),
          const SizedBox(height: 12),
          _buildResultCard(theme, 'Hexadecimal', _encHex),
        ],
      ],
    );
  }

  Widget _buildResultCard(ThemeData theme, String title, String result) {
    return Card(
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: theme.colorScheme.primary.withValues(alpha: 0.1),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  title,
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w800,
                    color: theme.colorScheme.primary,
                  ),
                ),
                GestureDetector(
                  onTap: () => _copy(result),
                  child: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      Pixel.copy,
                      size: 16,
                      color: theme.colorScheme.primary,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            SelectableText(
              result,
              style: theme.textTheme.bodyMedium?.copyWith(
                fontFeatures: const [FontFeature.tabularFigures()],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
