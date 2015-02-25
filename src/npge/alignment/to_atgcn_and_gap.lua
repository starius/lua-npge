-- use C version if available
local has_c, cpp = pcall(require,
    'npge.cpp')
if has_c then
    return cpp.func.toAtgcnAndGap
end

return function(text)
    assert(type(text) == 'string')
    return text:upper()
        :gsub('[RYMKWSBVHD]', 'N')
        :gsub('[^ATGCN%-]', '')
end
