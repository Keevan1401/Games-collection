function love.load()
    math.randomseed(os.time())

    sprites = {}
    sprites.background = love.graphics.newImage('sprites/background.png')
    sprites.bullet = love.graphics.newImage('sprites/bullet.png')
    sprites.player = love.graphics.newImage('sprites/player.png')
    sprites.zombie = love.graphics.newImage('sprites/zombie.png')

    player = {}
    player.x = love.graphics.getWidth()/2
    player.y = love.graphics.getHeight()/2
    player.speed = 180

    myFont = love.graphics.newFont(30)

    zombies = {}
    bullets = {}

    gameState = 1
    score = 0
    maxTime = 2
    timer = maxTime
    health = 2
end

function love.update(dt) 
    if gameState == 2 then
        if love.keyboard.isDown("d") and player.x < love.graphics.getWidth() then -- continuously checks if key is down
            player.x = player.x + player.speed*dt
        end

        if love.keyboard.isDown("w") and player.y > 0 then
            player.y = player.y - player.speed*dt
        end

        if love.keyboard.isDown("s") and player.y < love.graphics.getHeight() then
            player.y = player.y + player.speed*dt
        end

        if love.keyboard.isDown("a") and player.x > 0 then
            player.x = player.x - player.speed*dt
        end
    end


    for i,z in ipairs(zombies) do --zombie movement
        z.x = z.x + (math.cos(zombiePlayerAngle(z)) * z.speed * dt)
        z.y = z.y + (math.sin(zombiePlayerAngle(z)) * z.speed * dt)

        if distanceBetween(z.x,z.y,player.x,player.y) < 30 then --game over due to collision between player and zombie
                if health == 1 then
                    for i,z in ipairs(zombies) do
                        zombies[i] = nil
                        gameState = 1
                        player.x = love.graphics.getWidth()/2
                        player.y = love.graphics.getHeight()/2
                    end
                end
            z.dead = true
            health = health - 1 -- second life mechanic
            player.speed = 240
        end
    end

    for i,b in ipairs(bullets) do -- bullet velocity
        b.x = b.x + (math.cos(b.direction + math.pi) * b.speed * dt)
        b.y = b.y + (math.sin(b.direction + math.pi) * b.speed * dt)
    end

    for i=#bullets, 1, -1 do
        local b = bullets[i]
        if b.x < 0 or b.y < 0 or b.x > love.graphics.getWidth() or b.y > love.graphics.getHeight() then --if offscreen
            table.remove(bullets, i) -- get rid of bullet from table
        end
    end

    for i,z in ipairs(zombies) do --compare zombie and bullet distance
        for j,b in ipairs(bullets) do 
            if distanceBetween(z.x, z.y, b.x, b.y) < 20 then
                z.dead = true
                b.dead = true
                score = score + 1
            end
        end
    end

    for i=#zombies, 1, -1 do -- zombies die after being shot
        local z = zombies[i]
        if z.dead == true then
            table.remove(zombies,i)
        end
    end

    for i=#bullets, 1, -1 do -- bullets die after colliding with zombie
        local b = bullets[i]
        if b.dead == true then
            table.remove(bullets,i)
        end
    end

    if gameState == 2 then
        timer = timer - dt
        if timer <= 0 then
            spawnZombie()
            maxTime = 0.95 * maxTime
            timer = maxTime
        end
    end
end

function love.draw()
    love.graphics.draw(sprites.background,0,0)

    if gameState == 1 then
        love.graphics.setFont(myFont)
        love.graphics.printf("Click anywhere to begin!", 0,50,love.graphics.getWidth(),"center")
    end
    love.graphics.printf("Score: ".. score, 0,love.graphics.getHeight()-100, love.graphics.getWidth(),"center")

    if health == 1 then
        love.graphics.setColor(1,0,0)
    end
    love.graphics.draw(sprites.player,player.x,player.y, playerMouseAngle() + math.pi, nil, nil, sprites.player:getWidth()/2, sprites.player:getHeight()/2)
    love.graphics.setColor(1,1,1)
    for i,z in ipairs(zombies) do --drawing all zombies
        love.graphics.draw(sprites.zombie, z.x, z.y,zombiePlayerAngle(z), nil,nil, sprites.zombie:getWidth()/2, sprites.zombie:getHeight()/2)
    end

    for i,b in ipairs(bullets) do --drawing all bullets
        love.graphics.draw(sprites.bullet, b.x, b.y, nil, 0.5, 0.5, sprites.bullet:getWidth()/2, sprites.bullet:getHeight()/2)
    end
end

function love.keypressed(key) -- checks once if key is down
    if key == "space" then
        spawnZombie()
    end
end

function love.mousepressed(x,y,button) -- spawn bullet on left mouse button
    if button == 1 and gameState == 2 then
        spawnBullet()
    elseif button == 1 and gameState == 1 then
        gameState = 2
        maxTime = 2
        timer = maxTime
        score = 0
        player.speed = 180
        health = 2
    end
end

function playerMouseAngle() -- figure out angle between player and mouse in radians
    return math.atan2(player.y - love.mouse.getY(), player.x - love.mouse.getX())
end

function zombiePlayerAngle(enemy) -- figure out angle between zombie and player in radians
    return math.atan2(player.y - enemy.y, player.x - enemy.x)
end

function spawnZombie() -- zombie entities
    local zombie = {}
    zombie.x = 0
    zombie.y = 0
    zombie.speed = 140
    zombie.dead = false

    local side = math.random(1,4) -- chose a side
    if side == 1 then -- left
        zombie.x = -30
        zombie.y = math.random(0,love.graphics.getHeight())

    elseif side == 2 then
        zombie.x = love.graphics.getWidth() + 30
        zombie.y = math.random(0,love.graphics.getHeight())

    elseif side == 3 then
        zombie.x = math.random(0,love.graphics.getWidth())
        zombie.y = -30

    elseif side == 4 then
        zombie.x = math.random(0,love.graphics.getWidth())
        zombie.y = love.graphics.getHeight() + 30
    end

    table.insert(zombies, zombie)
end

function spawnBullet() -- bullet entities
    local bullet = {}
    bullet.x = player.x
    bullet.y = player.y
    bullet.speed = 500
    bullet.dead = false
    bullet.direction = playerMouseAngle()
    table.insert(bullets, bullet)
end

function distanceBetween(x1,y1,x2,y2) -- distance between formula
    return math.sqrt((x2-x1)^2 + (y2-y1)^2)
end