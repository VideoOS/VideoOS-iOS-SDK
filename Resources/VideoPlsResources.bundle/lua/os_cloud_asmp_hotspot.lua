--云图--
require "os_config"
require "os_string"
require "os_constant"
require "os_util"
require "os_track"
cloud = object:new()

CLOUD_ID_BUBBLE = "0012"
CLOUD_ID_CHAIN = "0011"
CLOUD_ID_DIALOG = "0013"
CLOUD_ID_MIDDLE = "0014"

local adTypeName = "cloud"
local scale = getScale()
local OS_ICON_WEDGE_CLOSE = "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"

local adsButtonWidth = 22 * scale
local adsButtonHeight = 9 * scale
local closeButtonSize = 19 * scale

local cloudTypeNormal = 0 --普通云图
local cloudTypeBanner = 1 --创可贴(底部 banner)
local cloudTypeEdge = 2 --擎天柱(右侧竖版 banner)
local cloudTypeChain = 3 --文字链
local cloudTypeBubble = 4 -- 气泡帖
local appKey = Native:appKey()
local renrenAppKey = "edf748ef-77ba-4f18-9348-9dc1ec9ba041"


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

local function delay(data)
    if (data == nil) then
        return
    end

    local duration = data.duration
    if (duration ~= nil) then
        if (cloud.timer == nil) then
            cloud.timer = Timer()
        end
        cloud.timer:delay(rounded(duration / 1000.0))
        cloud.timer:callback(function()
            print("delay finish close----------")
            widgetEvent(eventTypeClose, cloud.id, adTypeName, actionTypeNone, "")
            Native:destroyView()
        end)
        cloud.timer:start()
    end
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

    for i, v in ipairs(hotspotTrackLinkTable) do
        local showLinkUrl = v.exposureTrackLink
        if (showLinkUrl ~= nil) then
            -- print("luaView showLinkUrl " .. tostring(showLinkUrl))
            Native:get(showLinkUrl)
        end
    end
end

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

    for i, v in ipairs(hotspotTrackLinkTable) do
        local clickLinkUrl = v.clickTrackLink
        -- print("luaView clickLinkUrl " .. tostring(clickLinkUrl))
        if (clickLinkUrl ~= nil) then
            Native:get(clickLinkUrl)
        end
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

local function getVideoSize(isPortrait)
    local videoWidth, videoHeight
    local screenWidth, screenHeight = Native:getVideoSize(2)
    if (isPortrait) then
        videoWidth, videoHeight = Native:getVideoSize(0)
    else
        videoWidth = math.max(screenWidth, screenHeight)
        videoHeight = math.min(screenWidth, screenHeight)
    end
    return videoWidth, videoHeight;
end

local function isNeedShowOnPortrait(data)
    if (data == nil) then
        return false
    end
    local dataTable = data.data
    if (dataTable == nil) then
        return false
    end
    return dataTable.needShowOnPortrait
end

local function setLuaViewSize(luaview, isPortrait) --设置当前容器大小
    if (luaview == nil) then
        return
    end
    local screenWidth, screenHeight = Native:getVideoSize(2)
    if (isPortrait) then
        local videoWidth, videoHight, y = Native:getVideoSize(0)
        if System.android() then
            y = 0.0
        end
        luaview:frame(0, y, math.min(screenWidth, screenHeight), videoHight)
    else
        luaview:frame(0, 0, math.max(screenWidth, screenHeight), math.min(screenWidth, screenHeight))
    end
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

