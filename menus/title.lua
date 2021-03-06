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
 
 
 -- https://love2d.org/wiki/love.textinput
 -- https://love2d.org/wiki/love.keyboard.setTextInput
title = {}


function title:getmaps()
	return love.filesystem.getDirectoryItems( "maps/" )
end

function title:mapname(id)
	for i,map in ipairs(title:getmaps()) do
		if i == id then return map end
	end
end




function title:init()


	mode = "title"
	self.bg = love.graphics.newImage("graphics/backgrounds/sky.png")
	self.bg:setWrap("repeat", "repeat")
	self.bgquad = love.graphics.newQuad( 0,0, WIDTH, HEIGHT, self.bg:getDimensions() )
	self.bgscroll = 0
	self.bgscrollspeed = 60
	
	self.frame = love.graphics.newImage("graphics/tiles/checked.png")
	self.frame:setWrap("repeat", "repeat")

	
	sound:playbgm(6)
	self.sel = 1
	self.menu = "main"
	self.keystr = ""
	self.mapsel = 1
	
	cheats = {
		catlife = false,
		jetpack = false,
		magnet = false,
		millionare = false,
	}
	
		
	--use for fade transition
	--self.fade = 255
	transitions:fadein()

	util:dprint("initialized title")
end

function title:mainselect(cmd)

	if cmd == "up" then self.sel = self.sel -1 end
	if cmd == "down" then self.sel = self.sel +1 end
	
 
		if cmd == "left" then self.mapsel = self.mapsel -1 end
		if cmd == "right" then self.mapsel = self.mapsel +1 end
		
		if self.mapsel < 1 then self.mapsel = 1 end
		if self.mapsel > #self:getmaps() then self.mapsel = #self:getmaps() end

	
	if cmd == "go" then
		world.map = self:mapname(self.mapsel)
		if self.sel == 1 then transitions:fadeout("game") end
		if self.sel == 2 then transitions:fadeout("editing") end
		if self.sel == 3 then self.menu = "options" end
		if self.sel == 4 then love.event.quit() end
	end
	
	if self.sel < 1 then self.sel = 1 return end
	if self.sel > 4 then self.sel = 4 return end
	sound:play(sound.blip)
end


function title:keypressed(key)
	if not transitions.active then
		self:checkcheatcodes(key)
	
		if self.menu == "main" then
			if key == "escape" then love.event.quit() end
			if key == "up"     then title:mainselect("up") end
			if key == "down"   then title:mainselect("down") end
			if key == "return"   then title:mainselect("go") end
			if key == "left"   then title:mainselect("left") end
			if key == "right"   then title:mainselect("right") end
		end
	
		if self.menu == "options" then
			if key == "escape" then self.menu = "main" end
		end
	end
end

function title:draw()

	---background
	love.graphics.setBackgroundColor(0,0,0,255)
	love.graphics.setColor(255,255,255,255)		
	self.bgquad:setViewport(-self.bgscroll,0,WIDTH, HEIGHT )
	love.graphics.draw(self.bg, self.bgquad, 0,0)
		
	--frames	
	love.graphics.setColor(210,150,100,255)		
	self.framequad = love.graphics.newQuad( 0,0, WIDTH/2+160,HEIGHT/2+60, self.frame:getDimensions() ) -- update this
	love.graphics.draw(self.frame, self.framequad, WIDTH/4-80, HEIGHT/4-30)
	
	love.graphics.setColor(10,10,10,150)
	love.graphics.rectangle("fill", WIDTH/4-50, HEIGHT/4+50, WIDTH/2+100,HEIGHT/2-50)
	
	
	--title	
	love.graphics.setFont(fonts.huge)
	love.graphics.setColor(255,255,255,155)
	love.graphics.printf("Boxclip " ..version .." (alpha)",WIDTH/4,HEIGHT/4,WIDTH/2,"center")
	
	if self.menu == "main" then
		self:drawmain()
	end
	
	love.graphics.setFont(fonts.default)
