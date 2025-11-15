module NumberRepresentation

export 
	FixedPointNotation,
	ScientificNotation,
	EngineeringNotation,
	NumberRepresentationPlain,
	NumberRepresentationUnicode,
	NumberRepresentationTeX,
	getSignificand,
	getExponent,
	decomposeNumberString,
	getTimesSymbol,
	getNumberType,
	getNotationType


using Printf
using NumericIO


include("common.jl")
include("regex.jl")
include("number.jl")
include("parser.jl")
include("notation.jl")
include("representation.jl")


end 