local function checkShowPosition(x, y, w, h, data, isPortrait)
    local maxWidth, maxHeight = 0, 0
    if (isPortrait) then
        maxWidth, maxHeight = Native:getVideoSize(0)
    else
        local screenWidth, screenHeight = Native:getVideoSize(2)
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
    -- if (cloud.landscapeWidth ~= nil and cloud.landscapeHeight ~= nil and cloud.landscapeX ~= nil and cloud.landscapeY ~= nil) then
    --     return cloud.landscapeX, cloud.landscapeY, cloud.landscapeWidth, cloud.landscapeHeight
    -- end
    local screenWidth, screenHeight = Native:getVideoSize(2)
    local showWidth = 1
    local showHeight = 1
    local width = 1
    local height = 1
    local x = 0
    local y = 0
    local scaleWidth = dataTable.width
    if (scaleWidth ~= nil) then
        showWidth = math.max(screenWidth, screenHeight) * scaleWidth
    end
    local scaleHeight = dataTable.height
    if (scaleHeight ~= nil) then
        showHeight = math.min(screenWidth, screenHeight) * scaleHeight
    end

    local showRatio = showWidth / showHeight

    local imageWidth = dataTable.imageWidth
    local imageHeight = dataTable.imageHeight

    if dataTable._imageUrl ~= nil and dataTable._imageUrl.width ~= nil and dataTable._imageUrl.height ~= nil then
        imageWidth = dataTable._imageUrl.width
        imageHeight = dataTable._imageUrl.height
    end

    local imageRatio = 1.0
    if imageHeight > 0 then
        imageRatio = imageWidth / imageHeight
    end
    if (imageWidth <= 1 or imageHeight <= 1) then
        width = showWidth
        height = showHeight
    else
        if imageWidth <= showWidth and imageHeight <= showHeight then
            width = imageWidth
            height = imageHeight
        elseif imageWidth > showWidth and imageRatio >= showRatio then
            width = showWidth
            height = showWidth / imageRatio
        elseif imageHeight > showHeight and imageRatio < showRatio then
            width = showHeight * imageRatio
            height = showHeight
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
    x, y, width, height = checkShowPosition(x, y, width, height, data, false)
    cloud.landscapeX = x
    cloud.landscapeY = y
    cloud.landscapeWidth = width
    cloud.landscapeHeight = height
    return cloud.landscapeX, cloud.landscapeY, cloud.landscapeWidth, cloud.landscapeHeight
end

local function setDefaultNeedShowOnPortrait(data)
    if (data == nil or data.data == nil) then
        return
    end
    data.data.needShowOnPortrait = true
    if appKey == renrenAppKey then
        data.data.needShowOnPortrait = false
    end
end

local function setDefaultValue(data) --设置默认大小值
    cloud.cloudType = cloudTypeNormal
    data.data.width = 0.22
    data.data.height = 0.28
    data.data.positionX = 0.05
    data.data.positionY = 0.53
    data.data.imageWidth = 1.0
    data.data.imageHeight = 1.0
    data.data.ratio = 0.0
    setDefaultNeedShowOnPortrait(data)
end

local function setCloudType(data)
    if (data == nil) then
        setDefaultValue(data)
        return;
    end

    local dataTable = data.data
    if (dataTable == nil) then
        setDefaultValue(data)
        return;
    end

    local title = data.slogan
    local desc = data.desc
    if (title ~= nil and string.len(title) > 0) then
        if (desc ~= nil and string.len(desc) > 0) then
            cloud.cloudType = cloudTypeBubble
            return
        end
        cloud.cloudType = cloudTypeChain
        return
    end

    local _imageUrl = dataTable._imageUrl
    if (_imageUrl == nil or _imageUrl.width == nil or _imageUrl.height == nil) then
        setDefaultValue(data)
        return;
    end

    cloud.data.data.imageWidth = _imageUrl.width
    cloud.data.data.imageHeight = _imageUrl.height
    if (cloud.data.data.imageWidth == 900 and cloud.data.data.imageHeight == 180) then
        cloud.cloudType = cloudTypeBanner
        setDefaultNeedShowOnPortrait(data)
    elseif (cloud.data.data.imageWidth == 360 and cloud.data.data.imageHeight == 1080) then
        cloud.cloudType = cloudTypeEdge
        setDefaultNeedShowOnPortrait(data)
    else
        setDefaultValue(data)
    end
end

