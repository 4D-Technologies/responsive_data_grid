import assert from "node:assert/strict";
import test from "node:test";
import { loadCriteriaFromJson, loadCriteriaToJson } from "../src/lib/json.ts";
import { Logic } from "../src/lib/enums.ts";
import { LoadCriteria } from "../src/lib/loadcriteria.ts";

const canonicalJson = {
  skip: 10,
  take: 25,
  filterBy: [
    { fieldName: "name", op: 1, logicalOperator: 1, values: ["Ada"] },
    { fieldName: "id", op: 2, logicalOperator: 10, values: ["2"] },
  ],
  orderBy: [{ fieldName: "name", direction: 1 }],
  groupBy: [
    {
      fieldName: "name",
      direction: 2,
      aggregates: [{ fieldName: "id", aggregation: 5 }],
    },
    { fieldName: "accepted", direction: 1, aggregates: [] },
  ],
  aggregates: [{ fieldName: "id", aggregation: 5 }],
};

const dotnetLegacyJson = {
  Skip: 10,
  Take: 25,
  FilterBy: [
    { FieldName: "name", Op: "And", Relation: "Equals", Values: ["Ada"] },
    { FieldName: "id", Op: "Or", Relation: "NotEqual", Values: ["2"] },
  ],
  OrderBy: [{ FieldName: "name", Direction: "Ascending" }],
  GroupBy: {
    FieldName: "name",
    Direction: "Descending",
    Aggregates: [{ FieldName: "id", Aggregation: "Count" }],
    SubGroup: {
      FieldName: "accepted",
      Direction: "Ascending",
      Aggregates: [],
    },
  },
  Aggregates: [{ FieldName: "id", Aggregation: "Count" }],
};

function assertCanonical(criteria: LoadCriteria): void {
  assert.equal(criteria.Skip, 10);
  assert.equal(criteria.Take, 25);
  assert.equal(criteria.FilterBy.length, 2);
  assert.equal(criteria.FilterBy[0].FieldName, "name");
  assert.equal(criteria.FilterBy[0].LogicalOperator, Logic.Equals);
  assert.equal(criteria.FilterBy[1].Op, 2);
  assert.equal(criteria.GroupBy?.length, 2);
  assert.equal(criteria.GroupBy?.[0].FieldName, "name");
  assert.equal(criteria.GroupBy?.[1].FieldName, "accepted");
  assert.equal(criteria.Aggregates?.[0].Aggregation, 5);
}

test("parses canonical V2 JSON", () => {
  assertCanonical(loadCriteriaFromJson(canonicalJson));
});

test("parses legacy .NET JSON", () => {
  assertCanonical(loadCriteriaFromJson(dotnetLegacyJson));
});

test("toJSON emits canonical keys and int enums", () => {
  const json = loadCriteriaToJson(loadCriteriaFromJson(canonicalJson));
  assert.equal(
    (json.filterBy as { logicalOperator: number }[])[0].logicalOperator,
    1
  );
  assert.ok(Array.isArray(json.groupBy));
  assert.equal((json.groupBy as unknown[]).length, 2);
  assert.equal((json.orderBy as { direction: number }[])[0].direction, 1);
});
