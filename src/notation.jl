# ----------------------------------------------------------------------------------------------- #
#
@doc """
	AbstractNumberNotation

An abstract type for number notation types.
"""
abstract type AbstractNumberNotation end


# ----------------------------------------------------------------------------------------------- #
#
@doc """
	ScientificNotation

	A type representing scientific notation.
"""
struct ScientificNotation <: AbstractNumberNotation end


# ----------------------------------------------------------------------------------------------- #
#
@doc """
	EngineeringNotation
	
A type representing engineering notation.
"""
struct EngineeringNotation <: AbstractNumberNotation end


# ----------------------------------------------------------------------------------------------- #
#
@doc """
	FixedPointNotation

A type representing fixed-point notation.
"""
struct FixedPointNotation <: AbstractNumberNotation end


# ----------------------------------------------------------------------------------------------- #
