function love.load()
	map = { {1, 1, 2, 3, 1, 1, 5, 7, 3, 6, 1, 6 },
		{6, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 3 },
		{8, 0, 0, 0, 0, 9, 0, 0, 0, 0, 0, 4 },
		{4, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 6 },
		{1, 2, 4, 1, 7, 7, 4, 2, 6, 3, 7, 3 } }
	
	player = {}
	player.x = 2.5
	player.y = 2.5
	player.a = 0

	player.tex = {}
	player.tex.img = love.graphics.newImage("player.png")
	player.tex.x = 0
	player.tex.size = 1
	player.tex.doDraw = false

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

function ray(startx, starty, stepx, stepy, iter, drawnplayer)
	x = startx
	y = starty
	angle = player.a
	steps = 1
	reflected = false
	drawplayer = false
	for i=1,100000 do
		if reflected then
			if not drawplayer then
				if math.sqrt((x- player.x)^2 + (y - player.y)^2) < 0.05 then
					drawplayer = true
				end
			end
		end
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
			cache = 100/steps 
			--r = cache*r
			--g = cache*g
			--b = cache*b
			if not reflect and not scatter then
				return r, g, b, cache, drawplayer
			elseif reflect then
				reflected = true
				r = 0
				g = 0
				b = 0
				cache = 0

				if (x % 1 < 0.05 or x % 1 > 0.95) and (y % 1 < 0.05 or y % 1 > 0.95) then
					return 1, 1, 1, cache
				end

				if x % 1 < 0.05 or x % 1 > 0.95 then
					stepx = stepx * -1
					--stepy = stepy * -1
				else
					--stepx = stepx * -1
					stepy = stepy * -1
				end
				--x = stepx*10 + x
				--y = stepy*10 + y
			elseif scatter then
				oldx = x
				oldy = y
				while math.floor(oldx) == math.floor(x) and math.floor(oldy) == math.floor(y) do
					x = stepx + x
					y = stepy + y
				end
				stepx = stepx + stepx*2*love.math.noise(x, y, oldx, oldy)
				stepy = stepy + stepx*2*love.math.noise(x, y, oldx, oldy)
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
	drawnplayer = false
	for f=1,rays do
		stepx = math.sin(player.a+remap(f, 0, rays, -(90/fov), (90/fov)))
		stepy = math.cos(player.a+remap(f, 0, rays, -(90/fov), (90/fov)))

		red, green, blue, raw, dp = ray(player.x, player.y, stepx/256, stepy/256, f, drawnplayer)

		if dp then
			player.tex.doDraw = true
			player.tex.x = remap(f, 0, rays, 0, 800)
			player.tex.size = raw*4
		end
		love.graphics.setColor(red, green, blue)
		love.graphics.rectangle("fill", remap(f, 0, rays, 0, 800), 300, rays/800, (500*raw))
		love.graphics.rectangle("fill", remap(f, 0, rays, 0, 800), 300, rays/800, (-500*raw))
		love.graphics.setColor(1, 1, 1)
	end
	if player.tex.doDraw then
		player.tex.doDraw = false
		love.graphics.draw(player.tex.img, player.tex.x, 300, 0, player.tex.size, player.tex.size, 100, 200)
	end
	--love.graphics.draw(player.tex, 0, 0, 0, 1, 1, 100, 200)
	love.graphics.print("Current FPS: "..tostring(love.timer.getFPS()), 10, 10)
end
