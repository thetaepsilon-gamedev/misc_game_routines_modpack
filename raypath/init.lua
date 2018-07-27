--[[
raypath:
using vectorextra's dda_raytrace module,
traces along a given path and invokes a callback for each node traversed.
halts if the callback returns false.
]]

local b = "ds2.minetest.vectorextras."
local m_dda = mtrequire(b.."dda_raytrace")
local iterate_ray = m_dda.iterate_ray
local m_add = mtrequire(b.."add")
local vadd = m_add.raw

local m_coords = mtrequire("com.github.thetaepsilon.minetest.libmthelpers.coords")
local center = m_coords.round_to_node_raw



local ydebug = function(...) print("# [raypath]", ...) end
local ndebug = function() end
local debug = ndebug



local tointp = function(b) return b and 1 or 0 end 
local tointn = function(b) return b and -1 or 0 end
local tointz = function(b)
	assert(not b, "a dimension which was zero in the ray vector shouldn't move!")
	return 0
end
local get_signed_toint = function(v)
	return (v < 0) and tointn or
		((v > 0) and tointp or tointz)
end
local g = get_signed_toint
local get_signed_increments = function(sdx, sdy, sdz)
	return g(sdx), g(sdy), g(sdz)
end



local i = {}
local none = {}
local stop = function(reason)
	debug("terminate:", reason)
end
local run = function(_px, _py, _pz, sdx, sdy, sdz, t, opts, callback)
	opts = opts or none
	local limit = opts.maxnodes or math.huge
	assert(type(limit) == "number")

	-- dda_raytrace assumes 1.0 = node boundary,
	-- but in MT this is not the case.
	-- add .5 to re-align grid
	local psx, psy, psz = vadd(_px, _py, _pz, 0.5, 0.5, 0.5)
	-- round the initial position to a whole node,
	-- then invoke the callback on this initial node.
	local pcx, pcy, pcz = center(_px, _py, _pz)
	local cont = callback(pcx, pcy, pcz)
	if not cont then return stop("initial callback fail") end

	-- get increment functions for traversing sides.
	-- if we're e.g. going -X, that increment will be negative
	local tointx, tointy, tointz = get_signed_increments(sdx, sdy, sdz)

	-- for each node boundary we cross, we move the corresponding node counter,
	-- then invoke the callback again.
	local count = 0
	for pbx, pby, pbz, tr, btx, bty, btz in
		iterate_ray(psx, psy, psz, sdx, sdy, sdz, t)
	do
		count = count + 1
		-- if no sides were traversed
		-- (e.g. because end of ray reached), stop
		debug("bool traversed:", btx, bty, btz)
		if not (btx or bty or btz) then
			return stop("no sides traversed")
		end
		local dx = tointx(btx)
		local dy = tointy(bty)
		local dz = tointz(btz)
		pcx, pcy, pcz = vadd(pcx, pcy, pcz, dx, dy, dz)
		if not callback(pcx, pcy, pcz) then
			return stop("callback fail")
		end
		-- stop if we've reached the limit on the number of nodes.
		if count >= limit then return end
	end
	return stop("end of iterator")
end
i.run = run



-- take some values from a player to run with
local run_from_player = function(player, ...)
	assert(player:is_player())
	local p = player:get_pos()
	local l = player:get_look_dir()
	return run(p.x, p.y, p.z, l.x, l.y, l.z, ...)
end
i.run_from_player = run_from_player



modtable_register("ds2.minetest.misc_game_routines.raypath", i)


