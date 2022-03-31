local Vector3D = {}

function Vector3D:new(x, y, z)
    local vector = {x=x, y=y, z=z}
    setmetatable(vector, self)
    self.__index = self
    return vector
end

function Vector3D.dist(v1, v2)
    return ((v2.x-v1.x)^2+(v2.y-v1.y)^2+(v2.z-v1.z)^2)^0.5
end

function Vector3D:len()
    return ((self.x)^2+(self.y)^2+(self.z)^2)^0.5
end

function Vector3D:normalize()
    local len = self:len()

    self.x = self.x/len
    self.y = self.y/len
    self.z = self.z/len
end

function Vector3D.cross(v1, v2)
    return Vector3D:new(
        v1.y * v2.z - v1.z * v2.y,
        v1.z * v2.x - v1.x * v2.z,
        v1.x * v2.y - v1.y * v2.x
    )
end

function Vector3D.worldCamRot(vec, pos, front, right, up, w)
    return Vector3D:new(
        right.x*vec.x+up.x*vec.y+front.x*vec.z+pos.x*w,
        right.y*vec.x+up.y*vec.y+front.y*vec.z+pos.y*w,
        right.z*vec.x+up.z*vec.y+front.z*vec.z+pos.z*w
    )
end

function Vector3D:__tostring()
    return self.x .. " | " .. self.y .. " | " .. self.z
end

function Vector3D.cameraRotationCalculation(yaw, pitch)
    local front = Vector3D:new(0, 0, 0)

    front.x = math.cos(math.rad(yaw)) * math.cos(math.rad(pitch))
    front.y = math.sin(math.rad(pitch))
    front.x = math.sin(math.rad(yaw)) * math.cos(math.rad(pitch))

    front:normalize()

    local right = Vector3D.cross(front, Vector3D:new(0, 1, 0))
    right:normalize()

    local up = Vector3D.cross(right, front)
    up:normalize()

    return front, right, up
end

function Vector3D:rotateWithVec(vec)
    self:xRot(vec.x)
    self:yRot(vec.y)
    self:zRot(vec.z)
end

function Vector3D:xRot(r)
    self.x = self.x
    self.y = math.cos(r)*self.y-math.sin(r)*self.z
    self.z = math.sin(r)*self.y+math.cos(r)*self.z
end

function Vector3D:yRot(r)
    self.x = math.cos(r)*self.x+math.sin(r)*self.z
    self.y = self.y
    self.z = -math.sin(r)*self.x+math.cos(r)*self.z
end

function Vector3D:zRot(r)
    self.x = math.cos(r)*self.x-math.sin(r)*self.y
    self.y = math.sin(r)*self.x+math.cos(r)*self.y
    self.z = self.z
end

function Vector3D.__add(v1, v2)
    if type(v2) == "table" then
        return Vector3D:new(
            v1.x+v2.x,
            v1.y+v2.y,
            v1.z+v2.z
        )
    elseif type(v2) == "number" then
        return Vector3D:new(
            v1.x+v2,
            v1.y+v2,
            v1.z+v2
        )
    else
        error("Only numbers and vectors allowed")
    end
end

function Vector3D.__sub(v1, v2)
    if type(v2) == "table" then
        return Vector3D:new(
            v1.x-v2.x,
            v1.y-v2.y,
            v1.z-v2.z
        )
    elseif type(v2) == "number" then
        return Vector3D:new(
            v1.x-v2,
            v1.y-v2,
            v1.z-v2
        )
    else
        error("Only numbers and vectors allowed")
    end
end

function Vector3D.__mod(v1, v2)
    if type(v1) == "number" then
        local save = v1
        v1 = v2
        v2 = save
    end

    if type(v2) == "table" then
        return Vector3D:new(
            v1.x%v2.x,
            v1.y%v2.y,
            v1.z%v2.z
        )
    elseif type(v2) == "number" then
        return Vector3D:new(
            v1.x%v2,
            v1.y%v2,
            v1.z%v2
        )
    else
        error("Only numbers and vectors allowed")
    end
end

function Vector3D.__mul(v1, v2)
    if type(v1) == "number" then
        local save = v1
        v1 = v2
        v2 = save
    end

    if type(v2) == "table" then
        return Vector3D:new(
            v1.x*v2.x,
            v1.y*v2.y,
            v1.z*v2.z
        )
    elseif type(v2) == "number" then
        return Vector3D:new(
            v1.x*v2,
            v1.y*v2,
            v1.z*v2
        )
    else
        error("Only numbers and vectors allowed")
    end
end

function Vector3D.__div(v1, v2)
    if type(v2) == "table" then
        return Vector3D:new(
            v1.x/v2.x,
            v1.y/v2.y,
            v1.z/v2.z
        )
    elseif type(v2) == "number" then
        return Vector3D:new(
            v1.x/v2,
            v1.y/v2,
            v1.z/v2
        )
    else
        error("Only numbers and vectors allowed")
    end
end

return Vector3D