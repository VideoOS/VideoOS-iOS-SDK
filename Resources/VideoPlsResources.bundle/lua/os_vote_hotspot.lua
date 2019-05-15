--
-- Created by IntelliJ IDEA.
-- User: videojj_pls
-- Date: 2018/10/29
-- Time: 11:07 AM
-- To change this template use File | Settings | File Templates.
--
require "os_config"
require "os_string"
require "os_constant"
require "os_util"
require "os_track"
vote = object:new()
local adTypeName = "vote"
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
    if Native:getCacheData(vote.id) == tostring(eventTypeShow) then
        Native:widgetEvent(eventTypeClose, vote.id, adTypeName, actionTypeNone, "")
        Native:deleteBatchCacheData({ vote.id })
    end
    Native:destroyView()
end

local function getVoteCountInfo()

    local businessInfoTable = {}
    for k, v in pairs(vote.data.data.voteList) do
        businessInfoTable[k] = {
            action = "count",
            condition = {
                {
                    key = "vote",
                    value = k,
                    operator = "equal"
                }
            }
        }
    end


    local businessParamTable = {
        creativeId = vote.data.creativeId,
        businessInfo = businessInfoTable
    }

    local paramData = {
        businessParam = businessParamTable,
        commonParam = Native:commonParam()
    }

    local paramDataString = Native:tableToJson(paramData)
    -- print("[LuaView] "..paramDataString)
    -- print("[LuaView] "..OS_HTTP_GET_COMMON_QUERY)
    -- print("[LuaView] "..Native:aesEncrypt(paramDataString, OS_HTTP_PUBLIC_KEY, OS_HTTP_PUBLIC_KEY))
    vote.request:post(OS_HTTP_GET_COMMON_QUERY, {
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
        local dataTable = response.commonResult
        if (dataTable == nil) then
            return
        end
        vote.data.data.voteCount = dataTable
    end, vote.luaview)
end

local function getUserVoteInfo()

    local businessInfo = {
        userId = Native:getIdentity(),
        creativeId = vote.data.creativeId
    }

    local paramData = {
        businessParam = businessInfo,
        commonParam = Native:commonParam()
    }

    local paramDataString = Native:tableToJson(paramData)
    -- print("[LuaView] "..paramDataString)
    -- print("[LuaView] "..OS_HTTP_GET_MOBILE_QUERY)
    -- print("[LuaView] "..Native:aesEncrypt(paramDataString, OS_HTTP_PUBLIC_KEY, OS_HTTP_PUBLIC_KEY))
    vote.request:post(OS_HTTP_GET_MOBILE_QUERY, {
        bu_id = buId,
        device_type = deviceType,
        data = Native:aesEncrypt(paramDataString, OS_HTTP_PUBLIC_KEY, OS_HTTP_PUBLIC_KEY)
    }, function(response, errorInfo)
        -- print("luaview getUserVoteInfo")
        if (response == nil) then
            return
        end
        -- print("luaview getUserVoteInfo 11"..Native:tableToJson(response))
        responseData = Native:aesDecrypt(response.encryptData, OS_HTTP_PUBLIC_KEY, OS_HTTP_PUBLIC_KEY)
        print("luaview " .. responseData)
        response = toTable(responseData)
        if (response.resCode ~= "00") then
            return
        end
        local dataTable = response.businessInfo
        if (dataTable == nil) then
            return
        end
        vote.data.data.userVote = dataTable
    end, vote.luaview)
end

--获取竖屏位置 ratio=3.762  dataTable.width=0.237  positionX=0.745  positionY=0.613
local function getPortraitLocation(data)
    if (data == nil) then
        return 0, 0, 0, 0
    end
    local dataTable = data.data
    if (dataTable == nil) then
        return 0, 0, 0, 0
    end
    if (vote.portraitWidth ~= nil and vote.portraitHeight ~= nil and vote.portraitX ~= nil and vote.portraitY ~= nil) then
        return vote.portraitX, vote.portraitY, vote.portraitWidth, vote.portraitHeight
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
    local scaleY = dataTable.portraitPositionY
    if (scaleY ~= nil) then
        y = math.min(screenWidth, screenHeight) * scaleY * sacleH
    end
    vote.portraitX = x
    vote.portraitY = y
    vote.portraitWidth = width
    vote.portraitHeight = height
    return vote.portraitX, vote.portraitY, vote.portraitWidth, vote.portraitHeight
end

--获取横屏位置  ratio=3.762  dataTable.width=0.237  positionX=0.745  positionY=0.613
local function getLandscapeLocation(data)
    if (data == nil) then
        return 0, 0, 0, 0
    end
    local dataTable = data.data
    if (dataTable == nil) then
        return 0, 0, 0, 0
    end
    if (vote.landscapeWidth ~= nil and vote.landscapeHeight ~= nil and vote.landscapeX ~= nil and vote.landscapeY ~= nil) then
        return vote.landscapeX, vote.landscapeY, vote.landscapeWidth, vote.landscapeHeight
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
    local scaleY = dataTable.landscapePositionY
    if (scaleY ~= nil) then
        y = math.min(screenWidth, screenHeight) * scaleY
    end
    vote.landscapeX = x
    vote.landscapeY = y
    vote.landscapeWidth = width
    vote.landscapeHeight = height
    return vote.landscapeX, vote.landscapeY, vote.landscapeWidth, vote.landscapeHeight
end

local function getVoteLocation(data, isPortrait) --设置当前容器大小
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
        local videoWidth, videoHight, y = Native:getVideoSize(0)
        if System.android() then
            y = 0.0
        end
        luaview:frame(0, y, math.min(screenWidth, screenHeight), videoHight)
    else
        luaview:frame(0, 0, math.max(screenWidth, screenHeight), math.min(screenWidth, screenHeight))
    end
end

local function setVoteViewSize(data, voteView, isPortrait) --设置卡牌显示容器大小
    if (voteView == nil or data == nil) then
        return
    end
    local x, y, w, h = getVoteLocation(data, isPortrait)
    voteView:frame(x, y, w, h)
end

local function setVoteCloseLayoutSize(data, voteCloseView, voteCloseImage, isPortrait)
    if (data == nil or voteCloseView == nil or voteCloseImage == nil) then
        return
    end
    local w, h = 0, 0
    if (isPortrait) then
        h = vote.portraitHeight * 0.324
        w = h
    else
        h = vote.landscapeHeight * 0.324
        w = h
    end
    voteCloseImage:size(w * 0.4, w * 0.4)
    voteCloseImage:align(Align.CENTER)
    voteCloseView:size(w, h)
    voteCloseView:cornerRadius(w / 2)
    if (System.android()) then
        voteCloseView:alignTopRight()
    else
        voteCloseView:alignTop()
        voteCloseView:alignRight()
    end
end

local function setVoteImageLayoutSize(data, voteImage, isPortrait)
    if (data == nil or voteImage == nil) then
        return
    end
    local x, y, w, h = 0, 0, 0, 0
    if (isPortrait) then
        h = vote.portraitHeight * 0.568
        w = vote.portraitWidth
        y = vote.portraitHeight * 0.432
    else
        h = vote.landscapeHeight * 0.568
        w = vote.landscapeWidth
        y = vote.landscapeHeight * 0.432
    end
    voteImage:frame(x, y, w, h)
end

--屏幕旋转--
local function rotationScreen(isPortrait)
    setLuaViewSize(vote.luaview, isPortrait)
    setVoteViewSize(vote.data, vote.voteView, isPortrait)
    setVoteCloseLayoutSize(vote.data, vote.voteCloseView, vote.voteCloseImage, isPortrait)
    setVoteImageLayoutSize(vote.data, vote.voteImage, isPortrait)
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
            vote.luaview:hide()
        end,
        onMediaPlay = function()
            vote.luaview:show()
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

--投票大小控件
local function createVoteView(data, isPortrait)
    local voteView = View()
    setVoteViewSize(data, voteView, isPortrait)
    return voteView
end

local function createVoteCloseView(data, isPortrait)
    local voteCloseView = View()
    voteCloseView:backgroundColor(0x000000, 0.5)

    local voteCloseImage = Image(Native)
    voteCloseImage:image(Data(OS_ICON_WEDGE_CLOSE))
    voteCloseImage:scaleType(ScaleType.CENTER_CROP)
    if (vote.isShowClose == false) then
        voteCloseView:hide()
    end
    setVoteCloseLayoutSize(data, voteCloseView, voteCloseImage, isPortrait)
    return voteCloseView, voteCloseImage
end

local function createVoteImageView(data, isPortrait)

    local voteImage = Image(Native)
    voteImage:scaleType(ScaleType.CENTER_CROP)
    setVoteImageLayoutSize(data, voteImage, isPortrait)
    return voteImage
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
        vote.isShowClose = isShowClose
    else
        vote.isShowClose = false
    end
    dataTable.ratio = 2.135
    dataTable.width = 0.237
    dataTable.positionX = 0.037
    if (System.android()) then
        dataTable.portraitPositionY = 0.65
    else
        dataTable.portraitPositionY = 0.65
    end
    dataTable.landscapePositionY = 0.65
end

local function onCreate(args)
    local showLinkUrl = getHotspotExposureTrackLink(args, 1)
    if (showLinkUrl ~= nil) then
        Native:get(showLinkUrl)
    end
    if (vote.launchPlanId ~= nil) then
        osTrack(vote.launchPlanId, 1, 2)
        osTrack(vote.launchPlanId, 2, 2)
    end
    vote.data = args
    configSize(args)
    local isPortrait = Native:isPortraitScreen()
    vote.luaview = createLuaView(isPortrait)
    vote.voteView = createVoteView(args, isPortrait)
    vote.voteCloseView, vote.voteCloseImage = createVoteCloseView(args, isPortrait)
    vote.voteImage = createVoteImageView(args, isPortrait)

    vote.voteCloseView:addView(vote.voteCloseImage)

    vote.luaview:addView(vote.voteView)
    vote.voteView:addView(vote.voteCloseView)
    vote.voteView:addView(vote.voteImage)
    -- vote.voteImage:anchorPoint(1, 1)
    vote.voteImage:scale(0)
    Animation():scale(1):duration(0.2):with(vote.voteImage):start()
    vote.voteCloseView:onClick(function()
        closeView()
    end)
    vote.voteImage:onClick(function()
        Native:widgetEvent(eventTypeClick, vote.id, adTypeName, actionTypeNone, "")
        closeView()
        local clickLinkUrl = getHotspotClickTrackLink(args, 1)
        if (clickLinkUrl ~= nil) then
            Native:get(clickLinkUrl)
        end
        if (vote.launchPlanId ~= nil) then
            osTrack(vote.launchPlanId, 3, 2)
        end
        Native:sendAction(Native:base64Encode("LuaView://defaultLuaView?template=" .. "os_vote_window.lua" .. "&id=" .. "os_vote_window" .. tostring(vote.id) .. "&priority=2"), args)
    end)
    local dataTable = args.data
    if (dataTable == nil) then
        return
    end
    --    vote.voteCloseView:hide()
    local imageUrl = dataTable.imageUrl
    if (imageUrl ~= nil) then
        vote.voteImage:image(imageUrl, function(status)
            --            if status == true then
            --                if (vote.isShowClose == true) then
            --                    vote.voteCloseView:show()
            --                end
            --            end
        end)
    end
    vote.media = registerMedia()
    vote.window = registerWindow()
    Native:widgetEvent(eventTypeShow, vote.id, adTypeName, actionTypeNone, "") --todo 修改参数为table
    Native:saveCacheData(vote.id.id, tostring(eventTypeShow))
    checkMqttHotspotToSetClose(vote.data, function()
        closeView()
    end)
end

function show(args)
    if (args == nil or args.data == nil or vote.luaview ~= nil) then
        return
    end
    vote.id = args.data.id
    vote.launchPlanId = args.data.launchPlanId
    vote.request = HttpRequest()
    onCreate(args.data)
    getVoteCountInfo()
    getUserVoteInfo()
end

