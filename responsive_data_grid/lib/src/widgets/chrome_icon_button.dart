part of '../../responsive_data_grid.dart';

/// Compact header/pager icon control that does not use Material's 48px
/// [IconButton] target, so it looks the same under Material and Cupertino.
class GridChromeIconButton extends StatelessWidget {
  final Widget icon;
  final VoidCallback? onPressed;
  final String? tooltip;
  final Color? color;
  final Color? disabledColor;
  final double size;
  final double extent;
  final Color? hoverColor;

  const GridChromeIconButton({
    super.key,
    required this.icon,
    required this.onPressed,
    this.tooltip,
    this.color,
    this.disabledColor,
    required this.size,
    required this.extent,
    this.hoverColor,
  });

  @override
  Widget build(BuildContext context) {
    final enabled = onPressed != null;
    final iconColor = enabled
        ? color
        : (disabledColor ?? color?.withValues(alpha: 0.38));

    Widget child = SizedBox(
      width: extent,
      height: extent,
      child: Center(
        child: IconTheme.merge(
          data: IconThemeData(size: size, color: iconColor),
          child: icon,
        ),
      ),
    );

    if (hoverColor != null && enabled) {
      child = MouseRegion(cursor: SystemMouseCursors.click, child: child);
    } else {
      child = MouseRegion(
        cursor: enabled ? SystemMouseCursors.click : SystemMouseCursors.basic,
        child: child,
      );
    }

    child = GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onPressed,
      child: child,
    );

    if (tooltip != null && tooltip!.isNotEmpty) {
      child = Tooltip(message: tooltip!, child: child);
    }

    return child;
  }
}
