# ----------------------------------------------------------------------------------------------- #
#
@inline getExponent(x::Real) = NumericIO.base10exp(x)

# ----------------------------------------------------------------------------------------------- #
#
@inline getSignificand(x::Real) = x / getExponent(x)

# ----------------------------------------------------------------------------------------------- #
#
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
function getNumberOfIntegersFromString(s::String, splitter::Union{Char, S}) where {S <: AbstractString}
	if occursin(".", s)
		parts = split(s, '.')
		subParts = split(parts[1], splitter)
		decimals = replace(subParts[1], r"\s+" => "")
		return length(decimals)
	end

	return 0
end


# ----------------------------------------------------------------------------------------------- #
