function moderror(msg)
    error(msg, 0)
end

function modassert(predicate, msg)
    if not predicate then
        moderror(msg)
    end
end