local function getPortraitLocation(data) --获取竖屏位置
    if (data == nil) then
        return 0, 0, 0, 0
    end
    local dataTable = data.data
    if (dataTable == nil) then
        return 0, 0, 0, 0
    end
    -- if (cloud.portraitWidth ~= nil and cloud.portraitHeight ~= nil and cloud.portraitX ~= nil and cloud.portraitY ~= nil) then
    --     return cloud.portraitX, cloud.portraitY, cloud.portraitWidth, cloud.portraitHeight
    -- end
    local screenWidth, screenHeight = Native:getVideoSize(2)
    local videoWidth, videoHight = Native:getVideoSize(0)
    local sacleW = math.min(screenWidth, screenHeight) / math.max(screenWidth, screenHeight)

    local showWidth = 1
    local showHeight = 1
    local width = 1
    local height = 1
    local x = 0
    local y = 0
    local scaleWidth = dataTable.width
    if (scaleWidth ~= nil) then
        showWidth = math.max(screenWidth, screenHeight) * scaleWidth * sacleW
    end
    local scaleHeight = dataTable.height
    if (scaleHeight ~= nil) then
        showHeight = math.min(screenWidth, screenHeight) * scaleHeight * sacleW
    end

    local showRatio = showWidth / showHeight
    local imageWidth = dataTable.imageWidth
    local imageHeight = dataTable.imageHeight

    if dataTable._imageUrl ~= nil and dataTable._imageUrl.width ~= nil and dataTable._imageUrl.height ~= nil then
        imageWidth = dataTable._imageUrl.width
        imageHeight = dataTable._imageUrl.height
    end

    local imageRatio = 1.0

    if imageHeight > 0 then
        imageRatio = imageWidth / imageHeight
    end
    if (imageWidth <= 1 or imageHeight <= 1) then
        width = showWidth
        height = showHeight
    else
        if imageWidth <= showWidth and imageHeight <= showHeight then
            width = imageWidth
            height = imageHeight
        elseif imageWidth > showWidth and imageRatio >= showRatio then
            width = showWidth
            height = showWidth / imageRatio
        elseif imageHeight > showHeight and imageRatio < showRatio then
            width = showHeight * imageRatio
            height = showHeight
        end
    end

    local scaleX = dataTable.positionX
    if (scaleX ~= nil) then
        x = math.max(screenWidth, screenHeight) * scaleX * sacleW
    end
    local scaleY = dataTable.positionY
    if (scaleY ~= nil) then
        y = math.min(screenWidth, screenHeight) * scaleY * sacleW
    end
    x, y, width, height = checkShowPosition(x, y, width, height, data, true)
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

local function adjustEdgeCloudSize(isPortrait)
    if (cloud.cloudImage == nil) then
        return
    end

    local videoWidth, videoHeight = getVideoSize(isPortrait)
    local imgWidth = videoHeight / 3
    cloud.bannerParent:size(imgWidth, videoHeight)
    cloud.cloudImage:size(imgWidth, videoHeight)
    if (deviceType == 1) then
        cloud.bannerParent:xy(videoWidth - imgWidth, 0)
    else
        cloud.luaView:alignRight()
        cloud.bannerParent:alignRight()
    end

end

local function adjustBannerSize(isPortrait)
    if (cloud.bannerParent == nil or cloud.cloudImage == nil) then
        return
    end
    local videoWidth, videoHeight = getVideoSize(isPortrait)
    local imgWidth, imgHeight
    local bannerParentWidth, bannerParentHeight
    imgWidth = videoWidth * 0.35
    imgHeight = imgWidth / 5
    bannerParentWidth = imgWidth + closeButtonSize
    bannerParentHeight = imgHeight + closeButtonSize
    cloud.bannerParent:frame((videoWidth - bannerParentWidth) / 2,
        videoHeight - videoHeight * 0.15 - bannerParentHeight,
        bannerParentWidth, bannerParentHeight)
    cloud.cloudImage:frame(0, closeButtonSize, imgWidth, imgHeight)
end

local function setCloudImageSize(data, cloudImage, isPortrait)
    if (cloudImage == nil) then
        return
    end
    if (data == nil) then
        return
    end
    print("cloud type ==" .. tostring(cloud.cloudType))
    if (cloud.cloudType == cloudTypeNormal) then
        local x, y, w, h = getLocation(data, isPortrait)
        cloudImage:frame(x, y, w, h)
    elseif (cloud.cloudType == cloudTypeBanner) then
        adjustBannerSize(isPortrait)
    else
        adjustEdgeCloudSize(isPortrait)
    end
end

local function rotationScreenAdsButton(data, isPortrait)
    if (data == nil or cloud.adsBtn == nil) then
        return
    end
    local x, y, w, h = getLocation(data, isPortrait)
    if (cloud.cloudType == cloudTypeNormal) then
        cloud.adsBtn:frame(x, y + h + 5 * scale, adsButtonWidth, adsButtonHeight)
    elseif (cloud.cloudType == cloudTypeBanner) then
        local x, y = cloud.bannerParent:xy()
        cloud.adsBtn:xy(x, y + closeButtonSize)
    end
