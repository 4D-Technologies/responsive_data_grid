using System;
namespace ClientFilteringTests.Model
{
    public record Contact(string Id, string Name, DateTime DateOfBirth, Contact? Child = null, int? OrganizationId = null);

}