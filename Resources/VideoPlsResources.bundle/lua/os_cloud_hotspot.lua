--云图--
require "os_config"
require "os_string"
require "os_constant"
require "os_util"
require "os_track"
cloud = object:new()
local adTypeName = "cloud"
local scale = getScale()
local OS_ICON_WEDGE_CLOSE = "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"

local function getHotspotExposureTrackLink(data, index)
    if (data == nil or index == nil) then
        return nil
    end
    local hotspotTrackLinkTable = data.hotspotTrackLink
    if (hotspotTrackLinkTable == nil) then
        return nil
    end
    local indexHotspotTrackLinkTable = hotspotTrackLinkTable[index]
    if (indexHotspotTrackLinkTable == nil) then
        return nil
    end
    return indexHotspotTrackLinkTable.exposureTrackLink
end

local function getHotspotClickTrackLink(data, index)
    if (data == nil or index == nil) then
        return nil
    end
    local hotspotTrackLinkTable = data.hotspotTrackLink
    if (hotspotTrackLinkTable == nil) then
        return nil
    end
    local indexHotspotTrackLinkTable = hotspotTrackLinkTable[index]
    if (indexHotspotTrackLinkTable == nil) then
        return nil
    end
    return indexHotspotTrackLinkTable.clickTrackLink
end

local function closeView()
    if Native:getCacheData(cloud.id) == tostring(eventTypeShow) then
        Native:widgetEvent(eventTypeClose, cloud.id, adTypeName, actionTypeNone, "")
        Native:deleteBatchCacheData({ cloud.id })
    end
    Native:destroyView()
end

local function getLinkUrl(data)
    if (data == nil) then
        return nil
    end
    local dataTable = data.data
    if (dataTable == nil) then
        return nil
    end
    local link = dataTable.linkUrl
    if (link ~= nil and string.match(tostring(link), "http") == "http") then
        return link
    else
        return nil
    end
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

local function isShowClose(data)
    if (data == nil) then
        return false
    end
    local dataTable = data.data
    if (dataTable == nil) then
        return false
    end
    return dataTable.isShowClose
end

local function isNeedShowOnPortrait(data)
    if (data == nil) then
        return true
    end
    local dataTable = data.data
    if (dataTable == nil) then
        return true
    end
    if (dataTable.needShowOnPortrait == nil) then
        return true
    end
    return dataTable.needShowOnPortrait
end

local function getTagImage(data)
    if (data == nil) then
        return nil
    end
    local dataTable = data.data
    if (dataTable == nil) then
        return nil
    end
    return dataTable.imageUrl
end

local function setLuaViewSize(luaview, isPortrait) --设置当前容器大小
    if (luaview == nil) then
        return
    end
    local screenWidth, screenHeight = System.screenSize()
    if (isPortrait) then
        local videoWidth, videoHight = Native:getVideoSize(0)
        luaview:frame(0, 0, math.min(screenWidth, screenHeight), videoHight)
    else
        luaview:frame(0, 0, math.max(screenWidth, screenHeight), math.min(screenWidth, screenHeight))
    end
end

local function checkShowPosition(x, y, w, h, data, isPortrait)
    local maxWidth, maxHeight = 0, 0
    if (isPortrait) then
        maxWidth, maxHeight = Native:getVideoSize(0)
    else
        local screenWidth, screenHeight = System.screenSize()
        maxWidth = math.max(screenWidth, screenHeight)
        maxHeight = math.min(screenWidth, screenHeight)
    end
    if data == nil then
        return 0, 0, 0, 0
    end
    local tempX, tempY, tempWidth, tempHeight = x, y, w, h
    if (isShowClose(data)) then
        tempY = y - 19 * scale
        tempWidth = w + 19 * scale
        tempHeight = h + 19 * scale
    end
    if (isShowAds(data)) then
        --忽略图片宽度小于广告标识（44）的情况
        tempHeight = tempHeight + 5 * scale + 19 * scale
    end
    --不考虑上下同时超出边界的情况
    local top, left, bottom, right = 0, 0, 0, 0
    if Native.safeAreaInsets then
        top, left, bottom, right = Native:safeAreaInsets()
    end
    if tempY < math.max(0, top) then
        y = y + (math.max(0, top) - tempY)
    end
    if tempX < math.max(0, left) then
        x = x + (math.max(0, left) - tempX)
    end
    if tempX + tempWidth > maxWidth - right then
        x = x - (tempX + tempWidth - (maxWidth - right))
    end
    if tempY + tempHeight > maxHeight - bottom then
        y = y - (tempY + tempHeight - (maxHeight - bottom))
    end
    return x, y, w, h
