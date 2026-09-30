import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:pixelarticons/pixelarticons.dart';

import '../app_strings.dart';
import '../services/app_controller.dart';
import '../widgets/screen_header.dart';
import 'about_screen.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});
  @override
  Widget build(BuildContext context) {
    final controller = AppControllerScope.of(context);
    final id = controller.indonesian;
    return ListView(
      padding: EdgeInsets.fromLTRB(
        20,
        22,
        20,
        28 + MediaQuery.paddingOf(context).bottom,
      ),
      children: [
        ScreenHeader(
          title: tr(id, 'settings'),
          subtitle: id
              ? 'Atur tampilan dan preferensi aplikasi'
              : 'Customize app appearance and preferences',
          icon: Pixel.sliders2,
        ),
        const SizedBox(height: 18),
        _Group(
          title: tr(id, 'appearance'),
          children: [
            SwitchListTile.adaptive(
              secondary: Icon(controller.darkMode ? Pixel.moon : Pixel.sun),
              title: Text(tr(id, 'dark_mode')),
              value: controller.darkMode,
              onChanged: controller.setDarkMode,
            ),
          ],
        ),
        const SizedBox(height: 14),
        _Group(
          title: tr(id, 'language'),
          children: [
            ListTile(
              leading: const Icon(Pixel.chat),
              title: Text(id ? 'Bahasa Indonesia' : 'English'),
              trailing: SegmentedButton<bool>(
                segments: const [
                  ButtonSegment(value: true, label: Text('ID')),
                  ButtonSegment(value: false, label: Text('EN')),
                ],
                selected: {id},
                onSelectionChanged: (value) =>
                    controller.setIndonesian(value.first),
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),
        _Group(
          title: tr(id, 'privacy'),
          children: [
            ListTile(
              leading: const Icon(Pixel.clock),
              title: Text(tr(id, 'clear_recent')),
              onTap: () => _confirm(
                context,
                tr(id, 'clear_recent'),
                controller.clearRecent,
              ),
            ),
            ListTile(
              leading: const Icon(Pixel.heart),
              title: Text(tr(id, 'clear_favorites')),
              onTap: () => _confirm(
                context,
                tr(id, 'clear_favorites'),
                controller.clearFavorites,
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),
        _Group(
          title: tr(id, 'about'),
          children: [
            ListTile(
              leading: const Icon(Pixel.infobox),
              title: Text(id ? 'Tentang aplikasi' : 'About this app'),
              subtitle: Text(
                id
                    ? 'Misi, privasi, dan informasi aplikasi'
                    : 'Mission, privacy, and app information',
              ),
              trailing: const Icon(Pixel.chevronright),
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute<void>(builder: (_) => const AboutScreen()),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Future<void> _confirm(
    BuildContext context,
    String title,
    Future<void> Function() action,
  ) async {
    final id = AppControllerScope.of(context).indonesian;
    final confirmed = await showAdaptiveDialog<bool>(
      context: context,
      builder: (context) {
        final isIOS = Theme.of(context).platform == TargetPlatform.iOS;
        return AlertDialog.adaptive(
          title: Text(title),
          content: Text(
            id
                ? 'Tindakan ini tidak dapat dibatalkan.'
                : 'This action cannot be undone.',
          ),
          actions: [
            if (isIOS) ...[
              CupertinoDialogAction(
                onPressed: () => Navigator.pop(context, false),
                child: Text(id ? 'Batal' : 'Cancel'),
              ),
              CupertinoDialogAction(
                isDestructiveAction: true,
                onPressed: () => Navigator.pop(context, true),
                child: Text(id ? 'Hapus' : 'Clear'),
              ),
            ] else ...[
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: Text(id ? 'Batal' : 'Cancel'),
              ),
              FilledButton(
                onPressed: () => Navigator.pop(context, true),
                child: Text(id ? 'Hapus' : 'Clear'),
              ),
            ],
          ],
        );
      },
    );
    if (confirmed == true) await action();
  }
}

class _Group extends StatelessWidget {
  const _Group({required this.title, required this.children});
  final String title;
  final List<Widget> children;
  @override
  Widget build(BuildContext context) => Card(
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 15, 16, 2),
          child: Text(
            title,
            style: Theme.of(context).textTheme.titleSmall
                ?.copyWith(fontWeight: FontWeight.w800),
          ),
        ),
        ...children,
      ],
    ),
  );
}
