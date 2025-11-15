using Test

push!(LOAD_PATH, joinpath(@__DIR__, "..", "src"))
using NumberRepresentation 

import NumberRepresentation: 
	getNumberType,
	getNotationType,
	getTimesSymbol,
	showSignSignificand!,
	showSignExponent!,
	shortenOneTimes!,
	updateRepresentation!,
	decomposeNumberString,
	parseNumberString,
	getSignificand,
	getExponent





# ---------------------------------------------------------------------------------- #
#
@testset "Testing decomposition" begin

	@testset "getExponent & getSignificand" begin
		x1 = 1.23e4
		exp1 = getExponent(x1)
		sig1 = getSignificand(x1)
		@test exp1 == 4
		@test sig1 == 1.23

		x2 = -0.01234
		exp2 = getExponent(x2)
		sig2 = getSignificand(x2)
		@test exp2 == -2.0
		@test sig2 == -1.234

		x3 = 12345.0
		@test isapprox(getSignificand(x3), 1.23456; atol = 1e-2)
		@test ! isapprox(getSignificand(x3), 1.23456; atol = 1e-12)
	end


	@testset "decomposeNumberString" begin
		@test decomposeNumberString("1.23e4", "e") == ("1.23", "4")
		@test decomposeNumberString("  -1.23 ×   3  ", "×") == ("-1.23", "3")
		@test decomposeNumberString("12345", "e") == ("12345", nothing)
	end

	@testset "parseNumberString" begin
		@test parseNumberString("1.2e3", "e") == 1200.0
		@test isapprox(parseNumberString("-1.5e-2", "e"), -0.015; atol = 1e-12)
		@test parseNumberString("1.2 × 3", "×") == 1200.0

		# when no times symbol is present the result is parsed as the requested type
		@test parseNumberString(" 42 ", "×", Int64) === 42

		# when a times symbol is present the implementation currently returns a Float64
		@test typeof(parseNumberString("1e3", "e", Float64)) == Float64
		@test parseNumberString("3", "e") == 3.
	end

end

# ---------------------------------------------------------------------------------- #
#
@testset "NumberRepresentation basic behavior" begin

	@testset "types and times symbol" begin
		x = NumberRepresentationPlain(12.34, FixedPointNotation)
		@test getNumberType(x) == Float64
		@test getNotationType(x) == FixedPointNotation
		@test getTimesSymbol(x) == "e"

		y = NumberRepresentationUnicode(12.34, ScientificNotation)
		@test getNumberType(y) == Float64
		@test getNotationType(y) == ScientificNotation
		@test getTimesSymbol(y) == "×"
	end

	@testset "showSignSignificand!" begin
		x = NumberRepresentationPlain(12.34, FixedPointNotation)
		showSignSignificand!(x)
		@test startswith(x.representation, "+")

		y = NumberRepresentationPlain(-5.0, FixedPointNotation)
		showSignSignificand!(y)
		@test startswith(y.representation, "-")
	end

	@testset "showSignExponent!" begin
		x1 = NumberRepresentationPlain(1200.0, ScientificNotation; decimals = 2, signExponent = false)
		x2 = NumberRepresentationPlain(1200.0, ScientificNotation; decimals = 2, signExponent = true)
		x3 = NumberRepresentationPlain(0.1200, ScientificNotation; decimals = 2, signExponent = false)
		x4 = NumberRepresentationPlain(0.1200, ScientificNotation; decimals = 2, signExponent = true)
		@test x1.representation == "1.20e+03"
		@test x2.representation == "1.20e+03"
		@test x3.representation == "1.20e-01"
		@test x4.representation == "1.20e-01" 

		y1 = NumberRepresentationUnicode(1200.0, ScientificNotation; decimals = 2, signExponent = false)
		y2 = NumberRepresentationUnicode(1200.0, ScientificNotation; decimals = 2, signExponent = true)
		y3 = NumberRepresentationUnicode(0.1200, ScientificNotation; decimals = 2, signExponent = false)
		y4 = NumberRepresentationUnicode(0.1200, ScientificNotation; decimals = 2, signExponent = true)
		@test y1.representation == "1.20×10³"
		@test y2.representation == "1.20×10⁺³"
		@test y3.representation == "1.20×10⁻¹"
		@test y4.representation == "1.20×10⁻¹" 
	end

	@testset "shortenOneTimes!" begin
		x1 = NumberRepresentationPlain(1000.0, ScientificNotation; decimals = 3)
		shortenOneTimes!(x1)
		@test x1.representation == "1.000e+03"

		y1 = NumberRepresentationUnicode(1000.0; timesSymbol = "×", decimals = 1)
		y2 = NumberRepresentationUnicode(1000.0; timesSymbol = "×", decimals = 1)
		shortenOneTimes!(y1; ε = 1e-5)
		@test y1.representation == "10³"
		@test y2.representation == "1.0×10³"

		z1 = NumberRepresentationUnicode(-0.001; timesSymbol = "×", signExponent = false, signSignificand = true)
		z2 = NumberRepresentationUnicode(-0.001; timesSymbol = "×", signExponent = true, signSignificand = true)
		z3 = NumberRepresentationUnicode(-0.001; timesSymbol = "×", signExponent = true, signSignificand = false)
		shortenOneTimes!(z1)
		shortenOneTimes!(z2)
		shortenOneTimes!(z3)
		@test z1.representation == "-10⁻³"
		@test z2.representation == "-10⁻³"
		@test z3.representation == "10⁻³"

		a1 = NumberRepresentationUnicode(1.00001e3; timesSymbol = "×", decimals = 5)
		a2 = NumberRepresentationUnicode(1.00001e3; timesSymbol = "×", decimals = 5)
		shortenOneTimes!(a1; ε = 1e-2)
		shortenOneTimes!(a2; ε = 1e-10)
		@test a1.representation == "10³"
		@test a2.representation == "1.00001×10³"
	end

end

# ---------------------------------------------------------------------------------- #