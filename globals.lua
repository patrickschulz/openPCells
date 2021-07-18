function modinfo(msg)
    print(msg)
end

function moderror(msg)
    error(msg, 0)
end

function modwarning(msg)
    print(msg)
end

function modassert(predicate, msg)
    if not predicate then
        moderror(msg)
    end
end
