local Vector3D = require "Vector3D"

local sizes = {w=200, h=200}

love.window.setMode(sizes.w, sizes.h)
love.graphics.setPointSize(1)

local cam = {pos = Vector3D:new(0, 0, 0), speed = 10}

local spheres = {
    {pos = Vector3D:new(0, 0, 30), r = 9},
    {pos = Vector3D:new(9, 0, 30), r = 3},
    {pos = Vector3D:new(-15, 15, 30), r = 9}
}

function love.draw()
    for x = -sizes.w/2,sizes.w/2 do
        for y = -sizes.h/2,sizes.h/2 do
            local ro = cam.pos
            local rd = Vector3D:new(x/sizes.w, y/sizes.h, 1) -- roter den..?

            local distTraveled = 0
            local numberOfSteps = 32
            local minHitDist = 0.001
            local maxTraceDist = 1000

            for i = 1,numberOfSteps do
                local curPos = ro+distTraveled*rd
                local distToClose = closestDistance(curPos)

                if distToClose < minHitDist then
                    love.graphics.setColor(0.2+2/distTraveled, 0.2+2/distTraveled, 0.2+2/distTraveled)
                    love.graphics.points(x+sizes.w/2, y+sizes.h/2)
                    break
                end

                if distToClose > maxTraceDist then
                    break
                end

                distTraveled = distTraveled + distToClose;
            end
        end            
    end
end

function closestDistance(curPos)
    local cD = 9999

    for _, sphere in pairs(spheres) do
        cD = math.min(cD, Vector3D.dist(sphere.pos, curPos)-sphere.r)
    end
    
    return cD
end

function love.update(dt)
    if love.keyboard.isDown("s") then
        cam.pos = cam.pos + Vector3D:new(0, dt*cam.speed, 0)
    end
    if love.keyboard.isDown("w") then
        cam.pos = cam.pos - Vector3D:new(0, dt*cam.speed, 0)
    end
    if love.keyboard.isDown("d") then
        cam.pos = cam.pos + Vector3D:new(dt*cam.speed, 0, 0)
    end
    if love.keyboard.isDown("a") then
        cam.pos = cam.pos - Vector3D:new(dt*cam.speed, 0, 0)
    end
    if love.keyboard.isDown("up") then
        cam.pos = cam.pos + Vector3D:new(0, 0, dt*cam.speed)
    end
    if love.keyboard.isDown("down") then
        cam.pos = cam.pos - Vector3D:new(0, 0, dt*cam.speed)
    end
end