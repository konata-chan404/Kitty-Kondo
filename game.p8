pico-8 cartridge // http://www.pico-8.com
version 29
__lua__
--------------------------------------
-- Tab 0
--------------------------------------

-- first thing we do is make the debugging variable and make pico8 64x64
debug = 0
poke(0x5f2c,3)

-- Main pico functions
function _init()
	-- create and load all objects
	create_game_stuff()
	create_player()

	load_level(levels[1])
end

function _update()
	-- update player position
	player:move()
	if btnp(5) then
		load_level(levels[current_level.index+1])
	end
end 

function _draw()
	-- clean screen
	cls()

	-- draw current map (including box objects)
	map(current_level.celx, current_level.cely, current_level.sx, current_level.sy, current_level.celw, current_level.celh)
	camera()

	-- draw main character
	draw_entity_outline(player, 0)

	-- draw debugging value
	print(debug)
end

-->8
--------------------------------------
-- Tab 1
--------------------------------------

-- player stuff!!


-- For creating the player!
function create_player()
	player = {
	movement_speed = 1,	-- how fast the player moves

	xpos = 1, -- postion on the x axis (in grid columns!!)
	ypos = 1, -- postion on the y axis (in grid columns!!)

	sprite = 0, -- sprite of the player (can be changed for animations!)
	
	flip = false, -- which way the player is facing (on the x axis)
	
	-- Player movement
	move = function(self)
		local newx, newy

		if (btnp(0))  -- Move left
		then
			debug = "moving left"
			self.flip = true -- player now facing opposite direction of the it's sprite

			-- calculate new position
			newx = self.xpos - self.movement_speed

			-- if a box exists at the new player position
			if (is_box(newx, self.ypos))
			then
				debug = "box found"
				-- get box object and move it
				boxtomove = get_box(newx, self.ypos)
				boxtomove:push(0, self.movement_speed) 
			end

			-- if the next position in the grid doesnt have anything collidable 
			-- move the player that way
			if not is_collidable(newx, self.ypos)
			then
				self.xpos = newx
			end
		end

		if (btnp(1)) -- move right
		then
			debug = "moving right"
			self.flip = false -- player now facing the direction of it's sprite

			-- calculate new position
			newx = self.xpos + self.movement_speed

			-- if a box exists at the new player position
			if (is_box(newx, self.ypos))
			then
				debug = "box found"
				-- get box object and move it
				boxtomove = get_box(newx, self.ypos)
				boxtomove:push(1, self.movement_speed)
			end

			-- if the next position in the grid doesnt have anything collidable 
			-- move the player that way
			if not is_collidable(newx, self.ypos)
			then
				self.xpos = newx
			end
		end

		if (btnp(2)) -- move down
		then
			debug = "moving down"

			-- calculate new position
			newy = self.ypos - self.movement_speed

			-- if a box exists at the new player position
			if (is_box(self.xpos, newy))
			then
				debug = "box found"
				-- get box object and move it
				boxtomove = get_box(self.xpos, newy)
				boxtomove:push(2, self.movement_speed)
			end

			-- if the next position in the grid doesnt have anything collidable 
			-- move the player that way
			if not is_collidable(self.xpos, newy)
			then
				self.ypos = newy
			end
		end

		if (btnp(3)) -- move up
		then
			debug = "moving up"

			-- calculate new position
			newy = self.ypos + self.movement_speed

			-- if a box exists at the new player position
			if (is_box(self.xpos, newy))
			then
				debug = "box found"
				-- get box object and move it
				boxtomove = get_box(self.xpos, newy)
				boxtomove:push(3, self.movement_speed)
			end


			-- if the next position in the grid doesnt have anything collidable 
			-- move the player that way
			if not is_collidable(self.xpos, newy)
			then
				self.ypos = newy
			end
		end
	end
	}
end

-- for creating a box!!
function create_box(new_xpos, new_ypos)
	local new_box = {
		xpos = new_xpos, -- position on the x axis (passed in the "constructor")
		ypos = new_ypos, -- position on the y axis (passed in the "constructor")
		sprite = 3, -- sprite of the box (will be changed for different types of boxes)

		current_tile = mget(new_xpos+1, new_ypos), -- estimate the tile that the box sits on (very hacky!!)

		-- push function: moves the box in the movedir direction
		-- gets called when player moves into a box

		push = function(self, movedir, movement_speed)
			local newx, newy

			if (movedir == 0)  -- move left
			then
				-- calculate new position
				newx = self.xpos - movement_speed

				-- if the next position in the grid doesnt have anything collidable 
				-- move the box that way
				if not is_collidable(newx, self.ypos)
				then
					self:draw(self.xpos, self.ypos, newx, self.ypos)
					self.xpos = newx
				 end
			end
			
			if (movedir == 1) -- move right
			then
				-- calculate new position
				newx = self.xpos + movement_speed

				-- if the next position in the grid doesnt have anything collidable 
				-- move the box that way
				if not is_collidable(newx, self.ypos)
				then
					self:draw(self.xpos, self.ypos, newx, self.ypos)
					self.xpos = newx
				end
			end

			if (movedir == 2) -- move down
			then
				-- calculate new position
				newy = self.ypos - movement_speed

				-- if the next position in the grid doesnt have anything collidable 
				-- move the box that way
				if not is_collidable(self.xpos, newy)
				then
					self:draw(self.xpos, self.ypos, self.xpos, newy)
					self.ypos = newy
				end
			end

			if (movedir == 3) -- move up
			then
				-- calculate new position
				newy = self.ypos + movement_speed

				-- if the next position in the grid doesnt have anything collidable 
				-- move the box that way
				if not is_collidable(self.xpos, newy)
				then
					self:draw(self.xpos, self.ypos, self.xpos, newy)
					self.ypos = newy
				end
			end
		end,

		-- updates the box position on the map
		draw = function(self, old_xpos, old_ypos, new_xpos, new_ypos)
			mset(old_xpos, old_ypos, self.current_tile)
			self.current_tile = mget(new_xpos, new_ypos)
			mset(new_xpos, new_ypos, self.sprite)
		end
		}
	
	-- adds the new box to the array of boxes
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
	return fget(mget(xpos, ypos), 0)
