local function Finish(Thread, Success, ...)
    if not Success then
        warn(debug.traceback(Thread, tostring((...))))
    end
 
    return Success, ...
end
 
local function FastSpawn(Function, ...)
    local Thread = coroutine.create(Function)
    return Finish(Thread, coroutine.resume(Thread, ...))
end

return FastSpawn