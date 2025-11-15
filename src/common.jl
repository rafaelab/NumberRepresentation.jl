# ----------------------------------------------------------------------------------------------- #
#
# The default tolerance for approximations in functions like `shortenOneTimes!`, `shortenBaseToZero!`, etc.
const default_ε = 1e-12

# ----------------------------------------------------------------------------------------------- #
#
# Regex special characters set
const regexSpecialChars = Set{Char}(
	[
		'\\', 
		'^',
		'$',
		'.',
		'|',
		'?',
		'*',
		'+',
		'(',
		')',
		'[',
		']',
		'{',
		'}',
		'-'
	]
)

# ----------------------------------------------------------------------------------------------- #
#
# Superscript symbols dictionary: from normal characters to superscript
const superscriptSymbolsDictTo = Dict{Char, Char}(
	'0' => '⁰',
	'1' => '¹',
	'2' => '²',
	'3' => '³',
	'4' => '⁴',
	'5' => '⁵',
	'6' => '⁶',
	'7' => '⁷',
	'8' => '⁸',
	'9' => '⁹',
	'+' => '⁺',
	'-' => '⁻',
	'.' => '·'
)

# ----------------------------------------------------------------------------------------------- #
#
# Superscript symbols dictionary: from superscript to normal characters
const superscriptSymbolsDictFrom = Dict{Char, Char}(
	'⁰' => '0',
	'¹' => '1',
	'²' => '2',
	'³' => '3',
	'⁴' => '4',
	'⁵' => '5',
	'⁶' => '6',
	'⁷' => '7',
	'⁸' => '8',
	'⁹' => '9',
	'⁺' => '+',
	'⁻' => '-',
	'·' => '.'
)


# ----------------------------------------------------------------------------------------------- #
#