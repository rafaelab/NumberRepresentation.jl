# ----------------------------------------------------------------------------------------------- #
#
@doc """
	AbstractNumberRepresentation

An abstract type for number representations.

# Type Parameters
. `T` [`<: Real`]: the numeric type of the represented number \\
. `U` [`<: AbstractNumberNotation`]: the notation type used for the representation
"""
abstract type AbstractNumberRepresentation{T <: Real, U <: AbstractNumberNotation} end

# ----------------------------------------------------------------------------------------------- #
#
@doc """
	NumberRepresentationPlain{T}

Defines a number representation in plain string format.
This is the direct output of NumericIO formatting.

# Fields
. `number` [`Real`]: the number being represented \\
. `representation` [`String`]: the string representation of the number \\
. `timesSymbol` [`String`]: the multiplication symbol used in the representation \\
"""
mutable struct NumberRepresentationPlain{T, U} <: AbstractNumberRepresentation{T, U}
	number::T
	representation::String
end

NumberRepresentationPlain(number::Real, ::Type{FixedPointNotation}; decimals::Integer = 6, signSignificand::Bool = true, signExponent::Bool = false, shortenOneTimes::Bool = false, shortenBaseToZero::Bool = false, ε::Real = 1e-8) = begin
	fmt = signSignificand ? "%+.$(decimals)f" : "%.$(decimals)f"
	repr = NumberRepresentationPlain{typeof(number), FixedPointNotation}(number, fmt, timesSymbol)
	return updateRepresentation!(repr; signSignificand = signSignificand, signExponent = signExponent, shortenOneTimes = shortenOneTimes, shortenBaseToZero = shortenBaseToZero, ε = ε)
end	

NumberRepresentationPlain(number::Real, ::Type{ScientificNotation}; decimals::Integer = 3, signSignificand::Bool = false, signExponent::Bool = false, shortenOneTimes::Bool = false, shortenBaseToZero::Bool = false, ε::Real = 1e-8) = begin
	fmt = decimals + 1
	s = formatted(number, :SCI; ndigits = fmt)
	repr = NumberRepresentationPlain{typeof(number), ScientificNotation}(number, s)
	return updateRepresentation!(repr; signSignificand = signSignificand, signExponent = signExponent, shortenOneTimes = shortenOneTimes, shortenBaseToZero = shortenBaseToZero, ε = ε)
end

NumberRepresentationPlain(number::Real, ::Type{EngineeringNotation}; decimals::Integer = 2, signSignificand::Bool = false, signExponent::Bool = false, shortenOneTimes::Bool = false, shortenBaseToZero::Bool = false, ε::Real = 1e-8) = begin
	s0 = formatted(number, :ENG)
	parts = split(split(s0, "×")[1], ".")

	if length(parts) == 1
		nDigits = 0
	else
		nDigits = decimals + length(@sprintf("%.0f", number / (exp10(NumericIO.base10exp(number))))) + 1
	end

	s = formatted(number, :ENG; ndigits = nDigits)
	repr = NumberRepresentationPlain{typeof(number), EngineeringNotation}(number, s, timesSymbol)
	return updateRepresentation!(repr; signSignificand = signSignificand, signExponent = signExponent, shortenOneTimes = shortenOneTimes, shortenBaseToZero = shortenBaseToZero, ε = ε)
end

NumberRepresentationPlain(number::Real, notation::AbstractNumberNotation; args...) = begin
	return NumberRepresentationPlain(number, typeof(notation); args...)
end

NumberRepresentationPlain(number::Real; args...) = begin
	return NumberRepresentationPlain(number, FixedPointNotation; args...)
end


# ----------------------------------------------------------------------------------------------- #
#
@doc """
	NumberRepresentationUnicode

Defines a number representation in unicode string format.

# Fields
. `number` [`Real`]: the number being represented \\
. `representation` [`String`]: the string representation of the number \\
. `timesSymbol` [`String`]: the multiplication symbol used in the representation \\
"""
mutable struct NumberRepresentationUnicode{T, U} <: AbstractNumberRepresentation{T, U}
	number::T
	representation::String
	timesSymbol::String
