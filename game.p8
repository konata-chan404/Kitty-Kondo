pico-8 cartridge // http://www.pico-8.com
version 29
__lua__
--------------------------------------
-- Tab 0
--------------------------------------


function _init()
	cartdata("konata_kitty-kondo_1")
	debug = 0


	poke(0x5f2c,3)
	poke(0x5f2e,1)
	
	menu_init()
end

-- menu functions
function menu_init() 
	t = 0
	t_flash = 10
	flash_time = 5
	_update = menu_update
	_draw = menu_draw

	load_palette({128,0,2,136,132,4,137,9,129,131,139,138,133,5,134,7})
	music(0)
end

function menu_update()
	if btnp(4) then
		help_menu_init()
	end
end

function menu_draw()
	cls(0)
	sspr(72, 56, 55, 50, 4, 0)
	if t < t_flash
	then
		print("press z", 32-14 , 50, 6)
	else 
		if t == flash_time + t_flash
		then t = 0 end
	end

	t += 1
end

-- save menu functions
function save_menu_init() 
	_update = save_menu_update
	_draw = save_menu_draw
end

function save_menu_update()
	if btnp(4) then
		load_game()
	end

	if btnp(5) then
		poke(0x5e00, 1)
		load_game()
	end
end

function save_menu_draw()
	cls(0)
	print("z - load", 32-16, 20, 6)
	print("x - new",32-14, 40, 6)
end



-- help menu functions
function help_menu_init() 
	_update = help_menu_update
	_draw = help_menu_draw
end

function help_menu_update()
	if btnp(4) then
		save_menu_init()
	end
end

function help_menu_draw()
	cls(0)
	print("controls", 32-16, 5, 6)
	print("z to undo", 32-18, 25, 6)
	print("x to restart",32-24, 45, 6)
end


-- end screen functions
function end_screen_init() 
	_update = end_screen_update
	_draw = end_screen_draw

	t = 0
	t_flash = 7
	flash_time = 550

	music(1)
end

function end_screen_update()
	if t < flash_time then
		t += 1
	end
end

function end_screen_draw()
	cls(0)
	print("the end", 32-14, 32-t/t_flash, 6)
	print("thank you", 32-18, 45-t/t_flash, 6)
	print("for playing!", 32-22, 55-t/t_flash, 6)

	print("credits", 32-14, 80-t/t_flash, 6)

	print("konata - </>", 32-24, 95-t/t_flash, 6)
	print("sindiewen - </>", 32-30, 105-t/t_flash, 6)
	print("sein ruhe - 🐱", 32-28, 115-t/t_flash, 6)
	print("gajrio - ♪", 32-24, 125-t/t_flash, 6)
end


-- main game functions
function load_game()
	_update = game_update
	_draw = game_draw
	game_init()
end

function game_init()
	-- create and load all objects
	create_game_stuff()
	create_player()
	-- camera(player.xpos, player.ypos) - this line is pointless. were updating the camera position every frame anyway so whats the point?

	current_level.index = @0x5e00-1
	if current_level.index < 0
	then
		current_level.index = 0
	end
	load_next_level()
end

