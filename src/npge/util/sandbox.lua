-- lua-npge, Nucleotide PanGenome explorer (Lua module)
-- Copyright (C) 2014-2016 Boris Nagaev
-- See the LICENSE file for terms of use.

-- based on http://stackoverflow.com/a/6982080

-- takes code of Lua function
-- return the function sandboxed using environment env

return function(env, code)
    assert(type(env) == 'table')
    if type(code) ~= 'string' then
        return nil, 'Type of code should be string'
    end
    if code:byte(1) == 27 then
        return nil, 'Bytecode is not allowed'
    end
    assert(_VERSION == 'Lua 5.1' or _VERSION == 'Lua 5.2' or
        _VERSION == 'Lua 5.3',
        'Implemented in Lua 5.1, 5.2 and 5.3 only')
    if _VERSION == 'Lua 5.2' or _VERSION == 'Lua 5.3' then
        return _G.load(code, 'sandbox', 't', env)
    elseif _VERSION == 'Lua 5.1' then
        local f, message = _G.loadstring(code, 'sandbox')
        if not f then
            return nil, message
        end
        _G.setfenv(f, env)
        return f
    end
end
