local vertexcode = [[
    vec4 position( mat4 transform_projection, vec4 vertex_position )
    {
        return transform_projection * vertex_position;
    }
]]

local shaders = {}
local selectedShader = 1;

function reloadShaderLib()
    local files = love.filesystem.getDirectoryItems("ShadersToUse")
    shaders = {}
    
    for _, shaderName in pairs(files) do
        local txt, _ = love.filesystem.read("ShadersToUse/"..shaderName)
        local shader = love.graphics.newShader(txt, vertexcode)
    
        table.insert(shaders, {string.gsub(shaderName, '[.*]frag', ""), shader})
    end
end

reloadShaderLib()

local ui = false

love.window.setMode(600, 600)

love.mouse.setGrabbed(true)
love.mouse.setVisible(false)

local plr = {x=0, y=0, z=0, r1=0, r2=0, speed = 2, mouseSen = 4}

local paused = false

local vecForManip = {
    {0, 0}, {0, 0}, {0, 0}, {0, 0}, {0, 0}, 
    {0, 0}, {0, 0}, {0, 0}, {0, 0}, {0, 0}
}

local selectedManip = 1
local time = 0

function love.update(dt)
    if not paused then
        if love.keyboard.isDown("space") then
            time = time + dt*0.1
        elseif love.keyboard.isDown("lctrl") then
            time = time + dt*10
        else
            time = time + dt
        end
    end

    if not ui then
        if love.keyboard.isDown("w") then
            local xm, ym, zm = moveForward()

            plr.x = plr.x + zm*dt*plr.speed
            plr.y = plr.y - ym*dt*plr.speed
            plr.z = plr.z + xm*dt*plr.speed
        end
        if love.keyboard.isDown("s") then
            local xm, ym, zm = moveForward()

            plr.x = plr.x - zm*dt*plr.speed
            plr.y = plr.y + ym*dt*plr.speed
            plr.z = plr.z - xm*dt*plr.speed
        end
        if love.keyboard.isDown("d") then
            local xm, ym, zm = moveRight()

            plr.x = plr.x + zm*dt*plr.speed
            plr.z = plr.z + xm*dt*plr.speed
        end
        if love.keyboard.isDown("a") then
            local xm, ym, zm = moveRight()

            plr.x = plr.x - zm*dt*plr.speed
            plr.z = plr.z - xm*dt*plr.speed
        end
        if love.keyboard.isDown("e") then
            local xm, ym, zm = moveUp()

            plr.x = plr.x - zm*dt*plr.speed
            plr.y = plr.y + ym*dt*plr.speed
            plr.z = plr.z - xm*dt*plr.speed
        end
        if love.keyboard.isDown("q") then
            local xm, ym, zm = moveUp()

            plr.x = plr.x + zm*dt*plr.speed
            plr.y = plr.y - ym*dt*plr.speed
            plr.z = plr.z + xm*dt*plr.speed
        end
    end
end

function love.mousemoved(x, y, mx, my)
    if love.mouse.isGrabbed() then
        if not ui then
            plr.r1 = plr.r1 - my/(8/plr.mouseSen)
            plr.r2 = plr.r2 + mx/(8/plr.mouseSen)
        else
            if love.keyboard.isDown("lshift") then
                vecForManip[selectedManip][1] = math.min(math.max(vecForManip[selectedManip][1] + mx/5000, 0), 1)
                vecForManip[selectedManip][2] = math.min(math.max(vecForManip[selectedManip][2] + my/5000, 0), 1)
            else
                vecForManip[selectedManip][1] = math.min(math.max(vecForManip[selectedManip][1] + mx/500, 0), 1)
                vecForManip[selectedManip][2] = math.min(math.max(vecForManip[selectedManip][2] + my/500, 0), 1)
            end
        end
    end
end

