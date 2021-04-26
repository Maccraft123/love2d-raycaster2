function love.load()
	map = { {1, 1, 2, 3, 1 },
		{6, 0, 0, 0, 4 },
		{8, 0, 2, 1, 1 },
		{4, 0, 0, 0, 7 },
		{1, 2, 4, 1, 7 } }
	
	player = {}
	player.x = 2.5
	player.y = 2.5
	player.a = 0

	fov = 90
	rays = 800
end

function love.update(dt)
	if love.keyboard.isDown("w") then
		player.x = player.x + 2*dt*math.sin(player.a)
		player.y = player.y + 2*dt*math.cos(player.a)
	elseif love.keyboard.isDown("s") then
		player.x = player.x - 2*dt*math.sin(player.a)
		player.y = player.y - 2*dt*math.cos(player.a)
	end
	if love.keyboard.isDown("q") then
		player.y = player.y + 2*dt*math.sin(player.a)
		player.x = player.x - 2*dt*math.cos(player.a)
	elseif love.keyboard.isDown("e") then
		player.y = player.y - 2*dt*math.sin(player.a)
		player.x = player.x + 2*dt*math.cos(player.a)

	end
	if love.keyboard.isDown("a") then
		player.a = player.a - 5*dt
	elseif love.keyboard.isDown("d") then
		player.a = player.a + 5*dt
	end
end

function ray(startx, starty, stepx, stepy, iter)
	x = startx
	y = starty
	angle = player.a
	steps = 1
	for i=1,2048 do
		if map[math.floor(x)][math.floor(y)] ~= 0 then
			m = map[math.floor(x)][math.floor(y)]
			r = 0
			g = 0
			b = 0
			if m == 1 or m == 3 or m == 5 or m == 7 then r = 1 end
			if m == 2 or m == 3 or m == 6 or m == 7 then g = 1 end
			if m == 4 or m == 5 or m == 6 or m == 7 then b = 1 end
			if m == 8 then reflect = true else reflect = false end
			if m == 9 then scatter = true else scatter = false end
			cache = 80/steps 
			r = cache*r
			g = cache*g
			b = cache*b
			if not reflect then
				return r, g, b, cache
			elseif reflect then
				r = 0
				g = 0
				b = 0
				cache = 0

				if stepx < stepy then
					stepx = stepx * -1
				else
					stepy = stepy * -1
				end
				x = stepx*10 + x
				y = stepy*10 + y
			end
		end
		x = stepx + x
		y = stepy + y
		--love.graphics.line(x*20, y*20, startx*20, starty*20)
		steps = steps + 1
	end
end

-- https://www.arduino.cc/reference/en/language/functions/math/map/
function remap(x, in_min, in_max, out_min, out_max)
	return (x - in_min) * (out_max - out_min) / (in_max - in_min) + out_min
end

function love.draw()
	for f=1,rays do
		stepx = math.sin(player.a+remap(f, 0, rays, -(90/fov), (90/fov)))
		stepy = math.cos(player.a+remap(f, 0, rays, -(90/fov), (90/fov)))

		red, green, blue, raw = ray(player.x, player.y, stepx/256, stepy/256, f)

		love.graphics.setColor(red, green, blue)
		love.graphics.rectangle("fill", remap(f, 0, rays, 0, 800), 300, rays/800, (500*raw))
		love.graphics.rectangle("fill", remap(f, 0, rays, 0, 800), 300, rays/800, (-500*raw))
		love.graphics.setColor(1, 1, 1)
	end
	love.graphics.print("Current FPS: "..tostring(love.timer.getFPS()), 10, 10)
end
