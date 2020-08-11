pico-8 cartridge // http://www.pico-8.com
version 29
__lua__
--------------------------------------
-- Tab 0
--------------------------------------


function _init()
	debug = 0
	poke(0x5f2c,3)
	menu_init()
end

-- menu functions
function menu_init() 
	_update = menu_update
	_draw = menu_draw
end

function menu_update()
	if btnp(4) then
		load_game()
	end
end

function menu_draw()
	cls(1)
end

-- main game functions
function load_game()
	game_init()
	_update = game_update
	_draw = game_draw
end

function game_init()
	-- create and load all objects
	create_game_stuff()
	create_player()
	-- camera(player.xpos, player.ypos) - this line is pointless. were updating the camera position every frame anyway so whats the point?


	load_level(levels[1], true)
end

function game_update()
	-- update player position
	player:move()
	if btnp(5) then
		restart_level()
	end
	
	if btnp(4) then
		load_next_level()
	end
end 

function game_draw()
	-- clean screen
	cls()

	-- draw current map (including box objects)
	camera(cam.xpos*8, cam.ypos*8)
	map(current_level.celx, current_level.cely, current_level.sx, current_level.sy, current_level.celw, current_level.celh)

	-- draw main character
	draw_entity_outline(player, 1)


	-- draw debugging values
    camera()
    --print(player.xpos)
    --print(player.ypos)
	--print(#boxes)
	--print(#block_points)
	--print(debug)
	-- print(player.xpos)
	-- print(player.ypos)

	-- print(current_level.celw)
	-- print(current_level.celw/2)
	-- print(current_level.barrier.xpos != nil)
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
				if is_sokoban and current_level.barrier.xpos != nil
				then
					if all_block_points_occupied() then
						open_barrier()
					else
						close_barrier()
					end
				end
			end

			-- if the next position in the grid doesnt have anything collidable 
			-- move the player that way
			if not is_collidable(newx, self.ypos)
			then
				if (is_level_finish(newx, self.ypos))
				then
					load_next_level()
					
				else
					self.xpos = newx
					self:update_camera()
				end
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
				
				if is_sokoban and current_level.barrier.xpos != nil
				then
					if all_block_points_occupied() then
						open_barrier()
					else
						close_barrier()
					end
				end
			
			end

			-- if the next position in the grid doesnt have anything collidable 
			-- move the player that way
			if not is_collidable(newx, self.ypos)
			then
				if (is_level_finish(newx, self.ypos))
				then
					load_next_level()
				else
					self.xpos = newx
					self:update_camera()
				end
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
				
				if is_sokoban and current_level.barrier.xpos != nil
				then
					if all_block_points_occupied() then
						open_barrier()
					else
						close_barrier()
					end
				end
			end

			-- if the next position in the grid doesnt have anything collidable 
			-- move the player that way
			if not is_collidable(self.xpos, newy)
			then
				if (is_level_finish(self.xpos, newy))
				then
					load_next_level()
				else
					self.ypos = newy
					self:update_camera()
				end
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
				
				if is_sokoban and current_level.barrier.xpos != nil
				then
					if all_block_points_occupied() then
						open_barrier()
					else
						close_barrier()
					end
				end

			end

			-- if the next position in the grid doesnt have anything collidable 
			-- move the player that way
			if not is_collidable(self.xpos, newy)
			then
				if (is_level_finish(self.xpos, newy))
				then
					load_next_level()

				else
					self.ypos = newy
					self:update_camera()
				end
			end
		end
	end,

    update_camera = function(self)
        local new_cam_xpos = mid(0, player.xpos - current_level.celx-4, current_level.celw-8)
        local new_cam_ypos = mid(0, player.ypos - current_level.cely-4, current_level.celh-8)
        
        cam.xpos = new_cam_xpos
        cam.ypos = new_cam_ypos
	end
	}
end

-- for creating a box!!
function create_box(new_xpos, new_ypos)
	local new_box = {
		xpos = new_xpos, -- position on the x axis (passed in the "constructor")
		ypos = new_ypos, -- position on the y axis (passed in the "constructor")
		sprite = 3, -- sprite of the box (will be changed for different types of boxes)

		current_tile = current_level.ground_tile, -- estimate the tile that the box sits on (very hacky!!)

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
	boxes[#boxes+1] = new_box
end

function create_block_point(new_xpos, new_ypos)
	local new_block_point = {
		xpos = new_xpos,
		ypos = new_ypos
	}

	block_points[#block_points+1] = new_block_point
end

function open_barrier()
	mset(current_level.barrier.xpos, current_level.barrier.ypos, current_level.ground_tile)
end

function close_barrier()
	mset(current_level.barrier.xpos, current_level.barrier.ypos, current_level.barrier.sprite)
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
	return fget(mget(xpos, ypos), 1)
end

-- --returns if xpos, ypos position is equal to end point set in level struct
-- function is_level_finish(xpos, ypos)
-- 	return xpos == current_level.end_point.xpos and ypos == current_level.end_point.ypos
-- end

--returns if end point flag is set at xpos, ypos position
function is_level_finish(xpos, ypos)
	return fget(mget(xpos, ypos), 2)
end

-- retruns if block point falg is set at xpos, ypos position
-- for sokoban like puzzles
function is_block_point(xpos, ypos)
	return fget(mget(xpos, ypos), 3)
end

function is_barrier(xpos, ypos)
	return fget(mget(xpos, ypos), 4)
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

function all_block_points_occupied()
	for point in all(block_points)
	do
		if not is_box(point.xpos, point.ypos)
		then
			return false
		end
	end
	return true
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
	
	spr(entity.sprite, (entity.xpos-current_level.celx)*8, (entity.ypos-current_level.cely)*8, w, h, entity.flip, flip_y)
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
			spr(entity.sprite, (entity.xpos-current_level.celx)*8+dx, (entity.ypos-current_level.cely)*8+dy, w, h, entity.flip, flip_y)
  		end
  	end
  end
  
  entity.xpos = og_xpos
  entity.ypos = og_ypos
		  
  -- returns all of the colors
  -- might need to change that if we'll do custom palette
  load_palette(current_level.palette)
  
  -- finally draws teh actual thing
 	draw_entity(entity, w, h, flip_x, flip_y)
end

-- creates game related stuff (box array, level harcoding...)
function create_game_stuff()
	boxes = {}
	block_points = {}
	cam = {
		xpos = 0,
		ypos = 0
	}
	is_sokoban = false

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
			celx_start = 8,
			cely_start = 0,
			celx_end = 18,
			cely_end = 9,
			player_spawn = {xpos=17, ypos=6},
			end_point = {xpos=22, ypos = 4},
			ground_tile = 4,
			palette = {128,0,2,8,132,4,137,9,129,131,139,138,133,5,134,7}
		},

		--second level
		{
			celx_start = 0,
			cely_start = 0,
			celx_end = 7,
			cely_end = 7,
			player_spawn = {xpos=4, ypos=1},
			end_point = {xpos=6, ypos = 6},
			ground_tile = 4
		},

		--third level
		{
			celx_start = 20,
			cely_start = 0,
			celx_end = 27,
			cely_end = 7,
			player_spawn = {xpos=25, ypos=3},
			end_point = {xpos=22, ypos = 4},
			ground_tile = 4
		},


		-- fourth level
		{
			celx_start = 0,
			cely_start = 11,
			celx_end = 14,
			cely_end = 21,
			player_spawn = {xpos=2, ypos=13},
			end_point = {xpos=22, ypos = 4},
			ground_tile = 4
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
function load_level(level, next_level)

	local last_palette = current_level.palette

	current_level = {
		index = current_level.index + (next_level and 1 or 0),
		celx = level.celx_start,
		cely = level.cely_start,
		sx = 0,
		sy = 0,
		celw = level.celx_end - level.celx_start + 1,
		celh = level.cely_end - level.cely_start + 1,
		end_point = level.end_point,
		ground_tile = level.ground_tile,
		barrier = {},
		palette = last_palette
	}
	
	boxes = {}
	block_points = {}
	is_sokoban = false

	player.xpos = level.player_spawn.xpos
	player.ypos = level.player_spawn.ypos

	player:update_camera()

	if level.palette ~= nil then
		current_level.palette = level.palette
		load_palette(current_level.palette)
	end

	for cely = level.cely_start, level.cely_end do
		for celx = level.celx_start, level.celx_end do
			if is_box(celx, cely) then
				create_box(celx, cely)
			end

			if is_block_point(celx, cely) then
				is_sokoban = true
				create_block_point(celx, cely)
			end
			
			if is_barrier(celx, cely) then
				current_level.barrier = {
					xpos = celx,
					ypos = cely,
					sprite = mget(celx, cely)
				}
			end
		end
	end
end

function load_next_level()
	local new_level = current_level.index+1
	if not (new_level > #levels) then
		load_level(levels[new_level], true)
	end
end

function restart_level()
	reload(0x2000, 0x2000, 0x1000)
	load_level(levels[current_level.index], false)
end

function load_palette(palette)
	pal()
	for i=1,#palette do
		pal(i-1, palette[i], 1)
	end
end

__gfx__
000000000007006000000000000000001eeeeee11111111111111111cccccccccccccccccccccccc111111111111111111111111111111111111111111111111
00000000007377200000000000000000eeeeeeee1eeeeee1eeeeeeeecccccccccccccccccccccccc1eeeeee116666661eeeeeeee1eeeeeeeeeeeeeeeeeeeeee1
000ff000007777700000000000000000eeeeeeee1eeeeee1eeeeeeeecccccccccccccccccccccccc1eeeeee116000061eeeeeeee1eeeeeeeeeeeeeeeeeeeeee1
00f00f00007977900000000000000000eeeeeeee1eeeeee1eeeeeeeecccccc1eeeeeeeeee1cccccc1eeeeee116000061eeeeeeee1eeeeeeeeeeeeeeeeeeeeee1
00f00f00026277200000000000000000eeeeeeee1eeeeee1eeeeeeeecccccc1cccccccccc1cccccc1eeeeee116666661eeeeeeee1eeeeeeeeeeeeeeeeeeeeee1
000ff000020544000000000000000000eeeeeeee1eeeeee1eeeeeeeecccccc110bbbfbb011cccccc1eeeeee115455451eeeeeeee1eeeeeeeeeeeeeeeeeeeeee1
00000000002777000000000000000000cccccccc1eeeeee1ceeeeeecccccccc10bbfbbb01ccccccc1eeeeee115055051eeeeeeee1eeeeeeeeeeeeeeeeeeeeee1
00000000000706000000000000000000111111111eeeeee11eeeeee1ccccccc10afaafa01ccccccc1eeeeee1166666611eeeeee11eeeeee1111111111eeeeee1
000000000000000000000000000000001eeeeee11eeeeee11eeeeee1ccccccc10aaafaa01ccccccc1eeeeee11eeeeee11eeeeee11eeeeee1cccccccc1eeeeee1
00000000000000000000000000000000eeeeeee11eeeeee11eeeeeeeccccccc1045555401ccccccc1eeeeee1eeeeeeee1eeeeee11eeeeee1cccccccc1eeeeee1
00000000000000000000000000000000eeeeeee11eeeeee11eeeeeeeccccccc1000000001ccccccc1eeeeee1eeeeeeee1eeeeee11eeeeee1cccccccc1eeeeee1
00000000000000000000000000000000eeeeeee11eeeeee11eeeeeeecccccccccccccccccccccccc1eeeeee1eeeeeeee1eeeeee11eeeeee1cccccccc1eeeeee1
00000000000000000000000000000000eeeeeee11eeeeee11eeeeeeecccccccccccccccccccccccc1eeeeee1eeeeeeee1eeeeee11eeeeee1cccccccc1eeeeee1
00000000000000000000000000000000eeeeeee11eeeeee11eeeeeeeeeeeeeeeeeeeeeeeeeeeeeee1eeeeee1eeeeeeee1eeeeee11eeeeee1cccccccc1eeeeee1
00000000000000000000000000000000ccccccc11eeeeee11ccccccccccccccccccccccccccccccc1eeeeee1eeeeeeee1cccccc11cccccc1cccccccc1cccccc1
00000000000000000000000000000000111111111eeeeee1111111111111111111111111111111111eeeeee1111111111101001111010011cccccccc11010011
00000000000000000000000000000000111111111eeeeee111111111cccccccccccccccc1eeeeee11eeeeee11eeeeee1c1c0cc1c01c0cc1cccccccccc1c0cc10
00000000000000000000000000000000eeeeeee11eeeeee11eeeeeeecccccccccccccccc1eeeeeee1eeeeee1eeeeeee1c1c0cc1c01c0cc1cccccccccc1c0cc10
00000000000000000000000000000000eeeeeee11eeeeee11eeeeeeecccccccccccccccc1eeeeeee1eeeeee1eeeeeee1c101001c0101001cccccccccc1010010
00000000000000000000000000000000eeeeeee11eeeeee11eeeeeeeeeeeeeeeeeeeeeee1eeeeeee1eeeeee1eeeeeee1c1cccc1c01cccc1cccccccccc1cccc10
00000000000000000000000000000000eeeeeee11eeeeee11eeeeeeecccccccccccccccc1eeeeeee1eeeeee1eeeeeee1c1cccc1c01cccc1cccccccccc1cccc10
00000000000000000000000000000000eeeeeee11eeeeee11eeeeeee0bbbbbbbfbbbbbb01eeeeeee1eeeeee1eeeeeee1e100101e0100101eeeeeeeeee1001010
00000000000000000000000000000000ceeeeee11cccccc11eeeeeec0bbbbbbfbbbbbbb01eeeeeee1eeeeee1eeeeeee1c1cc0c1c01cc0c1cccccccccc1cc0c10
000000000000000000000000000000001eeeeee1111111111eeeeee10aaaaafaafaaaaa011111111111111111111111111cc0c1101cc0c111111111111cc0c10
0000000000000000000000001eeeeee11111111111111111111111110aaaaaaafaaaaaa01111111111111111111111111100101111001011cddddddd11001011
000000000000000000000000eeeeeeee1eeeeeeeeeeeeeeeeeeeeee104555555555555401eeeeeeeeeeeeeeeeeeeeee11ecccce11ecccce1deeeeeee1ecccce1
000000000000000000000000eeeeeeee1eeeeeeeeeeeeeeeeeeeeee100000000000000001eeeeeeeeeeeeeeeeeeeeee11ecccce11ecccce1deeeeeee1ecccce1
000000000000000000000000eeeeeeee1eeeeeeeeeeeeeeeeeeeeee1cccccccccccccccc1eeeeeeeeeeeeeeeeeeeeee11e0100e11e0100e1deeeeeee1e0100e1
000000000000000000000000eeeeeeee1eeeeeeeeeeeeeeeeeeeeee1cccccccccccccccc1eeeeeeeeeeeeeeeeeeeeee11ec0cce11ec0cce1deeeeeee1ec0cce1
000000000000000000000000eeeeeeee1eeeeeeeeeeeeeeeeeeeeee1eeeeeeeeeeeeeeee1eeeeeeeeeeeeeeeeeeeeee11eeeeee11eeeeee1deeeeeee1eeeeee1
000000000000000000000000ceeeeeec1cccccccccccccccccccccc1cccccccccccccccc1eeeeeeeeeeeeeeeeeeeeee11cccccc11cccccc1deeeeeee1cccccc1
0000000000000000000000001eeeeee111111111111111111111111111111111111111111111111111111111111111111111111111111111deeeeeee11111111
00000022000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
032ab232007600000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
03733b20073706700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
27272a00067907370000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
3373090b000089760000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
003389aa00b090000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000008a0000a80a00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000080000009a000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__gff__
0000000301010101110101000101010100000000010101010101010101010101000000000001010101010101010101010000000101010101000101010101000100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__map__
0505050505050604050505050505050504040505040404040404040405000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0504040404050404050404040404040405040505040505050505040405000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0504030305050805050403040505050405040505040504040705050405000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0504030407040405050304030504040405040505060804040304050405000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0505040507050405050404040504050505040505040505030404050405000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0507040404050405050404040504040406050505040405040704050405000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0504040404040405050404040505050505040505040405050505050405000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0505050505050505050404040505050505040505040405050404040405000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0404040404040404050404040404040404040505050505050505050505000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0404040404040404040505050505050505050500000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000040400000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0505050505050505050505050505050000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0504040404040404040404040404050000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0504040404040404040404040404050000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0504040405050505050505040404050000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0504040405040404040405040404050000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0504040405040506050405040404050000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0504040405040505050405040404050000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0504040405040404040405040404050000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0504040405050504050505040404050000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0504040404040404040404040404050000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0505050505050505050505050505050000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1500000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__sfx__
00010000000002f0502c0502b050000002c050000002e050000002f050000002f050000002f050000002c050270501b0501b05000000000001c050000001f0500000020050000002205000000220500000021050
