namespace ClientFilteringTests;

using System.Linq;
using System.Text.Json;
using ClientFiltering.Enums;
using ClientFiltering.Models;
using ClientFiltering.Serialization;
using FluentAssertions;
using Xunit;

public class LoadCriteriaContractTests
{
    private const string CanonicalJson = """
        {
          "skip": 10,
          "take": 25,
          "filterBy": [
            {
              "fieldName": "name",
              "op": 1,
              "logicalOperator": 1,
              "values": ["Ada"]
            },
            {
              "fieldName": "id",
              "op": 2,
              "logicalOperator": 10,
              "values": ["2"]
            }
          ],
          "orderBy": [
            {
              "fieldName": "name",
              "direction": 1
            }
          ],
          "groupBy": [
            {
              "fieldName": "name",
              "direction": 2,
              "aggregates": [
                { "fieldName": "id", "aggregation": 5 }
              ]
            },
            {
              "fieldName": "accepted",
              "direction": 1,
              "aggregates": []
            }
          ],
          "aggregates": [
            { "fieldName": "id", "aggregation": 5 }
          ]
        }
        """;

    private const string DotnetLegacyJson = """
        {
          "Skip": 10,
          "Take": 25,
          "FilterBy": [
            {
              "FieldName": "name",
              "Op": "And",
              "Relation": "Equals",
              "Values": ["Ada"]
            },
            {
              "FieldName": "id",
              "Op": "Or",
              "Relation": "NotEqual",
              "Values": ["2"]
            }
          ],
          "OrderBy": [
            { "FieldName": "name", "Direction": "Ascending" }
          ],
          "GroupBy": {
            "FieldName": "name",
            "Direction": "Descending",
            "Aggregates": [
              { "FieldName": "id", "Aggregation": "Count" }
            ],
            "SubGroup": {
              "FieldName": "accepted",
              "Direction": "Ascending",
              "Aggregates": []
            }
          },
          "Aggregates": [
            { "FieldName": "id", "Aggregation": "Count" }
          ]
        }
        """;

    [Fact]
    public void ParsesCanonicalV2Json()
    {
        var criteria = JsonSerializer.Deserialize<LoadCriteria>(
            CanonicalJson,
            ClientFilteringJson.Options
        )!;
        AssertCanonical(criteria);
    }

    [Fact]
    public void ParsesLegacyDotnetJson()
    {
        var criteria = JsonSerializer.Deserialize<LoadCriteria>(
            DotnetLegacyJson,
            ClientFilteringJson.Options
        )!;
        AssertCanonical(criteria);
    }

    [Fact]
    public void WritesCanonicalKeysAndIntEnums()
    {
        var criteria = JsonSerializer.Deserialize<LoadCriteria>(
            CanonicalJson,
            ClientFilteringJson.Options
        )!;
        using var doc = JsonDocument.Parse(
            JsonSerializer.Serialize(criteria, ClientFilteringJson.Options)
        );
        var root = doc.RootElement;
        root.GetProperty("skip").GetInt32().Should().Be(10);
        root.GetProperty("filterBy")[0].GetProperty("logicalOperator").GetInt32().Should().Be(1);
        root.GetProperty("filterBy")[0].GetProperty("op").GetInt32().Should().Be(1);
        root.GetProperty("groupBy").ValueKind.Should().Be(JsonValueKind.Array);
        root.GetProperty("groupBy").GetArrayLength().Should().Be(2);
        root.GetProperty("orderBy")[0].GetProperty("direction").GetInt32().Should().Be(1);
    }

    [Fact]
    public void BetweenIsARelationalOperator()
    {
        ((int)RelationalOperators.Between)
            .Should()
            .Be(13);
        JsonSerializer
            .Deserialize<RelationalOperators>("\"EndsWith\"", ClientFilteringJson.Options)
            .Should()
            .Be(RelationalOperators.EndsWidth);
    }

    private static void AssertCanonical(LoadCriteria c)
    {
        c.Skip.Should().Be(10);
        c.Take.Should().Be(25);
        c.FilterBy.Should().HaveCount(2);
        var first = c.FilterBy!.First();
        first.FieldName.Should().Be("name");
        first.Op.Should().Be(LogicalOperators.And);
        first.Relation.Should().Be(RelationalOperators.Equals);
        first.Values.Should().Equal("Ada");
        var second = c.FilterBy!.Skip(1).First();
        second.FieldName.Should().Be("id");
        second.Op.Should().Be(LogicalOperators.Or);
        second.Relation.Should().Be(RelationalOperators.NotEqual);
        c.OrderBy!.Single().Direction.Should().Be(OrderDirections.Ascending);
        c.GroupBy!.FieldName.Should().Be("name");
        c.GroupBy.Direction.Should().Be(OrderDirections.Descending);
        c.GroupBy.SubGroup!.FieldName.Should().Be("accepted");
        c.Aggregates!.Single().Aggregation.Should().Be(Aggregations.Count);
    }
}