end



function title:update(dt)
	self.bgscroll = self.bgscroll + self.bgscrollspeed * dt
	if self.bgscroll > self.bg:getHeight() then
		self.bgscroll = self.bgscroll - self.bg:getWidth()
	end	
	--love.audio.setVolume( volume )
end






function title:checkcheatcodes(key)

	self.keystr = self.keystr .. key
	
	if string.match(self.keystr, "catlife") then
		util:dprint("cheat: catlife enabled")
		cheats.catlife = true
		self.keystr = ""
	end
	if string.match(self.keystr, "jetpack") then
		util:dprint("cheat: jetpack enabled")
		cheats.jetpack = true
		self.keystr = ""
	end
	if string.match(self.keystr, "magnet") then
		util:dprint("cheat: magnet enabled")
		cheats.magnet = true
		self.keystr = ""
	end
	if string.match(self.keystr, "shield") then
		util:dprint("cheat: shield enabled")
		cheats.shield = true
		self.keystr = ""
	end
	
	if string.match(self.keystr, "millionare") then
		util:dprint("cheat: millionare enabled")
		cheats.millionare = true
		self.keystr = ""
	end
end


function title:drawmain()
	--options
	love.graphics.setFont(fonts.menu)


	if self.sel == 0 then
		love.graphics.setColor(0,0,0,155)
		love.graphics.rectangle("fill", WIDTH/4-10,HEIGHT/4+90,WIDTH/2+20,40)
	end
	love.graphics.setColor(255,255,255,255)
	love.graphics.printf("Pres left/right to select map",WIDTH/4,HEIGHT/4+100,WIDTH/3,"left")





	--play 
	if self.sel == 1 then
		love.graphics.setColor(0,0,0,155)
		love.graphics.rectangle("fill", WIDTH/4-10,HEIGHT/4+130,WIDTH/2+20,40)
	end
		
	love.graphics.setColor(100,150,160,255)
	love.graphics.printf("Play",WIDTH/4,HEIGHT/4+140,WIDTH/3,"left")
	love.graphics.setColor(100,140,60,155)
	love.graphics.printf("play " .. self:mapname(self.mapsel),WIDTH/4,HEIGHT/4+140,WIDTH/2,"right")

	--editing 
		
	if self.sel == 2 then
		love.graphics.setColor(0,0,0,155)
		love.graphics.rectangle("fill", WIDTH/4-10,HEIGHT/4+170,WIDTH/2+20,40)
	end
		
	love.graphics.setColor(100,150,160,255)
	love.graphics.printf("Map Editor",WIDTH/4,HEIGHT/4+180,WIDTH/3,"left")
	love.graphics.setColor(100,140,60,155)
	love.graphics.printf("edit " .. self:mapname(self.mapsel),WIDTH/4,HEIGHT/4+180,WIDTH/2,"right")
		
	--options
	if self.sel == 3 then
		love.graphics.setColor(0,0,0,155)
		love.graphics.rectangle("fill", WIDTH/4-10,HEIGHT/4+210,WIDTH/2+20,40)
	end
		
	love.graphics.setColor(100,150,160,255)
	love.graphics.printf("Options",WIDTH/4,HEIGHT/4+220,WIDTH/3,"left")
	love.graphics.setColor(100,140,60,155)
	love.graphics.printf("(unimplemented)",WIDTH/4,HEIGHT/4+220,WIDTH/2,"right")
	
	--quit
	if self.sel == 4 then
		love.graphics.setColor(0,0,0,155)
		love.graphics.rectangle("fill", WIDTH/4-10,HEIGHT/4+250,WIDTH/2+20,40)
	end
	
	love.graphics.setColor(100,150,160,255)
	love.graphics.printf("Quit",WIDTH/4,HEIGHT/4+260,WIDTH/3,"left")
	


end




