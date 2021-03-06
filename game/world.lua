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
 
world = {}

--add menu option to change this.
--also portal entity should have parameter for "next map" 
--which changes this string before reinitializing the world
--   world.map = "maps/test"

--groundLevel textures
water = love.graphics.newImage("graphics/tiles/water.png")
lava = love.graphics.newImage("graphics/tiles/lava.png")
blood = love.graphics.newImage("graphics/tiles/blood.png")
stream = love.graphics.newImage("graphics/tiles/stream.png")



function world:settheme(theme)
	--theme palettes for different settings
	--specified in map file as "theme=*"
	world.theme = theme or "default"
	
	--overlay test
	overlay = love.graphics.newImage("graphics/backgrounds/fog.png")
	overlay:setWrap("repeat", "repeat")
	overlay_quad = love.graphics.newQuad( 0,0, WIDTH, HEIGHT, overlay:getDimensions() )
	
	-- load the theme file
	if love.filesystem.load( "themes/".. theme ..".lua" )( ) then 
		util:dprint("failed to set theme:  " .. theme)
	else
		util:dprint("set theme: " .. theme)
		
	end
	
	groundLevel_tile:setWrap("repeat", "repeat")
	groundLevel_quad = love.graphics.newQuad( -50,world.groundLevel, 10000, 500, groundLevel_tile:getDimensions() )
	love.graphics.setBackgroundColor(background_r,background_g,background_b,255)
		
	--only set background if it exists
	if type(background) == "userdata" then
		background:setWrap("repeat", "repeat")
		background_quad = love.graphics.newQuad( 0,0, love.graphics.getWidth(),love.graphics.getHeight(), background:getDimensions() )
	end
		
	love.graphics.setBackgroundColor(background_r,background_g,background_b,255)	
end

function world:init(gamemode) 
	mode = gamemode
	--console = false
	editing = false
	paused = false
	
	--move this setting into map files
	--once editor menu can adjust variables
	world.gravity = 400

	world.groundLevel = 200
	world.time = 0

	camera:setScale(camera.defaultscale,camera.defaultscale)

	--initialize entity counts
	world.platforms = 0
	world.crates = 0
	world.enemies = 0
	world.pickups = 0
	world.checkpoints = 0
	world.props = 0
	world.collision = 0
	world.portals = 0
	world.springs = 0
	
	world:empty()
	player:init() 
	mapio:loadmap(world.map)
	
	
	player:respawn()
			
	util:dprint("initialized world")
end


    

function world:draw()
	love.graphics.setColor(255,255,255,255)
		
	-- set camera for world
	camera:set()

	--paralax background
	if not editing then
		if type(background) == "userdata" then
			love.graphics.draw(background, background_quad,camera.x-WIDTH/2*camera.scaleX,camera.y-HEIGHT/2*camera.scaleY)
		end
	end
	
	if type(groundLevel_tile) == "userdata" then
		love.graphics.draw(groundLevel_tile, groundLevel_quad, -1000,world.groundLevel)
	end

	love.graphics.setColor(255,255,255,255)
	
	--groundLevel placeholder
	

	

	platforms:draw()
	props:draw()
	springs:draw()
	checkpoints:draw()
	crates:draw()
	portals:draw()
	pickups:draw()
	enemies:draw()
	
	
	player:draw()	
	--world:drawWeather()
	camera:unset()

	-- overlay tests

	
	---cloud front layer?
	--love.graphics.setColor(255,255,255,155)
	--love.graphics.draw(background, background_quad,0,0)
	
	if mode == "editing" then
		editor:draw()
	end
	
	--draw the hud/scoreboard
	if mode =="game" then
		--love.graphics.setColor(0,0,0,50)
		--love.graphics.rectangle("fill",10,10,170,100)
		
		love.graphics.setFont(fonts.scoreboard)
		love.graphics.setColor(0,0,0,155)
		love.graphics.printf("SCORE", 21,21,300,"left",0,1,1)
		love.graphics.printf("LIVES", 21,41,300,"left",0,1,1)
		love.graphics.printf("TIME", 21,61,300,"left",0,1,1)
		love.graphics.printf("GEMS", 21,81,300,"left",0,1,1)
		love.graphics.printf(player.score, 21,21,150,"right",0,1,1)
		love.graphics.printf(player.lives, 21,41,150,"right",0,1,1)
		love.graphics.printf(world:formatTime(world.time), 21,61,150,"right",0,1,1)
		love.graphics.printf(player.gems, 21,81,150,"right",0,1,1)
		love.graphics.setFont(fonts.default)
		
		love.graphics.setFont(fonts.scoreboard)
		love.graphics.setColor(255,255,255,155)
		love.graphics.printf("SCORE", 20,20,300,"left",0,1,1)
		love.graphics.printf("LIVES", 20,40,300,"left",0,1,1)
		love.graphics.printf("TIME", 20,60,300,"left",0,1,1)
		love.graphics.printf("GEMS", 20,80,300,"left",0,1,1)
		love.graphics.printf(player.score, 20,20,150,"right",0,1,1)
		love.graphics.printf(player.lives, 20,40,150,"right",0,1,1)
		love.graphics.printf(world:formatTime(world.time), 20,60,150,"right",0,1,1)
		love.graphics.printf(player.gems, 20,80,150,"right",0,1,1)
		love.graphics.setFont(fonts.default)
	end
	
	if paused then
		love.graphics.setColor(0,0,0,155)
		love.graphics.rectangle("fill",0,0,WIDTH,HEIGHT)
		love.graphics.setColor(255,255,255,155)
		love.graphics.setFont(fonts.huge)
		love.graphics.printf("PAUSED", WIDTH/2,HEIGHT/3,0,"center",0,1,1)
		love.graphics.setFont(fonts.default)
	end
