pico-8 cartridge // http://www.pico-8.com
version 29
__lua__
function _init()
	create_player()
end

function _update()
	player:move()
end 

function _draw()
	-- Draw simple background
	cls(5)
	-- draw player circle for now
	draw_entity_outline(player, 0)
end

-->8
-- player stuff!!

function create_player()
	player = {
	movement_speed = 2,
	xpos = 32,
	ypos = 32,
	sprite = 0,
	
	-- Player movement
	move = function(self)
		-- At the moment we'll use a simple circle for the player
		if (btn(0)) 
		then
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
		
-->8
-- utility functions!!

-- draws entity based on its x and y vars
-- takes entity and spr() params
function draw_entity(entity, w, h, flip_x, flip_y)
	-- default values
	w = w or 1
	h = h or 1
	flip_x = flip_x or false
	flip_y = flip_y or false
	
	spr(entity.sprite, entity.xpos, entity.ypos, w, h, flip_x, flip_y)
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
000900400000b000ccccc77700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00089980000b0000c777cccc00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00999990008b80007777777c00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0091991008888800cccccccc00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
024299200888880077cccccc00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0209440008888800ccc777cc00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0029990000888000cc77777c00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0009090000000000cccccccc00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
