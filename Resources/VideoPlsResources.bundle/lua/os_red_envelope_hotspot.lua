--
-- Created by IntelliJ IDEA.
-- User: videojj_pls
-- Date: 2018/12/24
-- Time: 1:58 PM
-- To change this template use File | Settings | File Templates.
--

require "os_config"
require "os_string"
require "os_constant"
require "os_util"
require "os_track"
redEnvelope = object:new()
local adTypeName = "redEnvelope"
local scale = getScale()
local OS_ICON_WEDGE_CLOSE = "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"
local OS_ICON_CARD_IMAGE_BG = "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"

redEnvelope.requestIds = {}
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
    for key, value in pairs(redEnvelope.requestIds) do
        if (value ~= nil) then
            Native:abort(value)
        end
    end
    if Native:getCacheData(redEnvelope.id) == tostring(eventTypeShow) then
        Native:widgetEvent(eventTypeClose, redEnvelope.id, adTypeName, actionTypeNone, "")
        Native:deleteBatchCacheData({ redEnvelope.id })
    end
    Native:destroyView()
end

local function getPortraitLocation(data)
    if (data == nil) then
        return 0, 0, 0, 0
    end
    local dataTable = data.data
    if (dataTable == nil) then
        return 0, 0, 0, 0
    end

    if (redEnvelope.portraitWidth ~= nil and redEnvelope.portraitHeight ~= nil and redEnvelope.portraitX ~= nil and redEnvelope.portraitY ~= nil) then
        return redEnvelope.portraitX, redEnvelope.portraitY, redEnvelope.portraitWidth, redEnvelope.portraitHeight
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
    local scaleX = dataTable.positionX
    if (scaleX ~= nil) then
        x = math.max(screenWidth, screenHeight) * scaleX * sacleW
    end
    local scaleY = dataTable.positionY
    if (scaleY ~= nil) then
        y = math.min(screenWidth, screenHeight) * scaleY * sacleH
    end
    redEnvelope.portraitX = x
    redEnvelope.portraitY = y
    redEnvelope.portraitWidth = width
    redEnvelope.portraitHeight = height
    return redEnvelope.portraitX, redEnvelope.portraitY, redEnvelope.portraitWidth, redEnvelope.portraitHeight
end

--获取横屏位置  ratio=1.253  dataTable.width=0.248  positionX=0.037  positionY=0.531
local function getLandscapeLocation(data)
    if (data == nil) then
        return 0, 0, 0, 0
    end
    local dataTable = data.data
    if (dataTable == nil) then
        return 0, 0, 0, 0
    end
    if (redEnvelope.landscapeWidth ~= nil and redEnvelope.landscapeHeight ~= nil and redEnvelope.landscapeX ~= nil and redEnvelope.landscapeY ~= nil) then
        return redEnvelope.landscapeX, redEnvelope.landscapeY, redEnvelope.landscapeWidth, redEnvelope.landscapeHeight
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
    local scaleX = dataTable.positionX
    if (scaleX ~= nil) then
        x = math.max(screenWidth, screenHeight) * scaleX
    end
    local scaleY = dataTable.positionY
    if (scaleY ~= nil) then
        y = math.min(screenWidth, screenHeight) * scaleY
    end
    redEnvelope.landscapeX = x
    redEnvelope.landscapeY = y
    redEnvelope.landscapeWidth = width
    redEnvelope.landscapeHeight = height
    return redEnvelope.landscapeX, redEnvelope.landscapeY, redEnvelope.landscapeWidth, redEnvelope.landscapeHeight
end

local function getCardLocation(data, isPortrait) --设置当前容器大小
    if (isPortrait) then
        return getPortraitLocation(data)
    else
        return getLandscapeLocation(data)
    end
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

local function setCardViewSize(data, redEnvelopeView, isPortrait) --设置卡牌显示容器大小
    if (redEnvelope == nil or data == nil) then
        return
    end
    local x, y, w, h = getCardLocation(data, isPortrait)
    redEnvelopeView:frame(x, y, w, h)
