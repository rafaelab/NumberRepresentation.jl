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
	config::NumberRepresentationConfig
end

NumberRepresentationPlain(number::Real, ::Type{FixedPointNotation}, config::NumberRepresentationConfig) = begin
	fmt = config.signSignificand ? "%+.$(config.decimals)f" : "%.$(config.decimals)f"
	str = @eval @sprintf($fmt, $number)
	repr = NumberRepresentationPlain{typeof(number), FixedPointNotation}(number, str, config)
	updateRepresentation!(repr)
	return repr
end

NumberRepresentationPlain(number::Real, ::Type{ScientificNotation}, config::NumberRepresentationConfig) = begin
	fmt = config.signSignificand ? "%+.$(config.decimals)e" : "%.$(config.decimals)e"
	s = @eval @sprintf($fmt, $number)

	repr = NumberRepresentationPlain{typeof(number), ScientificNotation}(number, s, config)
	updateRepresentation!(repr)

	return repr
end

NumberRepresentationPlain(number::Real, ::Type{EngineeringNotation}, config::NumberRepresentationConfig) = begin
	s0 = formatted(number, :ENG)
	parts = split(split(s0, "×")[1], ".")
	if length(parts) == 1
		nDigits = 0
	else
		nDigits = config.decimals + length(@sprintf("%.0f", number / (exp10(NumericIO.base10exp(number))))) + 1
	end

	s1 = formatted(number, :ENG; ndigits = nDigits)
	sig, exp = decomposeNumberFromString(s1, "×")

	s = "$(sig)e$(exp)"
	repr = NumberRepresentationPlain{typeof(number), EngineeringNotation}(number, s, config)
	updateRepresentation!(repr)
	return repr
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
	config::NumberRepresentationConfig
	timesSymbol::String
end


NumberRepresentationUnicode(number::Real, ::Type{FixedPointNotation}, config::NumberRepresentationConfig; timesSymbol::Union{String, Char} = "×") = begin
	fmt = config.signSignificand ? "%+.$(config.decimals)f" : "%.$(config.decimals)f"
	str = @eval @sprintf($fmt, $number)
	repr = NumberRepresentationUnicode{typeof(number), FixedPointNotation}(number, str, config, timesSymbol)
	updateRepresentation!(repr)

	return repr
end	

NumberRepresentationUnicode(number::Real, ::Type{ScientificNotation}, config::NumberRepresentationConfig; timesSymbol::Union{String, Char} = "×") = begin
	str = formatted(number, :SCI; ndigits = config.decimals + 1)
	repr = NumberRepresentationUnicode{typeof(number), ScientificNotation}(number, str, config, timesSymbol)
	updateRepresentation!(repr)
	return repr
end

NumberRepresentationUnicode(number::Real, ::Type{EngineeringNotation}, config::NumberRepresentationConfig; timesSymbol::Union{String, Char} = "×") = begin
	str0 = formatted(number, :ENG)
	nIntegers = getNumberOfIntegersFromString(str0, timesSymbol)
	str = formatted(number, :ENG; ndigits = config.decimals + nIntegers + 1)
	repr = NumberRepresentationUnicode{typeof(number), ScientificNotation}(number, str, config, timesSymbol)
	updateRepresentation!(repr)
	return repr
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
	config::NumberRepresentationConfig
	timesSymbol::String
end

NumberRepresentationTeX(number::Real, ::Type{U}, config::NumberRepresentationConfig; timesSymbol::String = "\\times") where {U <: AbstractNumberNotation} = begin
	return NumberRepresentationTeX(NumberRepresentationUnicode(number, U, config); timesSymbol = timesSymbol)
end


NumberRepresentationTeX(reprU::NumberRepresentationUnicode; timesSymbol::String = "\\times") = begin
	number = reprU.number
	config = reprU.config
	s = reprU.representation
	U = getNotationType(reprU)


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

	return NumberRepresentationTeX{typeof(number), U}(number, str, config, timesSymbol)
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
	config::NumberRepresentationConfig
	timesSymbol::String
end


