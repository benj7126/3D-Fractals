local Vector3D = require "Vector3D"

local sizes = {w=200, h=200}

love.window.setMode(sizes.w, sizes.h)
love.graphics.setPointSize(1)

local cam = {
    pos = Vector3D:new(0, 0, 0), speed = 10, yaw = 0, pitch = 0,
    front = Vector3D:new(0, 0, 0), right = Vector3D:new(0, 0, 0), up = Vector3D:new(0, 0, 0)}

local spheres = {
    {pos = Vector3D:new(0, 0, 30), r = 9},
    {pos = Vector3D:new(9, 0, 30), r = 3},
    {pos = Vector3D:new(-15, 15, 30), r = 9}
}

function love.draw()
    for x = -sizes.w/2,sizes.w/2 do
        for y = -sizes.h/2,sizes.h/2 do
            --local ro = Vector3D.worldCamRot(cam.pos, cam.pos, cam.front, cam.right, cam.up, 1)
            --local rd = Vector3D.worldCamRot(Vector3D:new(x/sizes.w, y/sizes.h, 1), cam.pos, cam.front, cam.right, cam.up, 0) -- ray direction

            local ro = cam.pos
            local rd = Vector3D:new(x/sizes.w, y/sizes.h, 1)

            local distTraveled = 0
            local numberOfSteps = 32
            local minHitDist = 0.001
            local maxTraceDist = 100

            for i = 1,numberOfSteps do
                local curPos = ro+distTraveled*rd
                local distToClose = weirdShapeDist(curPos)

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

function infSphereDist(curPos)
    local pos = curPos + 1 * Vector3D:new(0, -0.5, 1)

    local d1 = Vector3D.dist(pos%2, Vector3D:new(1, 1, 1))-0.54321
    
    return d1
end

function weirdShapeDist(curPos)

    local Power = 2
    local Iterations = 1
    local Bailout = 99

    local z = curPos;
    local dr = 1.0;
    local r = 0.0;
    for i = 0, Iterations do
        r = z:len();
        if r > Bailout then break end
        
        -- convert to polar coordinates
        local theta = math.acos(z.z/r);
        local phi = math.atan(z.y,z.x);
        dr =  r^(Power-1.0)*Power*dr + 1.0;
        
        -- scale and rotate the point
        local zr = r^Power
        theta = theta*Power
        phi = phi*Power
        
        -- convert back to cartesian coordinates
        z = zr*Vector3D:new(math.sin(theta)*math.cos(phi), math.sin(phi)*math.sin(theta), math.cos(theta));
        z=z+curPos;
    end
    return 0.5*math.log(r)*r/dr;
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
    if love.keyboard.isDown("q") then
        cam.yaw = cam.yaw + dt
    end
    if love.keyboard.isDown("e") then
        cam.yaw = cam.yaw - dt
    end
    if love.keyboard.isDown("r") then
        cam.pitch = cam.pitch + dt
    end
    if love.keyboard.isDown("t") then
        cam.pitch = cam.pitch - dt
    end

    cam.front, cam.right, cam.up = Vector3D.cameraRotationCalculation(cam.yaw, cam.pitch)
end