end

local function getLandscapeLocation(data) --获取竖屏位置
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
    local screenWidth, screenHeight = System.screenSize()
    local width = 0
    local height = 0
    local x = 0
    local y = 0
    local scaleWidth = dataTable.width
    if (scaleWidth ~= nil) then
        width = math.max(screenWidth, screenHeight) * scaleWidth
    end
    local ratio = dataTable.ratio
    if (ratio ~= nil) then
        height = width / ratio
    end

    if dataTable._imageUrl ~= nil and dataTable._imageUrl.width ~= nil and dataTable._imageUrl.height ~= nil then
        if dataTable._imageUrl.width <= width and dataTable._imageUrl.height <= height then
            width = dataTable._imageUrl.width
            height = dataTable._imageUrl.height
        else
            if ratio >= (dataTable._imageUrl.width * 1.0 / dataTable._imageUrl.height) then
                width = (dataTable._imageUrl.width * 1.0 / dataTable._imageUrl.height) * height
            else
                height = width / (dataTable._imageUrl.width * 1.0 / dataTable._imageUrl.height)
            end
        end
    end

    local scaleX = dataTable.positionX
    if (scaleX ~= nil) then
        x = math.max(screenWidth, screenHeight) * scaleX
    end
    local scaleY = dataTable.positionY
    if (scaleY ~= nil) then
        y = math.min(screenWidth, screenHeight) * scaleY
    end
    x, y, width, height = checkShowPosition(x, y - height, width, height, data, false)
    cloud.landscapeX = x
    cloud.landscapeY = y
    cloud.landscapeWidth = width
    cloud.landscapeHeight = height
    return cloud.landscapeX, cloud.landscapeY, cloud.landscapeWidth, cloud.landscapeHeight
end

local function setDefaultValue(data) --设置默认大小值
    if (data == nil) then
    end
    data.data.width = 0.12 --横屏宽最大值 160 高120 (分辨率750*1334)
    data.data.ratio = 4.0 / 3.0 -- 160 / 120
    data.data.positionX = 0.037
    data.data.positionY = 0.751
end

local function getPortraitLocation(data) --获取竖屏位置
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
    local screenWidth, screenHeight = System.screenSize()
    local videoWidth, videoHight = Native:getVideoSize(0)
    local sacleW = math.min(screenWidth, screenHeight) / math.max(screenWidth, screenHeight)
    local sacleH = videoHight / math.min(screenWidth, screenHeight)
    local width = 0
    local height = 0
    local x = 0
    local y = 0
    local scaleWidth = dataTable.width
    if (scaleWidth ~= nil) then
        width = math.max(screenWidth, screenHeight) * scaleWidth * sacleW
    end
    local ratio = dataTable.ratio
    if (ratio ~= nil) then
        height = width / ratio
    end

    if dataTable._imageUrl ~= nil and dataTable._imageUrl.width ~= nil and dataTable._imageUrl.height ~= nil then
        if dataTable._imageUrl.width <= width and dataTable._imageUrl.height <= height then
            width = dataTable._imageUrl.width
            height = dataTable._imageUrl.height
        else
            if ratio >= (dataTable._imageUrl.width * 1.0 / dataTable._imageUrl.height) then
                width = (dataTable._imageUrl.width * 1.0 / dataTable._imageUrl.height) * height
            else
                height = width / (dataTable._imageUrl.width * 1.0 / dataTable._imageUrl.height)
            end
        end
    end

    local scaleX = dataTable.positionX
    if (scaleX ~= nil) then
        x = math.max(screenWidth, screenHeight) * scaleX * sacleW
    end
    local scaleY = dataTable.positionY
    if (scaleY ~= nil) then
        y = math.min(screenWidth, screenHeight) * scaleY * sacleH
    end
    x, y, width, height = checkShowPosition(x, y - height, width, height, data, true)
    cloud.portraitX = x
    cloud.portraitY = y
    cloud.portraitWidth = width
    cloud.portraitHeight = height
    return cloud.portraitX, cloud.portraitY, cloud.portraitWidth, cloud.portraitHeight