end


NumberRepresentationUnicode(number::Real, ::Type{FixedPointNotation}; decimals::Integer = 6, signSignificand::Bool = true, signExponent::Bool = false, shortenOneTimes::Bool = false, shortenBaseToZero::Bool = false, ε::Real = 1e-8) = begin
	fmt = signSignificand ? "%+.$(decimals)f" : "%.$(decimals)f"
	str = @eval @sprintf($fmt, $number)
	repr = NumberRepresentationPlain{typeof(number), FixedPointNotation}(number, str, timesSymbol)
	return updateRepresentation!(repr; signSignificand = signSignificand, signExponent = signExponent, shortenOneTimes = shortenOneTimes, shortenBaseToZero = shortenBaseToZero, ε = ε)
end	

NumberRepresentationUnicode(number::Real, ::Type{ScientificNotation}; decimals::Integer = 3, signSignificand::Bool = false, signExponent::Bool = false, shortenOneTimes::Bool = false, shortenBaseToZero::Bool = false, ε::Real = 1e-8, timesSymbol::Union{String, Char} = "×") = begin
	str = formatted(number, :SCI; ndigits = decimals + 1)
	repr = NumberRepresentationUnicode{typeof(number), ScientificNotation}(number, str, timesSymbol)
	updateRepresentation!(repr; signSignificand = signSignificand, signExponent = signExponent, shortenOneTimes = shortenOneTimes, shortenBaseToZero = shortenBaseToZero, ε = ε)
	return repr
end

NumberRepresentationUnicode(number::Real, ::Type{EngineeringNotation}; decimals::Integer = 2, signSignificand::Bool = false, signExponent::Bool = false, shortenOneTimes::Bool = false, shortenBaseToZero::Bool = false, ε::Real = 1e-8, timesSymbol::Union{String, Char} = "×") = begin
	str0 = formatted(number, :ENG)
	nIntegers = getNumberOfIntegersFromString(str0, timesSymbol)

	str = formatted(number, :ENG; ndigits = decimals + nIntegers + 1)
	repr = NumberRepresentationUnicode{typeof(number), ScientificNotation}(number, str, timesSymbol)
	updateRepresentation!(repr; signSignificand = signSignificand, signExponent = signExponent, shortenOneTimes = shortenOneTimes, shortenBaseToZero = shortenBaseToZero, ε = ε)

	return repr
end

NumberRepresentationUnicode(number::Real, notation::AbstractNumberNotation; args...) = begin
	return NumberRepresentationUnicode(number, typeof(notation); args...)
end

NumberRepresentationUnicode(number::Real; decimals::Integer = 2, signSignificand::Bool = false, signExponent::Bool = false, shortenOneTimes::Bool = false, shortenBaseToZero::Bool = false, ε::Real = 1e-8, timesSymbol::Union{String, Char} = "×") = begin
	return NumberRepresentationUnicode(number, ScientificNotation; decimals = decimals, signSignificand = signSignificand, signExponent = signExponent, shortenOneTimes = shortenOneTimes, shortenBaseToZero = shortenBaseToZero, ε = ε, timesSymbol = timesSymbol)
end



# ----------------------------------------------------------------------------------------------- #
#
@doc """
	NumberRepresentationTeX

Defines a number representation in TeX string format.

# Fields
. `number` [`Real`]: the number being represented \\
. `representation` [`String`]: the string representation of the number \\
. `timesSymbol` [`String`]: the multiplication symbol used in the representation \\
"""
mutable struct NumberRepresentationTeX{T, U} <: AbstractNumberRepresentation{T, U}
	number::T
	representation::String
	timesSymbol::String
end

# NumberRepresentationTeX(number::T, representation::String, ::Type{N}; timesSymbol::String = "×") where {T <: Real, N <: AbstractNumberNotation} = begin
# 	return NumberRepresentationTeX{T, N}(number, representation, timesSymbol)
# end

