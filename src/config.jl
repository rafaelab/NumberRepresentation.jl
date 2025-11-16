# ----------------------------------------------------------------------------------------------- #
#
@doc """
	NumberRepresentationConfig{I <: Integer, E <: Real}

Configuration struct for number representations.

# Fields
. `signSignificand` [`Bool`]: whether to print the significand's sign \\
. `signExponent` [`Bool`]: whether to print the exponent's sign \\
. `shortenOneTimes` [`Bool`]: whether to write numbers of the form 1xB^E as B^E \\
. `shortenBaseToZero` [`Bool`]: whether to write numbers like B^0 as 1 \\
. `decimals` [`Integer`]: number of decimals of the significand \\
. `toleranceShort` [`Real`]: tolerance for comparisons when shortening (absolute) \\
"""
struct NumberRepresentationConfig{I <: Integer, E <: Real}
	signSignificand::Bool
	signExponent::Bool
	shortenOneTimes::Bool
	shortenBaseToZero::Bool
	decimals::I
	toleranceShort::E
end

NumberRepresentationConfig(; signSignificand::Bool = false, signExponent::Bool = false, shortenOneTimes::Bool = false, shortenBaseToZero::Bool = false, decimals::Integer = 6, toleranceShort::Real = 1e-8, args...) = begin
	if ! isempty(args)
		unknown = join(keys(args), ", ")
		@warn("Unknown keyword(s) for NumberRepresentationConfig: $(unknown). Ignoring it (them).")
	end

	return NumberRepresentationConfig{typeof(decimals), typeof(toleranceShort)}(signSignificand, signExponent, shortenOneTimes, shortenBaseToZero, decimals, toleranceShort)
end

NumberRepresentationConfig(d::Dict{Symbol, Any}) = begin
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
. `cfg` [`NumberRepresentationConfig`]: the configuration object \\

# Output
. A `Dict{Symbol, Any}` with the configuration parameters.
"""
function toDict(cfg::NumberRepresentationConfig)
	return Dict(
		:signSignificand => cfg.signSignificand,
		:signExponent => cfg.signExponent,
		:shortenOneTimes => cfg.shortenOneTimes,
		:shortenBaseToZero => cfg.shortenBaseToZero,
		:decimals => cfg.decimals,
		:toleranceShort => cfg.toleranceShort
	)
end


# ----------------------------------------------------------------------------------------------- #