end


function world:timer(dt)
	--update the world time
	world.time = world.time + 1 *dt	
end


function world:formatTime(n)
	return  
		string.format("%02d",n / 60 % 60) .. ":" .. 
		string.format("%02d",n % 60)
end


function world:drawWeather()
	if editing then return end
	--rain gimick overlay
	--[[
	maxParticle=5000
	local i = 0
	for star = i, maxParticle do
		local x = math.random(-400,4000)
		local y = math.random(-400,4000)
			love.graphics.setColor(255,255,255,15)
			love.graphics.line(x, y, x-5, y+40)
	end
	--]]

	love.graphics.setColor(255,255,255,100)
	overlay_quad:setViewport(camera.x/2,camera.y/2,WIDTH*camera.scaleX,HEIGHT*camera.scaleY )
	love.graphics.draw(overlay, overlay_quad,camera.x-WIDTH/2*camera.scaleX,camera.y-HEIGHT/2*camera.scaleY)
			
			
end

function world:count(table)
	--count tables within a table
	local count = 0
	for n, object in pairs(table) do 
		if type(object) == "table" then
			count = count + 1 
		end
	end
	return count
end

function world:remove(objects)
	-- pass table here
	-- removes all entity types from world
	local n = 0
	for n, object in pairs(objects) do 
		if type(object) == "table" then
			table.remove(objects, n)
		end
	end
end

function world:empty()
	repeat world:remove(enemies) until world:count(enemies) == 0
	repeat world:remove(pickups) until world:count(pickups) == 0
	repeat world:remove(crates) until world:count(crates) == 0
	repeat world:remove(props) until world:count(props) == 0
	repeat world:remove(platforms) until world:count(platforms) == 0
	repeat world:remove(checkpoints) until world:count(checkpoints) == 0
	repeat world:remove(portals) until world:count(portals) == 0
	repeat world:remove(springs) until world:count(springs) == 0
end

function world:totalents()
	--returns total entitys
	return world:count(pickups)+world:count(enemies)+world:count(platforms)+
			world:count(crates)+world:count(checkpoints)+world:count(portals)+world:count(props)+world:count(springs)
end

function world:totalentsdrawn()
	--returns total drawn entities
	return world.pickups+world.enemies+world.platforms+world.crates+
		world.checkpoints+world.portals+world.props+world.springs
end


function world:inview(entity) 
	--check if entity is offset (probably swinging or rotating)
		if entity.swing == 1 then
			if (entity.xorigin-entity.radius < camera.x + (WIDTH/2*camera.scaleX)) 
			and (entity.xorigin+entity.w+entity.radius > camera.x - (WIDTH/2*camera.scaleX))  then
				if (entity.yorigin-entity.radius < camera.y + (HEIGHT/2*camera.scaleX)) 
				and (entity.yorigin+entity.h+entity.radius > camera.y - (HEIGHT/2*camera.scaleX)) then
					world.collision = world.collision +1
				return true
				end
			end
		else
			--decides if the entity is visible in the game viewport
			if (entity.x < camera.x + (WIDTH/2*camera.scaleX)) 
			and (entity.x+entity.w > camera.x - (WIDTH/2*camera.scaleX))  then
				if (entity.y < camera.y + (HEIGHT/2*camera.scaleX)) 
				and (entity.y+entity.h > camera.y - (HEIGHT/2*camera.scaleX)) then
					world.collision = world.collision +1
					return true
				end
			end	
		
		end
	
end


function world:update(dt)
	if paused then return end
	world:timer(dt)
	collision:checkWorld(dt)
	physics:world(dt)
	physics:player(dt)
	physics:pickups(dt)
	physics:enemies(dt)			
	player:setcamera(dt)
	
	
	
	if mode == "game" then
		if player.lives < 0 then
			util:dprint("game over")
			--add game over transition screen
			--should fade in, press button to exit to title
			title:init()
		end
			

		--[[
		if player.gems == 100 then
			player.gems = 0
			player.lives = player.lives +1
			sound:play(sound.lifeup)
		end
		--]]
	end

	
	
	--scroll groundLevel
	if type(groundLevel_tile) == "userdata" then
		groundLevel_scroll = groundLevel_scroll + (groundLevel_scrollspeed * dt)
		if groundLevel_scroll > groundLevel_tile:getHeight()then
			groundLevel_scroll = groundLevel_scroll - groundLevel_tile:getHeight()
		end
		groundLevel_quad:setViewport(0,-groundLevel_scroll,10000,500 )
	else
		groundLevel_scroll = 0
	end

	--scroll background
	if type(background) == "userdata" then
		background_scroll = background_scroll + background_scrollspeed * dt
		if background_scroll > background:getWidth()then
			background_scroll = background_scroll - background:getWidth()
		end
		background_quad:setViewport(camera.x/6-background_scroll,camera.y/6,WIDTH*camera.scaleX,HEIGHT*camera.scaleY )
	else
		background_scroll = 0
	end

	world.collision = 0
    
end
