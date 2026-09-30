import 'package:flutter/material.dart';
import 'package:pixelarticons/pixelarticons.dart';

import '../data/tool_catalog.dart';
import '../models/tool.dart';
import '../services/app_controller.dart';
import '../widgets/tool_card.dart';
import '../widgets/ios_back_button.dart';
import '../widgets/screen_header.dart';
import 'tool_screen.dart';

class ToolsScreen extends StatefulWidget {
  const ToolsScreen({this.initialCategory = 'all', this.onBack, super.key});
  final String initialCategory;
  final VoidCallback? onBack;
  @override
  State<ToolsScreen> createState() => _ToolsScreenState();
}

class _ToolsScreenState extends State<ToolsScreen> {
  late String _category;
  String _query = '';
  @override
  void initState() {
    super.initState();
    _category = widget.initialCategory;
  }

  @override
  Widget build(BuildContext context) {
    final language = AppControllerScope.of(context).indonesian;
    final tools = searchTools(_query, category: _category);
    return Material(
      color: Theme.of(context).scaffoldBackgroundColor,
      child: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(20, 22, 20, 12),
              sliver: SliverToBoxAdapter(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (widget.onBack == null)
                      IosBackButton(
                        label: language ? 'Beranda' : 'Home',
                        onPressed: _goBack,
                      ),
                    ScreenHeader(
                      title: language ? 'Semua alat' : 'All tools',
                      subtitle:
                          '${toolCatalog.length} ${language ? 'alat untuk pekerjaanmu' : 'tools for your workflow'}',
                      icon: Pixel.grid,
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      onChanged: (value) => setState(() => _query = value),
                      decoration: InputDecoration(
                        prefixIcon: const Icon(Pixel.search),
                        hintText: language ? 'Cari alat...' : 'Search tools...',
                      ),
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      height: 42,
                      child: ListView(
                        scrollDirection: Axis.horizontal,
                        children: toolCategories
                            .map(
                              (category) => Padding(
                                padding: const EdgeInsets.only(right: 8),
                                child: ChoiceChip(
                                  label: Text(category.title),
                                  selected: _category == category.id,
                                  onSelected: (_) =>
                                      setState(() => _category = category.id),
                                ),
                              ),
                            )
                            .toList(),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            if (tools.isEmpty)
              SliverFillRemaining(
                hasScrollBody: false,
                child: Center(
                  child: Text(
                    language
                        ? 'Tidak ada alat yang cocok.'
                        : 'No matching tools.',
                  ),
                ),
              )
            else
              SliverPadding(
                padding: EdgeInsets.fromLTRB(
                  14,
                  0,
                  14,
                  24 + MediaQuery.paddingOf(context).bottom,
                ),
                sliver: SliverGrid.builder(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 8,
                    mainAxisSpacing: 8,
                    mainAxisExtent: 208,
                  ),
                  itemCount: tools.length,
                  itemBuilder: (context, index) {
                    final tool = tools[index];
                    return ToolCard(tool: tool, onTap: () => _open(tool));
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }

  void _goBack() {
    if (widget.onBack != null) {
      widget.onBack!();
    } else if (Navigator.of(context).canPop()) {
      Navigator.of(context).pop();
    }
  }

  void _open(ToolDefinition tool) {
    AppControllerScope.of(context).addRecent(tool.id);
    Navigator.of(context)
        .push(MaterialPageRoute<void>(builder: (_) => ToolScreen(tool: tool)));
  }
}
