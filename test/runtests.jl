using Test

using NumberRepresentation 

import NumberRepresentation: 
	showSignSignificand!,
	showSignExponent!,
	shortenOneTimes!,
	shortenBaseToZero!,
	updateRepresentation!,
	superscriptSymbolsDictFrom,
	superscriptSymbolsDictTo



# ---------------------------------------------------------------------------------- #
#

include("decomposition.jl")
include("representation.jl")

# test extension NumberRepresentationMakieRichTextExt.jl
if ! isnothing(Base.find_package("Makie"))
	using Makie
	include("makieRT.jl")
else
	@warn "Makie.jl not installed, skipping Makie extension tests."
end



# ---------------------------------------------------------------------------------- #