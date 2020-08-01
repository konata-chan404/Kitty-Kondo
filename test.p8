pico-8 cartridge // http://www.pico-8.com
version 29
__lua__
function _init()
	create_player()
	create_Enemy()
end

function _update()
	player:move()
end 

function _draw()
	-- Draw simple background
	rectfill(0,0,127,127,5)
	-- draw player circle for now
	circfill(player.xpos, player.ypos,7,8);

	-- Draw simple wall off to the side
	rectfill((enemy.xpos - (enemy.w/2)), (enemy.ypos - (enemy.h/2)), (enemy.xpos + (enemy.w/2)), (enemy.ypos + (enemy.h/2)), 1)
end

-->8
-- player stuff!!
function create_player()
	player = {
	movement_speed = 2,
	xpos = 32,
	ypos = 32,
	w = 8,
	h = 8,
	
	-- Player movement
	move = function(self)
		-- At the moment we'll use a simple circle for the player
		if (btn(0)) 
		then
			-- Checking for collision
			-- for newx = xpos, x - movement_speed, -1 do
			-- 	if not box_hit(newx, y, w, h, enemy.xpos, enemy.ypos, enemy.w, enemy.y)
			-- end
			self.xpos -= self.movement_speed
		end
		
		if (btn(1)) 
		then
			self.xpos += self.movement_speed
		end
		
		if (btn(2)) 
		then
			self.ypos -= self.movement_speed
		end
		
		if (btn(3)) 
		then
			self.ypos += self.movement_speed
		end
	end
	}
end

function create_Enemy()
	enemy = {
		xpos = 60,
		ypos = 60,
		w = 30,
		h = 15
	}

end

-- Passes in the bounding boxes values
function box_hit(x1, y1, w1, h1, x2, y2, w2, h2)
	local hit = false

	-- Find xs
	-- Getting the half distances for both boxes
	local xs = w1 * 0.5 + w2 * 0.5	
	local ys = y1 * 0.5 + y2 * 0.5

	-- Find xd 
	-- Distance of the midpoint+width to get distance of both boxes
	local xd = abs((x1 + (w1 / 2)) - (x2 + (w2 / 2)))
	local yd = abs((y1 + (w1 / 2)) - (y2 + (w2 / 2)))

	-- If both bounding boxes have touched based on the values given, then set hit to true
	if xd < xs and ys < ys then
		hit = true
	end
end
		
-->8
-- utility functions!!

function load_level(cely_start, cely_end)
	for cely = cely_start, cely_end 
	do
		celx = 0 // or plaer.x // 8 or something idk
		repeat
			// blah blah 
			
			// initializing objects 
			// getting player spawnpoint
			// getting block points thing
			// and probably other stuff
			
			// blah blah
			
			celx += 1
		until ( is_level_border(celx, cely) ) 
	end

end
__gfx__
000002020000b000ccccc77700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000222000b0000c777cccc00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000a2a008b80007777777c00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0020022208888800cccccccc00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
022002200888880077cccccc00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0200222008888800ccc777cc00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0222222000888000cc77777c00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0022222000000000cccccccc00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
