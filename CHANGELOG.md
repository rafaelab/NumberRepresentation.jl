# Changelog



----
## [1.0.6]

## Fixed
- Fixed bug related to keyword-provided configuration, which was leading to `NumberRepresentationTeX` to ignore decimals.


---
## [1.0.5]

## Fixed
- Improve compatibility of package dependency versions.



---
## [1.0.4]

### Additions
- Auto-generate documentation
- Add documentation workflow

### Fixed
- Minor bug changed related to dict type in config.



---
## [1.0.3] 

### Changed
- Renamed `decomposeNumberString` → `decomposeNumberFromString` for consistency with Julia naming conventions.
- Renamed `parseNumberString` → `parseNumberFromString` for consistency with Julia naming conventions.


---
## [1.0.2]

### Fixed
- Minor bug fixes and stability improvements.


---
## [1.0.1]


---
### Fixed
- Minor bug fixes and stability improvements.


---
## [1.0.0]

### Added
- `NumberRepresentationPlain`: plain ASCII string representation (e.g. `1.23e+03`).
- `NumberRepresentationUnicode`: Unicode string representation with superscript exponents and `×` symbol (e.g. `1.23×10³`).
- `NumberRepresentationTeX`: LaTeX string representation (e.g. `1.23 \times 10^{3}`).
- `NumberRepresentationMakieRichText`: Makie `RichText` representation via a weak dependency extension.
- `NumberRepresentationConfig`: configuration struct with fields for decimal precision, sign display, and shortening options.
- `ScientificNotation`, `EngineeringNotation`, `FixedPointNotation`: notation type singletons.
- `getSignificand(x)`: returns the base-10 significand of a number.
- `getExponent(x)`: returns the base-10 exponent of a number.
- `decomposeNumberFromString(s, times)`: splits a numeric string into `(significand, exponent)`.
- `parseNumberFromString(s, times[, T])`: parses a numeric string to a `Real` value (default `Float64`).
- `getTimesSymbol(repr)`, `getNumberType(repr)`, `getNotationType(repr)`: accessor utilities.
- Post-processing mutators: `showSignSignificand!`, `showSignExponent!`, `shortenOneTimes!`, `shortenBaseToZero!`, `updateRepresentation!`.
- `@buildNumberRepresentationConstructor` macro for generating full constructor families for representation types.
- Makie extension (`NumberRepresentationMakieRichTextExt`) activated automatically when `Makie.jl` is loaded.
