import 'package:flutter/material.dart';
import 'package:pixelarticons/pixelarticons.dart';

import '../models/tool.dart';
import '../services/app_controller.dart';

const categoryColors = <String, Color>{
  'developer': Color(0xFF6684E8),
  'media': Color(0xFF40AFA7),
  'pdf': Color(0xFFEA7D91),
  'ai': Color(0xFF9B74D2),
};

class ToolCard extends StatelessWidget {
  const ToolCard({
    required this.tool,
    required this.onTap,
    this.compact = false,
    super.key,
  });

  final ToolDefinition tool;
  final VoidCallback onTap;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final controller = AppControllerScope.of(context);
    final theme = Theme.of(context);
    final color = categoryColors[tool.category] ?? theme.colorScheme.primary;
    final isFavorite = controller.favorites.contains(tool.id);

    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: EdgeInsets.all(compact ? 12 : 15),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: compact ? 38 : 42,
                    height: compact ? 38 : 42,
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: .13),
                      borderRadius: BorderRadius.circular(15),
                      border: Border.all(color: color.withValues(alpha: .18)),
                    ),
                    child: Icon(tool.icon, color: color, size: 21),
                  ),
                  const Spacer(),
                  IconButton(
                    visualDensity: VisualDensity.compact,
                    tooltip: isFavorite
                        ? 'Hapus dari favorit'
                        : 'Tambah ke favorit',
                    onPressed: () => controller.toggleFavorite(tool.id),
                    icon: Icon(
                      isFavorite ? Pixel.heart : Pixel.heart,
                      color: isFavorite
                          ? const Color(0xFFE6A536)
                          : theme.colorScheme.outline,
                      size: 20,
                    ),
                  ),
                ],
              ),
              SizedBox(height: compact ? 8 : 12),
              Text(
                tool.name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                tool.description,
                maxLines: compact ? 2 : 3,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                  height: 1.35,
                ),
              ),
              if (!compact) ...[
                const Spacer(),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Icon(
                      tool.local ? Pixel.lock : Pixel.cloud,
                      size: 13,
                      color: tool.local ? color : theme.colorScheme.outline,
                    ),
                    const SizedBox(width: 5),
                    Text(
                      tool.local ? 'Di perangkat' : 'Perlu layanan',
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const Spacer(),
                    Icon(Pixel.arrowright, size: 16, color: color),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
