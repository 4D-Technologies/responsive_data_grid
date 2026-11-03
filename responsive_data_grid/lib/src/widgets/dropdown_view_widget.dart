part of '../../responsive_data_grid.dart';

abstract class DropDownViewWidget extends StatefulWidget {
  final IconData icon;
  final Color? iconColor;
  final double? iconSize;
  final ThemeData theme;
  final double? dropDownWidth;
  final double? dropDownHeight;

  const DropDownViewWidget({
    super.key,
    required this.icon,
    this.iconColor,
    this.iconSize,
    required this.theme,
    this.dropDownWidth,
    this.dropDownHeight,
  });

  @override
  State<DropDownViewWidget> createState() => _DropDownViewState();

  Widget build(
    BuildContext context,
    void Function(BuildContext context) close, {
    double? maxHeight,
  });
}

class _DropDownViewState extends State<DropDownViewWidget> {
  final MenuController _controller = MenuController();

  void close(BuildContext context) {
    _controller.close();
  }

  double _panelMaxHeight(BuildContext context, GridMenuTheme menu) {
    final size = MediaQuery.sizeOf(context);
    var maxHeight =
        widget.dropDownHeight ??
        math.min(menu.maxHeight, math.max(120.0, size.height * 0.75));
    final box = context.findRenderObject() as RenderBox?;
    if (box != null && box.hasSize && box.attached) {
      final padding = MediaQuery.paddingOf(context);
      final top = box.localToGlobal(Offset.zero).dy;
      final bottom = top + box.size.height;
      final below = size.height - padding.bottom - bottom - 8;
      final above = top - padding.top - 8;
      final available = math.max(below, above);
      if (available.isFinite && available > 0) {
        maxHeight = math.min(maxHeight, available);
      }
    }
    return math.max(120.0, maxHeight);
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final menu = ResponsiveDataGridTheme.of(context).menu;
    final maxWidth = math.min(
      widget.dropDownWidth ?? menu.width,
      math.max(0.0, size.width - 16),
    );

    return MenuAnchor(
      controller: _controller,
      alignmentOffset: menu.alignmentOffset,
      consumeOutsideTap: true,
      style: MenuStyle(
        padding: const WidgetStatePropertyAll(EdgeInsets.zero),
        visualDensity: VisualDensity.compact,
        elevation: WidgetStatePropertyAll(menu.elevation),
        maximumSize: WidgetStatePropertyAll(
          Size(maxWidth, _panelMaxHeight(context, menu)),
        ),
      ),
      builder: (context, controller, child) {
        final gridTheme = ResponsiveDataGridTheme.of(context);
        void toggle() {
          if (controller.isOpen) {
            controller.close();
          } else {
            controller.open();
          }
        }

        return FocusableActionDetector(
          actions: {
            ActivateIntent: CallbackAction<ActivateIntent>(
              onInvoke: (_) {
                toggle();
                return null;
              },
            ),
          },
          child: GridChromeIconButton(
            icon: Icon(widget.icon),
            color: widget.iconColor ?? gridTheme.header.menuColor,
            size: widget.iconSize ?? gridTheme.header.iconSize,
            extent: gridTheme.header.actionExtent,
            tooltip: GridLocalizations.of(context).columnMenu,
            onPressed: toggle,
          ),
        );
      },
      menuChildren: [
        Builder(
          builder: (overlayContext) {
            final maxHeight = _panelMaxHeight(context, menu);
            return ConstrainedBox(
              constraints: BoxConstraints(
                maxWidth: maxWidth,
                maxHeight: maxHeight,
              ),
              child: SizedBox(
                width: maxWidth,
                child: widget.build(
                  overlayContext,
                  close,
                  maxHeight: maxHeight,
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}
