# ---------------------------------------------------------------------------------- #
#
@testset "AbstractNumberRepresentation: general behaviour" begin
	
	@testset "getTimesSymbol" begin
		repr1 = NumberRepresentationPlain(12.34, FixedPointNotation)
		repr2 = NumberRepresentationUnicode(12.34, FixedPointNotation)
		repr3 = NumberRepresentationTeX(12.34, FixedPointNotation)

		@test getTimesSymbol(repr1) == "e"
		@test getTimesSymbol(repr2) == "×"
		@test getTimesSymbol(repr3) == "\\times"
	end

	@testset "getNumberType" begin
		repr1 = NumberRepresentationPlain(12.34, FixedPointNotation)
		repr2 = NumberRepresentationUnicode(12.34, ScientificNotation)
		repr3 = NumberRepresentationTeX(12.34, EngineeringNotation)
		@test getNumberType(repr1) == Float64
		@test getNumberType(repr2) == Float64
		@test getNumberType(repr3) == Float64

		y1 = NumberRepresentationPlain(42, FixedPointNotation)
		y2 = NumberRepresentationUnicode(Int8(2), ScientificNotation)
		y3 = NumberRepresentationTeX(BigFloat(700), EngineeringNotation)
		@test getNumberType(y1) == Int64
		@test getNumberType(y2) == Int8
		@test getNumberType(y3) == BigFloat
	end

	# @testset "getNotationType" begin
	# 	repr1 = NumberRepresentationPlain(12.34, FixedPointNotation)
	# 	repr2 = NumberRepresentationUnicode(12.34, ScientificNotation)
	# 	repr3 = NumberRepresentationPlain(12.34, EngineeringNotation)
	# 	@test getNotationType(repr1) == FixedPointNotation
	# 	@test getNotationType(repr2) == ScientificNotation
	# 	@test getNotationType(repr3) == EngineeringNotation
	# end

end


# ---------------------------------------------------------------------------------- #
#
@testset "NumberRepresentationPlain" begin

	@testset "types and times symbol" begin
		repr = NumberRepresentationPlain(12.34, FixedPointNotation)
		@test getNumberType(repr) == Float64
		@test getNotationType(repr) == FixedPointNotation
		@test getTimesSymbol(repr) == "e"
	end

	@testset "showSignSignificand!" begin
		repr1 = NumberRepresentationPlain(12.34, FixedPointNotation)
		showSignSignificand!(repr1)
		@test startswith(repr1.representation, "+")

		repr2 = NumberRepresentationPlain(-5.0, FixedPointNotation)
		showSignSignificand!(repr2)
		@test startswith(repr2.representation, "-")
	end

	@testset "showSignExponent!" begin
		repr1 = NumberRepresentationPlain(1200.0, ScientificNotation; decimals = 2, signExponent = false)
		repr2 = NumberRepresentationPlain(1200.0, ScientificNotation; decimals = 2, signExponent = true)
		repr3 = NumberRepresentationPlain(0.1200, ScientificNotation; decimals = 2, signExponent = false)
		repr4 = NumberRepresentationPlain(0.1200, ScientificNotation; decimals = 2, signExponent = true)
		@test repr1.representation == "1.20e+03"
		@test repr2.representation == "1.20e+03"
		@test repr3.representation == "1.20e-01"
		@test repr4.representation == "1.20e-01" 
	end

	@testset "shortenOneTimes!" begin
		repr1 = NumberRepresentationPlain(1000.0, ScientificNotation; decimals = 3)
		shortenOneTimes!(repr1)
		@test repr1.representation == "1.000e+03"
	end

	@testset "shortenBaseToZero!" begin
		repr1 = NumberRepresentationPlain(1.0, FixedPointNotation; decimals = 2, signSignificand = false)
		before = repr1.representation
		shortenBaseToZero!(repr1; signSignificand = false, shortenOneTimes = false)
		@test repr1.representation == before
	end

	@testset "shortenBaseToZero! for FixedPoint is no-op" begin
		repr1 = NumberRepresentationPlain(1.0, FixedPointNotation; decimals=2, signSignificand=false)
		before = repr1.representation
		shortenBaseToZero!(repr1; signSignificand = false, shortenOneTimes = false, ε = 1e-12)
		@test repr1.representation == before
	end

end


