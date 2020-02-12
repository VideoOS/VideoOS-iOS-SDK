require "os_config"
require "os_string"
require "os_constant"
require "os_util"
require "os_track"

cloud = object:new()
local adTypeName = "pauseAd"
local scale = getScale()
local OS_ICON_WEDGE_CLOSE = "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"

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
        Native:widgetEvent(eventType, id, typeName, actionType, actionString)
    end
end

local function getLinkUrl(data)
    if (data == nil) then
        return nil
    end
    local linkData = data.linkData
    if (linkData ~= nil) then
        return linkData
    else
        return nil
    end
end

--[[
    曝光监控
]]
local function exposureTrack(data)
    if (data == nil) then
        return
    end

    if (cloud.launchPlanId ~= nil) then
        osTrack(cloud.launchPlanId, 1, 2)
        if (getLinkUrl(data) ~= nil) then
            osTrack(cloud.launchPlanId, 2, 2)
        end
    end

    local hotspotTrackLinkTable = data.hotspotTrackLink
    if (hotspotTrackLinkTable == nil) then
        return
    end

    for i,v in ipairs(hotspotTrackLinkTable) do
        local showLinkUrl = v.exposureTrackLink
        if (showLinkUrl ~= nil) then
            -- print("luaView showLinkUrl " .. tostring(showLinkUrl))
            Native:get(showLinkUrl)
        end
    end
end

--[[
    点击监控
]]
local function clickTrack(data)
    if (data == nil) then
        return
    end

    if (cloud.launchPlanId ~= nil) then
        osTrack(cloud.launchPlanId, 3, 2)
    end

    local hotspotTrackLinkTable = data.hotspotTrackLink
    if (hotspotTrackLinkTable == nil) then
        return nil
    end

    for i,v in ipairs(hotspotTrackLinkTable) do
        local clickLinkUrl = v.clickTrackLink
        -- print("luaView clickLinkUrl " .. tostring(clickLinkUrl))
        if (clickLinkUrl ~= nil) then
            Native:get(clickLinkUrl)
        end
    end
end

--[[
    获取横屏位置
]]
local function getLandscapeLocation(data)
    if (data == nil) then
        return 0, 0, 0, 0
    end
    local dataTable = data.data
    if (dataTable == nil) then
        return 0, 0, 0, 0
    end
    if (cloud.landscapeWidth ~= nil and cloud.landscapeHeight ~= nil and cloud.landscapeX ~= nil and cloud.landscapeY ~= nil) then
        return cloud.landscapeX, cloud.landscapeY, cloud.landscapeWidth, cloud.landscapeHeight
    end
    local screenWidth, screenHeight = Native:getVideoSize(2)
    local videoWidth = math.max(screenWidth, screenHeight)
    local videoHeight = math.min(screenWidth, screenHeight)
    local width = 0
    local height = 0
    width = videoWidth / 2
    height = width / (videoWidth / videoHeight)

    cloud.landscapeWidth = width
    cloud.landscapeHeight = height
    cloud.landscapeX = (videoWidth - width) / 2
    cloud.landscapeY = (videoHeight - height) / 2
    return cloud.landscapeX, cloud.landscapeY, cloud.landscapeWidth, cloud.landscapeHeight
end

--[[
    获取竖屏位置
]]
local function getPortraitLocation(data)
    if (data == nil) then
        return 0, 0, 0, 0
    end
    local dataTable = data.data
    if (dataTable == nil) then
        return 0, 0, 0, 0
    end
    if (cloud.portraitWidth ~= nil and cloud.portraitHeight ~= nil and cloud.portraitX ~= nil and cloud.portraitY ~= nil) then
        return cloud.portraitX, cloud.portraitY, cloud.portraitWidth, cloud.portraitHeight
    end
    local width = 0
    local height = 0
    local videoWidth, videoHeight = Native:getVideoSize(0)
    width = videoWidth / 2
    height = width / (videoWidth / videoHeight)

    cloud.portraitWidth = width
    cloud.portraitHeight = height
    cloud.portraitX = (videoWidth - width) / 2
    cloud.portraitY = (videoHeight - height) / 2
    return cloud.portraitX, cloud.portraitY, cloud.portraitWidth, cloud.portraitHeight
end

local function getLocation(data, isPortrait)
    if (isPortrait) then
        return getPortraitLocation(data)
    else
        return getLandscapeLocation(data)
    end
