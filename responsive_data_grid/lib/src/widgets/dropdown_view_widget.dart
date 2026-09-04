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
  @override
  void initState() {
    super.initState();
  }

  void close(BuildContext context) {
    _popMenuIfCurrent(
      Navigator.of(context, rootNavigator: true),
      ModalRoute.of(context),
    );
  }

  @override
  Widget build(BuildContext context) {
    return IconButton(
      key: widget.key,
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
      onPressed: (() {
        showAlignedDialog<void>(
          avoidOverflow: true,
          context: context,
          barrierDismissible: true,
          barrierColor: Colors.transparent,
          followerAnchor: Alignment.topRight,
          targetAnchor: Alignment.bottomLeft,
          offset: Offset(32, 0),
          builder: (BuildContext ctx) => SizedBox(
            width: widget.dropDownWidth,
            child: SingleChildScrollView(child: widget.build(ctx, close)),
          ),
        );
      }),
    );
  }
}

void _popMenuIfCurrent(NavigatorState navigator, Route<dynamic>? route) {
  if (route != null && route.isCurrent && navigator.canPop()) {
    navigator.pop();
  }
}
