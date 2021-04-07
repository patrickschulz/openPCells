local M = {}

function M.filter(obj, layers)
    for i, S in obj:iter() do
        if aux.any_of(function(l) return S.lpp:str() == l end, layers) then
            obj:remove_shape(i)
        end
    end
end

return M
