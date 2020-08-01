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
    rectfill(0,0,127,127,5)
    -- draw player circle for now
    circfill(player.xpos, player.ypos,7,8);
end


-- Player movement
function _playermovement()
    -- At the moment we'll use a simple circle for the player
    if (btn(0)) 
    then
        player.xpos= player.xpos - player.movementspeed
    end
    if (btn(1)) 
    then
        player.xpos= player.xpos + player.movementspeed
    end
    if (btn(2)) 
    then
        player.ypos= player.ypos - player.movementspeed
    end
    if (btn(3)) 
    then
        player.ypos= player.ypos + player.movementspeed
    end
end


-->8
-- player stuff!!

function create_player()
	player = {
    movement_speed = 2,
    xpos = 32,
    ypos = 32,
	
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
