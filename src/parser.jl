# ----------------------------------------------------------------------------------------------- #
#
@doc """
	decomposeNumberFromString(s::AbstractString, times::String) -> (significandStr::String, exponentStr::Union{String, Nothing})

Decomposes a number string into its significand and exponent parts based on the provided times symbol.

# Input
- `s` [`AbstractString`]: the number string to decompose
- `times` [`String`]: the symbol used to separate significand and exponent (e.g., "e", "×")

# Output
- A tuple containing the significand string and the exponent string (or `nothing` if no exponent is present).
"""
function decomposeNumberFromString(s::AbstractString, times::String)
	if occursin(times, s)
		parts = split(s, times)
		significandStr = replace(parts[1], r"\s+" => "")
		exponentStr = replace(parts[2], r"\s+" => "")
		return String(significandStr), String(exponentStr)
	else
		return String(s), nothing
	end
end


# ----------------------------------------------------------------------------------------------- #
#
@doc """
	parseNumberFromString(s::AbstractString, times::String, ::Type{T}) where {T <: Real} -> T

Parses a number string into a numeric value of type `T`, handling both standard and scientific notation based on the provided times symbol.

# Input
- `s` [`AbstractString`]: the number string to parse
- `times` [`String`]: the symbol used to separate significand and exponent (e.g., "e", "×")
- `T` [`Type{<:Real}`]: the desired numeric type for the output

# Output
- A numeric value of type `T` representing the parsed number.
"""
function parseNumberFromString(s::AbstractString, times::String, ::Type{T}) where {T <: Real}
	significandStr, exponentStr = decomposeNumberFromString(s, times)
	significandStr = replace(significandStr, r"\s+" => "")
	if isnothing(exponentStr) && ! (T <: Integer)
		return parse(T, significandStr)
	end

	exponent = isnothing(exponentStr) ? 0 : parse(Int, exponentStr)
	if T <: Integer
		parts = split(significandStr, '.'; limit = 2)
		significand = parse(BigInt, join(parts))
		exponent -= length(parts) == 2 ? length(parts[2]) : 0
		value = exponent ≥ 0 ? significand * big(10)^exponent : significand // big(10)^(-exponent)
		return T(value)
	end

	return parse(T, significandStr * "e" * string(exponent))
end

function parseNumberFromString(s::AbstractString, times::String)
	return parseNumberFromString(s, times, Float64)
end


# ----------------------------------------------------------------------------------------------- #
