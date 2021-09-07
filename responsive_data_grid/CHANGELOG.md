## [0.0.13] - September 7th, 2021

1. Added the remaining filter types and ensured that custom filters are possible. Cleaned up the entire filter process.
2. Fixed an issue with order by
3. Fixed multiple filter issue.
4. Made FieldName required.

## [0.0.12] - August 11th, 2021

1. Improved scrolling functionality so that the grid will scale automatically to whatever content there is, unless the height parameter is specified or it reaches the totality of the parent's height. If the grid is in a scrollable it will not itself scroll as this would cause an infinite height. Instead it will allow the parent scrollable to scroll and be the full size unless the height property is specified in which case there is a defined total height and it will then allow internal scrolling inside the parent scrollable.
2. Enabled scroll physics as an option on the grid that defaults to Bouncing.
3. Enable row divider option by setting separatorThickness. (Null = none)
4. Add Title support with themeing based on the appbar by default but you can override it.
5. Add elevation support - Give the grid a drop shadow
6. Add padding support - Add the grid in it's parent.
7. Added support for the DataTableTheme within theming so that all elements follow the same rules for styling by default as the DataTableTheme that you have assigned on your MaterialApp.
8. Added textStyle properties to both the header and the fields so that you can override the values on a case by case basis.

## [0.0.7]

- Updated to use client_filtering shared library

## [0.0.2]

- Changed LoadResult.items to List<TItem>

## [0.0.1]

- Initial commit of Responsive Data Grid
