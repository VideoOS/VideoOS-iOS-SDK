--
-- Created by IntelliJ IDEA.
-- User: videojj_pls
-- Date: 2018/10/25
-- Time: 10:11 AM
-- To change this template use File | Settings | File Templates.
--
require "os_config"
require "os_string"
require "os_constant"
require "os_util"
require "os_track"
baike = object:new()
local adTypeName = "baike"
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
    if Native:getCacheData(baike.id) == tostring(eventTypeShow) then
        Native:widgetEvent(eventTypeClose, baike.id, adTypeName, actionTypeNone, "")
        Native:deleteBatchCacheData({ baike.id })
    end
    Native:destroyView()
end
local function translationAnim(x, y)
    local anim = Animation():translation(x, y):duration(0.3)
    return anim
end

local function startViewTranslationAnim(view, x, y, table)
    if (view == nil) then
        return
    end
    if table ~= nil then
        translationAnim(x, y):with(view):callback(table):start()
    else
        translationAnim(x, y):with(view):start()
    end
end

local function configSize(data)
    if (data == nil) then
        return
    end
    local dataTable = data.data
    if (dataTable == nil) then
        return
    end
    local isShowClose = dataTable.isShowClose
    if (isShowClose ~= nil) then
        baike.isShowClose = isShowClose
    else
        baike.isShowClose = false
    end
    local isShowAds = dataTable.isShowAds
    if (isShowAds ~= nil) then
        baike.isShowAds = isShowAds
    else
        baike.isShowAds = false
    end
    dataTable.ratio = 1.253
    dataTable.width = 0.36
    dataTable.positionX = 0.56
    dataTable.positionY = 0.531
    local screenWidth, screenHeight = Native:getVideoSize(2)
    local videoWidth, videoHight, y = Native:getVideoSize(0)
    baike.portraitWidth = screenWidth
    baike.portraitHeight = videoHight
    baike.landscapeWidth = math.max(screenWidth, screenHeight)
    baike.landscapeHeight = math.min(screenWidth, screenHeight)
end

local function getPortraitLocation(data)
    if (data == nil) then
        return 0, 0, 0, 0
    end
    local dataTable = data.data
    if (dataTable == nil) then
        return 0, 0, 0, 0
    end

    if (baike.portraitWidth ~= nil and baike.portraitHeight ~= nil and baike.portraitX ~= nil and baike.portraitY ~= nil) then
        return baike.portraitX, baike.portraitY, baike.portraitWidth, baike.portraitHeight
    end
    local screenWidth, screenHeight = Native:getVideoSize(2)
    local videoWidth, videoHight = Native:getVideoSize(0)
    local sacleW = math.min(screenWidth, screenHeight) / math.max(screenWidth, screenHeight)
    local sacleH = videoHight / math.min(screenWidth, screenHeight)
    local width = 0
    local height = 0
    local x = 0
    local y = 0
    local scaleWidth = dataTable.width
    if (scaleWidth ~= nil) then
        width = math.min(screenWidth, screenHeight) * 0.36
    end
    local ratio = dataTable.ratio
    if (ratio ~= nil) then
        height = videoHight * 0.187
    end
    local scaleX = dataTable.positionX
    if (scaleX ~= nil) then
        x = math.min(screenWidth, screenHeight) * 0.56
    end
    local scaleY = dataTable.positionY
    if (scaleY ~= nil) then
        y = videoHight * 0.731
    end
    baike.portraitX = x
    baike.portraitY = y
    baike.portraitWidth = width
    baike.portraitHeight = height
    return baike.portraitX, baike.portraitY, baike.portraitWidth, baike.portraitHeight
end

local function setLuaViewSize(luaView, isPortrait)
    --设置当前容器大小
    if (luaView == nil) then
        return
    end
    local screenWidth, screenHeight = Native:getVideoSize(2)
    if (isPortrait) then
        local videoWidth, videoHight, y = Native:getVideoSize(0)
        if System.android() then
            y = 0.0
        end
        luaView:frame(0, y, math.min(screenWidth, screenHeight), videoHight)
    else
        luaView:frame(0, 0, math.max(screenWidth, screenHeight), math.min(screenWidth, screenHeight))
    end
end

--全局父控件
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

