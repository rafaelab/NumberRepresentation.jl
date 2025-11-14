module NumberRepresentation

export 
	FixedPointNotation,
	ScientificNotation,
	EngineeringNotation,
	NumberRepresentationPlain,
	NumberRepresentationUnicode,
	NumberRepresentationTeX


using Printf
using NumericIO


include("common.jl")
include("regex.jl")
include("number.jl")
include("parser.jl")
# include("helpers.jl")
include("notation.jl")
include("representation.jl")


end 
