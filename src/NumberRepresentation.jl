module NumberRepresentation

export 
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
include("notation.jl")
include("representation.jl")



end 
