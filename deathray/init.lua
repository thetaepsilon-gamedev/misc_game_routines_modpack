--[[
A "death ray" -
given a base position, offset and radius forming a cylinder,
any objects or players caught inside the beam will get nuked.

Technically what actually happens is that under the covers
minetest.get_objects_inside_radius() is used,
then is_in_cylinder from vectorextras is used to cut down the set
to just the objects present inside the cylinder;
then, an optional callback is invoked on each objectref in the cylinder.
]]

local m_cyl = mtrequire("ds2.minetest.vectorextras.is_in_cylinder")
local is_in_cylinder = m_cyl.raw_offset

local i = {}
-- initial search function
local cylinder_search = function(bpos, offset, cradius)
	-- do an initial scan for objects with a radius matching the length of the cylinder,
	-- positioned in the middle.
	-- this does overshoot, but this is necessary to include the edges of the cylinder.
	local sradius = vector.length(offset)
	local centre = vector.add(bpos, vector.multiply(offset, 0.5))
	local list = minetest.get_objects_inside_radius(centre, sradius)

	-- note: in-place conversion from list to map!
	for i, object in ipairs(list) do
		local p = object:get_pos()
		-- (ax, ay, az, dx, dy, dz, radius, _px, _py, _pz)
		local result = is_in_cylinder(
			bpos.x, bpos.y, bpos.z,
			offset.x, offset.y, offset.z,
			cradius, p.x, p.y, p.z)

		if result then
			-- save the object from removal
			list[object] = p
		end
		-- remove old array-like index
		list[i] = nil
	end
	return list
end
i.ray_search = cylinder_search



-- interface export
modtable_register("ds2.minetest.misc_game_routines.deathray", i)

