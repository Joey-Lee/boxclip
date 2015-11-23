--[[
 * Copyright (C) 2015 Ricky K. Thomson
 * 
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
 * GNU General Public License for more details.
 * u should have received a copy of the GNU General Public License
 * along with this program. If not, see <http://www.gnu.org/licenses/>.
 --]]
 
 mapio = {}

function mapio:savemap(map)
	local fh = io.open(map, "w+")
	fh:write("mapmusic="..world.mapmusic.."\n")
	fh:write("ambient="..world.mapambient.."\n")
	fh:write("theme="..world.theme.."\n")
	for i, entity in ipairs(platforms) do
		fh:write("platform="..math.round(entity.xorigin)..","..math.round(entity.yorigin)..","..entity.w..","..entity.h..","..entity.clip..","..entity.movex..","..entity.movey..","..entity.movespeed..","..entity.movedist..","..entity.swing..","..math.round(entity.angle,2).."\n")
	end
	
	for i, entity in ipairs(pickups) do
		fh:write("pickup="..math.round(entity.x)..","..math.round(entity.y)..","..entity.name.."\n")
	end
	for i, entity in ipairs(crates) do
		fh:write("crate="..math.round(entity.x)..","..math.round(entity.y)..","..entity.item.."\n")
	end
	for i, entity in ipairs(checkpoints) do
		fh:write("checkpoint="..math.round(entity.x)..","..math.round(entity.y).."\n")
	end
	for i, entity in ipairs(enemies) do
		if entity.name == "walker" then
			fh:write("walker="..math.round(entity.xorigin)..","..math.round(entity.y)..","..entity.movespeed..","..entity.movedist.."\n")
		end
		if entity.name == "floater" then
			fh:write("floater="..math.round(entity.xorigin)..","..math.round(entity.y)..","..entity.movespeed..","..entity.movedist.."\n")
		end
		if entity.name == "spikeball" then
			fh:write("spikeball="..math.round(entity.xorigin)..","..math.round(entity.yorigin).."\n")
		end
		if entity.name == "spike" then
			fh:write("spike="..math.round(entity.x)..","..math.round(entity.y)..","..math.round(entity.dir).."\n")
		end
		if entity.name == "spike_large" then
			fh:write("spike_large="..math.round(entity.x)..","..math.round(entity.y)..","..math.round(entity.dir).."\n")
		end
		
		if entity.name == "icicle" then
			fh:write("icicle="..math.round(entity.x)..","..math.round(entity.y).."\n")
		end
	end
	for i, entity in ipairs(props) do
		fh:write("props="..math.round(entity.x)..","..math.round(entity.y)..","..entity.name.."\n")
	end
	for i, entity in ipairs(springs) do
		fh:write("spring="..math.round(entity.x)..","..math.round(entity.y)..","..entity.dir.. ","..entity.name.."\n")
	end
	for i, entity in ipairs(portals) do
		fh:write("portal="..math.round(entity.x)..","..math.round(entity.y)..","..entity.name.."\n")
	end
	fh:close()
end