end

-- returns if box exists at position.
-- not a specific box, but any box
function is_box(xpos, ypos)
	return mget(xpos, ypos) == 3
end

-- loop through the box array, find the exact box in the position
function get_box(xpos, ypos)
	for box in all(boxes)
	do
		if (box.xpos == xpos and box.ypos == ypos)
		then
			return box
		end
	end

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
	
	spr(entity.sprite, entity.xpos*8, entity.ypos*8, w, h, entity.flip, flip_y)
end


-- draw_entity with an outline of the col_outline color
function draw_entity_outline(entity, col_outline, w, h, flip_x, flip_y)
	-- default values
	w = w or 1
	h = h or 1
	flip_x = flip_x or false
	flip_y = flip_y or false

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
			spr(entity.sprite, entity.xpos*8+dx, entity.ypos*8+dy, w, h, entity.flip, flip_y)
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

-- creates game related stuff (box array, level harcoding...)
function create_game_stuff()
	boxes = {}

	-- example_level = {
	-- 	celx_start = 0,
	-- 	cely_start = 0,
	-- 	celx_end = 0,
	-- 	cely_end = 0,
	--	player_spawn = {xpos=1, ypos=1}
	-- }

	levels = {
		-- first level
		{
			celx_start = 0,
			cely_start = 0,
			celx_end = 9,
			cely_end = 9,
			player_spawn = {xpos=6, ypos=5}
		},

		--second level
		{
			celx_start = 15,
			cely_start = 0,
			celx_end = 23,
			cely_end = 8,
			player_spawn = {xpos=2, ypos=2}
		}
	}

	current_level = {
		index = 0
	}
	
	cam = {
		xpos = 0,
		ypos = 0
	}
end

-- loads game objects and level stuff from the coordinates given to the function
function load_level(level)

	current_level = {
		index = current_level.index + 1,
		celx = level.celx_start,
		cely = level.cely_start,
		sx = 0,
		sy = 0,
		celw = level.celx_end - level.celx_start + 1,
		celh = level.cely_end - level.cely_start + 1
	}
	
	boxes = {}

	player.xpos = level.player_spawn.xpos
	player.ypos = level.player_spawn.ypos

	for cely = level.cely_start, level.cely_end do
		for celx = level.celx_start, level.cely_end do
			if is_box(celx, cely) then
				create_box(celx, cely)
			end
		end	
	end
end

__gfx__
00090040000900400000000065566556333333335555555500000000000000000000000000000000000000000000000000000000000000000000000000000000
00089980000899800000000066666666333333335555555500000000000000000000000000000000000000000000000000000000000000000000000000000000
00999990009999900000000044444444333333335555555500000000000000000000000000000000000000000000000000000000000000000000000000000000
00919910009199100000000044444444333333335555555500000000000000000000000000000000000000000000000000000000000000000000000000000000
02429920004299200000000044444444333333335555555500000000000000000000000000000000000000000000000000000000000000000000000000000000
02094400020944000000000044444444333333335555555500000000000000000000000000000000000000000000000000000000000000000000000000000000
00299900002999000000000044444444333333335555555500000000000000000000000000000000000000000000000000000000000000000000000000000000
00090900000909000000000044444444333333335555555500000000000000000000000000000000000000000000000000000000000000000000000000000000
__gff__
0000000100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__map__
0404040404040404040400000000000505050505050505050000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0404040404040404040300000000000505050505050305050000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0404040404040404040400000000000505050505050505050000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0404030404030404040400000000000505050505050505050000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0404040404040404040400000000000505050505050305050000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0404040404040404030400000000000505050404050505050000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0403040404040404040400000000000505050403050505050000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0404040404040404040400000000000503050505050505050000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0404040404030404040400000000000505050505050505050000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0404030404040404040400000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__sfx__
00010000000002f0502c0502b050000002c050000002e050000002f050000002f050000002f050000002c050270501b0501b05000000000001c050000001f0500000020050000002205000000220500000021050
