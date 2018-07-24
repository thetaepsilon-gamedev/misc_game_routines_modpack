local m_deathray = modtable("ds2.minetest.misc_game_routines.deathray")
local fire = m_deathray.fire

local vec3 = vector.new

local limit = -128
local get_firing_offset = function(bpos)
	-- walk downwards until we either hit a non-air node or a sanity limit.
	local offset = 0
	local y = bpos.y
	local nextpos = vec3(bpos.x, y - 1, bpos.z)
	while (offset > limit) do
		--print(offset, dump(nextpos))
		local n = minetest.get_node(nextpos).name
		--print(n)
		if n ~= "air" then
			--print("not air")
			break
		end
		offset = offset - 1
		nextpos.y = (y-1) + offset
	end
	-- step to the edge of the block
	offset = offset - 0.5
	return vec3(0, offset, 0)
end

local fire_from_pos = function(pos)
	print("BANG")
	print(dump(pos))
	local offset = get_firing_offset(pos)
	print(dump(offset))
	fire(pos, offset, 0.5)
end

local n = minetest.get_current_modname()
minetest.register_node(n..":fire", {
	description = "Fire death ray (stand beneath and right click to test)",
	on_rightclick = fire_from_pos,
	tiles = {"deathrayblock_fire.png"},
})

