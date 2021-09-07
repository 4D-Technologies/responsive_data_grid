# responsive_data_grid

A Flutter widget that is inspired by Kendo Data Grid and allows sorting, filtering, and paging with full bootstrap style responsive layout.

For a fully automatic implementation that allows you to tie your responsive data grid to your C# WebAPI REST/GRPC backend with full automatic filtering, sorting, take and skip functionality that generates a full expression tress against your Entity Framework or other Linq based queries, see the dotnet sub folder of the root project and the associated nuget package.

## Features

1. Paging
2. Sorting (including multi-column sorting)
3. Filtering (including mutli-column filtering with friendly interactive filter dialogs)
4. Paging
5. Infinite scroll with load on demand
6. Height, or shrinkwrap mode.
7. Full responsive design similar to how bootstrap grid layout works allowing for custom layouts of your data grid across mobile, web and desktop.

## Getting Started

1. Add the library per the instructions.
2. import the responsive_data_grid to your dart file.
3. Use ResponsiveDataGrid<RowItemType>. It is important to ensure that you specify the generic in the defintion so that the grid can do it's magic while you're setting it up.
4. Review the example project for more details.

**TODO**

1. Integration Testing
2. More documentation, examples, and getting started with screen shots
3. Column Freezing
4. Grouping with Sumaries and Group Footers
5. Footer with Overall Summaries
