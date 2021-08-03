# Client Filtering

## Overview

This library uses a standard set of models and enumerations that can be passed on WebAPI endpoints and allow dynamic client side filtering, sorting, take and skip similar to oData without the cerimony, complex string functions, or the MASSIVE overhead of oData.

Combined with the Flutter responsive_data_grid or Kendo UI Grid control for example you can easily provide full featured server side filtering, sorting, and paging in a single line of code.

## Getting Started

### Add the nuget library

dotnet package add clientfiltering

### Create an HttpGet endpoint within an ApiController

```
[HttpGet("SomeGet")]
public Task<ActionResult<IEnumerable<SomeDto>>> List([FromBody] LoadCriteria? criteria = null, [FromService] DbSession session, CancellationToken cancellationToken = default) {
    return session.SomeCollection.ApplyLoadCriteria(criteria).ToArrayAsync(cancellationToken);
}
```

With a single line, we can apply our LoadCriteria to our collection which results in an IQueryable which you can then materialize or otherwise return whatever you wish.

### Flutter

Check out the responsive_data_grid control for a full implementation that "Just Works" (TM) and provides advanced functionality for a data grid.

### Kendo UI Grid and other grid style controls

Because of the structure of this library it is generally trivial to convert Kendo UI's grid or other similar products to generate HTTP requests for data that filter, sort and page using this library as it is styled after the basic functionality in Kendo UI Grid.

## TODOs

1. It would be nice if on .NET that this library was strongly typed when used as a client or allowed you to use Linq against the objects and would generate a LoadCriteria.
2. It would be nice to add direct T-SQL implementations or other language specific implementations outside of Entity Framework. This library has already been proven to work nicely with RavenDB as an example.

## Contributing

Pull requests most welcome to fix any bugs found or address any of the above TODOs or any additional functionality you'd like to see.
