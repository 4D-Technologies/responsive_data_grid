# Change Log

## [0.0.28] - March 24th, 2025

- Update some versions

## [0.0.27] - January 27th, 2025

- Open up intl version constraint

## [0.0.26] - January 27th, 2025

- Enable oData query generation for filter, order, skip and take as extension methods

## [0.0.25] - November 29th, 2022

- Fix casing issue in serialization

## [0.0.24] - November 29th, 2022

- Fix serialization issue

## [0.0.23] - November 28th, 2022

- Add SimpleListResponse and ListResponse as wrappers that are returned from APIs supporting Client Filtering

## [0.0.22] - November 28th, 2022

- Improve Json serialization/deserialization
- Add result types

## [0.0.21] - November 28th, 2022

- Added the result types
- Updated to new dart enum types

## [0.0.20] - May 18th, 2022

## [0.0.19] - April 19th, 2022

- Updated to Dart 2.16
- Updated repro address

## [0.0.18] - September 10th, 2021

- Updated to Dart 2.14
- Updated linting and fixed various issues surfaced by the linter
- Fixed issue with json encoding of FilterCriteria

## [0.0.15] - September 8th, 2021

- Add Between Operator for numerics and date/times.
- Add Localization ability by setting the values in ClientFilteringLocalizedMessages.
- Use functions for copyWith so that nulls can be passed properly.
- Make FilterCriteria Strongly typed
- Make FilterCriteria hold list of values for filters on value lists where one to N values may be present.

## [0.0.7] - August 3rd, 2021

- Initial Release of the basic functionality to implement Client Filtering
