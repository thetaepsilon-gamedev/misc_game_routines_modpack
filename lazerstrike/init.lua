local i = {}
local strike_pos = function(pos, radius)
	tnt.boom(pos, {radius=radius})

	-- lethal core range: outright kills entities.
	-- players are zapped by setting their HP to zero in minetest.after.
	local objects = minetest.get_objects_inside_radius(pos, radius/2)
	local players = {}
	for _, ent in ipairs(objects) do
		if ent:is_player() then
			players[ent] = true
		else
			ent:remove()
		end
	end
	-- uses minetest.after, because :set_hp() can only be called in globalstep...
	minetest.after(0, function()
		for player, _ in pairs(players) do
			player:set_hp(0)
		end
	end)
end
i.strike_pos = strike_pos



-- vaporises a player and empties their inventory.
-- does this by forcing them to run /clearinv.
-- returns true if the player existed, false if not.
local strike_player = function(name, radius)
	local ref = minetest.get_player_by_name(name)
	if not ref then return false end

	minetest.registered_chatcommands["clearinv"].func(name)
	strike_pos(ref:get_pos(), radius)
	return true
end
i.strike_player = strike_player



modtable_register("ds2.minetest.misc_game_routines.lazerstrike", i)
