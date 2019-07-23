--WebView外链--
require "os_config"
require "os_string"
win_link = object:new()
local scale = getScale()

local function destroyCallBack(data) --关闭时中插回调
    if (data == nil) then
        return
    end
    local adType = data.adType
    if (adType == nil) then
        return
    end
    local adId = data.adId
    if (adId == nil) then
        return
    end
    if (adType == "os_wedge.lua") then
        Native:sendAction(Native:base64Encode("LuaView://defaultLuaView?template=" .. adType .. "&id=" .. adId .. "&priority=" .. tostring(osHotspotViewPriority)))
        return
    end
end

local function createParent(isPortrait)
    local luaView
    if System.android() then
        luaView = View()
    else
        luaView = ThroughView()
    end
    luaView:backgroundColor(0xFFFFFF)
    local screenWidth, screenHeight = Native:getVideoSize(2)
    if (isPortrait) then
        luaView:frame(0, 0, math.min(screenWidth, screenHeight), math.max(screenWidth, screenHeight))
    else
        luaView:frame(0, 0, math.max(screenWidth, screenHeight), math.min(screenWidth, screenHeight))
    end
    return luaView
end

local function createTopView(isPortrait)
    local topParentView = View()
    local screenWidth, screenHeight = Native:getVideoSize(2)
    if (isPortrait) then
        topParentView:frame(0, 0, math.min(screenWidth, screenHeight), 44 * scale)
    else
        topParentView:frame(0, 0, math.max(screenWidth, screenHeight), 44 * scale)
    end
    local backImageView = Image(Native)
    backImageView:frame(20 * scale, 14.45 * scale, 9.3 * scale, 15.1 * scale)
    backImageView:image(OS_ICON_WIN_LINK_BACK)

    local backTagView = Label()
    backTagView:frame(38 * scale, 0, 50 * scale, 44 * scale)
    backTagView:align(Align.V_CENTER)
    backTagView:textColor(0x555555)
    backTagView:textSize(16)
    backTagView:text("返回")

    topParentView:addView(backImageView)
    topParentView:addView(backTagView)
    return topParentView, backImageView, backTagView
end

local function createWebView(isPortrait)
    local webview = WebView()
    local screenWidth, screenHeight = Native:getVideoSize(2)
    if (isPortrait) then
        webview:frame(0, 44 * scale, math.min(screenWidth, screenHeight), math.max(screenWidth, screenHeight))
    else
        webview:frame(0, 44 * scale, math.max(screenWidth, screenHeight), math.min(screenWidth, screenHeight))
    end
    --webview:pullRefreshEnable(true)
    return webview
end

local function onCreate()
    win_link.luaview = createParent(Native:isPortraitScreen())
    win_link.topParentView, win_link.backImageView, win_link.backTagView = createTopView(Native:isPortraitScreen())
    win_link.webview = createWebView(Native:isPortraitScreen())
    win_link.luaview:addView(win_link.topParentView)
    win_link.luaview:addView(win_link.webview)
    win_link.backImageView:onClick(function()
        Native:destroyView()
        destroyCallBack(win_link.data)
    end)
    win_link.backTagView:onClick(function()
        Native:destroyView()
        destroyCallBack(win_link.data)
    end)
    win_link.topParentView:onClick(function()
        
    end)
end

function show(args)
    if (args == nil) then
        return
    end
    local dataTable = args.data
    if (dataTable == nil) then
        return
    end
    win_link.data = dataTable
    onCreate()
    local linkUrl = dataTable.link
    Native:widgetEvent(3, dataTable.id, dataTable.id, 2, linkUrl)
    if (linkUrl ~= nil) then
        win_link.webview:loadUrl(linkUrl)
    end
end