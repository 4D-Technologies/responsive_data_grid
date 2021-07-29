part of responsive_data_grid;

extension OrderCriteriaExtensions on List<OrderCriteria> {
  String toOdata() {
    if (this.isEmpty) return "";
    return this.map((e) {
      if (e.direction == OrderDirections.Descending) {
        return "${e.fieldName} desc";
      } else {
        return e.fieldName;
      }
    }).join(", ");
  }
}

extension FilterCriteriaExtensions on List<FilterCriteria> {
  String toOdata() {
    if (this.isEmpty) return "";

    String filter = '';
    this.forEach((e) {
      if (filter.isNotEmpty) {
        if (e.op == FilterOperators.Or) {
          filter += " OR ";
        } else {
          filter += " AND ";
        }
      }

      if (e.logicalOperator == LogicalOperators.endsWidth) {
        filter += " endsWidth(${escapeFieldName(e.fieldName)}, '${e.value}')";
      } else if (e.logicalOperator == LogicalOperators.contains) {
        filter += " contains(${escapeFieldName(e.fieldName)}, '${e.value}')";
      } else if (e.logicalOperator == LogicalOperators.notContains) {
        filter +=
            " not contains(${escapeFieldName(e.fieldName)}, '${e.value}')";
      } else if (e.logicalOperator == LogicalOperators.startsWith) {
        filter += " startsWith(${escapeFieldName(e.fieldName)}, '${e.value}')";
      } else {
        filter += "${escapeFieldName(e.fieldName)} ";
        switch (e.logicalOperator) {
          case LogicalOperators.equals:
            filter += "eq";
            break;
          case LogicalOperators.greaterThan:
            filter += "gt";
            break;
          case LogicalOperators.greaterThanOrEqualTo:
            filter += "ge";
            break;
          case LogicalOperators.lessThan:
            filter += "lt";
            break;
          case LogicalOperators.lessThanOrEqualTo:
            filter += "le";
            break;
          default:
            throw UnimplementedError();
        }
        filter += " ${e.value}";
      }
    });

    return filter;
  }

  String escapeFieldName(String fieldName) => fieldName.replaceAll("'", "''");
}
