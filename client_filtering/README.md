# client_filtering

Client Filtering works hand in hand with responsive_data_grid but can be used in other projects as well.

This project holds the models and enums required to do complex client side filtering similar to what oData or Kendo Data Grid does. This allows for advanced filtering scenarios for data grids, and other options that you might implement in your REST/GRPC API.

In addition to the flutter client side implementation there is a C# implementation using pure Linq Expressions available that will decode these objects and apply them to an IQueryable of the same type.

## Getting Started

Typically this package will be implemented as a dependancy of another package like responsive_data_grid and does not need to be directly implemented. However, if you wish to use this directly simply import and use the models provided and pass them to your API.