# ----------------------------------------------------------------------------------------------- #
#
# Meta-programming for defining redundant constructors.
#
# for T ∈ (:NumberRepresentationPlain, :NumberRepresentationTeX, :NumberRepresentationUnicode, :NumberRepresentationMakieRichText)
# 	@eval begin 

# 		function $(T)(number::Real, notation::AbstractNumberNotation, config::NumberRepresentationConfig; args...)
# 			opts = haskey(args, :timesSymbol) ? (; (key => value for (key, value) ∈ args if key ≠ :timesSymbol)...) : args
# 			return $(T)(number, typeof(notation), config; opts...)
# 		end

# 		function $(T)(number::Real, ::Type{U}; args...) where {U <: AbstractNumberNotation}
# 			if haskey(args, :timesSymbol)
# 				opts = (; (key => value for (key, value) ∈ args if key ≠ :timesSymbol)...)
# 				config = NumberRepresentationConfig(; opts...)
# 				return $(T)(number, U, config; timesSymbol = args[:timesSymbol])
# 			else
# 				config = NumberRepresentationConfig(; args...)
# 				return $(T)(number, U, config)
# 			end
# 		end

# 		function $(T)(number::Real, notation::AbstractNumberNotation; args...)
# 			return $(T)(number, typeof(notation); args...)
# 		end

# 		function $(T)(number::Real; args...) 
# 			return $(T)(number, ScientificNotation; args...)
# 		end

# 		Base.getproperty(repr::$(T), v::Symbol) = begin 
# 			if v ∈ (:decimals, :signSignificand, :signExponent, :shortenOneTimes, :shortenBaseToZero, :toleranceShort)
# 				return getfield(repr.config, v)
# 			else
# 				return getfield(repr, v)
# 			end
# 		end

# 	end
# end
@doc """
    @buildNumberRepresentationConstructor TypeName

Generate a set of convenience constructors and a `getproperty` fallback for a concrete NumberRepresentation type. 
The methods generated are: \\
- `TypeName(number::Real, notation::AbstractNumberNotation, config::NumberRepresentationConfig; args...)`: \\
	. Normalises keyword args so `:timesSymbol` (if present) is passed as a keyword to the final constructor while other keys are used to build a `NumberRepresentationConfig`. \\
- `TypeName(number::Real, ::Type{U}; args...) where {U <: AbstractNumberNotation}`: \\
	. Accepts a notation type directly; if `:timesSymbol` is present it is forwarded as a keyword and other args are used to construct `NumberRepresentationConfig`. \\
- `TypeName(number::Real, notation::AbstractNumberNotation; args...)`: \\
	. Dispatches to the `::Type{U}` form using `typeof(notation)`. \\
- `TypeName(number::Real; args...)`: \\
	. Shorthand that defaults to `ScientificNotation` when no notation is provided. \\
- `Base.getproperty(repr::TypeName, v::Symbol)`: \\
	. Forwards access to selected config fields `(:decimals, :signSignificand, :signExponent, :shortenOneTimes, :shortenBaseToZero, :toleranceShort)` to `repr.config`, otherwise returns the field from `repr`.

# Notes
- Call the macro with a literal type identifier (e.g. `@buildNumberRepresentationConstructor NumberRepresentationPlain` or `@buildNumberRepresentationConstructor(NumberRepresentationPlain)`). Do not pass a runtime variable. \\
- The macro uses `esc` to splice the provided type into generated code so it produces methods for the named type.
"""
macro buildNumberRepresentationConstructor(T)
	quote
		function $(esc(T))(number::Real, notation::AbstractNumberNotation, config::NumberRepresentationConfig; args...)
			opts = haskey(args, :timesSymbol) ? (; (key => value for (key, value) ∈ args if key ≠ :timesSymbol)...) : args
			return $(esc(T))(number, typeof(notation), config; opts...)
		end

		function $(esc(T))(number::Real, ::Type{U}; args...) where {U <: AbstractNumberNotation}
			if haskey(args, :timesSymbol)
				opts = (; (key => value for (key, value) ∈ args if key ≠ :timesSymbol)...)
				config = NumberRepresentationConfig(; opts...)
				return $(esc(T))(number, U, config; timesSymbol = args[:timesSymbol])
			else
				config = NumberRepresentationConfig(; args...)
				return $(esc(T))(number, U, config)
			end
		end

		function $(esc(T))(number::Real, notation::AbstractNumberNotation; args...)
			return $(esc(T))(number, typeof(notation); args...)
		end

		function $(esc(T))(number::Real; args...)
			return $(esc(T))(number, ScientificNotation; args...)
		end

		Base.getproperty(repr::$(esc(T)), v::Symbol) = begin
			if v ∈ (:decimals, :signSignificand, :signExponent, :shortenOneTimes, :shortenBaseToZero, :toleranceShort)
				return getfield(repr.config, v)
			else
				return getfield(repr, v)
			end
		end

	end