local function setRootViewSize(rootView, isPortrait)
    local screenWidth, screenHeight = Native:getVideoSize(2)
    local videoWidth, videoHeight = Native:getVideoSize(0)
    if (isPortrait) then
        baike.rootViewWidth = math.min(screenWidth, screenHeight) * 0.36;
        baike.rootViewHeight = videoHeight * 0.2;
        --rootView:alignBottomLeft()
        --rootView:margin(0, 0, math.min(screenWidth, screenHeight) * 0.08, videoHeight * 0.08)
        --rootView:margin(math.min(screenWidth, screenHeight) * 0.104, 0, 0, videoHeight * 0.24)
        rootView:frame(math.min(screenWidth, screenHeight) * 0.104, videoHeight - (videoHeight * 0.2) - 40 * scale, 40 * scale + baike.labelWidth + 10 * scale, 40 * scale)
    else
        baike.rootViewWidth = math.max(screenWidth, screenHeight) * 0.202;
        baike.rootViewHeight = math.min(screenWidth, screenHeight) * 0.105;
        rootView:frame(math.max(screenWidth, screenHeight) * 0.104, math.min(screenWidth, screenHeight) - (math.min(screenWidth, screenHeight) * 0.2) - 40 * scale, 40 * scale + baike.labelWidth + 10 * scale, 40 * scale)
    end

end

local function createRootView(isPortrait)
    local rootView = View()
    setRootViewSize(rootView, isPortrait)
    return rootView
end

local function setAdsButtonSize(adsLabel, isPortrait)
    local x, y, w, h = baike.rootView:frame();
    if (isPortrait) then
        adsLabel:frame(x, y + h + 2 * scale, 29 * scale, 15 * scale)
    else
        adsLabel:frame(x, y + h + 2 * scale, 29 * scale, 15 * scale)
    end
end

local function createCloudAdsButton(isPortrait)
    --创建底部'广告'标识
    local adsLabel = Label()
    adsLabel:size(29 * scale, 15 * scale)
    adsLabel:textSize(10)
    adsLabel:textAlign(TextAlign.CENTER)
    adsLabel:textColor(0xFFFFFF)
    adsLabel:backgroundColor(0x000000, 0.3)
    adsLabel:text("广告")
    setAdsButtonSize(adsLabel, isPortrait)
    adsLabel:hide()
    return adsLabel
end

local function isShowAds(data)
    if (data == nil) then
        return false
    end
    local dataTable = data.data.hotEditInfor
    if (dataTable == nil) then
        return false
    end
    return dataTable.isShowAds
end

local function isShowClose(data)
    if (data == nil) then
        return false
    end
    local dataTable = data.data.hotEditInfor
    if (dataTable == nil) then
        return false
    end
    return dataTable.isShowClose
end

local function setCloseViewSize(closeView, isPortrait)
    closeView:xy(baike.rootView:right() - 23 * scale, baike.rootView:top() - 15 * scale)
end

local function createCloseButton(isPortrait)
    local closeView = View()
    closeView:size(19 * scale, 19 * scale)
    closeView:cornerRadius(19 * scale / 2)
    closeView:backgroundColor(0x000000, 0.3)
    local closeImage = Image(Native)
    closeImage:size(7 * scale, 7 * scale)
    closeImage:align(Align.CENTER)
    closeImage:image(Data(OS_ICON_WEDGE_CLOSE))
    closeView:addView(closeImage)
    closeView:hide()

    setCloseViewSize(closeView, isPortrait)

    return closeView
end

local function createLogoImg(data)
    local logo = Image(Native)
    logo:image(data.data.hotEditInfor.hotImage)
    logo:frame(0, 0, 40 * scale, 40 * scale)
    logo:cornerRadius((40 * scale) / 2)
    logo:scaleType(ScaleType.CENTER_CORP)
    logo:align(Align.V_CENTER)
    return logo
end

local function setTitleBgSize(titleBg, title)
    -- baike.rootViewWidth 在setRootViewSize中会更新
    local w = baike.rootViewWidth * 0.844
    local h = baike.rootViewHeight * 0.727

    title:frame(40 * scale, 0, baike.labelWidth, h)
    titleBg:frame(0, 0, baike.labelWidth + 45 * scale, h)
    title:textAlign(TextAlign.CENTER)


