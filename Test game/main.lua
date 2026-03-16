--love.load - Variables and tools immediately loaded
function love.load()
    --Libraries

    sounds = {}
    sounds.blip = love.audio.newSource("sounds/blip.wav", "static")
    sounds.music = love.audio.newSource("sounds/music.mp3","stream")
    sounds.music:setLooping(true)
    sounds.music:setVolume(0.5)

    sounds.music:play()

    wf = require 'libraries/windfield'
    world = wf.newWorld(0,0)

    camera = require 'libraries/camera'
    cam = camera()

    anim8 = require 'libraries/anim8'
    love.graphics.setDefaultFilter("nearest", "nearest")

    sti = require'libraries/sti'
    gameMap = sti('maps/test map.lua')

    --Player variables
    player = {}
    player.collider = world:newBSGRectangleCollider(300,250,50,100,10)
    player.collider:setFixedRotation(true)
    player.x = 100
    player.y = 400
    player.size = 0.5
    player.angle = 0
    player.speed = 300
    player.spriteSheet = love.graphics.newImage('sprites/player-sheet.png')
    player.sprite = love.graphics.newImage('sprites/Bluey.png')
    player.grid = anim8.newGrid(12,18, player.spriteSheet:getWidth(), player.spriteSheet:getHeight())

    --Player Animation variables
    player.animations = {}
    player.animations.speed = 0.2
    player.animations.down = anim8.newAnimation(player.grid('1-4',1),player.animations.speed)
    player.animations.left = anim8.newAnimation(player.grid('1-4',2),player.animations.speed)
    player.animations.right = anim8.newAnimation(player.grid('1-4',3),player.animations.speed)
    player.animations.up = anim8.newAnimation(player.grid('1-4',4),player.animations.speed)

    --Starting Animation Direction
    player.anim = player.animations.down

    walls = {}
    if gameMap.layers["Walls"] then
        for i, obj in pairs(gameMap.layers["Walls"].objects) do
            local wall = world:newRectangleCollider(obj.x, obj.y, obj.width, obj.height)
            wall:setType('static') 
            table.insert(walls,wall)
        end
    end

end

--love.update - Items and variables updated every frame
function love.update(dt)
    --Lack of movement detection
    local isMoving = false

    local vx = 0
    local vy = 0

    --Movement controls
    if love.keyboard.isDown("right") then
        vx = player.speed
        player.anim = player.animations.right
        isMoving = true
    end

    if love.keyboard.isDown("left") then
        vx = -1 * player.speed
        player.anim = player.animations.left
        isMoving = true
    end

    if love.keyboard.isDown("down") then
        vy = player.speed
        player.anim = player.animations.down
        isMoving = true
    end

    if love.keyboard.isDown("up") then
        vy = -1 * player.speed
        player.anim = player.animations.up
        isMoving = true
    end

    player.collider:setLinearVelocity(vx,vy)

    --Animation lock if chara not moving
    if isMoving == false then
        player.anim:gotoFrame(2)
    end

    world:update(dt)
    player.x = player.collider:getX()
    player.y = player.collider:getY()
    player.anim:update(dt)

    --Camera effects
    cam:lookAt(player.x,player.y)

    local w = love.graphics.getWidth()
    local h = love.graphics.getHeight()
    
    local mapW = gameMap.width * gameMap.tilewidth
    local mapH = gameMap.height * gameMap.tileheight

    --Left border of map camera limit
    if cam.x < w/2 then
        cam.x = w/2
    end

    --Top border of map camera limit
    if cam.y < h/2 then
        cam.y = h/2
    end

    --Right border of map camera limit
    if cam.x > (mapW - w/2) then
        cam.x = (mapW - w/2)
    end

    --Bottom border of map camera limit
    if cam.y > (mapW - h/2) then
        cam.y = (mapW - h/2)
    end


end

--love.draw - update visuals
function love.draw()
    cam:attach()
        gameMap:drawLayer(gameMap.layers["Ground"])
        gameMap:drawLayer(gameMap.layers["Trees"])
        player.anim:draw(player.spriteSheet, player.x, player.y,0,6,nil,6,9)
        --world:draw() - remove (--) for walls outline
    cam:detach()
end

--love.mousepressed - what happens when mouse is pressed
function love.mousepressed(x,y,button,istouch,presses)
    if button == 1 then
        player.sprite = love.graphics.newImage('sprites/Bluey2.png')
        player.angle = -0.5
    end

end

--love.mousereleased - what happens when mouse is released
function love.mousereleased(x,y,button,istouch,presses)
    if button == 1 then
        player.sprite = love.graphics.newImage('sprites/Bluey.png')
        player.angle = 0
    end

end

function love.keypressed(key)
    if key == "space" then
        sounds.blip:play()
    end

    if key == "m" then
        sounds.music:stop()
    end

    if key == "p" then
        sounds.music:play()
    end
    
end