function mapio:loadmap(mapname)


	--load the mapfile
	local mapdata = love.filesystem.newFileData(mapname)
	local lines = split(mapdata:getString(), "\n")
	
	--defaults in case not specified in map file
	world.theme = "sunny"
	world.mapmusic = 0
	world.mapambient = 0
	
	for _, line in pairs(lines) do
		-- parse mapmusic
		if string.find(line, "^mapmusic=(.+)") then
			world.mapmusic = tonumber(string.match(line, "^mapmusic=(%d+)"))

		end
		-- parse ambient track
		if string.find(line, "^ambient=(.+)") then
			world.mapambient = tonumber(string.match(line, "^ambient=(%d+)"))
			
		end
		-- parse theme
		if string.find(line, "^theme=(.+)") then
			world.theme = string.match(line, "^theme=(.+)")
			world:settheme(world.theme)
			love.graphics.setBackgroundColor(background_r,background_g,background_b,255)
		
		end
		--parse platforms
		if string.find(line, "^platform=(.+)") then
		
			local x,y,w,h,clip,movex,movey,movespeed,movedist,swing,angle = string.match(
				line, "^platform=(%-?%d+),(%-?%d+),(%-?%d+),(%-?%d+),(%-?%d+),(%-?%d+),(%-?%d+),(%-?%d+),(%-?%d+),(%-?%d+),(%-?%d+)"
			)
			platforms:add(tonumber(x),tonumber(y),tonumber(w),tonumber(h),tonumber(clip),tonumber(movex),tonumber(movey),tonumber(movespeed),tonumber(movedist),tonumber(swing),tonumber(angle))
		end
		-- parse pickups
		if string.find(line, "^pickup=(.+)") then
			local x,y,item = string.match(
				line, "^pickup=(%-?%d+),(%-?%d+),(.+)"
			)
			pickups:add(tonumber(x),tonumber(y),item)
		end
		--parse crates
		if string.find(line, "^crate=(.+)") then
			local x,y,item = string.match(
				line, "^crate=(%-?%d+),(%-?%d+),(.+)"
			)
			crates:add(tonumber(x),tonumber(y),item)
		end
		--parse checkpoints
		if string.find(line, "^checkpoint=(.+)") then
			local x,y = string.match(
				line, "^checkpoint=(%-?%d+),(%-?%d+)"
			)
			checkpoints:add(tonumber(x),tonumber(y))
		end
		--parse enemy(walker)
		if string.find(line, "^walker=(.+)") then
			local x,y,movespeed,movedist = string.match(
				line, "^walker=(%-?%d+),(%-?%d+),(%-?%d+),(%-?%d+)"
			)
			enemies:walker(tonumber(x),tonumber(y),tonumber(movespeed),tonumber(movedist))
			
		end
		
		--parse enemy(icicle)
		if string.find(line, "^icicle=(.+)") then
			local x,y = string.match(
				line, "^icicle=(%-?%d+),(%-?%d+)"
			)
			enemies:icicle(tonumber(x),tonumber(y))
			
		end
		
		--parse enemy(floater)
		if string.find(line, "^floater=(.+)") then
			local x,y,movespeed,movedist = string.match(
				line, "^floater=(%-?%d+),(%-?%d+),(%-?%d+),(%-?%d+)"
			)
			enemies:floater(tonumber(x),tonumber(y),tonumber(movespeed),tonumber(movedist))
			
		end
		--parse enemy(spikeball)
		if string.find(line, "^spikeball=(.+)") then
			local xorigin,yorigin = string.match(
				line, "^spikeball=(%-?%d+),(%-?%d+)"
			)
			enemies:spikeball(tonumber(xorigin),tonumber(yorigin))
			
		end

		--parse enemy(spike)
		if string.find(line, "^spike=(.+)") then
			local x,y,dir = string.match(
				line, "^spike=(%-?%d+),(%-?%d+),(%-?%d+)"
			)
			enemies:spike(tonumber(x),tonumber(y),tonumber(dir))
			
		end

		--parse enemy(spike_large)
		if string.find(line, "^spike_large=(.+)") then
			local x,y,dir = string.match(
				line, "^spike_large=(%-?%d+),(%-?%d+),(%-?%d+)"
			)
			enemies:spike_large(tonumber(x),tonumber(y),tonumber(dir))
			
		end
		
		--parse props
		if string.find(line, "^props=(.+)") then
			local x,y,type = string.match(
				line, "^props=(%-?%d+),(%-?%d+),(.+)"
			)
			props:add(tonumber(x),tonumber(y),type)
			
		end
		--parse springs
		if string.find(line, "^spring=(.+)") then
			local x,y,dir,type = string.match(
				line, "^spring=(%-?%d+),(%-?%d+),(%-?%d+),(.+)"
			)
			springs:add(tonumber(x),tonumber(y),tonumber(dir),type)
			
		end
		
		--parse portals
		if string.find(line, "^portal=(.+)") then
			local x,y,type = string.match(
				line, "^portal=(%-?%d+),(%-?%d+),(.+)"
			)
			portals:add(tonumber(x),tonumber(y),type)
			
		end
		for _, portal in ipairs(portals) do
			--set starting spawn
			if portal.name == "spawn" then
				player.spawnX = portal.x
				player.spawnY = portal.y
			end
		end	
			

	end
   
end
