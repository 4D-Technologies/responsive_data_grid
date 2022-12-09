part of client_filtering;

class LoadCriteria with IJsonable {
  final int? skip;
  final int? take;
  final List<FilterCriteria<dynamic>> filterBy;
  final List<OrderCriteria> orderBy;
  final List<GroupCriteria>? groupBy;
  final List<AggregateCriteria>? aggregates;

  LoadCriteria({
    this.skip,
    this.take,
    this.groupBy,
    this.aggregates,
    List<FilterCriteria<dynamic>>? filterBy,
    List<OrderCriteria>? orderBy,
  })  : this.filterBy =
            filterBy ?? List<FilterCriteria<dynamic>>.empty(growable: true),
        this.orderBy = orderBy ?? List<OrderCriteria>.empty(growable: true);

  factory LoadCriteria.fromJson(Map<String, dynamic> json) => LoadCriteria(
        skip: json["skip"] as int?,
        take: json["take"] as int?,
        filterBy: (json["filterBy"] as List)
            .map<FilterCriteria<dynamic>>((dynamic model) =>
                FilterCriteria.fromJson<dynamic>(model as Map<String, dynamic>))
            .toList(),
        orderBy: (json["orderBy"] as List)
            .map<OrderCriteria>((dynamic model) =>
                OrderCriteria.fromJson(model as Map<String, dynamic>))
            .toList(),
      );

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
    List<GroupCriteria>? Function()? groupBy,
    List<AggregateCriteria>? Function()? aggregates,
  }) {
    return LoadCriteria(
      skip: skip == null ? this.skip : skip(),
      take: take == null ? this.take : take(),
      filterBy: filterBy == null ? this.filterBy : filterBy(),
      orderBy: orderBy == null ? this.orderBy : orderBy(),
      groupBy: groupBy == null ? this.groupBy : groupBy(),
      aggregates: aggregates == null ? this.aggregates : aggregates(),
    );
  }

  Map<String, dynamic> toJson() {
    // ignore: unnecessary_cast
    return {
      'skip': skip,
      'take': take,
      'filterBy': filterBy.map((x) => x.toJson()).toList(),
      'orderBy': orderBy.map((x) => x.toJson()).toList(),
    } as Map<String, dynamic>;
  }
}