# ---------------------------------------------------------------------------------- #
#
@testset "NumberRepresentationUnicode" begin
	
	@testset "types and times symbol" begin
		repr = NumberRepresentationUnicode(12.34, ScientificNotation)
		@test getNumberType(repr) == Float64
		@test getNotationType(repr) == ScientificNotation
		@test getTimesSymbol(repr) == "×"
	end

	@testset "showSignSignificand!" begin
		repr1 = NumberRepresentationUnicode(12.34, FixedPointNotation)
		showSignSignificand!(repr1)
		@test startswith(repr1.representation, "+")

		repr2 = NumberRepresentationUnicode(-5.0, FixedPointNotation)
		showSignSignificand!(repr2)
		@test startswith(repr2.representation, "-")
	end

	@testset "showSignExponent!" begin
		repr1 = NumberRepresentationUnicode(1200.0, ScientificNotation; decimals = 2, signExponent = false)
		repr2 = NumberRepresentationUnicode(1200.0, ScientificNotation; decimals = 2, signExponent = true)
		repr3 = NumberRepresentationUnicode(0.1200, ScientificNotation; decimals = 2, signExponent = false)
		repr4 = NumberRepresentationUnicode(0.1200, ScientificNotation; decimals = 2, signExponent = true)

		@test repr1.representation == "1.20×10³"
		@test repr2.representation == "1.20×10⁺³"
		@test repr3.representation == "1.20×10⁻¹"
		@test repr4.representation == "1.20×10⁻¹" 
	end

	@testset "shortenOneTimes!" begin
		repr1 = NumberRepresentationUnicode(1000.0; timesSymbol = "×", decimals = 1)
		repr2 = NumberRepresentationUnicode(1000.0; timesSymbol = "×", decimals = 1)
		shortenOneTimes!(repr1; ε = 1e-5)
		@test repr1.representation == "10³"
		@test repr2.representation == "1.0×10³"

		repr3 = NumberRepresentationUnicode(-0.001; timesSymbol = "×", signExponent = false, signSignificand = true)
		repr4 = NumberRepresentationUnicode(-0.001; timesSymbol = "×", signExponent = true, signSignificand = true)
		repr5 = NumberRepresentationUnicode(-0.001; timesSymbol = "×", signExponent = true, signSignificand = false)
		shortenOneTimes!(repr3)
		shortenOneTimes!(repr4)
		shortenOneTimes!(repr5)
		@test repr3.representation == "-10⁻³"
		@test repr4.representation == "-10⁻³"
		@test repr5.representation == "10⁻³"

		repr6 = NumberRepresentationUnicode(1.00001e3; timesSymbol = "×", decimals = 5)
		repr7 = NumberRepresentationUnicode(1.00001e3; timesSymbol = "×", decimals = 5)
		shortenOneTimes!(repr6; ε = 1e-2)
		shortenOneTimes!(repr7; ε = 1e-10)
		@test repr6.representation == "10³"
		@test repr7.representation == "1.00001×10³"
	end


	@testset "notations" begin
		repr1 = NumberRepresentationUnicode(123456789.0, EngineeringNotation; decimals = 2)
		sig, exp = decomposeNumberFromString(repr1.representation, getTimesSymbol(repr1))
		# e = parse(Int, replace(exp, r"\s+" => ""))# remove whitespace and parse exponent

		expStr = replace(exp, r"\s+" => "")
		expStr = replace(expStr, r"^10" => "")                     # drop "10" prefix
		expStr = replace(expStr, r"[^\d\+\-⁰¹²³⁴⁵⁶⁷⁸⁹⁺⁻]" => "")   # keep only signs and digits (including superscripts)
		s = String([get(superscriptSymbolsDictFrom, c, c) for c ∈ expStr])
		e = parse(Int, s)

		# @test occursin("×10", repr1.representation)
		# @test ! isnothing(exp)
		# @test e % 3 == 0
	end

end


# ---------------------------------------------------------------------------------- #
#
@testset "NumberRepresentationTeX" begin
	
	@testset "types and times symbol" begin
		repr = NumberRepresentationTeX(12.34, ScientificNotation)
		@test getNumberType(repr) == Float64
		@test getNotationType(repr) == ScientificNotation
		@test getTimesSymbol(repr) == "\\times"
	end

	@testset "constructor" begin
		reprU1 = NumberRepresentationUnicode{Float64, ScientificNotation}(1e5, "1×10⁵", "×")
		reprT1 = NumberRepresentationTeX(reprU1)
		@test occursin("\\times", reprT1.representation)
		@test occursin("^{", reprT1.representation) && occursin("}", reprT1.representation)
		@test ! occursin('⁵', reprT1.representation)
		@test occursin("5", reprT1.representation)

		reprU2 = NumberRepresentationUnicode{Float64, ScientificNotation}(-3.2e-4, "-3.2×10⁻⁴", "×")
		reprT2 = NumberRepresentationTeX(reprU2)
		@test startswith(reprT2.representation, "-")
		@test occursin("\\times", reprT2.representation)
		@test occursin("^{", reprT2.representation) && occursin("}", reprT2.representation)
		@test ! occursin('⁴', reprT2.representation)
		@test occursin("-4", reprT2.representation)

		reprU3 = NumberRepresentationUnicode{Float64, ScientificNotation}(5.3e2, "+5.3×10⁺²", "×")
		reprT3 = NumberRepresentationTeX(reprU3)
		@test startswith(reprT3.representation, "+")
		@test occursin("\\times", reprT3.representation)
		@test occursin("^{", reprT3.representation) && occursin("}", reprT3.representation)
		@test ! occursin('²', reprT3.representation)
		@test occursin("+2", reprT3.representation)
	end

	@testset "custom times symbol" begin
		reprU1 = NumberRepresentationUnicode{Float64, ScientificNotation}(1.0, "1×10²", "×")
		reprT1 = NumberRepresentationTeX(reprU1, timesSymbol = "\\cdot")
		@test reprT1.representation == "1 \\cdot 10^{2}"
	end

	@testset "string conversions" begin
		reprU1 = NumberRepresentationUnicode{Float64, ScientificNotation}(1.234e6, "1.234×10⁶", "×")
		reprT1 = NumberRepresentationTeX(reprU1)
		@test occursin("\\times", reprT1.representation)
		@test occursin("^{", reprT1.representation) && occursin("}", reprT1.representation)

		sig, exp = decomposeNumberFromString(reprT1.representation, getTimesSymbol(reprT1))
		digits = replace(sig, r"[^\d\+\-]" => "")
		@test ! isnothing(exp)
		@test parse(Int, digits) % 3 - 1 == 0
	end

end

# ---------------------------------------------------------------------------------- #



