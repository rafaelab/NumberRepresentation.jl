# ----------------------------------------------------------------------------------------------- #
#
@doc """
	NumberRepresentationConfig{I <: Integer, E <: Real}

Configuration struct for number representations.

The same configuration object is shared by plain, Unicode, TeX, and Makie rich-text representations. 
The most important option is `decimals`: it denotes the number of digits after the decimal point in the significand. 
It is not the total number of significant digits. 
For instance, `decimals = 2` gives `1.23×10³` in scientific notation and `12.35×10³` in engineering notation.

# Fields
- `signSignificand` [`Bool`]: whether to print the significand's sign
- `signExponent` [`Bool`]: whether to print the exponent's sign
- `shortenOneTimes` [`Bool`]: whether to write numbers of the form 1xB^E as B^E
- `shortenBaseToZero` [`Bool`]: whether to write numbers like B^0 as 1
- `decimals` [`Integer`]: number of decimals of the significand
- `toleranceShort` [`Real`]: tolerance for comparisons when shortening (absolute)

# Examples
```jldoctest
julia> cfg = NumberRepresentationConfig(; decimals = 2, signExponent = true);

julia> NumberRepresentationUnicode(1200.0, ScientificNotation, cfg).representation
"1.20×10⁺³"

julia> cfg = NumberRepresentationConfig(; decimals = 1, shortenOneTimes = true);

julia> NumberRepresentationTeX(1000.0, ScientificNotation, cfg).representation
"10^{3}"
```
"""
struct NumberRepresentationConfig{I <: Integer, E <: Real}
	signSignificand::Bool
	signExponent::Bool
	shortenOneTimes::Bool
	shortenBaseToZero::Bool
	decimals::I
	toleranceShort::E
end

NumberRepresentationConfig(; signSignificand::Bool = false, signExponent::Bool = false, shortenOneTimes::Bool = false, shortenBaseToZero::Bool = false, decimals::Int = 6, toleranceShort::T = 1e-8, args...) where {T <: Real} = begin
	if ! isempty(args)
		unknown = join(keys(args), ", ")
		@warn("Unknown keyword(s) for NumberRepresentationConfig: $(unknown). Ignoring it (them).")
	end

	return NumberRepresentationConfig{typeof(decimals), typeof(toleranceShort)}(signSignificand, signExponent, shortenOneTimes, shortenBaseToZero, decimals, toleranceShort)
end

NumberRepresentationConfig(d::AbstractDict{Symbol, V}) where {V} = begin
	return NumberRepresentationConfig(; d...)
end

NumberRepresentationConfig(d::NamedTuple) = begin
	return NumberRepresentationConfig(; d...)
end


# ----------------------------------------------------------------------------------------------- #
#
@doc """
	toDict(cfg::NumberRepresentationConfig)

Convert a `NumberRepresentationConfig` object to a dictionary.

# Input
- `cfg` [`NumberRepresentationConfig`]: the configuration object

# Output
- A `Dict{Symbol, Any}` with the configuration parameters.
"""
function toDict(cfg::NumberRepresentationConfig)
	return Dict{Symbol, Any}(
		:signSignificand => cfg.signSignificand,
		:signExponent => cfg.signExponent,
		:shortenOneTimes => cfg.shortenOneTimes,
		:shortenBaseToZero => cfg.shortenBaseToZero,
		:decimals => cfg.decimals,
		:toleranceShort => cfg.toleranceShort
	)
end


# ----------------------------------------------------------------------------------------------- #
