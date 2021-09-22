using System;
using Xunit;
using ClientFilteringTests.Model;
using System.Collections.Generic;
using ClientFiltering.Models;
using ClientFiltering.Enums;
using System.Linq;
using ClientFiltering;
using FluentAssertions;

namespace ClientFilteringTests
{
    public class Tests
    {
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

            var results = contacts.AsQueryable().ApplyLoadCriteria(criteria).ToArray();

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
