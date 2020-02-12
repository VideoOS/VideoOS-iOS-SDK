--
-- Create by bolo on 2019/12/27
--
require "os_config"
require "os_string"
require "os_constant"
require "os_util"
require "os_track"

sideBar = object:new()

local DEEPLINK_H5_URL = "http://op-plat.videojj.com/toufangzhongjianye/deeplink.html"
local OS_ICON_WEDGE_CLOSE = "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"
local CLOUD_ID_MIDDLE = "0014"

local adTypeName = "cloud"
local scale = getScale()
local sideBarWidth
local sideBarHeight

local function widgetEvent(eventType, adID, adName, actionType, linkUrl, deepLink, selfLink)

    local actionString = ""
    if (linkUrl ~= nil and string.len(linkUrl) > 0) then
        actionString = linkUrl
    elseif (deepLink ~= nil and string.len(deepLink) > 0) then
        actionString = deepLink
    elseif (selfLink ~= nil and string.len(selfLink) > 0) then
        actionString = selfLink
    end

    if Native.widgetNotify then

        local notifyTable = {}

        notifyTable["eventType"] = eventType
        notifyTable["adID"] = adID
        notifyTable["adName"] = adName
        notifyTable["actionType"] = actionType
        notifyTable["actionString"] = actionString

        if (linkUrl ~= nil) then
            notifyTable["linkUrl"] = linkUrl
        end

        if (deepLink ~= nil) then
            notifyTable["deepLink"] = deepLink
        end

        if (selfLink ~= nil) then
            notifyTable["selfLink"] = selfLink
        end

        Native:widgetNotify(notifyTable)
    else
        Native:widgetEvent(eventType, adID, adName, actionType, actionString)
    end
end

local function onEventTrack(key)
    if (sideBar.data.middle_page_st == nil) then
        return
    end
    local trackLink = sideBar.data.middle_page_st[key]
    print("exposureLink::" .. tostring(trackLink))
    if (trackLink == nil) then
        return
    end
    Native:get(trackLink)
end

local function getVideoSize()
    local videoWidth, videoHeight = Native:getVideoSize(2)
    local w, h
    w = math.max(videoWidth, videoHeight)
    h = math.min(videoWidth, videoHeight)
    sideBarWidth = 178 * scale
    sideBarHeight = 210 * scale
    return w, h
end

local function rotationScreen(isPortrait)
    if (isPortrait) then
        if (System.ios()) then
            sideBar.sideBarView:hide()
        else
            sideBar.webView:hide()
            sideBar.button:hide()
        end
        sideBar.closeView:hide()
    else
        if (System.ios()) then
            sideBar.sideBarView:show()
        else
            sideBar.webView:show()
            sideBar.button:show()
        end
        sideBar.closeView:show()
    end
end

local function registerMedia()
    local media = Media()
    -- body
    -- 注册window callback通知
    local callbackTable = {
        --0: 竖屏小屏幕，1 竖屏全凭，2 横屏全屏
        onPlayerSize = function(type)
            if (type == 0) then
                rotationScreen(true)
            elseif (type == 1) then
                rotationScreen(true)
            elseif (type == 2) then
                rotationScreen(false)
            end
        end
    }
    media:mediaCallback(callbackTable)
    return media
end

local function closeAnimation()
    Native:deleteBatchCacheData({ CLOUD_ID_MIDDLE })
    local distance = sideBarWidth
    local view
    if (System.ios()) then
        view = sideBar.sideBarView
    else
        view = sideBar.webView
        Animation():translationX(distance):duration(0.5):with(sideBar.button):start()
    end
    Animation():translationX(distance):duration(0.5):with(view):onEnd(function()
        Native:destroyView()
    end):start()
end

local function startAnimation()
    local view
    if (System.ios()) then
        view = sideBar.sideBarView
    else
        view = sideBar.webView
        sideBar.webView:translationX(sideBarWidth)
        sideBar.button:translationX(sideBarWidth)
        Animation():translationX(0):duration(0.5):with(sideBar.button):start()
    end
    Animation():translationX(0):duration(0.5):with(view):onEnd(function()
        onEventTrack("page_load")
        onEventTrack("button_show")
        if (not Native:isPortraitScreen()) then
            sideBar.closeView:show()
        end
    end):start()
end

local function setLuaViewSize(luaview, isPortrait) --设置当前容器大小
    if (luaview == nil) then
        return
    end
    local screenWidth, screenHeight = Native:getVideoSize(2)
    if (isPortrait) then
        local _, videoHight, y = Native:getVideoSize(0)
        if System.android() then
            y = 0.0
        end
        luaview:frame(0, y, math.min(screenWidth, screenHeight), videoHight)
    else
        luaview:frame(0, 0, math.max(screenWidth, screenHeight), math.min(screenWidth, screenHeight))
    end
end

