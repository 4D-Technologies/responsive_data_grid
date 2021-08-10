## [0.0.9] - August 10th, 2021

1. Improved scrolling functionality so that the grid will scale automatically to whatever content there is, unless the height parameter is specified or it reaches the totality of the parent's height. If the grid is in a scrollable it will not itself scroll as this would cause an infinite height. Instead it will allow the parent scrollable to scroll and be the full size unless the height property is specified in which case there is a defined total height and it will then allow internal scrolling inside the parent scrollable.
2. Enabled scroll physics as an option on the grid that defaults to Bouncing.
3. Enable row divider option by setting separatorThickness. (Null = none)

## [0.0.7]

- Updated to use client_filtering shared library

## [0.0.2]

- Changed LoadResult.items to List<TItem>

## [0.0.1]

- Initial commit of Responsive Data Grid
