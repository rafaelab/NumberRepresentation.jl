# NumberRepresentation.jl


[![Build Status](https://github.com/rafaelab/NumberRepresentation.jl/actions/workflows/CI.yml/badge.svg)](https://github.com/rafaelab/NumberRepresentation.jl/actions)
[![Documentation](https://img.shields.io/badge/docs-stable-blue.svg)](https://rafaelab.github.io/NumberRepresentation.jl/index.html)
[![License](https://img.shields.io/badge/license-MIT-green.svg)](LICENSE)




A small Julia library to format and manipulate numeric string representations of numbers, including scientific, engineering and fixed-point notations. 
It provides types and helpers to produce and post-process strings like `1.23×10^3` or plain `1.23e+03`.


## Highlights

- Create human-friendly string representations (plain, Unicode, TeX).
- Decompose numbers into significand and exponent.
- Parse numeric strings that use different multiplication symbols (e.g. `e`, `×`).
- Post-process representations: show explicit signs, shorten `1×10ⁿ` to `10ⁿ`, etc.


## Features

- Represent numbers as plain, Unicode or TeX strings via
  [`NumberRepresentationPlain`](src/representation.jl),
  [`NumberRepresentationUnicode`](src/representation.jl) and
  [`NumberRepresentationTeX`](src/representation.jl).


## Quickstart

```julia
using Pkg
Pkg.activate(".")
Pkg.instantiate()
using NumberRepresentation

# create a Unicode scientific representation
r = NumberRepresentationUnicode(1200.0, ScientificNotation; decimals=2, timesSymbol="×")
println(r.representation) # -> "1.20×10³"

# decompose and parse strings
(sig, exp) = decomposeNumberString("1.23×4", "×")
x = parseNumberString("1.2e3", "e") # -> 1200.0

# get significand/exponent
s = getSignificand(12345.0)
e = getExponent(12345.0)
```


## API (selected)

- Types
  - NumberRepresentationPlain(number, notation; ...)
  - NumberRepresentationUnicode(number, notation; ...)
  - NumberRepresentationTeX(number, notation; ...)
- Utilities
  - getSignificand(number)
  - getExponent(number)
  - decomposeNumberString(str, timesSymbol)
  - parseNumberString(str, timesSymbol[, ::Type])
  - showSignSignificand!(repr)
  - showSignExponent!(repr)
  - shortenOneTimes!(repr; ε = ...)

See source files in `src/` for full API details and options.

## Running tests
Run the package tests (see test/runtests.jl)
```
julia --project=. -e 'using Pkg; Pkg.test()'
```

## Development notes

- The package provides plain (ASCII) and Unicode renderings. Use `timesSymbol` to control the multiplicative separator (`"e"`, `"×"`, etc).
- Post-processing functions (e.g. sign handling, shortening) mutate the `representation` field in place.


## License

MIT — see `LICENSE`.

