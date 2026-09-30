import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:pixelarticons/pixelarticons.dart';

import '../app_strings.dart';
import '../data/tool_catalog.dart';
import '../models/tool.dart';
import '../services/app_controller.dart';
import '../widgets/tool_card.dart';
import '../widgets/screen_header.dart';
import 'tool_screen.dart';
import 'tools_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({this.onOpenSecurity, super.key});

  final VoidCallback? onOpenSecurity;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _open(ToolDefinition tool) {
    AppControllerScope.of(context).addRecent(tool.id);
    Navigator.of(context)
        .push(MaterialPageRoute<void>(builder: (_) => ToolScreen(tool: tool)));
  }

  @override
  Widget build(BuildContext context) {
    final controller = AppControllerScope.of(context);
    final language = controller.indonesian;
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final hour = DateTime.now().hour;
    final greeting = hour < 12
        ? 'good_morning'
        : hour < 18
        ? 'good_afternoon'
        : 'good_evening';
    final results = _searchController.text.trim().isEmpty
        ? const <ToolDefinition>[]
        : searchTools(_searchController.text);
    final recent = controller.recent
        .map((id) => toolCatalog.where((tool) => tool.id == id).firstOrNull)
        .whereType<ToolDefinition>()
        .toList();
    return CustomScrollView(
      slivers: [
        SliverPadding(
          padding: EdgeInsets.fromLTRB(
            20,
            14,
            20,
            24 + MediaQuery.paddingOf(context).bottom,
          ),
          sliver: SliverList.list(
            children: [
              ScreenHeader(
                title: 'IMPHNEN',
                subtitle: language
                    ? 'Semua alat online dalam satu tempat'
                    : 'All your online tools in one place',
                icon: Pixel.home,
                iconWidget: Image.asset(
                  'assets/images/imphnen-sidebar-logo.png',
                  width: 58,
                  height: 58,
                  fit: BoxFit.contain,
                ),
                trailing: IconButton(
                  onPressed: () => controller.setDarkMode(!controller.darkMode),
                  tooltip: 'Theme',
                  icon: Icon(controller.darkMode ? Pixel.sun : Pixel.moon),
                ),
              ),
              const SizedBox(height: 16),
              _WelcomeBanner(
                greeting: tr(language, greeting),
                subtitle: tr(language, 'what_today'),
                indonesian: language,
              ),
              const SizedBox(height: 18),
              TextField(
                controller: _searchController,
                onChanged: (_) => setState(() {}),
                decoration: InputDecoration(
                  prefixIcon: const Icon(Pixel.search),
                  hintText: tr(language, 'search'),
                  suffixIcon: _searchController.text.isNotEmpty
                      ? IconButton(
                          onPressed: () {
                            _searchController.clear();
                            setState(() {});
                          },
                          icon: const Icon(Pixel.close),
                        )
                      : null,
                ),
              ),
              if (results.isNotEmpty) ...[
                const SizedBox(height: 10),
                ...results
                    .take(5)
                    .map(
                      (tool) => ListTile(
                        dense: true,
                        leading: Icon(tool.icon),
                        title: Text(tool.name),
                        subtitle: Text(tool.category),
                        onTap: () => _open(tool),
                      ),
                    ),
              ] else if (_searchController.text.trim().isNotEmpty)
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text(tr(language, 'no_tools')),
                )
              else ...[
                const SizedBox(height: 22),
                _SectionTitle(title: tr(language, 'categories')),
                const SizedBox(height: 12),
                SizedBox(
                  height: 112,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: toolCategories.length + 1,
                    separatorBuilder: (_, _) => const SizedBox(width: 10),
                    itemBuilder: (context, index) {
                      if (index == toolCategories.length) {
                        return SizedBox(
                          width: 140,
                          child: Card(
                            color: isDarkMode
                                ? const Color(0xFF2B263F)
                                : const Color(0xFFFFF1F4),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(22),
                              side: BorderSide(
                                color: isDarkMode
                                    ? const Color(0xFF514563)
                                    : const Color(0xFFF5D4DF),
                                width: 1.3,
                              ),
                            ),
                            child: InkWell(
                              borderRadius: BorderRadius.circular(20),
                              onTap: widget.onOpenSecurity,
                              child: const Padding(
                                padding: EdgeInsets.all(13),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Icon(
                                      Pixel.shield,
                                      color: Color(0xFF9B74D2),
                                    ),
                                    Text(
                                      'Hacking / Pentest',
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        );
                      }
                      final category = toolCategories[index];
                      return SizedBox(
                        width: 110,
                        child: Card(
                          color: isDarkMode
                              ? const Color(0xFF2B263F)
                              : const Color(0xFFFFF1F4),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(22),
                            side: BorderSide(
                              color: isDarkMode
                                  ? const Color(0xFF514563)
                                  : const Color(0xFFF5D4DF),
                              width: 1.3,
                            ),
                          ),
                          child: InkWell(
                            borderRadius: BorderRadius.circular(18),
                            onTap: () => _openCategory(context, category.id),
                            child: Padding(
                              padding: const EdgeInsets.all(13),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Icon(
                                    category.icon,
                                    color: Theme.of(context)
                                        .colorScheme
                                        .primary,
                                  ),
                                  Text(
                                    category.title,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
                if (recent.isNotEmpty) ...[
                  const SizedBox(height: 24),
                  _SectionTitle(title: tr(language, 'recent')),
                  const SizedBox(height: 10),
                  ...recent
                      .take(3)
                      .map(
                        (tool) => ToolCard(
                          tool: tool,
                          compact: true,
                          onTap: () => _open(tool),
                        ),
                      ),
                ],
                const SizedBox(height: 24),
                _SectionTitle(title: tr(language, 'popular')),
                const SizedBox(height: 10),
                ...toolCatalog
                    .where((tool) => tool.popular)
                    .take(8)
                    .map(
                      (tool) => Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: ToolCard(
                          tool: tool,
                          compact: true,
                          onTap: () => _open(tool),
                        ),
                      ),
                    ),
                const SizedBox(height: 12),
                Card(
                  color: isDarkMode
                      ? const Color(0xFF29243F)
                      : const Color(0xFFEAF6FD),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18),
                    side: BorderSide(
                      color: isDarkMode
                          ? const Color(0xFF514563)
                          : const Color(0xFFD9ECF7),
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        Icon(
                          Pixel.lock,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            language
                                ? 'Pemrosesan lokal menjaga file tetap di perangkat jika alat mendukungnya.'
                                : 'Local processing keeps files on your device when supported by the tool.',
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }

  void _openCategory(BuildContext context, String category) {
    // Category shortcuts switch to the catalog tab through the shell event bus.
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => ToolsScreen(initialCategory: category),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.title});
  final String title;
  @override
  Widget build(BuildContext context) => Text(
    title,
    style: Theme.of(context).textTheme.titleMedium
        ?.copyWith(fontWeight: FontWeight.w800),
  );
}

class _WelcomeBanner extends StatelessWidget {
  const _WelcomeBanner({
    required this.greeting,
    required this.subtitle,
    required this.indonesian,
  });

  final String greeting;
  final String subtitle;
  final bool indonesian;

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    final ink = dark ? const Color(0xFFF7F0FF) : const Color(0xFF47334A);
    final softInk = dark ? const Color(0xFFD0C5E3) : const Color(0xFF725969);
    return Container(
      height: 178,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: dark
              ? const [Color(0xFF392B53), Color(0xFF47334F), Color(0xFF263D54)]
              : const [Color(0xFFFFDCE8), Color(0xFFFFEBD5), Color(0xFFE3F5FF)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(
          color: dark ? const Color(0xFF655171) : const Color(0xFFF3C9D7),
          width: 1.5,
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0x28000000),
            blurRadius: 18,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned(
            right: 115,
            top: 18,
            child: _sparkle(Pixel.animation, 18, const Color(0xFFFFA64D)),
          ),
          Positioned(
            right: 24,
            top: 27,
            child: _sparkle(Pixel.heart, 17, const Color(0xFFFFB44D)),
          ),
          Positioned(
            right: 100,
            bottom: 15,
            child: _sparkle(Pixel.heart, 13, const Color(0xFFEF8BA8)),
          ),
          Positioned(
            right: 16,
            bottom: 15,
            child: Container(
              width: 112,
              height: 112,
              decoration: BoxDecoration(
                color: dark
                    ? const Color(0xFF211D32).withValues(alpha: .78)
                    : Colors.white.withValues(alpha: .62),
                shape: BoxShape.circle,
                border: Border.all(
                  color: dark ? const Color(0xFF9F83C0) : Colors.white,
                  width: 3,
                ),
              ),
              alignment: Alignment.center,
              child: Lottie.asset(
                'assets/lottie/Developer.json',
                width: 96,
                height: 96,
                fit: BoxFit.contain,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 19, 128, 18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: dark
                        ? const Color(0xFF211D32).withValues(alpha: .75)
                        : Colors.white.withValues(alpha: .72),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    indonesian
                        ? '✦ TEMAN PRODUKTIFMU'
                        : '✦ YOUR PRODUCTIVITY BUDDY',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 9,
                      fontWeight: FontWeight.w900,
                      letterSpacing: .65,
                      color: dark
                          ? const Color(0xFFF0C4DE)
                          : const Color(0xFF8E536C),
                    ),
                  ),
                ),
                const SizedBox(height: 11),
                Text(
                  greeting,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w900,
                    height: 1.05,
                    color: ink,
                    letterSpacing: -.5,
                  ),
                ),
                const SizedBox(height: 7),
                Text(
                  subtitle,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.bodySmall
                      ?.copyWith(color: softInk, height: 1.25),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  static Widget _sparkle(IconData icon, double size, Color color) =>
      Icon(icon, size: size, color: color);
}
