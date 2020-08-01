pico-8 cartridge // http://www.pico-8.com
version 29
__lua__
--------------------------------------
-- Tab 0
--------------------------------------

-- Main pico functions

function _init()
	-- make pico 64x64
	poke(0x5f2c,3)
	boxes = {}

	create_player()
	create_box()
end

function _update()
	player:move()
end 

function _draw()
	-- Draw simple background
	cls()
	-- draw player circle for now
	draw_entity_outline(player, 0)

	-- Draw a wall to test collisions
	//draw_entity(box)

	map()
	camera()

	draw_entity_outline(player, 0)
end

-->8
--------------------------------------
-- Tab 1
--------------------------------------

-- player stuff!!


-- For creating the player!
function create_player()
	player = {
	movement_speed = 8,	-- How fast the player moves

	-- NOTE: The way this is written at the moment, this means the position of the player is anchored
	-- to it's top left corner, rat	her than it's center. SO it's center point will need to be calculated separately
	-- If you want it. Honestly keep it top left anchored, i dont wana anymore

	-- we would probably make some sort of a player spawnpoint tile and in the load_level function we would get it's position
	xpos = 0,
	ypos = 0,
	width = 8,		-- Width of player
	height = 8,		-- Height of player
	sprite = 0,
	
	flip = false,
	
	-- Player movement
	move = function(self)
		local newx, newy

		if (btnp(0))  -- Move left
		then
			self.flip = true

			-- Check for collision between the player and the 'box'
			newx = self.xpos - self.movement_speed
			if not is_collidable(newx, self.ypos)
			then
				self.xpos = newx
			end
		end
			-- self.xpos -= self.movement_speed
		
		if (btnp(1)) -- move right
		then
			self.flip = false

			-- Check for collision between the player and the 'box'
			newx = self.xpos + self.movement_speed
			if not is_collidable(newx, self.ypos)
			then
				self.xpos = newx
			end
		end
			-- self.xpos += self.movement_speed
		
		if (btnp(2)) -- move down
		then
			-- Check for collision between the player and the 'box'
			newy = self.ypos - self.movement_speed
			if not is_collidable(self.xpos, newy)
			then
				self.ypos = newy
			end
		end
			-- self.ypos -= self.movement_speed
		
		if (btnp(3)) -- move up
		then
			-- Check for collision between the player and the 'box'
			newy = self.ypos + self.movement_speed
			if not is_collidable(self.xpos, newy)
			then
				self.ypos = newy
			end
		end
	end
			-- self.ypos += self.movement_speed
	}
end

-- Test creation of box, similar to create_player
function create_box()
	local new_box = {
		xpos = 60,
		ypos = 100,
		sprite = 1, 
		}
	add(boxes, new_box)

end


-------------------------------------------------------------
-- Collisions stuff

-- Check for collision between two objects from this site and based off this code too
-- http://gamedev.docrobs.co.uk/first-steps-in-pico-8-hitting-things
-- CHecking for box collisions is based on the bounding box top left corners, soooo...
-- Gosh this was confusig to figure out i spent way too much time on this
-- x1,y1,x2,y2 are the top left cordinates of the bounding boxes you want to calculate collision with
-- in case you were to get confused like i was kek
-- We'll need to figure out how to interface this with all the other things in the game we want to
-- do collision stuff with. Gosh im scared thinking about that
function box_hit(x1,y1,w1,h1,x2,y2,w2,h2)
	hit = false
	
	-- Get the half heights and widths of the bounding boxes
	local xs = w1 * 0.5 + w2 * 0.5
	local ys = h1 * 0.5 + h2 * 0.5

	-- Get their distances
	local xd = abs((x1 + (w1 / 2)) - (x2 + (w2 / 2)))
	local yd = abs((y1 + (h1 / 2)) - (y2 + (h2 / 2)))

	if xd < xs and yd < ys then 
		hit = true 
	end

	return hit
end

-- returns if the sprite in the xpos and ypos has the collide flag
function is_collidable(xpos, ypos)
	return fget(mget(xpos/8, ypos/8), 0)
		or fget(mget((xpos+7)/8, ypos/8), 0)
		or fget(mget(xpos/8, (ypos+7)/8), 0)
		or fget(mget((xpos+7)/8, (ypos+7)/8), 0)
end


-->8
--------------------------------------
-- Tab 2
--------------------------------------


-- utility functions!!

-- draws entity based on its x and y vars
-- takes entity and spr() params
function draw_entity(entity, w, h, flip_x, flip_y)
	-- default values
	w = w or 1
	h = h or 1
	flip_x = flip_x or false
	flip_y = flip_y or false
	
	spr(entity.sprite, entity.xpos, entity.ypos, w, h, entity.flip, flip_y)
end


-- draw_entity with outline
-- its 4am im not going to write comments lol

function draw_entity_outline(entity, col_outline, w, h, flip_x, flip_y)

  -- makes all colors black
  for c=1,15 do
    pal(c,col_outline)
  end
  
  -- draws sprite's shape with col_outline color
  local og_xpos = entity.xpos
  local og_ypos = entity.ypos
  
  for dy=-1,0 do
  	for dx=-1,1 do
  		if abs(dy) - abs(dx) ~= 0 then
					entity.xpos = og_xpos + dx
					entity.ypos = og_ypos + dy
					draw_entity(entity, w, h, flip_x, flip_y)
  		end
  	end
  end
  
  entity.xpos = og_xpos
  entity.ypos = og_ypos
		  
  -- returns all of the colors
  -- might need to change that if we'll do custom palette
  pal()
  
  -- finally draws teh actual thing
 	draw_entity(entity, w, h, flip_x, flip_y)
end


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
00090040000900400000000065566556333333330000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00089980000899800000000066666666333333330000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00999990009999900000000044444444333333330000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00919910009199100000000044444444333333330000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
02429920004299200000000044444444333333330000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
02094400020944000000000044444444333333330000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00299900002999000000000044444444333333330000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00090900000909000000000044444444333333330000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__gff__
0000000100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__map__
0404040404040404000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0403040404040404000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0404040404040404000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0404040404030404000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0404040404040404000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0404040404040404000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0403040404040404000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0404040404040404000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
