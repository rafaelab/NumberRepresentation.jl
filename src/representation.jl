# ----------------------------------------------------------------------------------------------- #
#
@doc """
	AbstractNumberRepresentation

An abstract type for number representations.

# Type Parameters
. `T` [`<: Real`]: the numeric type of the represented number \\
. `U` [`<: AbstractNumberNotation`]: the notation type used for the representation \\
. `S` : the storage type for the representation (`AbstractString`, etc.) \\
"""
abstract type AbstractNumberRepresentation{T <: Real, U <: AbstractNumberNotation, S} end


# ----------------------------------------------------------------------------------------------- #
#
@doc """
	NumberRepresentationPlain{T, U}

Defines a number representation in plain string format.
This is the direct output of NumericIO formatting.

# Fields
. `number` [`Real`]: the number being represented \\
. `representation` [`String`]: the string representation of the number \\
. `timesSymbol` [`String`]: the multiplication symbol used in the representation \\
"""
mutable struct NumberRepresentationPlain{T, U} <: AbstractNumberRepresentation{T, U, String}
	number::T
	representation::String
end

NumberRepresentationPlain(number::Real, ::Type{FixedPointNotation}; decimals::Integer = 6, signSignificand::Bool = true, signExponent::Bool = false, shortenOneTimes::Bool = false, shortenBaseToZero::Bool = false, ε::Real = default_ε) = begin
	fmt = signSignificand ? "%+.$(decimals)f" : "%.$(decimals)f"
	str = @eval @sprintf($fmt, $number)

	repr = NumberRepresentationPlain{typeof(number), FixedPointNotation}(number, str)
	updateRepresentation!(repr; signSignificand = signSignificand, signExponent = signExponent, shortenOneTimes = shortenOneTimes, shortenBaseToZero = shortenBaseToZero, ε = ε)

	return repr
end	

NumberRepresentationPlain(number::Real, ::Type{ScientificNotation}; decimals::Integer = 3, signSignificand::Bool = false, signExponent::Bool = false, shortenOneTimes::Bool = false, shortenBaseToZero::Bool = false, ε::Real = default_ε) = begin
	fmt = signSignificand ? "%+.$(decimals)e" : "%.$(decimals)e"
	s = @eval @sprintf($fmt, $number)

	repr = NumberRepresentationPlain{typeof(number), ScientificNotation}(number, s)
	updateRepresentation!(repr; signSignificand = signSignificand, signExponent = signExponent, shortenOneTimes = shortenOneTimes, shortenBaseToZero = shortenBaseToZero, ε = ε)

	return repr
end

NumberRepresentationPlain(number::Real, ::Type{EngineeringNotation}; decimals::Integer = 3, signSignificand::Bool = false, signExponent::Bool = false, shortenOneTimes::Bool = false, shortenBaseToZero::Bool = false, ε::Real = default_ε) = begin
	s0 = formatted(number, :ENG)
	parts = split(split(s0, "×")[1], ".")
	if length(parts) == 1
		nDigits = 0
	else
		nDigits = decimals + length(@sprintf("%.0f", number / (exp10(NumericIO.base10exp(number))))) + 1
	end

	s1 = formatted(number, :ENG; ndigits = nDigits)
	sig, exp = decomposeNumberFromString(s1, "×")

	s = "$(sig)e$(exp)"
	repr = NumberRepresentationPlain{typeof(number), EngineeringNotation}(number, s)
	updateRepresentation!(repr; signSignificand = signSignificand, signExponent = signExponent, shortenOneTimes = shortenOneTimes, shortenBaseToZero = shortenBaseToZero, ε = ε)

	return repr
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
	NumberRepresentationUnicode{T, U}

Defines a number representation in unicode string format.