end

local function setCardImageLayoutSize(data, redEnvelopeImageLayout, redEnvelopeImage, isPortrait)
    if (data == nil or redEnvelopeImageLayout == nil or redEnvelopeImage == nil) then
        return
    end
    local x, y, w, h = 0, 0, 0, 0
    if (isPortrait) then
        w = redEnvelope.portraitWidth * 0.515
        h = redEnvelope.portraitHeight * 0.867
    else
        w = redEnvelope.landscapeWidth * 0.515
        h = redEnvelope.landscapeHeight * 0.867
    end
    redEnvelopeImageLayout:frame(x, y, w, h)
    redEnvelopeImage:frame(x, y, w, h)
    redEnvelopeImage:cornerRadius(3 * scale)
end

local function setCardAdsLayoutSize(data, redEnvelopeAdsLabel, isPortrait)
    if (data == nil or redEnvelopeAdsLabel == nil) then
        return
    end
    local w, h = 0, 0, 0, 0
    if (isPortrait) then
        w = redEnvelope.portraitWidth * 0.176
        h = redEnvelope.portraitHeight * 0.114
        redEnvelopeAdsLabel:textSize(6)
    else
        w = redEnvelope.landscapeWidth * 0.176
        h = redEnvelope.landscapeHeight * 0.114
        redEnvelopeAdsLabel:textSize(10)
    end
    redEnvelopeAdsLabel:size(w, h)
    redEnvelopeAdsLabel:alignBottom()
end

local function setCardCloseLayoutSize(data, redEnvelopeCloseView, redEnvelopeCloseImage, isPortrait)
    if (data == nil or redEnvelopeCloseView == nil or redEnvelopeCloseImage == nil) then
        return
    end
    local w, h = 0, 0
    if (isPortrait) then
        h = redEnvelope.portraitHeight * 0.144
        w = h
    else
        h = redEnvelope.landscapeHeight * 0.144
        w = h
    end
    redEnvelopeCloseImage:size(w * 0.368, w * 0.368)
    redEnvelopeCloseImage:align(Align.CENTER)
    redEnvelopeCloseView:size(w, h)
    redEnvelopeCloseView:cornerRadius(w / 2)

    if (System.android()) then
        redEnvelopeCloseView:alignTopRight()
    else
        redEnvelopeCloseView:alignTop()
        redEnvelopeCloseView:alignRight()
    end
end

local function setCardFlexLayoutSize(data, redEnvelopeFlexView, redEnvelopeFlexLabel, isPortrait)
    if (data == nil or redEnvelopeFlexView == nil or redEnvelopeFlexLabel == nil) then
        return
    end
    local x, y, w, h = 0, 0, 0, 0
    if (isPortrait) then
        x = redEnvelope.portraitWidth * 0.239
        y = redEnvelope.portraitHeight * 0.364
        w = redEnvelope.portraitWidth * 0.762
        h = redEnvelope.portraitHeight * 0.387
        redEnvelopeFlexLabel:textSize(8)
    else
        x = redEnvelope.landscapeWidth * 0.239
        y = redEnvelope.landscapeHeight * 0.364
        w = redEnvelope.landscapeWidth * 0.762
        h = redEnvelope.landscapeHeight * 0.387
        redEnvelopeFlexLabel:textSize(11)
    end
    redEnvelopeFlexLabel:frame(w * 0.4, 0, w, h)
    local corner = h / 2
    redEnvelopeFlexView:frame(x, y, w, h)
    redEnvelopeFlexView:corner(0, 0, corner, corner, corner, corner, 0, 0)
end

