part of client_filtering;

class LoadCriteria with IJsonable {
  final int? skip;
  final int? take;
  final List<FilterCriteria<dynamic>> filterBy;
  final List<OrderCriteria> orderBy;

  LoadCriteria({
    this.skip,
    this.take,
    List<FilterCriteria<dynamic>>? filterBy,
    List<OrderCriteria>? orderBy,
  })  : this.filterBy =
            filterBy ?? List<FilterCriteria<dynamic>>.empty(growable: true),
        this.orderBy = orderBy ?? List<OrderCriteria>.empty(growable: true);

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is LoadCriteria &&
        other.skip == skip &&
        other.take == take &&
        listEquals(other.filterBy, filterBy) &&
        listEquals(other.orderBy, orderBy);
  }

  @override
  int get hashCode {
    return skip.hashCode ^ take.hashCode ^ filterBy.hashCode ^ orderBy.hashCode;
  }

  LoadCriteria copyWith({
    int? Function()? skip,
    int? Function()? take,
    List<FilterCriteria<dynamic>>? Function()? filterBy,
    List<OrderCriteria>? Function()? orderBy,
  }) {
    return LoadCriteria(
      skip: skip == null ? this.skip : skip(),
      take: take == null ? this.take : take(),
      filterBy: filterBy == null ? this.filterBy : filterBy(),
      orderBy: orderBy == null ? this.orderBy : orderBy(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'skip': skip,
      'take': take,
      'filterBy': filterBy.map((x) => x.toJson()).toList(),
      'orderBy': orderBy.map((x) => x.toJson()).toList(),
    };
  }

  factory LoadCriteria.fromJson(Map<String, dynamic> map) {
    return LoadCriteria(
      skip: map['skip'],
      take: map['take'],
      filterBy: List<FilterCriteria<dynamic>>.from(
          map['filterBy']?.map((x) => FilterCriteria<dynamic>.fromJson(x))),
      orderBy: List<OrderCriteria>.from(
          map['orderBy']?.map((x) => OrderCriteria.fromJson(x))),
    );
  }
}
