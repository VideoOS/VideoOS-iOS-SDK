object = {}
function object:new(o)
    o = o or {}
    setmetatable(o, self)
    self.__index = self
    return o
end
helloworld = object:new()


local function setLuaViewSize(luaView)
    --设置当前容器大小
    if (luaView == nil) then
        return
    end
    local containerWidth, containerHeight = Applet:appletSize()
    luaView:frame(0, 0, math.min(containerWidth, containerHeight), math.max(containerWidth, containerHeight))
end
--全局父控件
local function createLuaView()
    local luaView
    if System.android() then
        luaView = View()
    else
        luaView = ThroughView()
    end
    setLuaViewSize(luaView)
    return luaView
end

local function createTitle()
    local titleLabel = Label()
    titleLabel:textColor(0xFF0000)
    titleLabel:textSize(16)
    titleLabel:text("HelloWorld")
    titleLabel:frame(0, 0, 100, 30)
    titleLabel:align(Align.V_CENTER)
    titleLabel:align(Align.H_CENTER)
    return titleLabel
end

-- 小程序的入口方法
function show(args)
    local isPortrait = Native:isPortraitScreen()
    if isPortrait then
        return
    end
    helloworld.luaView = createLuaView()
    helloworld.titleLabel = createTitle()
    helloworld.luaView:addView(helloworld.titleLabel)
end
