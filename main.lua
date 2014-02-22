require "player/Player"
require "spriteAnimation"
require "camera"

function love.load()
    g = love.graphics
    width = g.getWidth()
    height = g.getHeight()
    g.setBackgroundColor(85, 85, 85)
    groundColor = {25, 200, 25}
    trunkColor = {139, 69, 19}
 
    -- Load player animation
    animation = SpriteAnimation:new("player/robosprites.png", 32, 32, 4, 4)
    animation:load(delay)

    -- restrict the camera
    camera:setBounds(0, 0, width, math.floor(height / 8))
 
    -- instantiate our player and set initial values
    p = Player:new()
   
    p.x = 300 
    p.y = 300
    p.width = 32
    p.height = 32
    p.jumpSpeed = -550
    p.runSpeed = 500
   
    gravity = 1800
    hasJumped = false
    delay = 120
    yFloor = 500
end
 
function love.update(dt)
    -- check controls
    if love.keyboard.isDown("right") then
        p:moveRight()
        animation:flip(false, false)
    end
    if love.keyboard.isDown("left") then
        p:moveLeft()
        animation:flip(true, false)
    end
    if love.keyboard.isDown("x") and not(hasJumped) then
        hasJumped = true
        p:jump()
    end
 
    -- update the player's position
    p:update(dt, gravity)
 
    -- stop the player when they hit the borders
    p.x = math.clamp(p.x, 0, width * 2 - p.width)
    if p.y < 0 then p.y = 0 end
    if p.y > yFloor - p.height then
        p:hitFloor(yFloor)
    end
 
    -- update the sprite animation
    if (p.state == "stand") then
        animation:switch(1, 4, 200)
    end
    if (p.state == "moveRight") or (p.state == "moveLeft") then
        animation:switch(2, 4, 120)
    end
    if (p.state == "jump") or (p.state == "fall") then
        animation:reset()
        animation:switch(3, 1, 300)
    end
    animation:update(dt)
    camera:setPosition(math.floor(p.x - width / 2), math.floor(p.y - height / 2))
end
 
function love.draw()
    camera:set()
    -- round down our x, y values
    local x, y = math.floor(p.x), math.floor(p.y)
 
    -- draw the ground
    g.setColor(groundColor)
    g.rectangle("fill", 0, yFloor, width * 5, height)
 
    -- add a tree!
    g.rectangle("fill", 725, 285, 125, 125)
    g.setColor(trunkColor)
    g.rectangle("fill", 770, 410, 40, 90)
 
    -- draw the player
    g.setColor(255, 255, 255)
    animation:draw(x, y)
 
    camera:unset()

    -- debug information
    g.print("Player coordinates: ("..x..","..y..")", 5, 5)
    g.print("Current state: "..p.state, 5, 20)
end
 
function love.keyreleased(key)
    if key == "escape" then
        love.event.push("quit")  -- actually causes the app to quit
    end
    if (key == "right") or (key == "left") then
        p:stop()
    end
    if (key == "x") then
        hasJumped = false
    end
end

function math.clamp(x, min, max)
    return x < min and min or (x > max and max or x)
end