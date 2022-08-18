using System;
using System.Collections.Generic;
using System.Linq;
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

            var criteria = LoadCriteria.FromExpressions<Contact>(c => c.Name == "Test User" && c.Id == id, null, null, new OrderCriteria { FieldName = nameof(Contact.Name), Direction = OrderDirections.Ascending});

            var results = contacts.AsQueryable().ApplyLoadCriteria(criteria).ToArray();

            results.Should().HaveCount(1);
            results.First().Name.Should().BeEquivalentTo("Test User");
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
                        LogicalOperator = Logic.Equals,
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
                        LogicalOperator = Logic.Equals,
                        Values = Enumerable.Empty<string>(),
                    }
                }
            };

            var results = contacts.AsQueryable().ApplyLoadCriteria(criteria).ToArray();

            results.Should().HaveCount(0);
        }
    }
}