# Fields
. `number` [`Real`]: the number being represented \\
. `representation` [`String`]: the string representation of the number \\
. `timesSymbol` [`String`]: the multiplication symbol used in the representation \\
"""
mutable struct NumberRepresentationUnicode{T, U} <: AbstractNumberRepresentation{T, U, String}
	number::T
	representation::String
	timesSymbol::String
end


NumberRepresentationUnicode(number::Real, ::Type{FixedPointNotation}; decimals::Integer = 6, signSignificand::Bool = true, signExponent::Bool = false, shortenOneTimes::Bool = false, shortenBaseToZero::Bool = false, ε::Real = default_ε, timesSymbol::Union{String, Char} = "×") = begin
	fmt = signSignificand ? "%+.$(decimals)f" : "%.$(decimals)f"
	str = @eval @sprintf($fmt, $number)

	repr = NumberRepresentationUnicode{typeof(number), FixedPointNotation}(number, str, timesSymbol)
	updateRepresentation!(repr; signSignificand = signSignificand, signExponent = signExponent, shortenOneTimes = shortenOneTimes, shortenBaseToZero = shortenBaseToZero, ε = ε)

	return repr
end	

NumberRepresentationUnicode(number::Real, ::Type{ScientificNotation}; decimals::Integer = 3, signSignificand::Bool = false, signExponent::Bool = false, shortenOneTimes::Bool = false, shortenBaseToZero::Bool = false, ε::Real = default_ε, timesSymbol::Union{String, Char} = "×") = begin
	str = formatted(number, :SCI; ndigits = decimals + 1)

	repr = NumberRepresentationUnicode{typeof(number), ScientificNotation}(number, str, timesSymbol)
	updateRepresentation!(repr; signSignificand = signSignificand, signExponent = signExponent, shortenOneTimes = shortenOneTimes, shortenBaseToZero = shortenBaseToZero, ε = ε)

	return repr
end

NumberRepresentationUnicode(number::Real, ::Type{EngineeringNotation}; decimals::Integer = 2, signSignificand::Bool = false, signExponent::Bool = false, shortenOneTimes::Bool = false, shortenBaseToZero::Bool = false, ε::Real = default_ε, timesSymbol::Union{String, Char} = "×") = begin
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

NumberRepresentationUnicode(number::Real; args...) = begin
	return NumberRepresentationUnicode(number, ScientificNotation; args...)
end


# ----------------------------------------------------------------------------------------------- #
#
@doc """
	NumberRepresentationTeX{T, U}

Defines a number representation in TeX string format.

# Fields
. `number` [`Real`]: the number being represented \\
. `representation` [`String`]: the string representation of the number \\
. `timesSymbol` [`String`]: the multiplication symbol used in the representation \\
"""
mutable struct NumberRepresentationTeX{T, U} <: AbstractNumberRepresentation{T, U, String}
	number::T
	representation::String
	timesSymbol::String
end

NumberRepresentationTeX(number::Real, ::Type{U}; timesSymbol::String = "\\times", args...) where {U <: AbstractNumberNotation} = begin
	reprU = NumberRepresentationUnicode(number; args...)
	return NumberRepresentationTeX(reprU; timesSymbol = timesSymbol)
end

NumberRepresentationTeX(number::Real, notation::AbstractNumberNotation; args...) = begin
	return NumberRepresentationTeX(number, typeof(notation); args...)
end

NumberRepresentationTeX(number::Real; args...) = begin
	return NumberRepresentationTeX(number, ScientificNotation; args...)
end

NumberRepresentationTeX(uni::NumberRepresentationUnicode; timesSymbol::String = "\\times") = begin
	s = uni.representation

	io = IOBuffer()
	inExp = false

	for c ∈ s
		if haskey(superscriptSymbolsDictFrom, c)
			mapped = superscriptSymbolsDictFrom[c]
			if ! inExp
				print(io, "^{", mapped)
				inExp = true
			else
				print(io, mapped)
			end
		else
			if inExp
				print(io, "}")
				inExp = false
			end
			if c == '×'
				print(io, " " * timesSymbol * " ")
			else
				print(io, c)
			end
		end
	end

	if inExp
		print(io, "}")
	end

	str = String(take!(io))

	return NumberRepresentationTeX{typeof(uni.number), getNotationType(uni)}(uni.number, str, timesSymbol)
end


# ----------------------------------------------------------------------------------------------- #
#
@doc """
	NumberRepresentationMakieRichText{T, U, S}
	
Defines a number representation in Makie RichText format.
This struct is only activated when Makie.jl is available, through the corresponding extension in `NumberRepresentation.jl/ext/`.

# Fields
. `number` [`Real`]: the number being represented \\
. `representation` [`S`]: the string representation of the number, typically `Makie.RichText`; this is NOT a subtype of `AbstractString` \\
. `timesSymbol` [`String`]: the multiplication symbol used in the representation \\
"""
mutable struct NumberRepresentationMakieRichText{T, U, S} <: AbstractNumberRepresentation{T, U, S}
	number::T
	representation::S
	timesSymbol::String
end


# ----------------------------------------------------------------------------------------------- #
#
@doc """
	getNumberType(repr::AbstractNumberRepresentation)

