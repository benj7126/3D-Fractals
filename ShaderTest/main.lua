local pixelcode = [[

    uniform float time;
    uniform float deg1;
    uniform float deg2;
    uniform vec3 xyzOffset;

    uniform vec2 vecForManip[10];

    float infSphere(vec3 pos){
        pos = pos + 1 * vec3(0, -0.5, 1);

        return distance(mod(pos, 2), vec3(1, 1, 1))-0.54321;
    }

    vec4 sphere (vec4 z) {
        float r2 = dot (z.xyz, z.xyz);
        if (r2 < 2.0)
            z *= (1.0 / r2);
        else z *= 0.5;
    
        return z;
    }
      
    // SDF box
    vec3 box (vec3 z) {
        return clamp (z, -1.0, 1.0) * 2.0 - z;
    }
      
    float DE0 (vec3 pos) {
        vec2 m = vec2(0.0);
        vec3 from = vec3 (0.0);
        vec3 z = pos - from;
        float r = dot (pos - from, pos - from) * pow (length (z), 2.0);
        return (1.0 - smoothstep (0.0, 0.01, r)) * 0.01;
    }

    float DE2 (vec3 pos) {
        vec2 m = vec2(0.0);
        // vec3 params = vec3 (0.22, 0.5, 0.5);
        vec3 params = vec3 (vecForManip[0].x+cos(time+vecForManip[2].y)+sin(time+vecForManip[4].y), vecForManip[0].y+cos(time+vecForManip[2].y)+sin(time+vecForManip[4].x), vecForManip[3].x*vecForManip[3].y+cos(time+vecForManip[2].x));
        vec4 scale = vec4 (((-10.0*(vecForManip[1].x+1))*(vecForManip[1].y+1)) * 0.272321);
        vec4 p = vec4 (pos, 1.0), p0 = p;
        vec4 c = vec4 (params, 0.5) - 0.5; // param = 0..1

        for (float i = 0.0; i < 10.0; i++) {
            p.xyz = box (p.xyz);
            p = sphere (p);
            p = p * scale + c;
        }

        return length (p.xyz) / p.w;
        }

    float DE (vec3 pos) {

        float d0 = DE0 (pos);
        float d2 = DE2 (pos);

        return max (d0, d2);
    }

    float rayToSky(vec3 pos)
    {
        vec3 dir = vec3(cos(radians(time+270)), sin(radians(time+270)), 0.1);
        dir = normalize(dir);

        pos = pos + dir;

        int loop = 500;
        float distTraveled = 0;
        float minHitDist = 0.1;
        float minTraceDist = 1000;

        for(int i = 0; i < loop; i++){
            vec3 curPos = pos+distTraveled*dir;

            float distToJump = DE(curPos);
            
            //infSphere(curPos);
            
            //min(distance(vec3(0, 0, 15), curPos)-5, distance(vec3(cos(time*2)*9, sin(time*2)*9, 15), curPos)-3); // 5 is circle rad

            if (distToJump < minHitDist){
                return 1;
            }

            if (distToJump > minTraceDist){
                return 0;
            }

            distTraveled += distToJump;
        }
        
        return 0;
    }

    vec4 effect( vec4 color, Image tex, vec2 texture_coords, vec2 screen_coords )
    {
        texture_coords = vec2(screen_coords.x/600, screen_coords.y/600);
        vec2 texture_coords_center = texture_coords-0.5;

        vec3 ro = xyzOffset;
        vec3 rd = vec3(texture_coords_center.x, texture_coords_center.y, 1);

        float r1 = radians(deg1);
        float r2 = radians(deg2);
        rd *= mat3(
            vec3(1, 0, 0),
            vec3(0, cos(r1), -sin(r1)),
            vec3(0, sin(r1), cos(r1))
        );
        rd *= mat3( // around y
            vec3(cos(r2), 0, sin(r2)),
            vec3(0, 1, 0),
            vec3(-sin(r2), 0, cos(r2))
        );
        // rd *= mat3( // around z
        //    vec3(cos(r), -sin(r), 0),
        //    vec3(sin(r), cos(r), 0),
        //    vec3(0, 0, 1)
        // );

        int loop = 500;
        float distTraveled = 0;
        float minHitDist = 0.001;
        float maxTraceDist = 100;

        float maxRenderDist = 100;

        for(int i = 0; i < loop; i++){
            vec3 curPos = ro+distTraveled*rd;

            //closest point
            float de = DE(curPos);

            //adding floor
            float floorLevel = 5;
            float distToFloor = floorLevel-curPos.y;

            float distToJump = min(distToFloor, de);
            
            //infSphere(curPos);
            
            //min(distance(vec3(0, 0, 15), curPos)-5, distance(vec3(cos(time*2)*9, sin(time*2)*9, 15), curPos)-3); // 5 is circle rad

            if (distToJump < minHitDist){
                float shadows = 0;
                if (distToJump == distToFloor)
                    shadows = rayToSky(curPos);

                float aO = 1.0/(float(i)/10.0);
                return vec4(0.2+aO * cos(curPos.x+(10+time/10))-shadows, 0.2+aO * cos(curPos.y+(20+time/10))-shadows, 0.2+aO * cos(curPos.z+(30+time/10))-shadows, 1);
            }

            if (distToJump > maxTraceDist){
                return vec4(0, 0, 0, 0);
            }

            if (distTraveled > maxRenderDist){
                return vec4(0, 0, 0, 0);
            }

            distTraveled += distToJump;
        }
        
        return vec4(0, 0, 0, 1);
    }
]]

local vertexcode = [[
    vec4 position( mat4 transform_projection, vec4 vertex_position )
    {
        return transform_projection * vertex_position;
    }
]]

local shader = love.graphics.newShader(pixelcode, vertexcode)

local ui = false

love.window.setMode(600, 600)

love.mouse.setGrabbed(true)
love.mouse.setVisible(false)

local plr = {x=0, y=0, z=0, r1=0, r2=0, speed = 10, mouseSen = 8}

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

function love.draw()
    shader:send("time", time)
    shader:send("deg1", plr.r1)
    shader:send("deg2", plr.r2)
    shader:send("xyzOffset", {plr.x, plr.y, plr.z})
    shader:send("vecForManip", unpack(vecForManip))

    love.mouse.setPosition(300, 300)
    love.graphics.setShader(shader)
    love.graphics.rectangle("fill", 0, 0, 800, 600)
    love.graphics.setShader()

    if ui then
        love.graphics.setColor(0.6, 0.6, 0.6)
        love.graphics.rectangle("fill", 5, 5, 100, 20)
        love.graphics.rectangle("fill", 5, 35, 100, 20)

        love.graphics.setColor(0, 0, 0)
        love.graphics.print("Speed: "..math.floor(plr.speed*10)/10, 7, 7)
        love.graphics.print("MSpeed: "..plr.mouseSen, 7, 37)

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
    if ui then
        if love.keyboard.isDown("lshift") then
            plr.mouseSen = plr.mouseSen + y/10
        else
            plr.speed = plr.speed + y/10
        end
    end
end

function love.keypressed(key)
    if key == "u" then
        ui = not ui
    elseif key == "p" then
        paused = not paused
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