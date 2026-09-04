part of '../../responsive_data_grid.dart';

abstract class DropDownViewWidget extends StatefulWidget {
  final Icon icon;
  final ThemeData theme;
  final double dropDownWidth;
  final double? dropDownHeight;

  const DropDownViewWidget({
    super.key,
    required this.icon,
    required this.theme,
    required this.dropDownWidth,
    this.dropDownHeight,
  });

  @override
  State<DropDownViewWidget> createState() => _DropDownViewState();

  Widget build(BuildContext context, void Function(BuildContext context) close);
}

class _DropDownViewState extends State<DropDownViewWidget> {
  final MenuController _controller = MenuController();

  void close(BuildContext context) {
    _controller.close();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final maxWidth = math.min(
      widget.dropDownWidth,
      math.max(0.0, size.width - 16),
    );
    final maxHeight =
        widget.dropDownHeight ?? math.max(120.0, size.height * 0.7);

    return MenuAnchor(
      controller: _controller,
      alignmentOffset: const Offset(0, 4),
      consumeOutsideTap: true,
      style: MenuStyle(
        padding: const WidgetStatePropertyAll(EdgeInsets.zero),
        visualDensity: VisualDensity.compact,
        maximumSize: WidgetStatePropertyAll(Size(maxWidth, maxHeight)),
      ),
      builder: (context, controller, child) {
        return IconButton(
          visualDensity: VisualDensity.compact,
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints(minWidth: 24, minHeight: 24),
          style: IconButton.styleFrom(
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            minimumSize: const Size(24, 24),
            padding: EdgeInsets.zero,
          ),
          icon: widget.icon,
          color: widget.theme.gridPrimaryColor,
          onPressed: () {
            if (controller.isOpen) {
              controller.close();
            } else {
              controller.open();
            }
          },
        );
      },
      menuChildren: [
        Builder(
          builder: (overlayContext) {
            return ConstrainedBox(
              constraints: BoxConstraints(
                maxWidth: maxWidth,
                maxHeight: maxHeight,
              ),
              child: SingleChildScrollView(
                primary: false,
                child: SizedBox(
                  width: maxWidth,
                  child: widget.build(overlayContext, close),
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}