local function createButton()
    local buttonHeight = 30 * scale
    sideBar.button = GradientView()
    sideBar.button:gradient(0xfad15b, 0xf67a27)

    local textSize = 12
    local label = Label(Native)
    label:textSize(textSize)
    label:textColor(0x000000)
    label:textAlign(TextAlign.CENTER)
    label:textBold()
    sideBar.button:addView(label)

    local text = "打开淘宝APP"
    label:text(text)
    if (System.ios()) then
        sideBar.button:frame(0, sideBarHeight - buttonHeight, sideBarWidth, buttonHeight)
        sideBar.sideBarView:addView(sideBar.button)
        label:size(sideBarWidth, buttonHeight)
        label:align(Align.CENTER)
    else
        sideBar.button:align(Align.RIGHT, Align.BOTTOM)
        label:align(Align.CENTER)
        local _, videoHeight = getVideoSize()
        sideBar.button:size(sideBarWidth, 30 * scale)
        sideBar.button:margin(0, 0, 0, (videoHeight - sideBarHeight) / 2)
        sideBar.button:corner(0, 0, 0, 0, 0, 0, scale * 10, scale * 10)
    end
    sideBar.button:onClick(function()
        onEventTrack("button_click")
        local deepLink = sideBar.data.deepLink
        local linkUrl = sideBar.data.linkUrl
        local extraLink
        if (deepLink == nil or string.len(deepLink) <= 0) then
            if(linkUrl == nil or string.len(linkUrl) <= 0) then
                return
            end
            extraLink = linkUrl
        end
        if (extraLink == nil or string.len(extraLink) <= 0) then
            extraLink = DEEPLINK_H5_URL  .. "?deeplink=" .. Native:encode(deepLink)
                    .. "&url=" .. Native:encode(linkUrl)
        end
        print("middel button on tap ::" .. tostring(extraLink))
        widgetEvent(eventTypeClick, "", adTypeName, actionTypeOpenUrl, extraLink, "", "")
        closeAnimation()
    end)
end

local function createWebViewAndroid()
    sideBar.webView = WebView()
    sideBar.luaView:addView(sideBar.webView)
    sideBar.webView:align(Align.RIGHT, Align.BOTTOM)
    sideBar.luaView:alignRight()
    local _, videoHeight = getVideoSize()
    sideBar.webView:size(sideBarWidth, sideBarHeight - 30 * scale)
    sideBar.webView:margin(0, 0, 0,
        (videoHeight - sideBarHeight) / 2 + 30 * scale)

    createButton()
end

local function createWebViewIOS()

    -- ios 需要圆角
    sideBar.sideBarView = GradientView()
    sideBar.webView = WebView()
    sideBar.sideBarView:corner(scale * 10, scale * 10, 0, 0, 0, 0, scale * 10, scale * 10)
    local videoWidth, videoHeight = getVideoSize()
    sideBar.sideBarView:frame(videoWidth - sideBarWidth, (videoHeight - sideBarHeight) / 2,
        sideBarWidth, sideBarHeight)
    sideBar.sideBarView:addView(sideBar.webView)
    sideBar.webView:size(sideBarWidth, sideBarHeight - 30 * scale)
    -- button
    createButton()

    sideBar.sideBarView:translationX(sideBarWidth)
end

local function createLuaView(isPortrait)
    local luaView
    if System.android() then
        luaView = View()
    else
        luaView = ThroughView()
    end
    setLuaViewSize(luaView, isPortrait)
    return luaView
end

local function createCloseView()
    local closeButtonSize = 19 * scale
    local closeView = View()
    closeView:size(closeButtonSize, closeButtonSize)
    closeView:cornerRadius(19 * scale / 2)
    closeView:backgroundColor(0x000000, 0.5)
    local closeImage = Image(Native)
    closeImage:size(7 * scale, 7 * scale)
    closeImage:align(Align.CENTER)
    closeImage:image(Data(OS_ICON_WEDGE_CLOSE))
    closeView:addView(closeImage)
    closeView:hide()

    local videoWidth, videoHeight = getVideoSize()
    if (System.ios()) then
        closeView:xy(videoWidth - 25 * scale, (videoHeight - sideBarHeight) / 2 + 6 * scale)
    else
        closeView:align(Align.RIGHT)
        closeView:margin(0, (videoHeight - sideBarHeight) / 2 + 6 * scale, 6 * scale, 0)
    end
    sideBar.closeView = closeView
end

local function onCreate()
    local isPortrain = Native:isPortraitScreen()

    sideBar.luaView = createLuaView(isPortrain)
    if (System.ios()) then
        createWebViewIOS()
    else
        createWebViewAndroid()
    end
    local middelUrl = sideBar.data.middle_page_url .."?" .. os.date("%Y-%m-%d-%H:%M:%S")
    print("middleUrl::" .. tostring(middelUrl))
    sideBar.webView:loadUrl(middelUrl)
    createCloseView()
    sideBar.closeView:onClick(function()
        sideBar.closeView:hide()
        closeAnimation()
    end)
    if (isPortrain) then
        rotationScreen(isPortrain)
    end
    startAnimation()
    Native:saveCacheData(CLOUD_ID_MIDDLE, tostring(eventTypeShow))
end

function show(args)
    print("web side bar show 11111111111" .. Native:tableToJson(args))
    if (args == nil) then
        return
    end
    local dataTable = args.data
    if (dataTable == nil) then
        return
    end
    sideBar.data = dataTable
    registerMedia()
    onCreate()
end