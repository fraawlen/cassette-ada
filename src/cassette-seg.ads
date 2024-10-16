-- Copyright © 2024 Fraawlen <fraawlen@posteo.net>
--
-- This file is part of the Cassette Ada (CADA) bindings library.
--
-- This library is free software; you can redistribute it and/or modify it either under the terms of the GNU
-- Lesser General Public License as published by the Free Software Foundation; either version 2.1 of the
-- License or (at your option) any later version.
--
-- This software is distributed on an "AS IS" basis, WITHOUT WARRANTY OF ANY KIND, either express or implied.
-- See the LGPL for the specific language governing rights and limitations.
--
-- You should have received a copy of the GNU Lesser General Public License along with this program. If not,
-- see <http://www.gnu.org/licenses/>.

--------------------------------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------------------------

with Interfaces; use Interfaces;
with Interfaces.C;
with Interfaces.C.Extensions;
with System;

--------------------------------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------------------------

package Cassette.Seg is

	-------------------------------------------------------------------------------------------------
	-- TYPES ---------------------------------------------------------------------------------------- 
	-------------------------------------------------------------------------------------------------

	-- Representation of a 1-dimension segment defined by a length and an origin. No overflow or
	-- underflow can occur and the following equation is guaranteed to be true:
	-- Min <= Origin + Length <= Max.
	--
	type T is tagged private;

	-------------------------------------------------------------------------------------------------
	-- PRESETS --------------------------------------------------------------------------------------
	-------------------------------------------------------------------------------------------------

	-- Creates a segment with limits set between -(2 ** 63/31/15/7) and (2 ** 63/31/15/7 - 1).
	--
	-- [Return]
	--
	--	Segment.
	--
	function I_64 return T;
	function I_32 return T;
	function I_16 return T;
	function I_8  return T;

	-- Creates a segment with limits set between 0 and (2 ** 63/31/15/7 - 1).
	--
	-- [Return]
	--
	--	Segment.
	--
	function U_64 return T;
	function U_32 return T;
	function U_16 return T;
	function U_8  return T;

	-------------------------------------------------------------------------------------------------
	-- IMPURE METHODS ------------------------------------------------------------------------------- 
	-------------------------------------------------------------------------------------------------

	-- Rechecks and corrects a segment so that its parameters respect this equation :
	-- Min <= Origin + Length <= Max.
	--
	-- [Params]
	--
	-- 	Seg : Segment to interact with
	--
	procedure Bind (
		Seg : in out T);

	-- Adds a value to the segment's length.
	--
	-- [Params]
	--
	-- 	Seg    : Segment to interact with
	--	Length : Distance value
	--  
	procedure Grow (
		Seg    : in out T;
		Length : in Integer_64);

	-- Sets new limits. The order of Lim_1 or Lim_2 does not matter. If necessary, origin and length
	-- values will also be updated to respect the new limits.
	--
	-- [Params]
	--
	-- 	Seg   : Segment to interact with
	-- 	Lim_1 : First bound
	-- 	Lim_2 : Second bound
	--
	procedure Limit (
		Seg   : in out T;
		Lim_1 : Integer_64;
		Lim_2 : Integer_64);

	-- Sets a new origin. If necessary, the length will also be udpated to respect the limits.
	--
	-- [Params]
	--
	-- 	Seg    : Segment to interact with
	-- 	Origin : Position value
	--
	procedure Move (
		Seg    : in out T;
		Origin : in Integer_64);

	-- Add a value to the segment's origin. If necessary, the length will also be udpated to respect
	-- the limits.
	--
	-- [Params]
	--
	-- 	Seg    : Segment to interact with
	-- 	Length : Distance value
	--
	procedure Offset (
		Seg    : in out T;
		Length : in Integer_64);

	-- Offsets the segment by a length value, then decreases its length (stored by the segment) by
	-- 2 * length (the funtion parameter).
	--
	-- [Params]
	--
	-- 	Seg    : Segment to interact with
	-- 	Lenght : Distance value
	--
	procedure Pad (
		Seg    : in out T;
		Length : in Integer_64);

	-- Sets a new length value.
	--
	-- [Params]
	--
	-- 	Seg    : Segment to interact with
	-- 	Length : Distance value
	--
	procedure Resize (
		Seg    : in out T;
		Length : in Integer_64);

	-- Mutilplies the origin and length.
	--
	-- [Params]
	--
	--	Seg   : Segment to interact with
	-- 	Scale : Multiplier value
	--
	procedure Scale (
		Seg   : in out T;
		Scale : in Float);

	-------------------------------------------------------------------------------------------------
	-- PURE METHODS --------------------------------------------------------------------------------- 
	-------------------------------------------------------------------------------------------------

	-- Checks whether a point coordinate is on the segment.
	--
	-- [Params]
	--
	-- 	Seg   : Segment to interact with
	-- 	Point : Position value
	--
	-- [Return]
	--
	--	True if it is, false otherwise.
	--
	function Is_In (
		Seg   : in T;
		Point : in Integer_64)
			return Boolean;

	-- Gets the length.
	--
	-- [Params]
	--
	-- 	Seg : Segment to interact with
	--
	-- [Return]
	--
	--	Segment's Length value.
	--
	function Length (
		Seg : in T)
			return Integer_64;

	-- Gets the max limit.
	--
	-- [Params]
	--
	-- 	Seg : Segment to interact with
	--
	-- [Return]
	--
	--	Segment's Max value.
	--
	function Max (
		Seg : in T)
			return Integer_64;

	-- Gets the min limit.
	--
	-- [Params]
	--
	-- 	Seg : Segment to interact with
	--
	-- [Return]
	--
	--	Segment's Min value.
	--
	function Min (
		Seg : in T)
			return Integer_64;

	-- Gets the origin.
	--
	-- [Params]
	--
	-- 	Seg : Segment to interact with
	--
	-- [Return]
	--
	--	Segment's Origin value.
	--
	function Origin (
		Seg : in T)
			return Integer_64;

	-------------------------------------------------------------------------------------------------
	-- PRIVATE -------------------------------------------------------------------------------------- 
	-------------------------------------------------------------------------------------------------