# NumberRepresentationTeX(number::Real, representation::String; timesSymbol::String = "×") = begin
# 	return NumberRepresentationTeX(number, representation, FixedPointNotation; timesSymbol = timesSymbol)
# end


# ----------------------------------------------------------------------------------------------- #
#
@doc """
	getNumberType(repr::AbstractNumberRepresentation)

Get the number type of the number representation.
"""
@inline getNumberType(::AbstractNumberRepresentation{T, U}) where {T, U} = T


# ----------------------------------------------------------------------------------------------- #
#
@doc """
	getNotationType(repr::AbstractNumberRepresentation)

Get the notation type of the number representation.
"""
@inline getNotationType(::AbstractNumberRepresentation{T, U}) where {T, U} = U


# ----------------------------------------------------------------------------------------------- #
#
@doc """
	getTimesSymbol(repr::AbstractNumberRepresentation)

Get the multiplication symbol used in the number representation.
"""
@inline getTimesSymbol(repr::NumberRepresentationPlain) = "e"
@inline getTimesSymbol(repr::Union{NumberRepresentationUnicode, NumberRepresentationTeX}) = repr.timesSymbol


# ----------------------------------------------------------------------------------------------- #
#
@doc """
	showSignSignificand!(repr::NumberRepresentationPlain)

Modify the representation to include an explicit sign for the significand.

# Input
. `repr` [`NumberRepresentationPlain`]: the number representation to modify \\

# Output
. The modified `repr` with explicit sign for the significand.
"""
function showSignSignificand!(repr::AbstractNumberRepresentation)
	if startswith(repr.representation, '+') || startswith(repr.representation, '-')
		return repr
	end
	repr.representation = (repr.number ≥ 0 ? "+" : "-") * repr.representation
	return repr
end

showSignSignificand!(repr::AbstractNumberRepresentation, ::AbstractNumberNotation) = begin
	showSignSignificand!(repr)
end


# ----------------------------------------------------------------------------------------------- #
#
@doc """
	showSignExponent!(repr::NumberRepresentationPlain)

Modify the representation to include an explicit sign for the exponent.

# Input
. `repr` [`NumberRepresentationPlain`]: the number representation to modify \\

# Output
. The modified `repr` with explicit sign for the exponent.
"""
function showSignExponent!(repr::AbstractNumberRepresentation, ::FixedPointNotation)
	return repr
end

function showSignExponent!(repr::NumberRepresentationPlain, ::Union{ScientificNotation, EngineeringNotation})
	times = getTimesSymbol(repr)
	if occursin(times, repr.representation)
		parts = split(repr.representation, times)
		if ! startswith(strip(parts[2]), '+') && ! startswith(strip(parts[2]), '-')
			s = log10(abs(repr.number)) ≥ 0 ? "+" : "-"
			repr.representation = replace(repr.representation, times => times * s)
		end
	end

	return repr
end

function showSignExponent!(repr::NumberRepresentationUnicode, ::Union{ScientificNotation, EngineeringNotation})
	significand, exponent = decomposeNumberString(repr.representation, repr.timesSymbol)
	if ! isnothing(exponent)
		if ! startswith(strip(exponent), '⁺') && ! startswith(strip(exponent), '⁻')
			s = log10(abs(repr.number)) ≥ 0 ? "⁺" : "⁻"
			repr.representation = replace(repr.representation, "10" => "10$(s)")
		end
	end

	return repr
end

# function showSignExponent!(repr::NumberRepresentationTeX, ::Union{ScientificNotation, EngineeringNotation})
# 	significand, exponent = decomposeNumberString(repr.representation, repr.timesSymbol)
# 	if ! isnothing(exponent)
# 		if ! startswith(strip(exponent), '+') && ! startswith(strip(exponent), '-')
# 			s = log10(abs(repr.number)) ≥ 0 ? "+" : "-"
# 			repr.representation = "$(significand) $(repr.timesSymbol) 10^\{$(s)$(exponent)\}"
# 		end
# 	end
# end



