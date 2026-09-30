import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:pixelarticons/pixelarticons.dart';

import '../services/app_controller.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final id = AppControllerScope.of(context).indonesian;
    final theme = Theme.of(context);
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
          tooltip: id ? 'Kembali' : 'Back',
          onPressed: () => Navigator.of(context).maybePop(),
          icon: const Icon(Pixel.chevronleft),
        ),
        title: Text(id ? 'Tentang aplikasi' : 'About this app'),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
        children: [
          Card(
            color: theme.colorScheme.primaryContainer.withValues(alpha: .48),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 28),
              child: Column(
                children: [
                  Image.asset(
                    'assets/images/imphnen-sidebar-logo.png',
                    width: 230,
                    height: 120,
                    fit: BoxFit.contain,
                    semanticLabel: 'IMPHNEN',
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'IMPHNEN ONLINE TOOLS',
                    textAlign: TextAlign.center,
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w900,
                      letterSpacing: .3,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'All Your Tools. One Place.',
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    id
                        ? 'Kumpulan alat yang cepat, sederhana, dan berguna untuk semua orang.'
                        : 'A collection of fast, simple, and useful tools for everyone.',
                    textAlign: TextAlign.center,
                    style: theme.textTheme.bodyMedium,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          _AboutSection(
            icon: Pixel.flag,
            title: id ? 'Misi' : 'Mission',
            body: id
                ? 'Membuat alat digital sehari-hari mudah ditemukan dan digunakan dalam satu aplikasi, untuk developer, kreator, pelajar, dan siapa saja.'
                : 'Make everyday digital tools easy to find and use in one app for developers, creators, students, and everyone else.',
          ),
          const SizedBox(height: 12),
          _AboutSection(
            icon: Pixel.lock,
            title: id ? 'Privasi' : 'Privacy',
            body: id
                ? 'Alat yang mendukung pemrosesan lokal bekerja langsung di perangkat. Fitur yang membutuhkan layanan AI atau pemrosesan dokumen belum aktif di aplikasi ini. Favorit, riwayat, tema, dan bahasa disimpan lokal di perangkat.'
                : 'Tools that support local processing work on your device. Features that require AI or document processing services are not enabled in this app yet. Favorites, history, theme, and language are stored locally on your device.',
          ),
          const SizedBox(height: 12),
          _AboutSection(
            icon: Pixel.devices,
            title: id ? 'Teknologi' : 'Technology',
            body: id
                ? 'Aplikasi mobile ini dibuat dengan Flutter. Pemrosesan lokal digunakan jika tersedia; integrasi layanan eksternal hanya ditambahkan saat penyedianya dikonfigurasi.'
                : 'This mobile app is built with Flutter. Local processing is used when available; external services are integrated only when a provider is configured.',
          ),
          const SizedBox(height: 16),
          Center(
            child: Text(
              id ? 'Versi 1.0.0' : 'Version 1.0.0',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _AboutSection extends StatelessWidget {
  const _AboutSection({
    required this.icon,
    required this.title,
    required this.body,
  });

  final IconData icon;
  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(17),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: theme.colorScheme.primary, size: 20),
                const SizedBox(width: 9),
                Text(
                  title,
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              body,
              style: theme.textTheme.bodyMedium?.copyWith(height: 1.5),
            ),
          ],
        ),
      ),
    );
  }
}
