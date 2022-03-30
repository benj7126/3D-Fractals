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

function Vector3D:xRot(r)
    return Vector3D:new(
        1*self.x,
        math.cos(r)*self.y-math.sin(r)*self.z,
        math.sin(r)*self.y+math.cos(r)*self.z
    )
end

function Vector3D:yRot(r)
    return Vector3D:new(
        math.cos()
    )
end

function Vector3D:zRot(r)
    return Vector3D:new(
        math.cos()
    )
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