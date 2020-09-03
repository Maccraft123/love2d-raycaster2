function love.load()
	map = { {1, 1, 2, 3, 1 },
		{6, 0, 0, 0, 4 },
		{3, 0, 2, 1, 1 },
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
		player.y = player.y - 2*dt*math.sin(player.a)
		player.x = player.x - 2*dt*math.cos(player.a)
	elseif love.keyboard.isDown("e") then
		player.y = player.y + 2*dt*math.sin(player.a)
		player.x = player.x + 2*dt*math.cos(player.a)

	end
	if love.keyboard.isDown("a") then
		player.a = player.a - 5*dt
	elseif love.keyboard.isDown("d") then
		player.a = player.a + 5*dt
	end
end

function round(x)
	return math.floor(x+0.5)
end

function distance(px, py, x, y)
	return math.sqrt((px - x)^2 + (py - y)^2)
end

function between(sx, sy, ex, ey, tx, ty)
	l = math.abs(distance(sx, sy, tx, ty) + distance(tx, ty, ex, ey) - distance(sx, sy, ex, ey))
	if l < 0.01 then
		return true
	else
		return false
	end
end

function checkLine(OsX, OsY, OeX, OeY, TsX, TsY, TeX, TeY)
	a1	= OeY - OsY
	b1	= OsX - OeX
	c1	= a1 * OsX + b1 * OsY

	a2	= TeY - TsY
	b2	= TsX - TeX
	c2	= a2 * TsX + b2 * TsY

	d	= a1 * b2 - a2 * b1

	if d == 0 then
		return false, false
	else
		x = (b2 * c1 - b1 * c2)/d
		y = (a1 * c2 - a2 * c1)/d
		if between(OsX, OsY, OeX, OeY, x, y) then
			if between(TsX, TsY, TeX, TeY, x, y) then
				return x,y
			else
				return false, false
			end
		else
			return false, false
		end
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
			--if not reflect and not scatter then
				return r, g, b, cache
			--elseif reflect and false then -- FIXME: looks weird
			--	angle = angle + math.pi
			--	stepx = math.sin(angle+remap(iter, 0, rays, -(90/fov), (90/fov)))
			--	stepy = math.cos(angle+remap(iter, 0, rays, -(90/fov), (90/fov)))
			--	steps = steps * 2
			--end
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
