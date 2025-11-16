@testset "NumberRepresentationMakieRichTextExt" begin

	@testset "basic behaviour" begin
		repr = NumberRepresentationPlain(12.34, FixedPointNotation)
		repr2 = NumberRepresentationUnicode(12.34, ScientificNotation)
		repr3 = NumberRepresentationTeX(12.34, EngineeringNotation)
		@test typeof(repr1.representation) == String
		@test typeof(repr2.representation) == String
		@test typeof(repr3.representation) == String
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