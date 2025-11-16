@testset "NumberRepresentationMakieRichTextExt" begin

	@testset "constructor" begin
		
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