using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading;
using System.Threading.Tasks;
using ClientFiltering;
using ClientFiltering.Enums;
using ClientFiltering.Models;
using ClientFilteringTests.Model;
using FluentAssertions;
using Xunit;

namespace ClientFilteringTests
{
    public class Tests
    {
        [Fact]
        public void TypeSafeLoad()
        {
            var id = Guid.NewGuid().ToString();
            var contact = new Contact(Id: id, Name: "Test User", DateOfBirth: new DateTime(1977, 6, 17));

            var contacts = new List<Contact>(new[] { contact });

            var names = new[] { "Test User", "Testing" };

            var criteria = LoadCriteria.FromExpressions<Contact>(c => c.Name == "Test User" && c.Id == id, null, null, new[] { new OrderCriteria { FieldName = nameof(Contact.Name), Direction = OrderDirections.Ascending } });

            var results = contacts.AsQueryable().ApplyLoadCriteria(criteria).ToArray();

            results.Should().HaveCount(1);
            results.First().Name.Should().BeEquivalentTo("Test User");
        }

        [Fact]
        public async Task GetResultWithGroupsAndAggregates()
        {
            var id = Guid.NewGuid().ToString();
            var contact = new Contact(Id: id, Name: "Test User", DateOfBirth: new DateTime(1977, 6, 17));

            var contacts = new List<Contact>(new[] { contact });

            var names = new[] { "Test User", "Testing" };

            var criteria = LoadCriteria.FromExpressions<Contact>(c => c.Name == "Test User" && c.Id == id,
                                                null,
                                                null,
                                                new[] {
                                                    new OrderCriteria {
                                                        FieldName = nameof(Contact.Name),
                                                        Direction = OrderDirections.Ascending
                                                    }
                                                },
                                                new GroupCriteria
                                                {
                                                    FieldName = nameof(Contact.OrganizationId),
                                                    Direction = OrderDirections.Ascending,
                                                    Aggregates = new[] {
                                                        new AggregateCriteria {
                                                            Aggregation = Aggregations.Count,
                                                            FieldName = nameof(Contact.Name)
                                                        }
                                                    }
                                                },
                                                new[] {
                                                    new AggregateCriteria
                                                    {
                                                        Aggregation = Aggregations.Count,
                                                        FieldName = nameof(Contact.Name)
                                                    }
                                                });

            var results = await LoadCriteriaExtensions.GetCriteriaResult(contacts.AsQueryable(), criteria, CancellationToken.None);

            results.Should().NotBeNull();
            results.Items.Should().NotBeEmpty();
            results.GroupResults.Should().NotBeEmpty();
            results.GroupResults!.First().Value.Should().BeNull();
        }

        [Fact]
        public void VerifyCriteria()
        {
            var contact = new Contact(Id: Guid.NewGuid().ToString(), Name: "Test User", DateOfBirth: new DateTime(1977, 6, 17));

            var contacts = new List<Contact>(new[] { contact });

            var criteria = new LoadCriteria
            {
                OrderBy = new[] {new OrderCriteria {
                    Direction = OrderDirections.Ascending,
                    FieldName = nameof(Contact.Name),
                },},
                FilterBy = new[] {
                    new FilterCriteria {
                        FieldName = nameof(Contact.Name),
                        Relation = RelationalOperators.Equals,
                        Values = new [] {"Test User"},
                    }
                }
            };

            var query = contacts.AsQueryable().ApplyLoadCriteria(criteria);
            var results = query.ToArray();

            results.Should().HaveCount(1);
            results.First().Name.Should().BeEquivalentTo("Test User");
        }

        [Fact]
        public void VerifyEmptyFilterCriteria()
        {
            var contact = new Contact(Id: Guid.NewGuid().ToString(), Name: "Test User", DateOfBirth: new DateTime(1977, 6, 17));

            var contacts = new List<Contact>(new[] { contact });

            var criteria = new LoadCriteria
            {
                OrderBy = new[] {new OrderCriteria {
                    Direction = OrderDirections.Ascending,
                    FieldName = nameof(Contact.Name),
                },},
                FilterBy = new[] {
                    new FilterCriteria {
                        FieldName = nameof(Contact.Name),
                        Relation = RelationalOperators.Equals,
                        Values = Enumerable.Empty<string>(),
                    }
                }
            };

            Assert.Throws<InvalidOperationException>(() => contacts.AsQueryable().ApplyLoadCriteria(criteria));
        }

        [Fact]
        public void OrderBySubProperties()
        {
            var contact = new Contact(Id: Guid.NewGuid().ToString(),
                                        Name: "Test User",
                                        DateOfBirth: new DateTime(1977, 6, 17),
                                        Child: new Contact(Id: Guid.NewGuid().ToString(), Name: "Test Child", new DateTime(2010, 1, 26))
                                        );

            var contacts = new List<Contact>(new[] { contact });

            var criteria = new LoadCriteria
            {
                OrderBy = new[] {new OrderCriteria {
                    Direction = OrderDirections.Ascending,
                    FieldName = "Child.Name",
                },},
                FilterBy = new[] {
                    new FilterCriteria {
                        FieldName = nameof(Contact.Name),
                        Relation = RelationalOperators.Equals,
                        Values = new [] {"Test User"},
                    }
                }
            };

            var query = contacts.AsQueryable().ApplyLoadCriteria(criteria);
            var results = query.ToArray();

            results.Should().HaveCount(1);
            results.First().Name.Should().BeEquivalentTo("Test User");
        }

        [Fact]
        public void FilterByNullableProperty()
        {
            var contact = new Contact(Id: Guid.NewGuid().ToString(),
                            Name: "Test User",
                            DateOfBirth: new DateTime(1977, 6, 17),
                            Child: new Contact(Id: Guid.NewGuid().ToString(), Name: "Test Child", new DateTime(2010, 1, 26)),
                            OrganizationId: 100000
                            );

            var contacts = new List<Contact>(new[] { contact });

            var criteria = new LoadCriteria
            {
                FilterBy = new[] {
                    new FilterCriteria {
                        FieldName = nameof(Contact.OrganizationId),
                        Relation = RelationalOperators.Equals,
                        Values = new [] {"100000"},
                    }
                }
            };

            var query = contacts.AsQueryable().ApplyLoadCriteria(criteria);
            var results = query.ToArray();

            results.Should().HaveCount(1);
            results.First().Name.Should().BeEquivalentTo("Test User");
        }
    }
}