--屏幕旋转--
local function rotationScreen(isPortrait)
    setLuaViewSize(redEnvelope.luaview, isPortrait)
    setCardViewSize(redEnvelope.data, redEnvelope.redEnvelopeView, isPortrait)
    setCardImageLayoutSize(redEnvelope.data, redEnvelope.redEnvelopeImageLayout, redEnvelope.redEnvelopeImageView, isPortrait)
    setCardAdsLayoutSize(redEnvelope.data, redEnvelope.redEnvelopeAdsLabel, isPortrait)
    setCardCloseLayoutSize(redEnvelope.data, redEnvelope.redEnvelopeCloseLayout, redEnvelope.redEnvelopeCloseImage, isPortrait)
    setCardFlexLayoutSize(redEnvelope.data, redEnvelope.redEnvelopeFlexView, redEnvelope.redEnvelopeFlexLabel, isPortrait)
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
            redEnvelope.luaview:hide()
        end,
        onMediaPlay = function()
            redEnvelope.luaview:show()
        end
    }
    media:mediaCallback(callbackTable)
    return media
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

--显示卡牌大小控件
local function createCardView(data, isPortrait)
    local redEnvelopeView = View()
    setCardViewSize(data, redEnvelopeView, isPortrait)
    return redEnvelopeView
end

--创建卡牌显示图片
local function createCardImageView(data, isPortrait)
    local redEnvelopeImageLayout = View()
    local redEnvelopeImageView = Image(Native)
    redEnvelopeImageView:scaleType(ScaleType.CENTER_CROP)
    setCardImageLayoutSize(data, redEnvelopeImageLayout, redEnvelopeImageView, isPortrait)
    return redEnvelopeImageLayout, redEnvelopeImageView
end

local function createCardAdsView(data, isPortrait)
    local redEnvelopeAdsLabel = Label()
    local adsTag = "广告"
    redEnvelopeAdsLabel:textColor(0x9B9B9B)
    redEnvelopeAdsLabel:text(adsTag)
    redEnvelopeAdsLabel:textAlign(TextAlign.CENTER)
    redEnvelopeAdsLabel:backgroundColor(0x000000, 0.3)
    redEnvelopeAdsLabel:cornerRadius(2)
    redEnvelopeAdsLabel:alignBottom()
    setCardAdsLayoutSize(data, redEnvelopeAdsLabel, isPortrait)
    return redEnvelopeAdsLabel
end

local function createCardCloseView(data, isPortrait)
    local redEnvelopeCloseView = View()
    redEnvelopeCloseView:backgroundColor(0x000000, 0.3)

    local redEnvelopeCloseImage = Image(Native)
    redEnvelopeCloseImage:image(Data(OS_ICON_WEDGE_CLOSE))

    setCardCloseLayoutSize(data, redEnvelopeCloseView, redEnvelopeCloseImage, isPortrait)
    return redEnvelopeCloseView, redEnvelopeCloseImage
end

local function createCardFlexView(data, isPortrait)
    local redEnvelopeFlexView = GradientView()
    redEnvelopeFlexView:backgroundColor(0x000000, 0.5)
    local redEnvelopeFlexLabel = Label(Native)
    redEnvelopeFlexLabel:lines(2)
    --    local adsTag = "口令红包\n邀您来抢"
    redEnvelopeFlexLabel:textAlign(TextAlign.LEFT)
    redEnvelopeFlexLabel:textColor(0xFFFFFF)
    redEnvelopeFlexLabel:text(adsTag)

    setCardFlexLayoutSize(data, redEnvelopeFlexView, redEnvelopeFlexLabel, isPortrait)
    return redEnvelopeFlexView, redEnvelopeFlexLabel
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
        redEnvelope.isShowClose = isShowClose
    else
        redEnvelope.isShowClose = false
    end
    local isShowAds = dataTable.isShowAds
    if (isShowAds ~= nil) then
        redEnvelope.isShowAds = isShowAds
    else
        redEnvelope.isShowAds = false
    end
    dataTable.ratio = 1.253
    dataTable.width = 0.248
    dataTable.positionX = 0.037
    dataTable.positionY = 0.531
end