end

local function rotationScreenCloseButton(data, isPortrait)
    if (data == nil or cloud.closeView == nil) then
        return
    end
    if (cloud.cloudType == cloudTypeNormal) then
        local x, y, w, h = getLocation(data, isPortrait)
        cloud.closeView:frame(x + w, y - 19 * scale, closeButtonSize, closeButtonSize)
    elseif (cloud.cloudType == cloudTypeBanner) then
        local x, y = cloud.bannerParent:xy()
        local width, height = cloud.cloudImage:size()
        cloud.closeView:xy(x + width, y)
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
        cloud.luaView:show()
    end
end


--屏幕旋转--
local function rotationScreen(isPortrait)
    needShowOnPortrait(isPortrait)
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
        end
    }
    media:mediaCallback(callbackTable)
    return media
end

local function translateTopIn(view)
    if (view == nil) then
        return
    end
    local width, height = view:size()
    view:translationY(-height)
    return Animation():translationY(0):duration(1.0):with(view)
end

local function translateIn(view) -- content 显示动画
    if (view == nil) then
        return
    end
    local width, height = view:size()
    view:translationX(-width)
    return Animation():translationX(0):duration(1.0):with(view)
end

local function fadeIn(view)
    if view == nil then
        return
    end
    view:alpha(0.0)
    return Animation():alpha(1.0):duration(2.0):with(view)
end

local function startAnimation()
    local animation
    if (cloud.cloudType == cloudTypeNormal) then
        animation = fadeIn(cloud.cloudImage)
    elseif (cloud.cloudType == cloudTypeBanner) then
        animation = translateIn(cloud.cloudImage)
    else
        animation = translateTopIn(cloud.cloudImage)
    end
    animation:callback({
        onStart = function()
        end,
        onCancel = function()
        end,
        onEnd = function()
            if (isShowAds(cloud.data)) then
                cloud.adsBtn:show()
            end
            if (isShowClose(cloud.data)) then
                cloud.closeView:show()
            end
        end,
        onPause = function()
        end,
        onResume = function()
        end,
    }):start()
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


local function createCloudAdsButton(data, isPortrait) --创建底部'广告'标识
    local adsLabel = Label()
    adsLabel:size(adsButtonWidth, adsButtonHeight)
    adsLabel:textSize(7)
    adsLabel:textAlign(TextAlign.CENTER)
    adsLabel:textColor(0x9B9B9B)
    adsLabel:backgroundColor(0x000000, 0.5)
    adsLabel:text("广告")
    adsLabel:hide()
    return adsLabel
end

local function createCloseButton()
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
    return closeView, closeImage
end

local function createCloud(data, isPortrait, closeEvent)
    local imageView = Image(Native)
    imageView:scaleType(ScaleType.FIT_XY)
    local imageUrl = getTagImage(data)
    if (imageUrl ~= nil) then
        imageView:image(imageUrl, function(status, width, height)
            print('cloud image created >>>>>>>>>>>>>>>>>')
            if status == true then

                local isPortrait = Native:isPortraitScreen()
                rotationScreen(isPortrait)

                -- 曝光统计
                exposureTrack(cloud.data)
            end
        end)
    end
    cloud.cloudImage = imageView
    if (cloud.cloudType == cloudTypeBanner or cloud.cloudType == cloudTypeEdge) then
        -- banner 需要要单独的父 View
        cloud.bannerParent = View()
        cloud.bannerParent:addView(cloud.cloudImage)
        cloud.luaView:addView(cloud.bannerParent)
        if (cloud.cloudType == cloudTypeEdge) then
            cloud.bannerParent:addView(cloud.adsBtn)
            cloud.bannerParent:addView(cloud.closeView)
            cloud.adsBtn:align(Align.BOTTOM)
        end
    else
        cloud.luaView:addView(cloud.cloudImage)
    end

    setCloudImageSize(data, imageView, isPortrait)
    startAnimation()
    cloud.cloudImage:onClick(closeEvent)
end