# ----------------------------------------------------------------------------------------------- #
#
@doc """
	shortenOneTimes!(repr::NumberRepresentationPlain)

Modify the representation to shorten "1×10^n" to "10^n".
The function only shortens if the significand is approximately 1, within a tolerance `ε`.

# Input
. `repr` [`NumberRepresentationPlain`]: the number representation to modify \
. `ε` [`Real`]: tolerance for considering the significand approximately 1 \

# Output
. The modified `repr` with shortened "1×10^n" to "10^n".
"""
function shortenOneTimes!(repr::NumberRepresentationPlain, ::AbstractNumberNotation; ε::Real = 1e-8)
	# @warn("NumberRepresentationPlain does not support shortenOneTimes!")
	return repr
end

function shortenOneTimes!(repr::NumberRepresentationUnicode, ::Union{ScientificNotation, EngineeringNotation}; ε::Real = 1e-8)
	if isapprox(getSignificand(repr.number), 1.; atol = ε)
		pattern = Regex("([\\+\\-]?1(?:\\.0+)?\\s*" * repr.timesSymbol * "\\s*)?10([⁺⁻⁰¹²³⁴⁵⁶⁷⁸⁹]+)")
		repr.representation = replace(repr.representation, pattern => m -> begin
			matched = match(pattern, String(m))
			if isnothing(matched)
				return String(m)
			end
			expSup = String(matched.captures[2])
			return "10$(expSup)"
		end)
	end

	return repr
end


# ----------------------------------------------------------------------------------------------- #
#
@doc """
	shortenBaseToZero!(repr::NumberRepresentationPlain; signSignificand::Bool, shortenOneTimes::Bool, ε::Real)

Modify the representation to shorten "B^0" to "1".

# Input
. `repr` [`NumberRepresentationPlain`]: the number representation to modify \
. `shortenOneTimes` [`Bool`]: whether to shorten "1×10^n" to "10^n" \
. `signSignificand` [`Bool`]: whether to include an explicit sign for the significand \
. `ε` [`Real`]: tolerance for considering the exponent approximately zero \

# Output
. The modified `repr` with shortened "B^0" to "1".
"""
function shortenBaseToZero!(repr::AbstractNumberRepresentation, ::Union{T, Type{T}}; args...) where {T <: FixedPointNotation}
	# @warn("shortenBaseToZero! is not applicable for FixedPointNotation.")
	return repr
end

function shortenBaseToZero!(repr::AbstractNumberRepresentation, ::Union{T, Type{T}}; signSignificand::Bool = false, shortenOneTimes::Bool = false, ε::Real = 1e-8) where {T <: Union{ScientificNotation, EngineeringNotation}}
	if isapprox(getExponent(repr.number), 0; atol = ε)
		if shortenOneTimes && isapprox(getSignificand(repr.number), 1.; atol = ε)
			nDecimals = getNumberOfDecimalsFromString(repr.representation, getTimesSymbol(repr))
			fmt = signSignificand ? "%+.$(nDecimals)f" : "%.$(nDecimals)f"
			repr.representation = @eval @sprintf($fmt, 1.0)
		else
			repr.representation = decomposeNumberString(repr.representation, getTimesSymbol(repr))[1]
		end
	end

	return repr
end


# ----------------------------------------------------------------------------------------------- #
#
function updateRepresentation!(repr::AbstractNumberRepresentation; signSignificand::Bool = false, signExponent::Bool = false, shortenOneTimes::Bool = false, shortenBaseToZero::Bool = false, ε::Real = 1e-8)
	signSignificand && showSignSignificand!(repr)
	signExponent && showSignExponent!(repr)
	shortenOneTimes && shortenOneTimes!(repr; ε = ε)
	shortenBaseToZero && shortenBaseToZero!(repr; signSignificand = signSignificand, shortenOneTimes = shortenOneTimes, ε = ε)
	return repr
end

# ----------------------------------------------------------------------------------------------- #
#