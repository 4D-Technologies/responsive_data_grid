import { Logic, Operators, OrderDirections } from "./enums";
import { AggregateCriteria } from "./aggregatecriteria";
import { FilterCriteria } from "./filtercriteria";
import { GroupCriteria } from "./groupcriteria";
import { LoadCriteria } from "./loadcriteria";
import { OrderCriteria } from "./ordercriteria";

function valueOf(obj: Record<string, unknown>, camel: string, ...aliases: string[]): unknown {
  const names = [camel, ...aliases];
  for (const name of names) {
    for (const [key, value] of Object.entries(obj)) {
      if (key.toLowerCase() === name.toLowerCase()) {
        return value;
      }
    }
  }
  return undefined;
}

function parseEnum(value: unknown, names: Record<string, number>, fallback = 0): number {
  if (value == null) {
    return fallback;
  }
  if (typeof value === "number") {
    return value;
  }
  if (typeof value === "string") {
    const asInt = Number.parseInt(value, 10);
    if (!Number.isNaN(asInt) && String(asInt) === value) {
      return asInt;
    }
    const key = value.toLowerCase().replace(/[_\s]/g, "");
    if (key in names) {
      return names[key];
    }
  }
  throw new Error(`Cannot parse enum from ${String(value)}`);
}

const logicNames: Record<string, number> = {
  equals: Logic.Equals,
  lessthan: Logic.LessThan,
  greaterthan: Logic.GreaterThan,
  lessthanorequalto: Logic.LessThanOrEqualTo,
  greaterthanorequalto: Logic.GreaterThanOrEqualTo,
  contains: Logic.Contains,
  notcontains: Logic.NotContains,
  endswith: Logic.EndsWith,
  endswidth: Logic.EndsWidth,
  startswith: Logic.StartsWith,
  notequal: Logic.NotEqual,
  notstartswith: Logic.NotStartsWith,
  notendswith: Logic.NotEndsWith,
  between: Logic.Between,
};

const operatorNames: Record<string, number> = { and: Operators.And, or: Operators.Or };

const directionNames: Record<string, number> = {
  notset: OrderDirections.NotSet,
  ascending: OrderDirections.Ascending,
  descending: OrderDirections.Descending,
};

const aggregationNames: Record<string, number> = {
  sum: 1,
  average: 2,
  maximum: 3,
  minimum: 4,
  count: 5,
};

function asRecord(value: unknown): Record<string, unknown> {
  return value as Record<string, unknown>;
}

function asArray(value: unknown): unknown[] {
  return Array.isArray(value) ? value : [];
}

function groupByFromJson(raw: unknown): GroupCriteria[] | undefined {
  if (raw == null) {
    return undefined;
  }
  const groups: GroupCriteria[] = [];
  const add = (node: unknown): void => {
    if (node == null) {
      return;
    }
    if (Array.isArray(node)) {
      node.forEach(add);
      return;
    }
    if (typeof node === "object") {
      const map = asRecord(node);
      const group = new GroupCriteria(String(valueOf(map, "fieldName") ?? ""));
      group.Direction = parseEnum(
        valueOf(map, "direction", "directions"),
        directionNames,
        OrderDirections.Ascending
      );
      group.Aggregates = asArray(valueOf(map, "aggregates")).map((item) => {
        const row = asRecord(item);
        return new AggregateCriteria(
          String(valueOf(row, "fieldName") ?? ""),
          parseEnum(valueOf(row, "aggregation"), aggregationNames)
        );
      });
      groups.push(group);
      add(valueOf(map, "subGroup"));
    }
  };
  add(raw);
  return groups;
}

export function loadCriteriaFromJson(json: unknown): LoadCriteria {
  const map = asRecord(json);
  const criteria = new LoadCriteria();
  const skip = valueOf(map, "skip");
  const take = valueOf(map, "take");
  if (typeof skip === "number") {
    criteria.Skip = skip;
  }
  if (typeof take === "number") {
    criteria.Take = take;
  }
  criteria.FilterBy = asArray(valueOf(map, "filterBy")).map((item) => {
    const row = asRecord(item);
    const filter = new FilterCriteria();
    filter.FieldName = String(valueOf(row, "fieldName") ?? "");
    filter.Op = parseEnum(valueOf(row, "op") ?? 1, operatorNames, Operators.And);
    filter.LogicalOperator = parseEnum(
      valueOf(row, "logicalOperator", "relation"),
      logicNames
    );
    filter.Values = asArray(valueOf(row, "values")).map((v) =>
      v == null ? null : String(v)
    );
    return filter;
  });
  criteria.OrderBy = asArray(valueOf(map, "orderBy")).map((item) => {
    const row = asRecord(item);
    const order = new OrderCriteria();
    order.FieldName = String(valueOf(row, "fieldName") ?? "");
    order.Direction = parseEnum(
      valueOf(row, "direction"),
      directionNames,
      OrderDirections.Ascending
    );
    return order;
  });
  criteria.GroupBy = groupByFromJson(valueOf(map, "groupBy"));
  const aggregates = valueOf(map, "aggregates");
  criteria.Aggregates =
    aggregates == null
      ? undefined
      : asArray(aggregates).map((item) => {
          const row = asRecord(item);
          return new AggregateCriteria(
            String(valueOf(row, "fieldName") ?? ""),
            parseEnum(valueOf(row, "aggregation"), aggregationNames)
          );
        });
  return criteria;
}

export function loadCriteriaToJson(criteria: LoadCriteria): Record<string, unknown> {
  return {
    skip: criteria.Skip ?? null,
    take: criteria.Take ?? null,
    filterBy: criteria.FilterBy.map((filter) => ({
      fieldName: filter.FieldName,
      op: filter.Op,
      logicalOperator: filter.LogicalOperator,
      values: filter.Values,
    })),
    orderBy: criteria.OrderBy.map((order) => ({
      fieldName: order.FieldName,
      direction: order.Direction,
    })),
    groupBy: criteria.GroupBy?.map((group) => ({
      fieldName: group.FieldName,
      direction: group.Direction,
      aggregates: group.Aggregates.map((agg) => ({
        fieldName: agg.FieldName,
        aggregation: agg.Aggregation,
      })),
    })),
    aggregates: criteria.Aggregates?.map((agg) => ({
      fieldName: agg.FieldName,
      aggregation: agg.Aggregation,
    })),
  };
}
