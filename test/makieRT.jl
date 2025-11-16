@testset "NumberRepresentationMakieRichTextExt" begin

	@testset "constructor" begin
		x = 1234.5678
		config1 = NumberRepresentationConfig(; decimals = 3)
		reprU1 = NumberRepresentationUnicode(x, FixedPointNotation, config1)
		reprR1 = NumberRepresentationMakieRichText(reprU1)
		reprR2 = NumberRepresentationMakieRichText(x, FixedPointNotation, config1)
		@test reprR1.number == x
		@test reprR2.number == x
		@test reprR1.timesSymbol == reprU1.timesSymbol
		@test typeof(reprR1.representation) == typeof(Makie.rich(reprU1.representation))		
	end

	@testset "notations" begin
		reprU = NumberRepresentationUnicode(3.14159, FixedPointNotation; decimals = 2)
		reprR = NumberRepresentationMakieRichText(reprU)
		@test reprR.number == reprU.number
		@test reprR.timesSymbol == reprU.timesSymbol
		@test typeof(reprR.representation) == typeof(Makie.rich(reprU.representation))		


		reprU = NumberRepresentationUnicode(1.2345e4, ScientificNotation; decimals = 4)
		reprR = NumberRepresentationMakieRichText(reprU)
		@test reprR.number == reprU.number
		@test reprR.timesSymbol == reprU.timesSymbol
		@test typeof(reprR.representation) == typeof(Makie.rich(reprU.representation))

	end

end