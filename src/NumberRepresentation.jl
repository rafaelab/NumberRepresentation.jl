module NumberRepresentation

export 
	NumberRepresentationConfig,
	FixedPointNotation,
	ScientificNotation,
	EngineeringNotation,
	NumberRepresentationPlain,
	NumberRepresentationUnicode,
	NumberRepresentationTeX,
	NumberRepresentationMakieRichText,
	getSignificand,
	getExponent,
	decomposeNumberFromString,
	parseNumberFromString,
	getTimesSymbol,
	getNumberType,
	getNotationType


using Printf
using NumericIO
using Requires


include("common.jl")
include("regex.jl")
include("number.jl")
include("parser.jl")
include("config.jl")
include("notation.jl")
include("representation.jl")



end 
