import 'package:flutter/material.dart';
import 'package:pixelarticons/pixelarticons.dart';

import '../app_strings.dart';
import '../data/tool_catalog.dart';
import '../models/tool.dart';
import '../services/app_controller.dart';
import '../widgets/tool_card.dart';
import '../widgets/screen_header.dart';
import 'tool_screen.dart';

class FavoritesScreen extends StatelessWidget {
  const FavoritesScreen({super.key});
  @override
  Widget build(BuildContext context) {
    final controller = AppControllerScope.of(context);
    final language = controller.indonesian;
    final tools = toolCatalog
        .where((tool) => controller.favorites.contains(tool.id))
        .toList();
    return CustomScrollView(
      slivers: [
        SliverPadding(
          padding: EdgeInsets.fromLTRB(
            20,
            22,
            20,
            14 + MediaQuery.paddingOf(context).bottom,
          ),
          sliver: SliverToBoxAdapter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ScreenHeader(
                  title: tr(language, 'favorites'),
                  subtitle: language
                      ? 'Akses cepat ke alat pilihanmu.'
                      : 'Quick access to your favorite tools.',
                  icon: Pixel.heart,
                ),
              ],
            ),
          ),
        ),
        if (tools.isEmpty)
          SliverFillRemaining(
            hasScrollBody: false,
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Pixel.heart, size: 46),
                  const SizedBox(height: 12),
                  Text(tr(language, 'empty_favorites')),
                ],
              ),
            ),
          )
        else
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 14),
            sliver: SliverGrid.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 8,
                mainAxisSpacing: 8,
                mainAxisExtent: 208,
              ),
              itemCount: tools.length,
              itemBuilder: (context, index) => ToolCard(
                tool: tools[index],
                onTap: () => _open(context, tools[index]),
              ),
            ),
          ),
      ],
    );
  }

  void _open(BuildContext context, ToolDefinition tool) {
    AppControllerScope.of(context).addRecent(tool.id);
    Navigator.of(context)
        .push(MaterialPageRoute<void>(builder: (_) => ToolScreen(tool: tool)));
  }
}
