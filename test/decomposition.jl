
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

	@testset "decomposeNumberFromString" begin
		@test decomposeNumberFromString("1.23e4", "e") == ("1.23", "4")
		@test decomposeNumberFromString("  -1.23 ×   3  ", "×") == ("-1.23", "3")
		@test decomposeNumberFromString("12345", "e") == ("12345", nothing)
	end

	@testset "parseNumberFromString" begin
		@test parseNumberFromString("1.2e3", "e")[1] == 1200.0
		@test isapprox(parseNumberFromString("-1.5e-2", "e"), -0.015; atol = 1e-12)
		@test parseNumberFromString("1.2 × 3", "×") == 1200.0

		# when no times symbol is present the result is parsed as the requested type
		@test parseNumberFromString(" 42 ", "×", Int64) === 42

		# when a times symbol is present the implementation currently returns a Float64
		@test typeof(parseNumberFromString("1e3", "e", Float64)) == Float64
		@test parseNumberFromString("3", "e") == 3.
	end

end