Get the number type of the number representation.
"""
@inline getNumberType(::AbstractNumberRepresentation{T, U, S}) where {T, U, S} = T


# ----------------------------------------------------------------------------------------------- #
#
@doc """
	getNotationType(repr::AbstractNumberRepresentation)

Get the notation type of the number representation.
"""
@inline getNotationType(::AbstractNumberRepresentation{T, U, S}) where {T, U, S} = U


# ----------------------------------------------------------------------------------------------- #
#
@doc """
	getStringType(repr::AbstractNumberRepresentation)

Get the "string" type of the number representation.
Note that this is not necessarily a subtype of `AbstractString`.
"""
@inline getStringType(::AbstractNumberRepresentation{T, U, S}) where {T, U, S} = S



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
function showSignExponent!(repr::AbstractNumberRepresentation{T, FixedPointNotation, S}) where {T, S}
	return repr
end

function showSignExponent!(repr::NumberRepresentationPlain{T, U}) where {T, U <: Union{ScientificNotation, EngineeringNotation}}
	return repr
end

function showSignExponent!(repr::NumberRepresentationUnicode{T, U}) where {T, U <: Union{ScientificNotation, EngineeringNotation}}
	significand, exponent = decomposeNumberFromString(repr.representation, repr.timesSymbol)
	isnothing(exponent) && return repr

	if occursin("⁺", exponent) || occursin("⁻", exponent)
		return repr
	end
	superscriptSign = log10(abs(repr.number)) ≥ 0 ? '⁺' : '⁻'

	pattern = Regex("(" * escape_string(repr.timesSymbol) * "10)[\\+\\-]?(.*)", "s")
	matched = match(pattern, repr.representation)
	if ! isnothing(matched) 
		prefix = matched.captures[1]
		rest = matched.captures[2]
		repr.representation = replace(repr.representation, pattern => string(prefix, superscriptSign, rest))
	end

	return repr
end



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
function shortenOneTimes!(repr::AbstractNumberRepresentation{T, FixedPointNotation, S}; args...) where {T, S}
	return repr
end

function shortenOneTimes!(repr::NumberRepresentationPlain; args...)
	# @warn("NumberRepresentationPlain does not support shortenOneTimes!")
	return repr
end

function shortenOneTimes!(repr::NumberRepresentationUnicode{T, U}; ε::Real = default_ε) where {T, U <: Union{ScientificNotation, EngineeringNotation}}
	sigStr, expStr = decomposeNumberFromString(repr.representation, repr.timesSymbol)

	if ! isnothing(expStr) && isapprox(abs(getSignificand(repr.number)), 1.; atol = ε)
		repr.representation = expStr
		s = occursin("-", sigStr) ? "-" : (occursin("+", sigStr) ? "+" : "")
		repr.representation = s * repr.representation
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
function shortenBaseToZero!(repr::AbstractNumberRepresentation{T, U, S}; args...) where {T, U <: FixedPointNotation, S}
	# @warn("shortenBaseToZero! is not applicable for FixedPointNotation.")
	return repr
end

function shortenBaseToZero!(repr::AbstractNumberRepresentation{T, U, S}; signSignificand::Bool = false, shortenOneTimes::Bool = false, ε::Real = default_ε) where {T, U <: Union{ScientificNotation, EngineeringNotation}, S}
	if isapprox(getExponent(repr.number), 0; atol = ε)
		if shortenOneTimes && isapprox(getSignificand(repr.number), 1.; atol = ε)
			nDecimals = getNumberOfDecimalsFromString(repr.representation, getTimesSymbol(repr))
			fmt = signSignificand ? "%+.$(nDecimals)f" : "%.$(nDecimals)f"
			repr.representation = @eval @sprintf($fmt, 1.0)
		else
			repr.representation = decomposeNumberFromString(repr.representation, getTimesSymbol(repr))[1]
		end
	end

	return repr
end


# ----------------------------------------------------------------------------------------------- #
#
function updateRepresentation!(repr::AbstractNumberRepresentation; signSignificand::Bool = false, signExponent::Bool = false, shortenOneTimes::Bool = false, shortenBaseToZero::Bool = false, ε::Real = default_ε)
	signSignificand && showSignSignificand!(repr)
	signExponent && showSignExponent!(repr)
	shortenOneTimes && shortenOneTimes!(repr; ε = ε)
	shortenBaseToZero && shortenBaseToZero!(repr; signSignificand = signSignificand, shortenOneTimes = shortenOneTimes, ε = ε)
	return repr
end

# ----------------------------------------------------------------------------------------------- #
#
