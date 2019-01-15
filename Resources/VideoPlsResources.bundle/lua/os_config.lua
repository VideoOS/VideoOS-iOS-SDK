object = {}
function object:new(o)
    o = o or {}
    setmetatable(o, self)
    self.__index = self
    return o
end
function getScale()
    local screenW, screenH = System.screenSize()
    return math.min(screenW, screenH) / 375
end
is_iPhoneX = false
if System.ios() then
    NativeScanner = NativeScanner()
    if Native.iPhoneX then
        is_iPhoneX = Native:iPhoneX()
    end
end