end

# build constructors
@buildNumberRepresentationConstructor(NumberRepresentationPlain)
@buildNumberRepresentationConstructor(NumberRepresentationUnicode)
@buildNumberRepresentationConstructor(NumberRepresentationTeX)

## this constructor, while logical, requires Makie, so it is placed in the extension file
# @buildNumberRepresentationConstructor(NumberRepresentationMakieRichText)



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
The function only shortens if the significand is approximately 1, within a tolerance `toleranceShort`.

# Input
. `repr` [`NumberRepresentationPlain`]: the number representation to modify \
. `toleranceShort` [`Real`]: tolerance for considering the significand approximately 1 \
"""
function shortenOneTimes!(repr::AbstractNumberRepresentation{T, FixedPointNotation, S}) where {T, S}
	return repr
end

function shortenOneTimes!(repr::NumberRepresentationPlain)
	return repr
end

function shortenOneTimes!(repr::NumberRepresentationUnicode{T, U}) where {T, U <: Union{ScientificNotation, EngineeringNotation}}
	sigStr, expStr = decomposeNumberFromString(repr.representation, repr.timesSymbol)

	if ! isnothing(expStr) && isapprox(abs(getSignificand(repr.number)), 1.; atol = repr.toleranceShort)
		repr.representation = expStr
		s = occursin("-", sigStr) ? "-" : (occursin("+", sigStr) ? "+" : "")
		repr.representation = s * repr.representation
	end

	return repr
end


# ----------------------------------------------------------------------------------------------- #
#
@doc """
	shortenBaseToZero!(repr::NumberRepresentationPlain; signSignificand::Bool, shortenOneTimes::Bool, toleranceShort::Real)

Modify the representation to shorten "B^0" to "1".

# Input
. `repr` [`NumberRepresentationPlain`]: the number representation to modify \
. `shortenOneTimes` [`Bool`]: whether to shorten "1×10^n" to "10^n" \
. `signSignificand` [`Bool`]: whether to include an explicit sign for the significand \
. `toleranceShort` [`Real`]: tolerance for considering the exponent approximately zero \
"""
function shortenBaseToZero!(repr::AbstractNumberRepresentation{T, U, S}) where {T, U <: FixedPointNotation, S}
	return repr
end

function shortenBaseToZero!(repr::AbstractNumberRepresentation{T, U, S}) where {T, U <: Union{ScientificNotation, EngineeringNotation}, S}
	if isapprox(getExponent(repr.number), 0; atol = repr.toleranceShort)
		if repr.shortenOneTimes && isapprox(getSignificand(repr.number), 1.; atol = repr.toleranceShort)
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
@doc """
	updateRepresentation!(repr::AbstractNumberRepresentation)

Update the number representation based on the configuration options.

# Input
. `repr` [`AbstractNumberRepresentation`]: the number representation to update \\
"""
function updateRepresentation!(repr::AbstractNumberRepresentation)
	repr.config.signSignificand && showSignSignificand!(repr)
	repr.config.signExponent && showSignExponent!(repr)
	repr.config.shortenOneTimes && shortenOneTimes!(repr)
	repr.config.shortenBaseToZero && shortenBaseToZero!(repr)
	return repr
end

# ----------------------------------------------------------------------------------------------- #
#