local function sendAction2SideBar(ext)
    cloud.timer:cancel()
    cloud.timer:callback(nil)
    if Native:getCacheData(cloud.id) == tostring(eventTypeShow) then
        widgetEvent(eventTypeClose, cloud.id, adTypeName, actionTypeNone, "")
        Native:deleteBatchCacheData({ cloud.id })
    end
    Native:destroyView()

    ext["linkUrl"] = cloud.data.data.linkData.linkUrl
    ext["deepLink"] = cloud.data.data.linkData.deepLink
    local template = "os_web_side_bar_asmp.lua"
    local id = CLOUD_ID_MIDDLE
    local miniAppId = cloud.data.data.miniAppId
    if (miniAppId == nil or string.len(miniAppId) == 0) then
        if (cloud.data.miniAppInfo ~= nil) then
            miniAppId = cloud.data.miniAppInfo.miniAppId
        end
    end
    print("sendAction miniAppID ::" .. tostring(miniAppId))
    if (miniAppId == nil) then
        Native:sendAction(Native:base64Encode("LuaView://defaultLuaView?template=" .. template ..
                "&id=" .. id .. "&priority=" .. tostring(osInfoViewPriority)), ext)
    else
        Native:sendAction(Native:base64Encode("LuaView://defaultLuaView?template=" .. template ..
                "&id=" .. id .. "&priority=" .. tostring(osInfoViewPriority) .. "&miniAppId=" ..
                miniAppId), ext)
    end
end

local function canOpenMiddle()
    return cloud.ext ~= nil and tonumber(cloud.ext.jump_type) == 2
            and cloud.ext.middle_page_url ~= nil
            and string.len(cloud.ext.middle_page_url) > 0
end

local function onCreate(data)
    cloud.needShowOnPortrait = isNeedShowOnPortrait(data)
    local isPortrait = Native:isPortraitScreen()

    local closeCloud = function()
        if Native:getCacheData(cloud.id) == tostring(eventTypeShow) then
            widgetEvent(eventTypeClose, cloud.id, adTypeName, actionTypeNone, "")
            Native:deleteBatchCacheData({ cloud.id })
        end
        Native:destroyView()
    end

    local closeEvent = function()
        local linkData = cloud.data.data.linkData
        print("linkData::" .. Native:tableToJson(linkData))
        if (linkData == nil) then
            return
        end
        if ((linkData.linkUrl == nil or linkData.linkUrl == "")
                and (linkData.deepLink == nil or linkData.deepLink == "")
                and (linkData.selfLink == nil or linkData.selfLink == "")) then
            return
        end
        --lua不打开连接，通知native操作
        --local linkTable = { link = linkUrl, adId = data.id, adType = "os_cloud.lua" }
        --Native:sendAction(Native:base64Encode("LuaView://defaultLuaView?template=" .. "os_win_link.lua" .. "&id=os_cloud" .. "&priority=2"), linkTable)
        -- 点击统计
        clickTrack(cloud.data)
        if (Native:isPortraitScreen() or not canOpenMiddle()) then
            widgetEvent(eventTypeClick, cloud.id, adTypeName, actionTypeOpenUrl,
                linkData.linkUrl, linkData.deepLink, linkData.selfLink)
            closeCloud()
        else
            sendAction2SideBar(cloud.ext)
        end
    end

    cloud.luaView = createParent(isPortrait)
    cloud.adsBtn = createCloudAdsButton(data, isPortrait)
    cloud.closeView, cloud.closeImage = createCloseButton()
    createCloud(data, isPortrait, closeEvent)
    --    rotationScreenAdsButton(data, isPortrait)
    --    rotationScreenCloseButton(data, isPortrait)
    needShowOnPortrait(isPortrait)
    if (cloud.cloudType ~= cloudTypeEdge) then
        cloud.luaView:addView(cloud.adsBtn)
        cloud.luaView:addView(cloud.closeView)
    end
    cloud.closeView:onClick(closeCloud)
end