end

local function getLocation(data, isPortrait)
    if (isPortrait) then
        return getPortraitLocation(data)
    else
        return getLandscapeLocation(data)
    end
end

local function setCloudImageSize(data, cloudImage, isPortrait)
    if (cloudImage == nil) then
        return
    end
    if (data == nil) then
        return
    end
    local x, y, w, h = getLocation(data, isPortrait)
    cloudImage:frame(x, y, w, h)
end

local function rotationScreenAdsButton(data, isPortrait)
    if (data == nil or cloud.adsBtn == nil) then
        return
    end
    local x, y, w, h = getLocation(data, isPortrait)
    --    local width = w * 0.23
    --    local height = width * 0.43
    --    cloud.adsBtn:frame(x + width, y + h + 5 * scale, 44 * scale, 19 * scale)
    --    cloud.adsBtn:adjustFontSize()
    if isPortrait then
        cloud.adsBtn:frame(x, y + h + 5 * scale, 24.2 * scale, 12.5 * scale)
        cloud.adsBtn:textSize(8.33 * scale)
    else
        cloud.adsBtn:frame(x, y + h + 5 * scale, 29 * scale, 15 * scale)
        cloud.adsBtn:textSize(10 * scale)
    end
end

local function rotationScreenCloseButton(data, isPortrait)
    if (data == nil or cloud.closeView == nil) then
        return
    end
    local x, y, w, h = getLocation(data, isPortrait)
    if isPortrait then
        cloud.closeView:frame(x + w, y - 15.8 * scale, 15.8 * scale, 15.8 * scale)
        cloud.closeView:cornerRadius(15.8 * scale / 2)
    else
        cloud.closeView:frame(x + w, y - 19 * scale, 19 * scale, 19 * scale)
        cloud.closeView:cornerRadius(19 * scale / 2)
    end
end

local function needShowOnPortrait(isPortrait)
    if (cloud.luaView == nil) then
        return
    end
    if (cloud.needShowOnPortrait) then
        return
    end
    if (cloud.needShowOnPortrait == nil) then
        return
    end
    if (isPortrait) then
        if (cloud.luaView:isShow()) then
            cloud.luaView:hide()
        end
    else
        if (not cloud.luaView:isShow()) then
            cloud.luaView:show()
        end
    end
end

--屏幕旋转--
local function rotationScreen(isPortrait)
    if (cloud.luaView == nil or cloud.cloudImage == nil or cloud.data == nil) then
        return
    end
    needShowOnPortrait(isPortrait)
    local screenWidth, screenHeight = System.screenSize()
    local tempWidthSide, tempHeightSide
    if (isPortrait) then
        if (not cloud.needShowOnPortrait) then
            cloud.luaView:hide()
        end
    else
        if (cloud.luaView:isShow()) then
            cloud.luaView:show()
        end
    end
    setLuaViewSize(cloud.luaView, isPortrait)
    setCloudImageSize(cloud.data, cloud.cloudImage, isPortrait)
    rotationScreenAdsButton(cloud.data, isPortrait)
    rotationScreenCloseButton(cloud.data, isPortrait)
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

local function fadeIn(view)
    if view == nil then
        return
    end
    view:alpha(0.0)
    Animation():alpha(1.0):duration(2.0):with(view):start()
end

local function createParent(isPortrait)
    local luaView
    if System.android() then
        luaView = View()
    else
        luaView = ThroughView()
    end
    setLuaViewSize(luaView, isPortrait)
    return luaView
end