end
local function createBaikeTitle(data)
    local titleBg = GradientView()
    titleBg:backgroundColor(0x000000, 0.5)

    local title = Label()
    title:textColor(0xFFFFFF)
    title:textSize(16)
    title:text(data.data.hotEditInfor.hotTitle)
    local corner = scale * 18

    titleBg:frame(20 * scale, 5 * scale, 20 * scale + baike.labelWidth + 10 * scale, 30 * scale)
    corner = scale * 15

    setTitleBgSize(titleBg, title)

    titleBg:corner(corner, corner, corner, corner, corner, corner, corner, corner)
    titleBg:align(Align.V_CENTER)
    titleBg:addView(title)
    return titleBg, title
end

--屏幕旋转--
local function rotationScreen(isPortrait)
    setLuaViewSize(baike.luaView, isPortrait)
    setRootViewSize(baike.rootView, isPortrait)
    setTitleBgSize(baike.titleBg, baike.title)
    setCloseViewSize(baike.closeView, isPortrait)

    setAdsButtonSize(baike.adsBtn, isPortrait)

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
            baike.luaView:hide()
        end,
        onMediaPlay = function()
            baike.luaView:show()
        end
    }
    media:mediaCallback(callbackTable)
    return media
end

local function onCreate(data)

    local exposureTrackUrl = getHotspotExposureTrackLink(data, 1)
    if (exposureTrackUrl ~= nil) then
        Native:get(exposureTrackUrl)
    end

    configSize(data)

    if (baike.launchPlanId ~= nil) then
        osTrack(baike.launchPlanId, 1, 2)
        osTrack(baike.launchPlanId, 2, 2)
    end

    local isPortrait = Native:isPortraitScreen()

    baike.labelWidth = Native:stringDrawLength(data.data.hotEditInfor.hotTitle, 16)

    baike.luaView = createLuaView(isPortrait)
    --baike.luaView:backgroundColor(0xFC0D27, 0.5)
    baike.rootView = createRootView(isPortrait)
    baike.logo = createLogoImg(data)

    baike.titleBg, baike.title = createBaikeTitle(data, isPortrait)
    baike.adsBtn = createCloudAdsButton(isPortrait)
    baike.closeView = createCloseButton(isPortrait)

    baike.rootView:addView(baike.titleBg)
    baike.rootView:addView(baike.logo)

    baike.luaView:addView(baike.adsBtn)
    baike.luaView:addView(baike.rootView)
    baike.luaView:addView(baike.closeView)

    if (isShowAds(data)) then
        baike.adsBtn:show()
    end
    if (isShowClose(data)) then
        baike.closeView:show()
    end

    baike.closeView:onClick(function()
        closeView()
    end)

    if System.ios() then
        local x, y, w, h = baike.titleBg:frame()
        baike.titleBg:frame(x, y, 0, h)
        Animate(0.3,
                function()
                    baike.titleBg:frame(x, y, w, h)
                end,
                function()
                end);
    else
        if (isPortrait) then
            baike.titleBg:translation(-5 * scale, 0)
            startViewTranslationAnim(baike.titleBg, 0, 0)
        else
            baike.titleBg:translation(-5 * scale, 0)
            startViewTranslationAnim(baike.titleBg, 0, 0)
        end

    end

    baike.rootView:onClick(function()

        local clickTrackLink = getHotspotClickTrackLink(data, 1)
        if (clickTrackLink ~= nil) then
            Native:get(clickTrackLink)
        end

        Native:widgetEvent(eventTypeClick, baike.id, adTypeName, actionTypeNone, "")
        if (baike.launchPlanId ~= nil) then
            osTrack(baike.launchPlanId, 3, 2)
        end
        closeView()
        Native:sendAction(Native:base64Encode("LuaView://defaultLuaView?template=" .. "os_baike_window.lua" .. "&id=" .. "os_baike_window" .. tostring(baike.id) .. "&priority=" .. tostring(osInfoViewPriority)), data)
    end)

    baike.media = registerMedia()

end

function show(args)
    if (args == nil or args.data == nil or baike.luaView ~= nil) then
        return
    end
    baike.data = args.data
    baike.launchPlanId = baike.data.launchPlanId
    baike.id = baike.data.id
    onCreate(args.data)
    checkMqttHotspotToSetClose(args.data, function()
        closeView()
    end)
end