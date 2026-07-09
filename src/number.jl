# ----------------------------------------------------------------------------------------------- #
#
@doc """
	getExponent(x::Real)

Return the base-10 exponent used to write `x` as a significand times a power of ten.

The function delegates the exponent selection to `NumericIO.base10exp`, after promoting the input to a floating type. 
This keeps the exponent convention consistent with the rest of the package's scientific and engineering formatters.

# Examples
```jldoctest
julia> getExponent(1234.0)
3.0

julia> getExponent(0.012)
-2.0
```

# Notes
For `x == 0`, the exponent follows the convention used by `NumericIO.base10exp`.
"""
@inline getExponent(x::Real) = NumericIO.base10exp(promote_type(Float64, typeof(x))(x))

# ----------------------------------------------------------------------------------------------- #
#
@doc """
	getSignificand(x::Real)

Return the base-10 significand of `x`.

For non-zero inputs, the result is computed as `x / exp10(getExponent(x))`. The zero case is handled explicitly and returns zero of the same numeric kind whenever possible.

# Examples
```jldoctest
julia> getSignificand(1234.0)
1.234

julia> getSignificand(0.012)
1.2

julia> getSignificand(0)
0
```
"""
@inline getSignificand(x::Real) = x == 0 ? zero(x) : x / exp10(getExponent(x))

# ----------------------------------------------------------------------------------------------- #
#
@doc """
	getNumberOfDecimalsFromString(s::String, splitter::Union{Char, S})

Count the number of decimal digits in the significand part of a formatted number string.

The `splitter` separates the significand from the exponent, for example `"×"` in `"1.23×10³"` or `"\\times"` in `"1.23 \\times 10^{3}"`. 
Only the part before `splitter` is inspected, and whitespace in the decimal part is ignored. 
If the significand has no decimal point, the function returns `0`.

# Input
- `s` [`String`]: a formatted number string.
- `splitter` [`Union{Char, S}`]: the character or string that separates the significand from the exponent.

# Output
- [`Int`]: the number of decimal places in the significand.

# Examples
```jldoctest
julia> NumberRepresentation.getNumberOfDecimalsFromString("12.350×10³", "×")
3

julia> NumberRepresentation.getNumberOfDecimalsFromString("12×10³", "×")
0
```
"""
function getNumberOfDecimalsFromString(s::String, splitter::Union{Char, S}) where {S <: AbstractString}
	if occursin(".", s)
		parts = split(s, '.')
		subParts = split(parts[2], splitter)
		decimals = replace(subParts[1], r"\s+" => "")
		return length(decimals)
	end

	return 0
end


# ----------------------------------------------------------------------------------------------- #
#
@doc """
	getNumberOfIntegersFromString(s::String, splitter::Union{Char, S})

Count the number of integer digits in the significand part of a formatted number string.

The `splitter` separates the significand from the exponent. 
The function removes whitespace and explicit signs, including both ASCII `-` and Unicode `−`, before counting digits. 
This is useful for converting between a requested number of decimals and the total number of significant digits expected by some external formatters.

# Input
- `s` [`String`]: a formatted number string.
- `splitter` [`Union{Char, S}`]: the character or string that separates the significand from the exponent.

# Output
- [`Int`]: the number of integer digits in the significand.

# Examples
```jldoctest
julia> NumberRepresentation.getNumberOfIntegersFromString("12.35×10³", "×")
2

julia> NumberRepresentation.getNumberOfIntegersFromString("−999.90×10⁰", "×")
3
```
"""
function getNumberOfIntegersFromString(s::String, splitter::Union{Char, S}) where {S <: AbstractString}
	significand = split(s, splitter; limit = 2)[1]
	integerPart = split(significand, '.'; limit = 2)[1]
	integerPart = replace(integerPart, r"[\s\+\-−]" => "")
	return length(integerPart)
end


# ----------------------------------------------------------------------------------------------- #
