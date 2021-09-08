part of responsive_data_grid;

@immutable
class OrderRules {
  final bool? showSort;
  final OrderDirections direction;

  const OrderRules({
    this.showSort = false,
    this.direction = OrderDirections.notSet,
  });

  OrderRules copyWith({bool? showSort, OrderDirections? direction}) =>
      OrderRules(
        showSort: showSort ?? this.showSort,
        direction: direction ?? this.direction,
      );
}
