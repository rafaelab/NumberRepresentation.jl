# NumberRepresentation.jl


A small Julia library to format and manipulate numeric string representations of numbers, including scientific, engineering and fixed-point notations. 
It provides types and helpers to produce and post-process strings like `1.23×10^3` or plain `1.23e+03`.



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
(sig, exp) = decomposeNumberFromString("1.23×4", "×")
x = parseNumberFromString("1.2e3", "e") # -> 1200.0

# get significand/exponent
s = getSignificand(12345.0)
e = getExponent(12345.0)
```