function game_update()
	-- update player position
	player:move(nil)
	
	if btnp(5) then
		restart_level()
	end

	if btnp(4) then
		rewind()
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
	-- print(player.flip)
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

	sprite = 1, -- sprite of the player (can be changed for animations!)
	
	flip = false, -- which way the player is facing (on the x axis)
	
	-- Player movement
	move = function(self, direction)
		local newx, newy

		if (btnp(0) or direction == 0)  -- Move left
		then
			debug =  direction
			self.flip = true and direction==nil -- player now facing opposite direction of the it's sprite
			if direction == nil then
			moves[#moves + 1] = {direction=0} end

			-- calculate new position
			newx = self.xpos - self.movement_speed

			-- if a box exists at the new player position
			if (is_box(newx, self.ypos))
			then
				debug = "box found"
				-- get box object and move it
				boxtomove = get_box(newx, self.ypos)
				boxtomove:push(0, self.movement_speed)

				if direction == nil then
				moves[#moves].box = boxtomove end

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
			else
				if direction == nil then
					moves[#moves] = nil end
			end

		end

		if (btnp(1) or direction == 1) -- move right
		then
			debug = direction
			self.flip = true and direction~=nil -- player now facing the direction of it's sprite
			if direction == nil then
			moves[#moves + 1] = {direction=1} end

			-- calculate new position
			newx = self.xpos + self.movement_speed

			-- if a box exists at the new player position
			if (is_box(newx, self.ypos))
			then
				debug = "box found"
				-- get box object and move it
				boxtomove = get_box(newx, self.ypos)
				boxtomove:push(1, self.movement_speed)

				if direction == nil then
				moves[#moves].box = boxtomove end
				
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
			else
				if direction == nil then
					moves[#moves] = nil end
			end
		end

		if (btnp(2) or direction == 2) -- move down
		then
			debug = "moving down"
			if direction == null then
			moves[#moves + 1] = {direction=2} end

			-- calculate new position
			newy = self.ypos - self.movement_speed

			-- if a box exists at the new player position
			if (is_box(self.xpos, newy))
			then
				debug = "box found"
				-- get box object and move it
				boxtomove = get_box(self.xpos, newy)
				boxtomove:push(2, self.movement_speed)
				
				if direction == nil then
				moves[#moves].box = boxtomove end
				
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
			else
				if direction == nil then
					moves[#moves] = nil end
			end
		end

		if (btnp(3) or direction == 3) -- move up
		then
			debug = "moving up"
			if direction == nil then
			moves[#moves + 1] = {direction=3} end

			-- calculate new position
			newy = self.ypos + self.movement_speed

			-- if a box exists at the new player position
			if (is_box(self.xpos, newy))
			then
				debug = "box found"
				-- get box object and move it
				boxtomove = get_box(self.xpos, newy)
				boxtomove:push(3, self.movement_speed)

				if direction == nil then
				moves[#moves].box = boxtomove end
				
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
			else
				if direction == nil then
					moves[#moves] = nil end
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
		sprite = 17, -- sprite of the box (will be changed for different types of boxes)

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
	if not (current_level.barrier.open) then
		mset(current_level.barrier.xpos, current_level.barrier.ypos, current_level.ground_tile)
		current_level.barrier.open = true
	end
end

function close_barrier()
	if (current_level.barrier.open) then
		mset(current_level.barrier.xpos, current_level.barrier.ypos, current_level.barrier.sprite)
		current_level.barrier.open = false
	end
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
			celx_start = 1,
			cely_start = 0,
			celx_end = 8,
			cely_end = 7,
			player_spawn = {xpos=1, ypos=4},
			end_point = {xpos=6, ypos = 6},
			ground_tile = 62,
			palette = {128,0,2,136,132,4,137,9,129,131,139,138,133,5,134,7},
			music = 12
		},

		--second level
		{
			celx_start = 10,
			cely_start = 0,
			celx_end = 14,
			cely_end = 12,
			player_spawn = {xpos=10, ypos=4},
			end_point = {xpos=6, ypos = 6},
			ground_tile = 62,
			music = 12
		},

		--third level
		{
			celx_start = 0,
			cely_start = 8,
			celx_end = 7,
			cely_end = 17,
			player_spawn = {xpos=7, ypos=13},
			end_point = {xpos=22, ypos = 4},
			ground_tile = 62,
			music = 12
		},


		-- fourth level
		{
			celx_start = 0,
			cely_start = 20,
			celx_end = 10,
			cely_end = 27,
			player_spawn = {xpos=1, ypos=20},
			end_point = {xpos=11, ypos = 241},
			ground_tile = 62,
			music = 12
		},
		
		
		-- fifth level
		{
			celx_start = 13,
			cely_start = 21,
			celx_end = 21,
			cely_end = 32,
			player_spawn = {xpos=13, ypos=25},
			end_point = {xpos=17, ypos = 34},
			ground_tile = 62,
			music = 12
		},
		
		
		-- 6th level
		{
			celx_start = 13,
			cely_start = 35,
			celx_end = 20,
			cely_end = 44,
			player_spawn = {xpos=17, ypos=35},
			end_point = {xpos=100, ypos = 100},
			ground_tile = 62,
			music = 4
		},


		-- 7th level
		{
			celx_start = 16,
			cely_start = 0,
			celx_end = 28,
			cely_end = 12,
			player_spawn = {xpos=28, ypos=05},
			end_point = {xpos=15, ypos = 11},
			ground_tile = 62,
			music = 4
		},


		-- 8th level
		{
			celx_start = 32,
			cely_start = 0,
			celx_end = 41,
			cely_end = 09,
			player_spawn = {xpos=41, ypos=08},
			end_point = {xpos=33, ypos = 10},
			ground_tile = 62,
			music = 4
		},


		-- 9th level
		{
			celx_start = 48,
			cely_start = 0,
			celx_end = 57,
			cely_end = 9,
			player_spawn = {xpos=48, ypos=7},
			end_point = {xpos=58, ypos = 7},
			ground_tile = 62,
			music = 4
		},
		
		
		-- 10th level
		{
			celx_start = 59,
			cely_start = 0,
			celx_end = 65,
			cely_end = 12,
			player_spawn = {xpos=63, ypos=4},
			end_point = {xpos=66, ypos = 8},
			ground_tile = 62,
			music = 4
		},
		
		
		-- 11th level
		{
			celx_start = 67,
			cely_start = 0,
			celx_end = 78,
			cely_end = 8,
			player_spawn = {xpos=67, ypos=4},
			end_point = {xpos=79, ypos = 5},
			ground_tile = 62,
			music = 4
		},
		
		
		-- 12th level
		{
			celx_start = 80,
			cely_start = 0,
			celx_end = 89,
			cely_end = 10,
			player_spawn = {xpos=80, ypos=7},
			end_point = {xpos=79, ypos = 9},
			ground_tile = 62,
			music = 4
		},


		-- 13th level
		{
			celx_start = 91,
			cely_start = 0,
			celx_end = 102,
			cely_end = 08,
			player_spawn = {xpos=102, ypos=4},
			end_point = {xpos=102, ypos = 6},
			ground_tile = 62,
			music = 4
		},
		
		
 	-- 14th level
		{
			celx_start = 104,
			cely_start = 0,
			celx_end = 116,
			cely_end = 9,
			player_spawn = {xpos=110, ypos=4},
			end_point = {xpos=117, ypos = 07},
			ground_tile = 62,
			music = 4
		},
		
		
		-- 15th level
		{
			celx_start = 56,
			cely_start = 16,
			celx_end = 69,
			cely_end = 26,
			player_spawn = {xpos=56, ypos=20},
			end_point = {xpos=70, ypos = 24},
			ground_tile = 62,
			music = 4
		}
	}

	current_level = {
		index = 0,
		celx = 0,
		cely = 0,
		palette = {}
	}
	
	cam = {
		xpos = 0,
		ypos = 0
	}

	moves = {}
	
end


function rewind()
	local last_move = moves[#moves]

	if type(last_move) == "table" then
		player:move(last_move.direction + (last_move.direction%2==0 and 1 or -1))
		if type(last_move.box) == "table" then
		last_move.box:push(last_move.direction + (last_move.direction%2==0 and 1 or -1), 1) end
		
		moves[#moves] = nil
	end
end

-- loads game objects and level stuff from the coordinates given to the function
function load_level(level, next_level)

	local last_palette = current_level.palette
	local last_music = current_level.music

	current_level = {
		index = current_level.index,
		celx = level.celx_start,
		cely = level.cely_start,
		sx = 0,
		sy = 0,
		celw = level.celx_end - level.celx_start + 1,
		celh = level.cely_end - level.cely_start + 1,
		end_point = level.end_point,
		ground_tile = level.ground_tile,
		barrier = {},
		palette = last_palette,
		music = level.music
	}
	
	boxes = {}
	block_points = {}
	moves = {}
	is_sokoban = false

	player.xpos = level.player_spawn.xpos
	player.ypos = level.player_spawn.ypos

	player:update_camera()

	if level.palette ~= nil then
		current_level.palette = level.palette
		load_palette(current_level.palette)
	
	else
		current_level.palette = {128,0,2,136,132,4,137,9,129,131,139,138,133,5,134,7}
		load_palette(current_level.palette)
	end

	debug = last_music
	if level.music ~= nil and last_music ~= level.music then
		music(level.music)
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
					sprite = mget(celx, cely),
					open = false
				}
			end
		end
	end
end

function load_next_level()
	current_level.index = current_level.index+1
	poke(0x5e00, current_level.index)
	if not (current_level.index > #levels) then
		load_level(levels[current_level.index], true)

	else 
		debug = "swag"
		end_screen_init()
	end
end

function restart_level()
	reload()
	load_level(levels[current_level.index], false)
end

function load_palette(palette)
	pal()
	for i=1,#palette do
		pal(i-1, palette[i], 1)
	end
end

__gfx__
0000000000070060000000000000000000000000c1cccccccccccc1d11111111111111111eeeeee1111111111111111111111111111111111111111111111111
0000000000737720000000000000000000000000d1cccccccccccc1e1eeeeee11eeeeeeeeeeeeeeeeeeeeee11eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee1
000ff00000777770000000000000000000000000d1cccccccccccc1e1eeeeee11eeeeeeeeeeeeeeeeeeeeee11eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee1
00f00f0000797780000000000000000000000000d1cccccccccccc1e1eeeeee11eeeeeeeeeeeeeeeeeeeeee11eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee1
00f00f0002627720000000000000000000000000d1cccccccccccc1e1eeeeee11eeeeeeeeeeeeeeeeeeeeee11eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee1
000ff00002054400000000000000000000000000d1cccccccccccc1e1eeeeee11eeeeeeeeeeeeeeeeeeeeee11eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee1
0000000000277700000000000000000000000000d1cccccccccccc1e1eeeeee11eeeeeecccccccccceeeeee11eeeeeecccccccccceeeeeecccccccccceeeeee1
0000000000070600000000000000000000000000d1cccccccccccc1e1eeeeee11eeeeee1111111111eeeeee11eeeeee1111111111eeeeee1111111111eeeeee1
b000000b11111111000000000000000000000000c1cccccccccccc1d1eeeeee11eeeeee11eeeeee11eeeeee11eeeeee1cccccccc1eeeeee1cccccccc1eeeeee1
0b0000b016666661000000000000000000000000d1cccccccccccc1e1eeeeee1eeeeeee1eeeeeeee1eeeeeee1eeeeee1cccccccc1eeeeee1cccccccc1eeeeee1
000bb00016000061000000000000000000000000d1cccccccccccc1e1eeeeee1eeeeeee1eeeeeeee1eeeeeee1eeeeee1cccccccc1eeeeee1cccccccc1eeeeee1
00b00b0016000061000000000000000000000000d1cccccccccccc1e1eeeeee1eeeeeee1eeeeeeee1eeeeeee1eeeeee1cccccccc1eeeeee1cccccccc1eeeeee1
00b00b0016666661000000000000000000000000d1cccccccccccc1e1eeeeee1eeeeeee1eeeeeeee1eeeeeee1eeeeee1cccccccc1eeeeee1cccccccc1eeeeee1
000bb00015455451000000000000000000000000d1eeeeeeeeeeee1e1eeeeee1eeeeeee1eeeeeeee1eeeeeee1eeeeee1cccccccc1eeeeee1cccccccc1eeeeee1
0b0000b015055051000000000000000000000000d1cccccccccccc1e1eeeeee1ceeeeee1ceeeeeec1eeeeeec1cccccc1cccccccc1cccccc1cccccccc1cccccc1
b000000b16666661000000000000000000000000d11111111111111e1eeeeee11eeeeee11eeeeee11eeeeee111010011cccccccc11010011cccccccc11010011
0000000000000000000000000000000000000000c1cccccccccccc1c1eeeeee11eeeeee1111111111eeeeee101c0cc1cccccccccc1c0cc1cccccccccc1c0cc10
0000000000000000000000000000000000000000c1cccccccccccc1c1eeeeee11eeeeeeeeeeeeeeeeeeeeee101c0cc1cccccccccc1c0cc1cccccccccc1c0cc10
0000000000000000000000000000000000000000c1cccccccccccc1c1eeeeee11eeeeeeeeeeeeeeeeeeeeee10101001cccccccccc101001cccccccccc1010010
0000000000000000000000000000000000000000c1cccccccccccc1c1eeeeee11eeeeeeeeeeeeeeeeeeeeee101cccc1cccccccccc1cccc1cccccccccc1cccc10
0000000000000000000000000000000000000000c1cccccccccccc1c1eeeeee11eeeeeeeeeeeeeeeeeeeeee101cccc1cccccccccc1cccc1cccccccccc1cccc10
0000000000000000000000000000000000000000e1cccccccccccc1e1eeeeee11eeeeeeeeeeeeeeeeeeeeee10100101eeeeeeeeee100101eeeeeeeeee1001010
0000000000000000000000000000000000000000c1cccccccccccc1c1cccccc11cccccccceeeeeecccccccc101cc0c1cccccccccc1cc0c1cccccccccc1cc0c10
000000000000000000000000000000000000000011cccccccccccc1111111111111111111eeeeee11111111101cc0c111111111111cc0c111111111111cc0c10
33333333000000000000000000000000000000000000000011111111cddddddd11111111111111111111111111001011cddddddd11001011cddddddd11001011
3000000300000000000000000000000000000000000000001eeeeee1deeeeeee1eeeeeeeeeeeeeeeeeeeeee11ecccce1d111111e1ecccce1deeeeeee1ecccce1
3000000300000000000000000000000000000000000000001eeeeee1de00000e1eeeeeeeeeeeeeeeeeeeeee11ecccce1d1eeee1e1ecccce1deeeeeee1ecccce1
3000000300000000000000000000000000000000000000001eeeeee1de05550e1eeeeeeeeeeeeeeeeeeeeee11e0100e1d1eeee1e1e0100e1deeeeeee1e0100e1
3000000300000000000000000000000000000000000000001eeeeee1de05550e1eeeeeeeeeeeeeeeeeeeeee11ec0cce1d1eeee1e1ec0cce1deeeeeee1ec0cce1
3000000300000000000000000000000000000000000000001eeeeee1de04440e1eeeeeeeeeeeeeeeeeeeeee11eeeeee1d1dddd1e1eeeeee1deeeeeee1eeeeee1
3000000300000000000000000000000000000000000000001cccccc1de04440e1cccccccccccccccccccccc11cccccc1d1dddd1e1cccccc1deeeeeee1cccccc1
33333333000000000000000000000000000000000000000011111111deeeeeee11111111111111111111111111111111deeeeeee11111111deeeeeee11111111
ccccccc11cccccccccccccc1cccccccccccccccc0000000000000000cccfeccccccccccccccccc1c000000000000000000000000000000000000000000060000
ccccccc11cccccccccccccc1cccccccccccccccc000000000000000014555541cccccccccccccc1e000000000000000000000000000000000000000066060006
ccccccc11cccccccccc111c1cccc111ccccccccc000000000000000010000001ccc1ef1ccccccc1e000000000000000000000000000000000666000066666006
cc11cccccc111ccccc16331cc1113631cccccccc000000000000000010663f01ccc1eff1cccccc1e000000000000000000000000000000006660000066666666
c1761c11c176111cc160306113316361cccccccc000000000000000010663f01ccc13af61ccccc1e000000000000000000000000000000006600000066666666
176571b117371671e133733112313631eeeeeeee000000000000000010ff3f01ccc13a7661cccc1e000000000000000000000000000000001111111100000000
16546aa116791737c1303031c121121ccccccccc000000000000000010ff3f01cc143a176641cc1e000000000000000000000000000000001111111100000000
11769a1111118976111633911191191111111111000000000000000010ff3f01cc143a117641cc1e000000000000000000000000000000001111111100000000
c1118111c1b191111ab11181cd181821cdd111ddc11111111111111110777701cc1455555541cc1c000000000000000000000000000000000000000000000000
1ba181a1de1a81a1d1ab1ba1d1a181bade14441ed13333332333333110ff3f01cc1000000001cc1e000000000000000000000000000000000000000000000000
d11a9a11d1419a11d111a111d11a9ba1d1400041d13333332333333110455401cccccccccccccc1e000000000000000000000000000000000000000000000000
d1500051d1500051d1500051d1500051d1500051d13322332332233110000001cccccccccccccc1e000000000000000000000000000000000000000000000000
d1455541d1455541d1455541d1455541d1455541d133333323333331cccccccccccccccccccccc1e000000000000000000000000000000000000000000000000
d1044401d1044401d1044401d1044401d1044401d133333323333331eeeeeeeeeeeeeeeeeeeeee1e000000000000000000000000000000000000000000000000
de14441ede14441ede14441ede14441ede14441ed122222222222221cccccccccccccccccccccc1e000000000000000000000000000000000000000000000000
de10401ede10401ede10401ede10401ede10401ed101111111111101111111111111111111111111000000000000000000000000000000000000000000000000
ccccccccccccccccccccccccccccccccccccccccccccccccccccccccc1111111c111111100000000000000000000000000000000000000000000000000000000
ccccccccccccccccccccccccccccccccccccccccccccccccccccccccd1333331d155555100000000000000000000000000000000000000000000000000000000
cccccccccccccccccccccccccccccccfecccccccccccccccccccccccd1333331d155555100000000000000000000000000000000000000000000000000000000
cccccc1eeeeeeeeeeeeeeeeee1ccccfccecccc1eeeeeeeeee1ccccccd1332331d111111100000000000000000000000000000000000000000000000000000000
cccccc1cccccccccccccccccc1c1455555541c1cccccccccc1ccccccd1332331d1fefff100000000000000000000000000000000000000000000000000000000
cccccc110bbbbbbbfbbbbbb011c1000000001c110bbbfbb011ccccccd1333331d1fefef100000000000000000000000000000000000000000000000000000000
ccccccc10bbbbbbfbbbbbbb01cc10baaaab01cc10bbfbbb01cccccccd1333331d1dcccd100000000000000000000000000000000000000000000000000000000
ccccccc10aaaaafaafaaaaa01cc10a3763a01cc10afaafa01cccccccd1222221d1fffef100000000000000000000000000000000000000000000000000000000
ccccccc10aaaaaaafaaaaaa01cc1022662201cc10aaafaa01cccccccc1333331c1fefef100000000000000000000000000000000000000000000fffff0000000
ccccccc104555555555555401cc1045555401cc1045555401cccccccd1333331d16777610000000000000000000000000000000000000000000f11111f000000
ccccccc100000000000000001cc1000000001cc1000000001cccccccd1332331d1111111000000000000000000000000000000000000000000f1666661f00000
ccccccccccccccccccccccccccccccccccccccccccccccccccccccccd1332331d155555100000000000000000000000000000000000000000f166666661f0000
ccccccccccccccccccccccccccccccccccccccccccccccccccccccccd1333331d155555100000000000000000000000000000000000000000f1666666661f000
eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeed1333331d144444100000000000000000000000000000000000000000f16611166661f00
ccccccccccccccccccccccccccccccccccccccccccccccccccccccccd1222221d101110100000000000000000fff000000000000000000000f16661116661f00
11111111111111111111111111111111111111111111111111111111d1011101d101e1010000000000000000f111ffffffff0ffffff000000f16661f16661f00
00000000000000000000000000000082a3c3720000000000000000000000000000000000000000ffff0000ff166611111111f111111ffff000f1666116661f00
00000000000000000000000000000000000000000000000000000000000000000000000000000f1111ffff1f1166116666611666661f111fff116661f161f000
0000000000000000000000000000000000010000000000000000000000000000000000000000f1666611116111111166666616666661666111611666611f0000
0000000000000000000000000000000000000000000000000000000000000000000000000000f166661166661666116666111166611161611661f16661f00000
0000000000000000000000000000000000020000000000000000000000000000000000000000f116661666661666111666111166611161616161116661f00000
00000000000000000000000000000000000000000000000000000000000000000000000000000f166666666116661116661fff1661f116616661f16661f00000
00000000000000000000000000809393a3e370000000000000000000000000000000000000000f1666666111166611666611ff16611f1666661ff16661f00000
00000000000000000000000000000000000000000000000000000000000000000000000000000f16666611ff166611666661f166661ff166611ff16661f00000
0000000000000000000000000071748494e371000000000000000000000000000000000000000f1666666111166611666661f166661ff166661ff16661f00000
00000000000000000000000000000000000000000000000000000000000000000000000000000f1666166661166611666661f166661ff1666661166611f00000
0000000000000000000000000071758595e371000000000000000000000000000000000000000f1666166666161111166111f166111f1666666666661f000000
00000000000000000000000000000000000000000000000000000000000000000000000000000f16661166611111ff11111f0f1111ff166666666661f0000000
0000000000000000000000000071e3e3e3e371000000000000000000000000000000000000000f1661111611ffff00fffff000ffff00f1166666611f00000000
000000000000000000000000000000000000000000000000000000000000000000000000000000f111ff111f000000000000000000000f1111111ff000000000
0000000000000000000000000071e31111839093a00000000000000000000000000000000000000fff00fff00000000000000000000000ffffffff0000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000ffff00ff0000000000000000000000000000fffffff00000000
0000000000000000000000000071e311e373e3e371000000000000000000000000000000000000f1111ff11f00ffff000fff0fff00fffff000f11111ff000000
00000000000000000000000000000000000000000000000000000000000000000000000000000f16661f1661ff1111f0f111f111ff11111f0f16666611f00000
00000000000000000000000000a1a3e3457376e37100000000000000000000000000000000000f1666116661f166611f1666116611666661f166661661f00000
00000000000000000000000000000000000000000000000000000000000000000000000000000f16661666611661661166661166166666661166611661f00000
000000000000000000000000007173e3e3e377e37100000000000000000000000000000000000f16666666111611666166661116166611661166611661f00000
00000000000000000000000000000000000000000000000000000000000000000000000000000f16666611111611666166666116116611666166616661f00000
0000000000000000000000000071e3e3e3e3e3e37100000000000000000000000000000000000f16666611f11611666166666666116611666166666661f00000
00000000000000000000000000000000000000000000000000000000000000000000000000000f16666666116616666166666666116616666166666611f00000
0000000000000000000000000082a3c383939393a200000000000000000000000000000000000f1666166661666666616611666611666666116666661f000000
00000000000000000000000000000000000000000000000000000000000000000000000000000f1666166661666666116611166616666666111666611f000000
00000000000000000000000000000001000000000000000000000000000000000000000000000f16611166111666661166111666166666611f111111f0000000
00000000000000000000000000000000000000000000000000000000000000000000000000000f1111f111111666611166611666166666111fff111f00000000
000000000000000000000000000000000000000000000000000000000000000000000000000000ffff0f111f116111f16661166611661111f000fff000000000
000000000000000000000000000000000000000000000000000000000000000000000000000000000000fff0ff111ff11111f111f11111ff0000000000000000
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000fff00ff11f0fff0fffff000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000ff00000000000000000000000000000
__label__
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00mmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmm00
00mmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmm00
00mmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmm00
00mmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmm00
00mmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmm00
00mmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmm00
00mmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmm00
00mmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmm00
00mmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmm00
00mmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmm00
00mmmmmmmmmmmmllllllllllllllllllllllllllllllllllllllllllllllllllllllllllllllllllllllllllllllllllllllllllllllllllllmmmmmmmmmmmm00
00mmmmmmmmmmmmllllllllllllllllllllllllllllllllllllllllllllllllllllllllllllllllllllllllllllllllllllllllllllllllllllmmmmmmmmmmmm00
00mmmmmmmmmmmm0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000mmmmmmmmmmmm00
00mmmmmmmmmmmm0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000mmmmmmmmmmmm00
00mmmmmmmmmmmm00llllllllllllllllllllllllllllllllllllllllllllllllllllllllllllllllllllllllllllllllllllllllllllllll00mmmmmmmmmmmm00
00mmmmmmmmmmmm00llllllllllllllllllllllllllllllllllllllllllllllllllllllllllllllllllllllllllllllllllllllllllllllll00mmmmmmmmmmmm00
00mmmmmmmmmmmm00llllllllllllllllllllllllllllllllllllllllllllllllllllllllllllllllllllllllllllllllllllllllllllllll00mmmmmmmmmmmm00
00mmmmmmmmmmmm00llllllllllllllllllllllllllllllllllllllllllllllllllllllllllllllllllllllllllllllllllllllllllllllll00mmmmmmmmmmmm00
00mmmmmmmmmmmm00llllllllllllllllllllllllllllllllllllllllllllll77mmllllllllllllllllllllllllllllllllllllllllllllll00mmmmmmmmmmmm00
00mmmmmmmmmmmm00llllllllllllllllllllllllllllllllllllllllllllll77mmllllllllllllllllllllllllllllllllllllllllllllll00mmmmmmmmmmmm00
00mmmmmmmmmmmm00llllllllllll00mmmmmmmmmmmmmmmmmmmm00llllllll77llllmmllllllll00mmmmmmmmmmmmmmmmmmmm00llllllllllll00mmmmmmmmmmmm00
00mmmmmmmmmmmm00llllllllllll00mmmmmmmmmmmmmmmmmmmm00llllllll77llllmmllllllll00mmmmmmmmmmmmmmmmmmmm00llllllllllll00mmmmmmmmmmmm00
00mmmmmmmmmmmm00llllllllllll00llllllllllllllllllll00ll00kk444444444444kk00ll00llllllllllllllllllll00llllllllllll00mmmmmmmmmmmm00
00mmmmmmmmmmmm00llllllllllll00llllllllllllllllllll00ll00kk444444444444kk00ll00llllllllllllllllllll00llllllllllll00mmmmmmmmmmmm00
00mmmmmmmmmmmm00llllllllllll0000ggqqqqqq77qqqqgg0000ll00gggggggggggggggg00ll0000ggqqqqqq77qqqqgg0000llllllllllll00mmmmmmmmmmmm00
00mmmmmmmmmmmm00llllllllllll0000ggqqqqqq77qqqqgg0000ll00gggggggggggggggg00ll0000ggqqqqqq77qqqqgg0000llllllllllll00mmmmmmmmmmmm00
00llllllllllll00llllllllllllll00ggqqqq77qqqqqqgg00llll00ggqqrrrrrrrrqqgg00llll00ggqqqq77qqqqqqgg00llllllllllllll00llllllllllll00
00llllllllllll00llllllllllllll00ggqqqq77qqqqqqgg00llll00ggqqrrrrrrrrqqgg00llll00ggqqqq77qqqqqqgg00llllllllllllll00llllllllllll00
0000gg00gggg0000llllllllllllll00ggrr77rrrr77rrgg00llll00ggrroo99ppoorrgg00llll00ggrr77rrrr77rrgg00llllllllllllll0000gg00gggg0000
0000gg00gggg0000llllllllllllll00ggrr77rrrr77rrgg00llll00ggrroo99ppoorrgg00llll00ggrr77rrrr77rrgg00llllllllllllll0000gg00gggg0000
gg00llggllll00llllllllllllllll00ggrrrrrr77rrrrgg00llll00gg2222pppp2222gg00llll00ggrrrrrr77rrrrgg00llllllllllllllll00llggllll00gg
gg00llggllll00llllllllllllllll00ggrrrrrr77rrrrgg00llll00gg2222pppp2222gg00llll00ggrrrrrr77rrrrgg00llllllllllllllll00llggllll00gg
gg00llggllll00llllllllllllllll00ggkk44444444kkgg00llll00ggkk44444444kkgg00llll00ggkk44444444kkgg00llllllllllllllll00llggllll00gg
gg00llggllll00llllllllllllllll00ggkk44444444kkgg00llll00ggkk44444444kkgg00llll00ggkk44444444kkgg00llllllllllllllll00llggllll00gg
gg00gg00gggg00llllllllllllllll00gggggggggggggggg00llll00gggggggggggggggg00llll00gggggggggggggggg00llllllllllllllll00gg00gggg00gg
gg00gg00gggg00llllllllllllllll00gggggggggggggggg00llll00gggggggggggggggg00llll00gggggggggggggggg00llllllllllllllll00gg00gggg00gg
gg00llllllll00llllll0000llllllllllllllllllllllllllllllllllllllllllllllllllllllllllllllllllllllllllllllllllllllllll00llllllll00gg
gg00llllllll00llllll0000llllllllllllllllllllllllllllllllllllllllllllllllllllllllllllllllllllllllllllllllllllllllll00llllllll00gg
gg00llllllll00llll0099pp00ll0000llllllllllllllllllllllllllllllllllllllllllllllllllllllllllllllllllllllllllllllllll00llllllll00gg
gg00llllllll00llll0099pp00ll0000llllllllllllllllllllllllllllllllllllllllllllllllllllllllllllllllllllllllllllllllll00llllllll00gg
gg00gggg00gg00mm0099pp449900qq00mmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmm00gggg00gg00gg
gg00gggg00gg00mm0099pp449900qq00mmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmm00gggg00gg00gg
gg00llllggll00ll00pp44kkpprrrr00llllllllllllllllllllllllllllllllllllllllllllllllllllllllllllllllllllllllllllllllll00llllggll00gg
gg00llllggll00ll00pp44kkpprrrr00llllllllllllllllllllllllllllllllllllllllllllllllllllllllllllllllllllllllllllllllll00llllggll00gg
gg00llllggll0000000099ppjjrr0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000llllggll00gg
gg00llllggll0000000099ppjjrr0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000llllggll00gg
0000gggg00gg0000ll000000hh000000ll55555555555555ll55555555555555ll55555555555555ll55555555555555ll555555555555550000gggg00gg0000
0000gggg00gg0000ll000000hh000000ll55555555555555ll55555555555555ll55555555555555ll55555555555555ll555555555555550000gggg00gg0000
00mmllllllllmm0000qqrr00hh00rr0055mmmmmmmmmmmmmm55mmmmmmmmmmmmmm55mmmmmmmmmmmmmm55mmmmmmmmmmmmmm55mmmmmmmmmmmmmm00mmllllllllmm00
00mmllllllllmm0000qqrr00hh00rr0055mmmmmmmmmmmmmm55mmmmmmmmmmmmmm55mmmmmmmmmmmmmm55mmmmmmmmmmmmmm55mmmmmmmmmmmmmm00mmllllllllmm00
00mmllllllllmm00550000rrjjrr000055mmmmmmmmmmmmmm55mmmmmmmmmmmmmm55mmmmmmmmmmmmmm55mmmmmmmmmmmmmm55mmmmmmmmmmmmmm00mmllllllllmm00
00mmllllllllmm00550000rrjjrr000055mmmmmmmmmmmmmm55mmmmmmmmmmmmmm55mmmmmmmmmmmmmm55mmmmmmmmmmmmmm55mmmmmmmmmmmmmm00mmllllllllmm00
00mmgg00ggggmm00550044gggggg440055mmmmmmmmmmmmmm55mmmmmmmmmmmmmm55mmmmmmmmmmmmmm55mmmmmmmmmmmmmm55mmmmmmmmmmmmmm00mmgg00ggggmm00
00mmgg00ggggmm00550044gggggg440055mmmmmmmmmmmmmm55mmmmmmmmmmmmmm55mmmmmmmmmmmmmm55mmmmmmmmmmmmmm55mmmmmmmmmmmmmm00mmgg00ggggmm00
00mmllggllllmm005500kk444444kk0055mmmmmmmmmmmmmm55mmmmmmmmmmmmmm55mmmmmmmmmmmmmm55mmmmmmmmmmmmmm55mmmmmmmmmmmmmm00mmllggllllmm00
00mmllggllllmm005500kk444444kk0055mmmmmmmmmmmmmm55mmmmmmmmmmmmmm55mmmmmmmmmmmmmm55mmmmmmmmmmmmmm55mmmmmmmmmmmmmm00mmllggllllmm00
00mmmmmmmmmmmm005500ggkkkkkkgg0055mmmmmmmmmmmmmm55mmmmmmmmmmmmmm55mmmmmmmmmmmmmm55mmmmmmmmmmmmmm55mmmmmmmmmmmmmm00mmmmmmmmmmmm00
00mmmmmmmmmmmm005500ggkkkkkkgg0055mmmmmmmmmmmmmm55mmmmmmmmmmmmmm55mmmmmmmmmmmmmm55mmmmmmmmmmmmmm55mmmmmmmmmmmmmm00mmmmmmmmmmmm00
00llllllllllll0055mm00kkkkkk00mm55mmmmmmmmmmmmmm55mmmmmmmmmmmmmm55mmmmmmmmmmmmmm55mmmmmmmmmmmmmm55mmmmmmmmmmmmmm00llllllllllll00
00llllllllllll0055mm00kkkkkk00mm55mmmmmmmmmmmmmm55mmmmmmmmmmmmmm55mmmmmmmmmmmmmm55mmmmmmmmmmmmmm55mmmmmmmmmmmmmm00llllllllllll00
000000000000000055mm00ggkkgg00mm55mmmmmmmmmmmmmm55mmmmmmmmmmmmmm55mmmmmmmmmmmmmm55mmmmmmmmmmmmmm55mmmmmmmmmmmmmm0000000000000000
000000000000000055mm00ggkkgg00mm55mmmmmmmmmmmmmm55mmmmmmmmmmmmmm55mmmmmmmmmmmmmm55mmmmmmmmmmmmmm55mmmmmmmmmmmmmm0000000000000000
ll5500990000pp00ll555555555555550000000000000000ll55555555555555ll55555555555555ll00000000000000ll55555555555555ll55555555555555
ll5500990000pp00ll555555555555550000000000000000ll55555555555555ll55555555555555ll00000000000000ll55555555555555ll55555555555555
550099oo9999220055mmmmmmmmmmmmmm00pppppppppppp0055mmmmmmmmmmmmmm55mmmmmmmmmmmmmm5500oooooooooo0055mmmmmmmmmmmmmm55000000000000mm
550099oo9999220055mmmmmmmmmmmmmm00pppppppppppp0055mmmmmmmmmmmmmm55mmmmmmmmmmmmmm5500oooooooooo0055mmmmmmmmmmmmmm55000000000000mm
550099999999990055mmmmmmmmmmmmmm00ppggggggggpp0055mmmmmmmmmmmmmm55mmmmmmmmmmmmmm5500oooooooooo0055mmmmmmmmmmmmmm5500mmmmmmmm00mm
550099999999990055mmmmmmmmmmmmmm00ppggggggggpp0055mmmmmmmmmmmmmm55mmmmmmmmmmmmmm5500oooooooooo0055mmmmmmmmmmmmmm5500mmmmmmmm00mm
550099jj9999hh0055mmmmmmmmmmmmmm00ppggggggggpp0055mmmmmmmmmmmmmm55mmmmmmmmmmmmmm5500oooo22oooo0055mmmmmmmmmmmmmm5500mmmmmmmm00mm
550099jj9999hh0055mmmmmmmmmmmmmm00ppggggggggpp0055mmmmmmmmmmmmmm55mmmmmmmmmmmmmm5500oooo22oooo0055mmmmmmmmmmmmmm5500mmmmmmmm00mm
0022pp229999220055mmmmmmmmmmmmmm00pppppppppppp0055mmmmmmmmmmmmmm55mmmmmmmmmmmmmm5500oooo22oooo0055mmmmmmmmmmmmmm5500mmmmmmmm00mm
0022pp229999220055mmmmmmmmmmmmmm00pppppppppppp0055mmmmmmmmmmmmmm55mmmmmmmmmmmmmm5500oooo22oooo0055mmmmmmmmmmmmmm5500mmmmmmmm00mm
00220044kkkk00mm55mmmmmmmmmmmmmm0044kk4444kk440055mmmmmmmmmmmmmm55mmmmmmmmmmmmmm5500oooooooooo0055mmmmmmmmmmmmmm55005555555500mm
00220044kkkk00mm55mmmmmmmmmmmmmm0044kk4444kk440055mmmmmmmmmmmmmm55mmmmmmmmmmmmmm5500oooooooooo0055mmmmmmmmmmmmmm55005555555500mm
55002299999900mm55mmmmmmmmmmmmmm0044gg4444gg440055mmmmmmmmmmmmmm55mmmmmmmmmmmmmm5500oooooooooo0055mmmmmmmmmmmmmm55005555555500mm
55002299999900mm55mmmmmmmmmmmmmm0044gg4444gg440055mmmmmmmmmmmmmm55mmmmmmmmmmmmmm5500oooooooooo0055mmmmmmmmmmmmmm55005555555500mm
55mm009900pp00mm55mmmmmmmmmmmmmm00pppppppppppp0055mmmmmmmmmmmmmm55mmmmmmmmmmmmmm550022222222220055mmmmmmmmmmmmmm55mmmmmmmmmmmmmm
55mm009900pp00mm55mmmmmmmmmmmmmm00pppppppppppp0055mmmmmmmmmmmmmm55mmmmmmmmmmmmmm550022222222220055mmmmmmmmmmmmmm55mmmmmmmmmmmmmm
0000000000000000000000000000000000000000000000000000000000000000ll55555555555555ll00oooooooooo00ll555555555555550000000000000000
0000000000000000000000000000000000000000000000000000000000000000ll55555555555555ll00oooooooooo00ll555555555555550000000000000000
00mmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmm0055mmmmmmmmmmmmmm5500oooooooooo0055mmmmmmmmmmmmmm00mmmmmmmmmmmm00
00mmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmm0055mmmmmmmmmmmmmm5500oooooooooo0055mmmmmmmmmmmmmm00mmmmmmmmmmmm00
00mmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmm0055mmmmmmmmmmmmmm5500oooo22oooo0055mmmmmmmmmmmmmm00mmmmmmmmmmmm00
00mmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmm0055mmmmmmmmmmmmmm5500oooo22oooo0055mmmmmmmmmmmmmm00mmmmmmmmmmmm00
00mmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmm0055mmmmmmmmmmmmmm5500oooo22oooo0055mmmmmmmmmmmmmm00mmmmmmmmmmmm00
00mmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmm0055mmmmmmmmmmmmmm5500oooo22oooo0055mmmmmmmmmmmmmm00mmmmmmmmmmmm00
00mmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmm0055mmmmmmmmmmmmmm5500oooooooooo0055mmmmmmmmmmmmmm00mmmmmmmmmmmm00
00mmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmm0055mmmmmmmmmmmmmm5500oooooooooo0055mmmmmmmmmmmmmm00mmmmmmmmmmmm00
00mmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmm0055mmmmmmmmmmmmmm5500oooooooooo0055mmmmmmmmmmmmmm00mmmmmmmmmmmm00
00mmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmm0055mmmmmmmmmmmmmm5500oooooooooo0055mmmmmmmmmmmmmm00mmmmmmmmmmmm00
00mmmmmmmmmmmmllllllllllllllllllllllllllllllllllllllllllllllll0055mmmmmmmmmmmmmm550022222222220055mmmmmmmmmmmmmm00mmmmmmmmmmmm00
00mmmmmmmmmmmmllllllllllllllllllllllllllllllllllllllllllllllll0055mmmmmmmmmmmmmm550022222222220055mmmmmmmmmmmmmm00mmmmmmmmmmmm00
00mmmmmmmmmmmm0000000000000000000000000000000000000000000000000055mmmmmmmmmmmmmm5500gg000000gg0055mmmmmmmmmmmmmm00mmmmmmmmmmmm00
00mmmmmmmmmmmm0000000000000000000000000000000000000000000000000055mmmmmmmmmmmmmm5500gg000000gg0055mmmmmmmmmmmmmm00mmmmmmmmmmmm00
00mmmmmmmmmmmm00ll55555555555555ll55555555555555ll55555555555555ll55555555555555ll55555555555555ll5555555555555500mmmmmmmmmmmm00
00mmmmmmmmmmmm00ll55555555555555ll55555555555555ll55555555555555ll55555555555555ll55555555555555ll5555555555555500mmmmmmmmmmmm00
00mmmmmmmmmmmm0055mmmmmmmmmmmmmm55mmmmmmmmmmmmmm55mmmmmmmmmmmmmm55mmmmmmmmmmmmmm55mmmmmmmmmmmmmm55mmmmmmmmmmmmmm00mmmmmmmmmmmm00
00mmmmmmmmmmmm0055mmmmmmmmmmmmmm55mmmmmmmmmmmmmm55mmmmmmmmmmmmmm55mmmmmmmmmmmmmm55mmmmmmmmmmmmmm55mmmmmmmmmmmmmm00mmmmmmmmmmmm00
00mmmmmmmmmmmm0055mmggggggggggmm55mmmmmmmmmmmmmm55mmmmmmmmmmmmmm55mmmmmmmmmmmmmm55mmmmmmmmmmmmmm55mmmmmmmmmmmmmm00mmmmmmmmmmmm00
00mmmmmmmmmmmm0055mmggggggggggmm55mmmmmmmmmmmmmm55mmmmmmmmmmmmmm55mmmmmmmmmmmmmm55mmmmmmmmmmmmmm55mmmmmmmmmmmmmm00mmmmmmmmmmmm00
00mmmmmmmmmmmm0055mmgg444444ggmm55mmmmmmmmmmmmmm55mmmmmmmmmmmmmm55mmmmmmmmmmmmmm55mmmmmmmmmmmmmm55mmmmmmmmmmmmmm00mmmmmmmmmmmm00
00mmmmmmmmmmmm0055mmgg444444ggmm55mmmmmmmmmmmmmm55mmmmmmmmmmmmmm55mmmmmmmmmmmmmm55mmmmmmmmmmmmmm55mmmmmmmmmmmmmm00mmmmmmmmmmmm00
00mmmmmmmmmmmm0055mmgg444444ggmm55mmmmmmmmmmmmmm55mmmmmmmmmmmmmm55mmmmmmmmmmmmmm55mmmmmmmmmmmmmm55mmmmmmmmmmmmmm00mmmmmmmmmmmm00
00mmmmmmmmmmmm0055mmgg444444ggmm55mmmmmmmmmmmmmm55mmmmmmmmmmmmmm55mmmmmmmmmmmmmm55mmmmmmmmmmmmmm55mmmmmmmmmmmmmm00mmmmmmmmmmmm00
00mmmmmmmmmmmm0055mmggkkkkkkggmm55mmmmmmmmmmmmmm55mmmmmmmmmmmmmm55mmmmmmmmmmmmmm55mmmmmmmmmmmmmm55mmmmmmmmmmmmmm00mmmmmmmmmmmm00
00mmmmmmmmmmmm0055mmggkkkkkkggmm55mmmmmmmmmmmmmm55mmmmmmmmmmmmmm55mmmmmmmmmmmmmm55mmmmmmmmmmmmmm55mmmmmmmmmmmmmm00mmmmmmmmmmmm00
00mmmmmmmmmmmm0055mmggkkkkkkggmm55mmmmmmmmmmmmmm55mmmmmmmmmmmmmm55mmmmmmmmmmmmmm55mmmmmmmmmmmmmm55mmmmmmmmmmmmmm00mmmmmmmmmmmm00
00mmmmmmmmmmmm0055mmggkkkkkkggmm55mmmmmmmmmmmmmm55mmmmmmmmmmmmmm55mmmmmmmmmmmmmm55mmmmmmmmmmmmmm55mmmmmmmmmmmmmm00mmmmmmmmmmmm00
00mmmmmmmmmmmm0055mmmmmmmmmmmmmm55mmmmmmmmmmmmmm55mmmmmmmmmmmmmm55mmmmmmmmmmmmmm55mmmmmmmmmmmmmm55mmmmmmmmmmmmmm00mmmmmmmmmmmm00
00mmmmmmmmmmmm0055mmmmmmmmmmmmmm55mmmmmmmmmmmmmm55mmmmmmmmmmmmmm55mmmmmmmmmmmmmm55mmmmmmmmmmmmmm55mmmmmmmmmmmmmm00mmmmmmmmmmmm00
00mmmmmmmmmmmm0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000mmmmmmmmmmmm00
00mmmmmmmmmmmm0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000mmmmmmmmmmmm00
00mmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmm00
00mmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmm00
00mmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmm00
00mmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmm00
00mmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmm00
00mmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmm00
00mmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmm00
00mmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmm00
00mmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmm00
00mmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmm00
00llllllllllllllllllllllllllllllllllllllllllllllllllllllllllllllllllllllllllllllllllllllllllllllllllllllllllllllllllllllllllll00
00llllllllllllllllllllllllllllllllllllllllllllllllllllllllllllllllllllllllllllllllllllllllllllllllllllllllllllllllllllllllllll00
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000

__gff__
0000000000010101010101010101010104030000000101010101010101010101010000000001010101010101010101010100000000000108010101011101000101010101010000010101000000000000010101010101010101010000000000000101010101010101010000010101000001010101010101010100000000000000
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000ffffffffffffff000000000000000000ffffffffffffff000000000000000000ffffffffffffff000000000000000000ffffffffffffff00000000000000000000000000000000
__map__
000b0c0c0c0c0c0c0f000b0c0c0c0f00000b0c0c0c0c0c0c0c0c0c0f000000000839390a08393939390a000000000000000b0c0c0c0c0c0f000000080c0c0c0f0000000b0c0c0c0a0000080c0c0c0f000000000b0c0c0a0000000000080c0c0c0c0c0c0c0c0c0a000000000000000b0c0c0c0f00000000000000000000000000
001b6065636465661f001b60656617000b2a1c1c1c1c1c1c1c1c1e280f000000171c1c282a606162661700000000000000176065656566280c0a00176065661f0000001b1c471c280c0c2a1c471c17000008392a1c1c2839390a0000171c1c1c1c1c1c1c1c1c1f000000000000001b1c1c1c1700000000000000000000000000
002b4075737475762f002b427541170017262c2c2c2c2c2c2c2c2e251f000000172c2c2526707172761700000000000000177075757576251c1700177075762f0000002b2c572c251c1c262c572c1f0000171c262c2c25471c170000172c2c2c2c2c2c2c2c2c2f000000000000002b2c2c2c1700000000000000000000000000
003b503e3e3e3e3e3f003b523e51170017163e3e3e3e3e3e3e3e3e152f000000173e3e15163e3e3e3e170000000000000b2a3e3e373e37152c1700173e3e3e3f0000003b3e3e3e152c2c1637373e2f0000172c163e3e15572c1700082a373737373737373e3e3f000000000000003b3e3e3e280a000000000000000000000000
303e3e113e3e673e3c103e3e3e371700173e3e543e543e543e543e3e3f000000173e3e11371155563e170000000000001b683e373e373e373e1700173e373e3e2000203e3e1111113e3e3e3e3e3e3f0000173e113e11373e3e1700173e111111111111113e3e3e200000000000203e3e113e3e17000000000000000000000000
000839393a3e773e07000b0c3a3e170017673e3e1137113711373e3e3e200000173e3e3e37113e3e3e1f0000000000002b78543e555655563e170017373e37380c0a00073e3e3e11673e3e37373e3c10082a3e543e3e37113e1700173e3e3e673e543e543e383a00080c0c0c0c290c3a3e543e280a0000000000000000000000
0017373e3e3e3e3e17001737683e170017773e543e543e543e543e6807000000173c0711371167683e2f0000000000003b3e3e3e113e3e113e27001a3a37543e3e170028390a3e3e773e3e55563e0700273e3e3e55563738292a00173e543e773e3e3e3e3e3c3e00173e373e3e273e113e113e3e270000000000000000000000
00280e0e0e0e0e0e2a00173e783e170017673e3e1137113711373e7817000000173e173e373e77783e3f0000000000203e3e3e11113e3e113e3c10173e3e113e3e27000000173e3e080a3e3e3e3e17203e3e3e113e3e373e170000173e3e3e0839393939390a3e00173e3e3e3e3e3e3e3e11543e3c1000000000000000000000
0b0e0e0e0e0e0e0f000017113e11170017773e543e543e543e543e3e17000000173e173e373e3e3e3e3e2000000000003939390a3e3e3e08393a00173e113e3e3e3c1000002839392a28393939392a00363e3e3e073e3e3e170000283939392a0000000000273e0017373737080c0c0c0a3e3e3e070000000000000000000000
176065636465661f00002737113e170017673e3e1137113711373e3e17000000273e283939393939393a000000000000000000283939392a000000280a11113e3e0700000000000000000000000000103c3e3e08093939392a000000000000000000000000001000280c0c0c2a000000280c0c0c2a0000000000000000000000
177075737475762f00103c3e3e3e170027773e543e543e543e543e3e1700000000100000000000000000000000000000000000000000000000000000173e3e08392a00000000000000000000000000003839392a0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
175556373e3e3e3f0000073e3e3e17103c3e3e3e3e3e3e3e3e3e3e3e1700000000000000000000000000000000000000000000000000000000000000173e3e1700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
17683e11555655560000280c0c0c2a003839393939393939393939392a000000000000000000000000000000000000000000000000000000000000002839392a00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
17783e3e3e3e113e200000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
17373e1111370b3a000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1a3a3c073e0b2a00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
173e3e1737170000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000080c0c0c0c0c0c0c0c0c0c0c0c0a00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
273e3809392a0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000171c60616263646162661c471c1700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0010000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000172c70717273747172762c572c1700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0020000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000273e3e3e3e3e3e673e3e3e3e3e1700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
073e0b0c390c390c0c0c0f0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000203e3e113e11113e773e373e37371700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
17111b6065661e6065661f00000b0e0e0e0e0f00000000000000000000000000000000000000000000000000000000000000000000000000380a3e083a3e38393a3e380a3e1700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
173e2d707576437075762f00001b60616266170000000000000000000000000000000000000000000000000000000000000000000000000000173e173e3e3e3e3e3e3e173e1700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
173e3b3e3e3e533e3e373f00002b42717241170000000000000000000000000000000000000000000000000000000000000000000000000000173e173e3e3e073e3e3e173e2700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
173e3e3e1111373e3e113c10003b523e3e51280c0c0f0000000000000000000000000000000000000000000000000000000000000000000000173e28393939093939392a3e3c10000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
17373e3e3e37073e3e3e0700203e3e3e3e3e05471c170000000000000000000000000000000000000000000000000000000000000000000000173e3e3e3e3e3e3e3e3e3e3e0700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
283939393939185455561700000b393a3e3e15572c1700000000000000000000000000000000000000000000000000000000000000000000002839393939393939393939392a00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000283939392a000017484911113e3e681700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000001758593e11373e781700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000173737373e0839392a00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000028390a113e1700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000173e3e1700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__sfx__
01010000000002f0502c0502b050000002c050000002e050000002f050000002f050000002f050000002c050270501b0501b05000000000001c050000001f0500000020050000002205000000220500000021050
012800000c1351113515135111350c13511135151350c1310b1351113515135111350b13511135151350b1310a1351113515135111350a13511135151350a1310913211132111321113211132111321113211135
012800000c33500305003050c3350c33500300003050c3350b33500305003050b3350b33500305003050b3350a33500305003050a3350a33500305003050a3350933500000151521515215152151521515215155
012800000000000000000000000015314153121531215315000000000000000000001531415312153121531500000000000000000000153141531215312153150000000000000001815218152181521815218155
0128000000600000002b6000060000600000002b6000000000600000002b6000060000000006002b6000000000600000002b6000060000600000002b60000000006000000000000000001c1521c1521c1521c155
012800000000000000000001107515075180721807515075130721307213075180711807218072180721807516072160751807218075160761607513072130751507215072150721505513052130521305213055
012800000c1351113515135111350c13511135151350c1310b1351113515135111350b13511135151350b1310a1351113515135111350a13511135151350a1311113511132111321113210132101321013210132
012800001d5241d5221d5221d5221d5221d5221d5221d5251c5241c5221c5221c5221c5221c5221c5221c5251a5241a5221a5221a5221a5221a5221a5221a5251852418522185221852218522185221852218525
0128000000623000002b6250062300623000002b6250000000000006232b62500623006232b625000002b62500623000002b6250062300623000002b6250000000000006232b62500623006232b625000002b625
0128000000623000002b6250062300623000002b6250000000623000002b6250062300000006232b6250000000623000002b6250062300623000002b6250000000623000002b625006231f1521f1521f1521f152
011400000c5550f555135550f555165551855516555135550c5550f555135550f5550c5550f555135550f5550c5550f555135550f555165551855516555135550c5550f555135550f5550c5550f555135550f555
011400001855418552185521855218552185521855218552165521655216552165521855118552185521855213552135521355213552135521355213552135521355213552135521355213552135521355213555
011400000015500000000000000000000000000000000155001550000000000000000000000000000000000000155000000000000000000000000000000001550015500000000000000000000000000000000155
0114000011555145551855514555115551455511555105550f5551355516555135550f555135550f5550c5550d555115551455511555185551455511555145550d5551155514555115551b555165551355516555
011400000515500000000000000000000000000000005155031550000000000000000000000000000000315501155000000000000000000000000000000011550115500000000000000000000000000000000000
011400001d5541d5521d5521d5521d5521d55220551205521b5511b5521b5521b5521855218552185521855219551195521955219552195521855216552195521855218552185521855218552185521855218555
011400000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000002b62500000000002b62500000000002b62500000
0114000000000000002b6250000000000000002b6250000000000000002b6250000000000000002b6250000000000000002b6250000000000000002b625000002b62500000000002b62500000000002b62500000
011400001d5541d5521d5521d5521d5521d55220551205521b5511b5521b5521b55218552185521855218552195511955219552195521955218552165521d5521c5521c5521c5521c5521f5521f5521f5521f555
01140000270522605224052220522203222012220522405226052270522605224052240322402224012240022705226052240522205222032220122705226052270521b0521f0522205222032220222201200002
0114000000623006232b6250062300000006232b6250000000623006232b625006232b625000002b6250000000623006232b6250062300000006232b6250000000623006232b625006232b6252b6252b6252b625
01140000200521f0521d0521b0521b0321b0121b0521c0521b05216052180521905219032190121905519055200521f0521d0521c05224052200521d0521b052200521f0521d0521b05227052220521f0521b052
010e00000065500000000000000000655000000000000000006550000000000000000065500000000000000000655000000000000000006550000000000000000065500000000000000000655000002b6252b625
010e000000655000002b6252b62500655000002b6252b62500655000002b6252b62500000006552b6252b62500655000002b6252b62500655000002b6252b6252b62500655006552b62500655006552b62500655
010e00000c0550000013055180550c0550000013055180550c0550000513055180550c0550000513055180550c0550000513055180550c0550000513055180550c0550000513055180550c055000051305518050
010e00002411424112241122411224112241122411224112241122411224112241122411224112241122411224112241122411224112241122411224112241122411224112241122411224112241122411224115
010e00000000013000180001800018000180001800018000130521305218051180501805018050180501805016052160521605216052160521605216052160521505016050150501305011050130501505011050
010e00001305013050130501305013050130501305013050130521305218051180501805018050180501805016050000000000016055160501605016050160501805000000000001805518050180501805018050
010e00001305013050130501305013050130501305013050130521305218051180501805018050180501805016050000000000011055110501105011050110501a05000000000001605516050160501605016050
010e000021050000001d050000002105000000240502405029051290522905229052290522905229052290522c0502b05029050270502c0502b05029050260501d05021050240502805024050210501d05018050
010e000000655000000000000000000000000000655000002b6250000000000000000000000000006550000000000000000065500000000000000000655000002b62500000000000000000000000002b62500000
010e00002112221122211222112221122211221d1211d1222c1212c1222c1222c1222c1222c1222c1222c1222c1222c1222c1222c1222c1222c1222c1222c1222b1222b1222b1222b1222b1222b1222b1222b120
010e00002915229142291322911200000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__music__
01 01020304
00 06054244
00 06050708
02 01020309
01 0a0c4344
00 0d0e4344
00 0a0c0b10
00 0a0c0b11
00 0d0e0f11
00 0d0e1211
00 0a13140c
02 0d0e1514
01 16181944
00 17181944
00 17181a44
00 17181b44
00 17181a44
00 17181c44
00 1d1e1f44
02 17205a44

