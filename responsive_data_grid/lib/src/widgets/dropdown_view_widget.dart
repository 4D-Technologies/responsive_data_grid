part of responsive_data_grid;

abstract class DropDownViewWidget extends StatefulWidget {
  final Icon icon;
  final ThemeData theme;
  final double dropDownWidth;
  final double? dropDownHeight;

  DropDownViewWidget({
    Key? key,
    required this.icon,
    required this.theme,
    required this.dropDownWidth,
    this.dropDownHeight,
  }) : super(key: key);

  @override
  _DropDownViewState createState() => _DropDownViewState();

  Widget build(BuildContext context, void Function(BuildContext context) close);
}

class _DropDownViewState extends State<DropDownViewWidget> {
  @override
  void initState() {
    super.initState();
  }

  void close(BuildContext context) {
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return IconButton(
      key: widget.key,
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
      icon: widget.icon,
      color: widget.theme.buttonTheme.colorScheme!.primary,
      onPressed: (() {
        showAlignedDialog<void>(
          avoidOverflow: true,
          context: context,
          barrierDismissible: true,
          barrierColor: Colors.transparent,
          followerAnchor: Alignment.topRight,
          targetAnchor: Alignment.bottomLeft,
          offset: Offset(32, 0),
          builder: (BuildContext ctx) => Container(
            width: widget.dropDownWidth,
            child: SingleChildScrollView(
              child: widget.build(context, close),
            ),
          ),
        );
      }),
    );
  }
}