function love.draw()
    local curShader = shaders[selectedShader][2]

    local sendList = {
        {"time", time},
        {"deg1", plr.r1},
        {"deg2", plr.r2},
        {"xyzOffset", {plr.x, plr.y, plr.z}},
        {"vecForManip", unpack(vecForManip)},
    }

    for _, keySet in pairs(sendList) do
        if curShader:hasUniform(keySet[1]) then
            curShader:send(keySet[1], keySet[2])
        end
    end

    if love.mouse.isGrabbed() then
        love.mouse.setPosition(300, 300)
    end

    love.graphics.setShader(curShader)
    love.graphics.rectangle("fill", 0, 0, 800, 600)
    love.graphics.setShader()

    if ui then
        love.graphics.setColor(0.6, 0.6, 0.6)
        love.graphics.rectangle("fill", 5, 5, 100, 20)
        love.graphics.rectangle("fill", 5, 35, 100, 20)
        love.graphics.rectangle("fill", 5, 65, 100, 20)

        love.graphics.setColor(0, 0, 0)
        love.graphics.print(shaders[selectedShader][1], 7, 7)
        love.graphics.print("Speed: "..math.floor(plr.speed*10)/10, 7, 37)
        love.graphics.print("MSpeed: "..math.floor(plr.mouseSen*10)/10, 7, 67)

        for i, vec in pairs(vecForManip) do
            love.graphics.setColor(0.6, 0.6, 0.6)
            if i == selectedManip then
                love.graphics.setColor(0.7, 0.7, 0.7)
            end
            love.graphics.rectangle("fill", 495, 5+(i-1)*30, 100, 20)

            love.graphics.setColor(0, 0, 0)
            love.graphics.print(vec[1] .. " | " .. vec[2], 497, 7+(i-1)*30)
        end

        love.graphics.setColor(0, 0, 0)
        love.graphics.circle("fill", 600*vecForManip[selectedManip][1], 600*vecForManip[selectedManip][2], 10)
        love.graphics.setColor(1, 1, 1)
        love.graphics.circle("fill", 600*vecForManip[selectedManip][1], 600*vecForManip[selectedManip][2], 8)
    end
end

function love.wheelmoved(x, y)
    if love.mouse.isGrabbed() then
        if ui then
            if love.keyboard.isDown("lshift") then
                plr.mouseSen = plr.mouseSen + y/10
            else
                plr.speed = plr.speed + y/10
            end
        end
    end
end

function love.keypressed(key)
    if key == "up" then
        selectedShader = math.min(selectedShader+1, #shaders)
    elseif key == "down" then
        selectedShader = math.max(selectedShader-1, 1)
    elseif key == "u" then
        ui = not ui
    elseif key == "p" then
        paused = not paused
    elseif key == "r" then
        reloadShaderLib()
    else
        local keys = "1234567890"
        for w in string.gmatch(keys, ".") do
            if w == key then
                if w == "0" then
                    w = "10"
                end

                selectedManip = tonumber(w)
            end
        end
    end
end

function moveForward()
    local x = math.cos(math.rad(plr.r2)) * math.cos(math.rad(plr.r1))
    local y = math.sin(math.rad(plr.r1))
    local z = math.sin(math.rad(plr.r2)) * math.cos(math.rad(plr.r1))

    local len = ((x)^2+(y)^2+(z)^2)^0.5;
    return x/len, y/len, z/len
end

function moveRight()
    local x, y, z = moveForward()

    local x2 = -z
    local y2 = 0
    local z2 = x

    local len = ((x2)^2+(y2)^2+(z2)^2)^0.5;
    return x2/len, y2/len, z2/len
end

function moveUp()
    local x, y, z = moveForward()
    local x2, y2, z2 = moveRight()

    local x3 = y * z2 - z * y2
    local y3 = z * x2 - x * z2
    local z3 = x * y2 - y * x2
    local len = ((x3)^2+(y3)^2+(z3)^2)^0.5;
    return x3/len, y3/len, z3/len
end