local function createCloudImage(data, isPortrait) --创建云图控件
    local imageView = Image(Native)
    imageView:scaleType(ScaleType.FIT_XY)
    setCloudImageSize(data, imageView, isPortrait)
    local imageUrl = getTagImage(data)
    if (imageUrl ~= nil) then
        imageView:image(imageUrl, function(status)
            --            if status == true then
            --                if (isShowAds(data)) then
            --                    cloud.adsBtn:show()
            --                end
            --                if (isShowClose(data)) then
            --                    cloud.closeView:show()
            --                end
            --            end
        end)
    end
    return imageView
end

local function createCloudAdsButton(data, isPortrait) --创建底部'广告'标识
    local adsLabel = Label()
    adsLabel:size(44 * scale, 19 * scale)
    adsLabel:textSize(15)
    adsLabel:textAlign(TextAlign.CENTER)
    adsLabel:textColor(0x9B9B9B)
    adsLabel:backgroundColor(0x7D000000)
    adsLabel:text("广告")
    adsLabel:hide()
    return adsLabel
end

local function createCloseButton(data, isPortrait)
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
    return closeView, closeImage
end

local function onCreate(data)
    local showLinkUrl = getHotspotExposureTrackLink(data, 1)
    if (showLinkUrl ~= nil) then
        Native:get(showLinkUrl)
    end
    if (cloud.launchPlanId ~= nil) then
        osTrack(cloud.launchPlanId, 1, 2)
        if (getLinkUrl(data) ~= nil) then
            osTrack(cloud.launchPlanId, 2, 2)
        end
    end
    cloud.needShowOnPortrait = isNeedShowOnPortrait(data)
    local isPortrait = Native:isPortraitScreen()
    cloud.luaView = createParent(isPortrait)
    cloud.adsBtn = createCloudAdsButton(data, isPortrait)
    cloud.closeView, cloud.closeImage = createCloseButton(data, isPortrait)
    cloud.cloudImage = createCloudImage(data, isPortrait)
    rotationScreenAdsButton(data, isPortrait)
    rotationScreenCloseButton(data, isPortrait)

    cloud.closeView:onClick(function()
        closeView()
    end)

    needShowOnPortrait(isPortrait)
    cloud.luaView:addView(cloud.cloudImage)
    cloud.luaView:addView(cloud.adsBtn)
    cloud.luaView:addView(cloud.closeView)
    if (isShowAds(data)) then
        cloud.adsBtn:show()
    end
    if (isShowClose(data)) then
        cloud.closeView:show()
    end
    fadeIn(cloud.luaView)
    cloud.cloudImage:onClick(function()
        local linkUrl = getLinkUrl(data)
        if (linkUrl == nil) then
            return
        end
        Native:widgetEvent(eventTypeClick, cloud.id, adTypeName, actionTypeOpenUrl, linkUrl)
        --lua不打开连接，通知native操作
        --local linkTable = { link = linkUrl, adId = data.id, adType = "os_cloud.lua" }
        --Native:sendAction(Native:base64Encode("LuaView://defaultLuaView?template=" .. "os_win_link.lua" .. "&id=os_cloud" .. "&priority=2"), linkTable)
        closeView()
        local clickLinkUrl = getHotspotClickTrackLink(data, 1)
        if (clickLinkUrl ~= nil) then
            Native:get(clickLinkUrl)
        end
        if (cloud.launchPlanId ~= nil) then
            osTrack(cloud.launchPlanId, 3, 2)
        end
    end)
end

function show(args)
    if (args == nil or cloud.luaView ~= nil) then
        return
    end
    local dataTable = args.data
    if (dataTable == nil) then
        return
    end
    cloud.id = dataTable.id
    cloud.launchPlanId = dataTable.launchPlanId

    setDefaultValue(dataTable)
    Native:widgetEvent(eventTypeShow, cloud.id, adTypeName, actionTypeNone, "") --todo 修改参数为table
    Native:saveCacheData(cloud.id, tostring(eventTypeShow))
    cloud.data = dataTable
    onCreate(dataTable)
    cloud.media = registerMedia()
    cloud.window = registerWindow()
    checkMqttHotspotToSetClose(dataTable, function()
        closeView()
    end)
end