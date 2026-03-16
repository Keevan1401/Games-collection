function love.load()
    target = {}
    target.x = 300
    target.y = 300
    target.radius = 50

    newhigh = 0
    score = 0
    highscore = 0
    timer = 0
    gameState = 1

    gameFont = love.graphics.newFont(40)

    sounds = {} -- MUSIC! :D
    sounds.mainmusic = love.audio.newSource("music/lassolady.ogg", "stream")
    sounds.battlemusic = love.audio.newSource("music/Desert_Brawl.wav", "stream")
    sounds.mainmusic:setLooping(true)
    sounds.battlemusic:setLooping(true)
    sounds.mainmusic:setVolume(0.3)
    sounds.battlemusic:setVolume(0.1)

    sprites = {}
    sprites.sky = love.graphics.newImage('sprites/sky.png')
    sprites.crosshair = love.graphics.newImage('sprites/crosshairs.png')
    sprites.target = love.graphics.newImage('sprites/target.png')

    love.mouse.setVisible(false) -- Invisible mouse
end

function love.update(dt)
    if gameState == 1 or gameState == 3 then
        sounds.mainmusic:play()
        sounds.battlemusic:stop()
    elseif gameState == 2 then
        sounds.battlemusic:play()
        sounds.mainmusic:stop()
    end
    if timer > 0 then -- How to decrease timer in game via dt
        timer = timer - dt
    end

    if timer < 0 then
        timer = 0
        gameState = 3 -- Highscore menu
        if score > highscore then -- New highscore menu unlock
            highscore = score
            newhigh = 1 -- New Highscore menu
        end
    end
end

function love.draw()
    love.graphics.draw(sprites.sky, 0, 0) -- Background

    love.graphics.setColor(1,1,1)
    love.graphics.setFont(gameFont)
    if gameState == 2 then
        love.graphics.print("Score: " .. score,5,5) -- Score
        love.graphics.print("Timer: " .. math.ceil(timer),300,5) -- Timer
    end

    if gameState == 1 then -- Main menu
        love.graphics.printf("Click anywhere to start!", 0, 250, love.graphics.getWidth(), "center")
    end

    if gameState == 2 then -- Game
        love.graphics.draw(sprites.target, target.x - target.radius, target.y - target.radius)
    end
    love.graphics.draw(sprites.crosshair, love.mouse.getX() - 20,love.mouse.getY() - 20)

    if gameState == 3 then -- Highscore
        if newhigh == 0 then -- Regular highscore menu
            love.graphics.printf("Score is: ".. score ..", Highscore is: " .. highscore, 0, 250, love.graphics.getWidth(), "center")
        elseif newhigh == 1 then -- New highscore menu
            love.graphics.printf("NEW HIGHSCORE IS: " .. highscore .. "!", 0, 250, love.graphics.getWidth(), "center")
        end
    end
end

function love.mousepressed(x, y, button, istouch, presses)
    if button == 1 and gameState == 2 then -- If clicking in game gamestate
        local mouseToTarget = distanceBetween(x, y, target.x, target.y)
        if mouseToTarget < target.radius then
            score = score + 1 -- Reward for hitting
            target.x = math.random(target.radius, love.graphics.getWidth() - target.radius)
            target.y = math.random(target.radius, love.graphics.getHeight() - target.radius)
        end
        if mouseToTarget > target.radius then -- If not clicking target during gamestate
            target.x = math.random(target.radius, love.graphics.getWidth() - target.radius)
            target.y = math.random(target.radius, love.graphics.getHeight() - target.radius)
            if score > 0 then
                score = score - 1 -- Punishment for missing
            end
        end
    elseif button == 1 and gameState == 1 or gameState == 3 then
        gameState = 2 -- Back to game gamestate
        timer = 10 -- Reset timer
        score = 0 -- Reset score
        newhigh = 0 -- Reset back to normal highscore menu
    end
end

function distanceBetween(x1, y1, x2, y2) -- Distance formula (IMPORTANT)
    return math.sqrt ((x2 - x1)^2 + (y2 - y1)^2)
end

