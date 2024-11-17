function love.load(t)
	-- 
	width = 1280
	height = 720

	-- Create new fonts
	smallfont = love.graphics.newFont("neuropol.ttf", 50)
	mediumfont = love.graphics.newFont("neuropol.ttf", 150)
	largefont = love.graphics.newFont("neuropol.ttf", 350)

	-- Sounds
	blip = love.audio.newSource("blip.wav", "static")

	-- State variable
	state = "intro"
	winner = " "

	-- Create a table to store player variables
	player = {}
	player.width = 10
	player.height = 100
	player.x = 5
	player.y = (height / 2) - player.height / 2 
	player.yvel = 400
	player.score = 0
	-- Create a table to store ai variables
	ai = {}
	ai.width = 10
	ai.height = 100
	ai.x = width - ai.width - 5
	ai.y = (height / 2) - player.height / 2 
	ai.yvel = 200
	ai.score = 0
	-- Create a table to store ball variables
	ball = {}
	ball.width = 20
	ball.height = 20
	ball.x = (width / 2) - ball.width / 2
	ball.y = (height / 2) - ball.width / 2
	ball.yvel = 0
	ball.xvel = 0

end

function love.update(dt)
	-- Depending on game state choose correct update functions
	if state == "intro" then
		updateintro()
	elseif state == "game" then
		-- Update player
		updateplayer(dt)
		-- Update ai
		updateai(dt)
		-- Update ball
		updateball(dt)
	else
		-- Update game over
		updategameover()
	end
end

function love.draw()
	-- Depending on game state choose correct draw functions
	if state == "intro" then
		drawintro()
	elseif state == "game" then
		-- Draw player
		drawplayer()
		-- Draw ai
		drawai()
		-- Draw ball
		drawball()
		-- Draw ui
		drawui()
	else
		-- Draw game over
		drawgameover()
	end
end

function updateintro()
	-- If user presses SPACEBAR start game
	if love.keyboard.isDown("space") then
		state = "game"
		ball.xvel = 400
	end
end

function drawintro()
	-- Draw intro screen
	love.graphics.setFont(mediumfont)
	love.graphics.print("Pong", 400, 100)
	love.graphics.setFont(smallfont)
	love.graphics.print("by Mouse", 475, 220)
	love.graphics.print("Press SPACEBAR to start!", 300, 380)
end

function drawui()
	-- Draw line down center
	love.graphics.line(width / 2, 0, width / 2 , height)
	-- Draw scores
	love.graphics.setFont(smallfont)
	love.graphics.print(player.score, 150, 0)
	love.graphics.print(ai.score, width - 150, 0)
end

function updateplayer(dt)
	-- Check player input
	if love.keyboard.isDown("w") or love.keyboard.isDown("up") then
		player.y = player.y - player.yvel * dt
	elseif love.keyboard.isDown("s") or love.keyboard.isDown("down") then
		player.y = player.y + player.yvel * dt
	end

	-- Check player boundary
	if player.y < 0 then
		player.y = 0
	elseif player.y + player.height > height then
		player.y = height - player.height
	end
end

function drawplayer()
	-- Draw player paddle as simple rectangle
	love.graphics.rectangle("fill", player.x, player.y, player.width, player.height)
end

function updateai(dt)
	-- Move ai paddle only when balls is moving toward ai and paddle is not aligned with ball
	if ball.y + ball.height / 2 > ai.y + ai.height / 2 and ball.xvel < 0 then
		ai.y = ai.y + ai.yvel * dt
	end
	if ball.y + ball.height / 2 < ai.y + ai.height / 2 and ball.xvel < 0 then
		ai.y = ai.y - ai.yvel * dt
	end

	-- Check ai boundary
	if ai.y < 0 then
		ai.y = 0
	elseif ai.y + ai.height > height then
		ai.y = height - ai.height
	end
	
end

function drawai()
	-- Draw ai paddle as simple rectangle
	love.graphics.rectangle("fill", ai.x, ai.y, ai.width, ai.height)
end

function updateball(dt)
	-- Update ball position
	ball.x = ball.x - ball.xvel * dt
	ball.y = ball.y + ball.yvel * dt
	-- Check ball boundary
	if ball.y < 0 then
		ball.y = 0
		ball.yvel = -ball.yvel
	end
	if ball.y + ball.height > height then
		ball.y = height - ball.height
		ball.yvel = -ball.yvel
	end
	-- If ball gets past player
	if ball.x < 0 then
		ai.score = ai.score + 1
		ball.x = (width / 2) - ball.width / 2
		ball.y = (height / 2) - ball.width / 2
		ball.xvel = -ball.xvel
		ball.yvel = 0
	end
	-- If ball gets past aie
	if ball.x > width then
		player.score = player.score + 1
		ball.x = (width / 2) - ball.width / 2
		ball.y = (height / 2) - ball.width / 2
		ball.xvel = -ball.xvel
		ball.yvel = 0
	end

	-- Check if ball hits player (AABB collision test)
	if ball.x < player.x + player.width and 
	   ball.x + ball.width > player.x and
	   ball.y < player.y + player.height and
	   ball.y + ball.height > player.y and ball.xvel > 0 then
	   collisionpoint = (ball.y + ball.height / 2) - (player.y + player.height / 2)
	   ball.yvel = collisionpoint * 10
	   ball.xvel = -ball.xvel
	   love.audio.play(blip)
	end
	-- Check if ball hits ai (AABB collision test)
	if ball.x < ai.x + ai.width and 
	   ball.x + ball.width > ai.x and
	   ball.y < ai.y + ai.height and
	   ball.y + ball.height > ai.y and ball.xvel < 0 then
	   ball.xvel = -ball.xvel
	   love.audio.play(blip)
	end
	-- Once 5 scores game over
	if ai.score == 5 then
		state = "gameover"
		winner = "ai"
	elseif player.score == 5 then
		state = "gameover"
		winner = "player"
	end

end

function drawball()
	-- Draw ball as simple rectangle
	love.graphics.rectangle("fill", ball.x, ball.y, ball.width, ball.height)
end

function updategameover()
end

function drawgameover()
	love.graphics.setFont(mediumfont)
	love.graphics.print("Game Over!", 175, 200)
	if winner == "player" then
		love.graphics.print("Winner!", 325, 400)	
	end
	if winner == "ai" then
		love.graphics.print("Loser!", 325, 400)	
	end
end