end

local function closeView()
    if Native:getCacheData(cloud.id) == tostring(eventTypeShow) then
        widgetEvent(eventTypeClose, cloud.id, adTypeName, actionTypeNone, "")
        Native:deleteBatchCacheData({ cloud.id })
    end
    Native:destroyView()
end

--[[
    更新关闭按钮布局
]]
local function setUpCloseLayout(closeView, isPortrait)
    if (closeView == nil) then
        return
    end

    local x, y, w, _ = getLocation(cloud.data, isPortrait)
    local size = 19 * scale
    closeView:frame(x + w, y - size, size, size)
end

--[[
    更新 luaView 的布局大小和位置
]]
local function setUpLuaViewSize(luaView, isPortrait)
    if (luaView == nil) then
        return
    end
    local screenWidth, screenHeight = Native:getVideoSize(2)
    if (isPortrait) then
        local _, videoHeight, y = Native:getVideoSize(0)
        if System.android() then
            y = 0.0
        end
        luaView:frame(0, y, math.min(screenWidth, screenHeight), videoHeight)
    else
        print("setUpLuaViewSize screenWidth=" .. screenWidth .. " screenHeight=" .. screenHeight)
        luaView:frame(0, 0, math.max(screenWidth, screenHeight), math.min(screenWidth, screenHeight))
    end
end

--[[
    更新广告标识布局
]]
local function setUpAdBtnLayout(adBtn, isPortrait)
    if (adBtn == nil) then
        return
    end

    local x, y, _, _ = getLocation(cloud.data, isPortrait)
    local width, height, textSize
    if isPortrait then
        width = 24.2 * scale
        height = 12.5 * scale
        textSize = 8.33 * scale
    else
        width = 29 * scale
        height = 15 * scale
        textSize = 10 * scale
    end
    adBtn:frame(x, y - height, width, height)
    adBtn:textSize(textSize)
end

local function setUpImageLayout(data, imageView, isPortrait)
    if (imageView == nil) then
        return
    end
    if (data == nil) then
        return
    end
    local x, y, w, h = getLocation(data, isPortrait)
    print("setUpImageLayout x=" .. x .. " y=" .. y .. " w=" .. w .. " h=" .. h .. " isPortrait:" .. tostring(isPortrait))
    imageView:frame(x, y, w, h)
    --imageView:size(w, h)
end

--屏幕旋转--
local function rotationScreen(isPortrait)
    if (cloud.luaView == nil or cloud.cloudImage == nil or cloud.data == nil) then
        return
    end
    setUpLuaViewSize(cloud.luaView, isPortrait)
    setUpImageLayout(cloud.data, cloud.cloudImage, isPortrait)
    setUpAdBtnLayout(cloud.adsBtn, isPortrait)
    setUpCloseLayout(cloud.closeView, isPortrait)
end

--[[
    广告标识
]]
local function createAdsBtn(isPortrait)
    local adsLabel = Label()
    adsLabel:size(44 * scale, 19 * scale)
    adsLabel:textSize(15)
    adsLabel:textAlign(TextAlign.CENTER)
    adsLabel:textColor(0x9B9B9B)
    adsLabel:backgroundColor(0x7D000000)
    adsLabel:text("广告")
    --adsLabel:hide()
    setUpAdBtnLayout(adsLabel, isPortrait)
    return adsLabel
end

--[[
    关闭按钮
]]
local function createCloseBtn(isPortrait)
    local closeView = View()
    closeView:size(19 * scale, 19 * scale)
    closeView:cornerRadius(19 * scale / 2)
    closeView:backgroundColor(0x7D000000)
    local closeImage = Image(Native)
    closeImage:size(7 * scale, 7 * scale)
    closeImage:align(Align.CENTER)
    closeImage:image(Data(OS_ICON_WEDGE_CLOSE))
    closeView:addView(closeImage)
    closeView:hide()
    setUpCloseLayout(closeView, isPortrait)
    return closeView
end

local function isShowAds(data)
    if (data == nil) then
        return false
    end
    local dataTable = data.data
    if (dataTable == nil) then
        return false
    end
    return dataTable.isShowAds
end