private

	type C_T is record
		Origin : aliased Integer_64 := 0;
		Length : aliased Integer_64 := 0;
		Min    : aliased Integer_64 := -(2 ** 63);
		Max    : aliased Integer_64 :=   2 ** 63 - 1;
	end record
		with Convention => C_Pass_By_Copy;

	-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - --

	type T is tagged record
		Data : aliased C_T;
	end record;

	-------------------------------------------------------------------------------------------------
	-- IMPORTS -------------------------------------------------------------------------------------- 
	-------------------------------------------------------------------------------------------------

	procedure C_Bind   (Seg : access C_T);
	procedure C_Grow   (Seg : access C_T; Length : Integer_64);
	procedure C_Limit  (Seg : access C_T; Lim_1  : Integer_64; Lim_2 : Integer_64);
	procedure C_Move   (Seg : access C_T; Origin : Integer_64);
	procedure C_Offset (Seg : access C_T; Length : Integer_64);
	procedure C_Pad    (Seg : access C_T; Length : Integer_64);
	procedure C_Resize (Seg : access C_T; Length : Integer_64);
	procedure C_Scale  (Seg : access C_T; Scale  : C.double);

	function  C_Is_In  (Seg : C_T; Point : Integer_64) return C.Extensions.bool;

	pragma Import (C, C_Bind,   "cseg_bind");
	pragma Import (C, C_Grow,   "cseg_grow");
	pragma Import (C, C_Is_In,  "cseg_is_in");
	pragma Import (C, C_Limit,  "cseg_limit");
	pragma Import (C, C_Move,   "cseg_move");
	pragma Import (C, C_Offset, "cseg_offset");
	pragma Import (C, C_Pad,    "cseg_pad");
	pragma Import (C, C_Resize, "cseg_resize");
	pragma Import (C, C_Scale,  "cseg_scale");

end Cassette.Seg;
