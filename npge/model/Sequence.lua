
local Sequence = {}

local Sequence_mt = {}

Sequence_mt.__call = function(self, name, text, description)
    local mt = {}
    mt.name = function()
        return name
    end
    mt.text = function()
        return text
    end
    mt.description = function()
        return description
    end
    mt.size = function()
        return #text
    end
    mt.at = function(self, index)
        return text:sub(index + 1, index + 1)
    end
    mt.__index = mt
    return setmetatable({}, mt)
end

return setmetatable(Sequence, Sequence_mt)
