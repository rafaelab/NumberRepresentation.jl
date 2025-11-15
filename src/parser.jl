function decomposeNumberString(s::AbstractString, times::String)
	if occursin(times, s)
		parts = split(s, times)
		significandStr = replace(parts[1], r"\s+" => "")
		exponentStr = replace(parts[2], r"\s+" => "")

		return String(significandStr), String(exponentStr)
		# significand = parse(Float64, significandStr)
		# exponent = parse(Int, exponentStr)
		# return significand * exp10(exponent)
	else
		return String(s), nothing
	end
end


function parseNumberString(s::AbstractString, times::String, ::Type{T}) where {T <: Real}
	r = decomposeNumberString(s, times)
	if length(r) > 1
		significandStr, exponentStr = r
		significand = parse(Float64, replace(significandStr, r"\s+" => ""))
		if isnothing(exponentStr)
			return T(significand)
		else
			exponent = parse(Int, replace(exponentStr, r"\s+" => ""))
			return T(significand * exp10(exponent))
		end
	end

	return parse(T, replace(s, r"\s+" => ""))
end

parseNumberString(s::AbstractString, times::String) = begin 
	return parseNumberString(s, times, Float64)
end