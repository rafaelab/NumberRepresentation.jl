# ----------------------------------------------------------------------------------------------- #
#
@doc """
	escapeRegexLiteral(str::String)

Escape regex special characters in a string literal.

# Input
. `str` [`String`]: the input string \\

# Output
. A string with regex special characters escaped.
"""
function escapeRegexLiteral(str::String)
	io = IOBuffer()
	for c ∈ str
		if c ∈ regexSpecialChars
			print(io, '\\')
		end
		print(io, c)
	end

	return String(take!(io))
end


# ----------------------------------------------------------------------------------------------- #
#
@doc """
	escapeRegex(s::AbstractString)

	Escape regex special characters in a string.

# Input
. `s` [`AbstractString`]: the input string \\

# Output
. A string with regex special characters escaped.
"""
function escapeRegex(s::AbstractString) 
	return replace(s, r"([\\.^$|?*+(){}\[\]])" => s"\\\1")
end


# ----------------------------------------------------------------------------------------------- #
#