import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:pixelarticons/pixelarticons.dart';

class IosBackButton extends StatelessWidget {
  const IosBackButton({
    required this.onPressed,
    required this.label,
    super.key,
  });

  final VoidCallback onPressed;
  final String label;

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme.primary;
    return CupertinoButton(
      padding: EdgeInsets.zero,
      onPressed: onPressed,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Pixel.chevronleft, color: color, size: 25),
          const SizedBox(width: 2),
          Text(label, style: TextStyle(color: color, fontSize: 17)),
        ],
      ),
    );
  }
}
