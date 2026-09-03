import 'package:client_filtering/client_filtering.dart';
import 'package:odata_query/odata_query.dart';

extension OrderbyCriteriaExtensions on OrderCriteria {
  OrderBy toOdata() {
    switch (direction) {
      case OrderDirections.notSet:
      case OrderDirections.ascending:
        return OrderBy.asc(fieldName);
      case OrderDirections.descending:
        return OrderBy.desc(fieldName);
    }
  }
}
