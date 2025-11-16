module NumberRepresentationMakieRichTextExt

using NumberRepresentation
using Makie


import NumberRepresentation: 
	AbstractNumberRepresentation,
	AbstractNumberNotation,
	NumberRepresentationMakieRichText,
	superscriptSymbolsDictFrom



# ----------------------------------------------------------------------------------------------- #
#
NumberRepresentationMakieRichText(representation::NumberRepresentationUnicode{T, U}) where {T, U <:  FixedPointNotation} = begin
	str = rich(representation.representation)
	return NumberRepresentationMakieRichText{T, U, typeof(str)}(representation.number, str, representation.timesSymbol)
end


NumberRepresentationMakieRichText(representation::NumberRepresentationUnicode{T, U}) where {T, U <: Union{ScientificNotation, EngineeringNotation}} = begin
	sig, exp = decomposeNumberFromString(representation.representation, representation.timesSymbol)
	exp = replace(exp, "10" => "")
	exp = join(get(superscriptSymbolsDictFrom, c, string(c)) for c ∈ exp) 
	str = rich(sig, representation.timesSymbol, "10", superscript(exp))
	return NumberRepresentationMakieRichText{T, U, typeof(str)}(representation.number, str, representation.timesSymbol)
end

NumberRepresentationMakieRichText(number::Real; args...) = begin
	repr = NumberRepresentationUnicode(number; args...)
	return NumberRepresentationMakieRichText(repr)
end

NumberRepresentationMakieRichText(number::Real, ::Type{U}; args...) where {U <: AbstractNumberNotation} = begin
	return NumberRepresentationMakieRichText(NumberRepresentationUnicode(number, U; args...))
end

NumberRepresentationMakieRichText(number::Real, notation::AbstractNumberNotation; args...) = begin
	return NumberRepresentationMakieRichText(number, typeof(notation); args...)
end

# ----------------------------------------------------------------------------------------------- #
#





end # module

