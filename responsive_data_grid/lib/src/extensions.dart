part of responsive_data_grid;

extension OrderCriteriaExtensions on List<OrderCriteria> {
  String toOdata() {
    if (this.isEmpty) return "";
    return this.map((e) {
      if (e.direction == OrderDirections.descending) {
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
        if (e.op == Logic.or) {
          filter += " OR ";
        } else {
          filter += " AND ";
        }
      }

      if (e.logicalOperator == Operators.endsWidth) {
        filter +=
            " endsWidth(${escapeFieldName(e.fieldName)}, '${e.values.first}')";
      } else if (e.logicalOperator == Operators.contains) {
        filter +=
            " contains(${escapeFieldName(e.fieldName)}, '${e.values.first}')";
      } else if (e.logicalOperator == Operators.notContains) {
        filter +=
            " not contains(${escapeFieldName(e.fieldName)}, '${e.values.first}')";
      } else if (e.logicalOperator == Operators.startsWith) {
        filter +=
            " startsWith(${escapeFieldName(e.fieldName)}, '${e.values.first}')";
      } else if (e.logicalOperator == Operators.between) {
        filter += " ge ${e.values.first} and le ${e.values.last}";
      } else {
        filter += "${escapeFieldName(e.fieldName)} ";
        switch (e.logicalOperator) {
          case Operators.equals:
            filter += "eq";
            break;
          case Operators.greaterThan:
            filter += "gt";
            break;
          case Operators.greaterThanOrEqualTo:
            filter += "ge";
            break;
          case Operators.lessThan:
            filter += "lt";
            break;
          case Operators.lessThanOrEqualTo:
            filter += "le";
            break;
          default:
            throw UnimplementedError();
        }
        filter += " ${e.values.first}";
      }
    });

    return filter;
  }

  String escapeFieldName(String fieldName) => fieldName.replaceAll("'", "''");
}