local function registerWindow()
    local nativeWindow = nil
    if System.ios() then
        nativeWindow = NativeWindow()
    else
        nativeWindow = nativeWindow
    end
    local callbackTable = {
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

local function fillData(data)
    if (data == nil) then
        return
    end
    local dataTable = data.data
    if (dataTable == nil) then
        return
    end
    --开关控制关闭按钮
    local isShowClose = dataTable.isShowClose
    if (isShowClose ~= true) then
        redEnvelope.redEnvelopeCloseLayout:hide()
    end
    local isShowAds = dataTable.isShowAds
    if (isShowAds ~= true) then
        redEnvelope.redEnvelopeAdsLabel:hide()
    end
    local imageUrl = dataTable.imageUrl
    if (imageUrl ~= nil) then
        redEnvelope.redEnvelopeImageView:image(imageUrl)
    end
    local title = dataTable.title
    if (title ~= nil) then
        local _, charCount = string.gsub(title, "[^\128-\193]", "")
        local newTitle = title
        if charCount > 5 then
            local count = 0
            newTitle = ""
            for uchar, value in string.gmatch(title, "([%z\1-\127\194-\244][\128-\191]*)") do
                count = count + 1
                newTitle = newTitle .. tostring(uchar)
                if count == 5 then
                    newTitle = newTitle .. "\n"
                end
            end
        end
        redEnvelope.redEnvelopeFlexLabel:text(newTitle)
    end
end

local function onCreate(data)
    local showLinkUrl = getHotspotExposureTrackLink(redEnvelope.data, 1)
    if (showLinkUrl ~= nil) then
        Native:get(showLinkUrl)
    end
    if (redEnvelope.launchPlanId ~= nil) then
        osTrack(redEnvelope.launchPlanId, 1, 2)
        osTrack(redEnvelope.launchPlanId, 2, 2)
    end

    configSize(data)
    local isPortrait = Native:isPortraitScreen()
    redEnvelope.luaview = createLuaView(isPortrait)
    redEnvelope.redEnvelopeView = createCardView(data, isPortrait)
    redEnvelope.redEnvelopeImageLayout, redEnvelope.redEnvelopeImageView = createCardImageView(data, isPortrait)
    redEnvelope.redEnvelopeAdsLabel = createCardAdsView(data, isPortrait)
    redEnvelope.redEnvelopeCloseLayout, redEnvelope.redEnvelopeCloseImage = createCardCloseView(data, isPortrait)
    redEnvelope.redEnvelopeFlexView, redEnvelope.redEnvelopeFlexLabel = createCardFlexView(data, isPortrait)

    redEnvelope.redEnvelopeImageLayout:addView(redEnvelope.redEnvelopeImageView)
    redEnvelope.redEnvelopeCloseLayout:addView(redEnvelope.redEnvelopeCloseImage)
    redEnvelope.redEnvelopeFlexView:addView(redEnvelope.redEnvelopeFlexLabel)

    redEnvelope.redEnvelopeView:addView(redEnvelope.redEnvelopeFlexView)
    redEnvelope.redEnvelopeView:addView(redEnvelope.redEnvelopeImageLayout)
    redEnvelope.redEnvelopeView:addView(redEnvelope.redEnvelopeAdsLabel)
    redEnvelope.redEnvelopeView:addView(redEnvelope.redEnvelopeCloseLayout)

    redEnvelope.luaview:addView(redEnvelope.redEnvelopeView)
    if (redEnvelope.isShowAds == false) then
        redEnvelope.redEnvelopeAdsLabel:hide()
    end
    if (isPortrait) then
        redEnvelope.redEnvelopeFlexView:translation(-0.485 * redEnvelope.portraitWidth, 0)
        startViewTranslationAnim(redEnvelope.redEnvelopeFlexView, 0, 0)
    else
        redEnvelope.redEnvelopeFlexView:translation(-0.485 * redEnvelope.landscapeWidth, 0)
        startViewTranslationAnim(redEnvelope.redEnvelopeFlexView, 0, 0)
    end
    redEnvelope.media = registerMedia()
    redEnvelope.window = registerWindow()

    redEnvelope.redEnvelopeCloseLayout:onClick(function()
        closeView()
    end)

    redEnvelope.redEnvelopeImageLayout:onClick(function()
        Native:widgetEvent(eventTypeClick, redEnvelope.id, adTypeName, actionTypeNone, "")
        closeView()
        local clickLinkUrl = getHotspotClickTrackLink(redEnvelope.data, 1)
        if (clickLinkUrl ~= nil) then
            Native:get(clickLinkUrl)
        end
        if (redEnvelope.launchPlanId ~= nil) then
            osTrack(redEnvelope.launchPlanId, 3, 2)
        end
        Native:sendAction(Native:base64Encode("LuaView://defaultLuaView?template=" .. "os_red_envelope_window.lua" .. "&id=" .. "os_red_envelope_window" .. tostring(redEnvelope.id) .. tostring(redEnvelope.hotspotOrder) .. "&priority=" .. tostring(osInfoViewPriority)), data)
    end)
    redEnvelope.redEnvelopeFlexView:onClick(function()
        Native:widgetEvent(eventTypeClick, redEnvelope.id, adTypeName, actionTypeNone, "")
        closeView()
        local clickLinkUrl = getHotspotClickTrackLink(redEnvelope.data, 1)
        if (clickLinkUrl ~= nil) then
            Native:get(clickLinkUrl)
        end
        if (redEnvelope.launchPlanId ~= nil) then
            osTrack(redEnvelope.launchPlanId, 3, 2)
        end
        Native:sendAction(Native:base64Encode("LuaView://defaultLuaView?template=" .. "os_red_envelope_window.lua" .. "&id=" .. "os_red_envelope_window" .. tostring(redEnvelope.id) .. tostring(redEnvelope.hotspotOrder) .. "&priority=" .. tostring(osInfoViewPriority)), data)
    end)
    fillData(data)
    Native:widgetEvent(eventTypeShow, redEnvelope.id, adTypeName, actionTypeNone, "")
    Native:saveCacheData(redEnvelope.id, tostring(eventTypeShow))
    checkMqttHotspotToSetClose(data, function()
        closeView()
    end)
end

function getRedEnvelopeInfo(callback)

    local businessInfo = {
        userId = Native:getIdentity(),
        creativeId = redEnvelope.data.creativeId
    }

    local paramData = {
        businessParam = businessInfo,
        commonParam = Native:commonParam()
    }

    local paramDataString = Native:tableToJson(paramData)
    -- print("[LuaView] "..paramDataString)
    -- print("[LuaView] "..OS_HTTP_GET_MOBILE_QUERY)
    print("[LuaView] " .. Native:aesEncrypt(paramDataString, OS_HTTP_PUBLIC_KEY, OS_HTTP_PUBLIC_KEY))
    local requestId = Native:post(OS_HTTP_GET_MOBILE_QUERY, {
        bu_id = buId,
        device_type = deviceType,
        data = Native:aesEncrypt(paramDataString, OS_HTTP_PUBLIC_KEY, OS_HTTP_PUBLIC_KEY)
    }, function(response, errorInfo)
        -- print("luaview getRedEnvelopeInfo")
        if (response == nil) then
            return
        end
        -- print("luaview getRedEnvelopeInfo "..Native:tableToJson(response))
        responseData = Native:aesDecrypt(response.encryptData, OS_HTTP_PUBLIC_KEY, OS_HTTP_PUBLIC_KEY)
        print("luaview " .. tostring(responseData))
        response = toTable(responseData)
        if (response.resCode ~= "00") then
            return
        end

        local dataTable = response.businessInfo
        --没有领过红包，显示红包
        if (dataTable == nil) then
            if callback ~= nil then
                callback()
            end
            return
        end
    end)
    table.insert(redEnvelope.requestIds, requestId)
end

function show(args)
    if (args == nil or args.data == nil or redEnvelope.luaview ~= nil) then
        return
    end
    redEnvelope.data = args.data

    redEnvelope.id = redEnvelope.data.id
    redEnvelope.launchPlanId = redEnvelope.data.launchPlanId
    getRedEnvelopeInfo(function()
        onCreate(redEnvelope.data)
    end)
end