--[[
    创建云图控件
]]
local function createCloudImage(dataTable, isPortrait)
    local imageView = Image(Native)
    imageView:scaleType(ScaleType.FIT_XY)
    setUpImageLayout(dataTable, imageView, isPortrait)

    local imageUrl = cloud.cloudData.resUrl
    if (imageUrl ~= nil) then
        imageView:image(imageUrl, function(status, width, height)
            print('cloud image created >>>>>>>>>>>>>>>>>')
            if status == true then
                -- 曝光统计
                cloud.data.data.imageWidth = width
                cloud.data.data.imageHeight = height

                if cloud.data.data._imageUrl ~= nil and cloud.data.data._imageUrl.width ~= nil and cloud.data.data._imageUrl.height ~= nil then
                    cloud.data.data.imageWidth = cloud.data.data._imageUrl.width
                    cloud.data.data.imageHeight = cloud.data.data._imageUrl.height
                end

                local isPortrait = Native:isPortraitScreen()
                rotationScreen(isPortrait)

                if (isShowAds(dataTable)) then
                    cloud.adsBtn:show()
                end

                cloud.closeView:show()

                exposureTrack(cloud.cloudData)

            end
        end)
    end
    return imageView
end

local function registerMedia()
    local media = Media()
    -- body
    -- 注册window callback通知
    local callbackTable = {
        --0: 竖屏小屏幕，1 竖屏全屏，2 横屏全屏
        onPlayerSize = function(type)
            if (type == 0) then
                rotationScreen(true)
            elseif (type == 1) then
                rotationScreen(true)
            elseif (type == 2) then
                rotationScreen(false)
            end
        end,
        onMediaPause = function()
            cloud.luaView:hide()
        end,
        onMediaPlay = function()
            cloud.luaView:show()
        end
    }
    media:mediaCallback(callbackTable)
    return media
end

local function registerWindow()
    local nativeWindow = nil
    if System.ios() then
        nativeWindow = NativeWindow()
    else
        nativeWindow = nativeWindow
    end
    local callbackTable = {
        -- onShow = function()
        --     vote.luaview:show()
        -- end,
        onHide = function()
            if (System.ios()) then
                closeView()
            end
        end,
        onHome = function()
            closeView()
        end
    }
    if (nativeWindow == nil and System.android()) then
        nativeWindow = window
    end
    if (nativeWindow == nil) then
        return
    end
    nativeWindow:callback(callbackTable)
    return nativeWindow
end

--[[
    luaView 根布局
]]
local function createParent(isPortrait)
    local luaView
    if System.android() then
        luaView = View()
    else
        luaView = ThroughView()
    end
    setUpLuaViewSize(luaView, isPortrait)
    return luaView
end

function onCreate(dataTable)
    local isPortrait = Native:isPortraitScreen()
    cloud.luaView = createParent(isPortrait)
    cloud.cloudImage = createCloudImage(dataTable, isPortrait)
    cloud.adsBtn = createAdsBtn(isPortrait)
    cloud.closeView = createCloseBtn(isPortrait)

    cloud.luaView:addView(cloud.cloudImage)
    cloud.luaView:addView(cloud.adsBtn)
    cloud.luaView:addView(cloud.closeView)

    cloud.closeView:onClick(function()
        closeView()
    end)

    cloud.cloudImage:onClick(function()
        local linkData = cloud.cloudData.linkData
        if (linkData == nil) then
            return
        end
        widgetEvent(eventTypeClose, cloud.id, adTypeName, actionTypeOpenUrl, linkData.linkUrl, linkData.deepLink, linkData.selfLink)
        closeView()
        -- 点击统计
        clickTrack(cloud.cloudData)
    end)
end

function show(args)

    print("os_stand_cloud_hot show")
    if (args == nil or cloud.luaView ~= nil) then
        return
    end
    local dataTable = args.data
    if (dataTable == nil) then
        return
    end

    if (dataTable.data == nil) then
        return
    end

    cloud.data = dataTable
    cloud.id = dataTable.id
    cloud.launchPlanId = dataTable.launchPlanId
    cloud.cloudData = dataTable.data.adsList[1]

    if (cloud.cloudData == nil) then
        return
    end

    widgetEvent(eventTypeShow, cloud.id, adTypeName, actionTypeNone, "") --todo 修改参数为table
    Native:saveCacheData(cloud.id, tostring(eventTypeShow))
    onCreate(dataTable)
    cloud.media = registerMedia()
    --cloud.window = registerWindow()
end