local function showHotspot(dataTable)
    cloud.ext = dataTable.ext
    cloud.id = dataTable.id
    cloud.launchPlanId = dataTable.launchPlanId
    setCloudType(dataTable)
    local template
    local cloudId
    if(cloud.ext ~= nil and cloud.ext.bubble ~= nil and table_leng(cloud.ext.bubble) > 0) then
        template = "os_dialog_asmp_hotspot.lua"
        cloudId = cloud.id .. CLOUD_ID_DIALOG
    elseif (cloud.cloudType == cloudTypeChain) then
        template = "os_chain_asmp_hotspot.lua"
        cloudId = cloud.id .. CLOUD_ID_CHAIN
    elseif (cloud.cloudType == cloudTypeBubble) then
        template = "os_bubble_asmp_hotspot.lua"
        cloudId = cloud.id .. CLOUD_ID_BUBBLE
    end
    if (Native:getCacheData(CLOUD_ID_MIDDLE) == tostring(eventTypeShow)) then
        Native:deleteBatchCacheData({ CLOUD_ID_MIDDLE })
        Native:destroyView(CLOUD_ID_MIDDLE)
    end
    if (template ~= nil) then
        Native:destroyView()
        local miniAppId = dataTable.data.miniAppId
        if (miniAppId == nil or string.len(miniAppId) == 0) then
            if (cloud.data.miniAppInfo ~= nil) then
                miniAppId = cloud.data.miniAppInfo.miniAppId
            end
        end
        if (miniAppId == nil) then 
            Native:sendAction(Native:base64Encode("LuaView://defaultLuaView?template=" .. template .. "&id=" .. cloudId .. "&priority=" .. tostring(osInfoViewPriority)), dataTable)
        else
            Native:sendAction(Native:base64Encode("LuaView://defaultLuaView?template=" .. template .. "&id=" .. cloudId .. "&priority=" .. tostring(osInfoViewPriority) .. "&miniAppId=" .. miniAppId), dataTable)
        end
        return
    end

    delay(dataTable)
    cloud.id = dataTable.id
    widgetEvent(eventTypeShow, cloud.id, adTypeName, actionTypeNone, "")
    Native:saveCacheData(cloud.id, tostring(eventTypeShow))

    cloud.media = registerMedia()
    onCreate(dataTable)
end

local function checkHotspotShow(data)

    if (data == nil) then
        return nil
    end

    local paramData = {
        videoId = Native:nativeVideoID(),
        id = data.id,
        launchPlanId = data.launchPlanId,
        createId = data.createId,
        timestamp = data.videoStartTime,
        commonParam = Native:commonParam()
    }

    local paramDataString = Native:tableToJson(paramData)
    local OS_HTTP_POST_CHECK_HOTSPOT = OS_HTTP_HOST .. "/api/notice"

    -- print("[LuaView] "..paramDataString)
    -- print("[LuaView] "..OS_HTTP_POST_CHECK_HOTSPOT)
    -- print("[LuaView] "..Native:aesEncrypt(paramDataString, OS_HTTP_PUBLIC_KEY, OS_HTTP_PUBLIC_KEY))

    local deviceType = 2
    local buId = "videoos"

    if System.ios() then
        deviceType = 1
    end

    cloud.request:post(OS_HTTP_POST_CHECK_HOTSPOT, {
        bu_id = buId,
        device_type = deviceType,
        data = Native:aesEncrypt(paramDataString, OS_HTTP_PUBLIC_KEY, OS_HTTP_PUBLIC_KEY)
    }, function(response, errorInfo)
        -- print("luaview getVoteCountInfo")
        if (response == nil) then
            return
        end
        -- print("luaview getVoteCountInfo 11"..Native:tableToJson(response))
        responseData = Native:aesDecrypt(response.encryptData, OS_HTTP_PUBLIC_KEY, OS_HTTP_PUBLIC_KEY)
        print("luaview " .. responseData)
        response = toTable(responseData)
        if (response.resCode ~= "00") then
            return
        end

        if (response.status == "00") then
            showHotspot(cloud.data)
        else
            Native:destroyView()
        end
    end)
end

local function checkSDKVersion()

    local version = { "1.1.0", "1.2.0", "1.2.1", "1.2.2", "3.0.0" }
    local sdkVersion = Native:sdkVersion()
    for i, v in ipairs(version) do
        if (v == sdkVersion) then
            return true
        end
    end
    return false
end

function show(args)
    if (args == nil) then
        return
    end
    local dataTable = args.data
    if (dataTable == nil) then
        return
    end

    cloud.data = dataTable
    cloud.request = HttpRequest()

    --为ASMP，零时通过内部版本号，检测数据
    if checkSDKVersion() then
        checkHotspotShow(cloud.data)
    else
        showHotspot(cloud.data)
    end
end